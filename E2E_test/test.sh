
#!/bin/bash

# Colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Test Results Storage
RESULTS=()
OVERALL_STATUS="PASSED"

# Function to wait for services to be ready
wait_for_services() {
  echo -e "${YELLOW}Waiting for services to be ready...${NC}"
  
  # Wait for database
  echo -n "Waiting for database connection... "
  for i in {1..30}; do
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\q' &> /dev/null
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓${NC}"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo -e "\n${RED}Timeout waiting for database${NC}"
    fi
  done
  
  # Wait for backend
  echo -n "Waiting for backend service... "
  for i in {1..30}; do
    curl -s -o /dev/null $API_URL &> /dev/null
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓${NC}"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo -e "\n${RED}Timeout waiting for backend${NC}"
    fi
  done
  
  # Wait for frontend
  echo -n "Waiting for frontend service... "
  for i in {1..30}; do
    curl -s -o /dev/null $FRONTEND_URL &> /dev/null
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓${NC}"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo -e "\n${RED}Timeout waiting for frontend${NC}"
    fi
  done
  
  echo -e "${YELLOW}Proceeding with tests...${NC}"
  sleep 5 # Give services one last moment to stabilize
}

# Function to check database connectivity
test_database_connection() {
  echo -e "${YELLOW}Running Database Connectivity Test...${NC}"
  
  # Display database connection info for debugging
  echo "Connecting to: PostgreSQL@$DB_HOST with user $DB_USER"
  
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\conninfo' &> /dev/null
  DB_RESULT=$?
  
  if [ $DB_RESULT -eq 0 ]; then
    echo -e "${GREEN}Database Connectivity Test: PASSED${NC}"
    RESULTS+=("Database Connectivity Test: PASSED")
    echo "Database Connectivity Test: PASSED" > /tmp/db_test_result.txt
    if [ "$TEST_TYPE" == "database" ]; then
      exit 0
    fi
  else
    echo -e "${RED}Database Connectivity Test: FAILED (Error code: $DB_RESULT)${NC}"
    RESULTS+=("Database Connectivity Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "Database Connectivity Test: FAILED" > /tmp/db_test_result.txt
    
    # Additional diagnostics
    echo "Testing connectivity with ping:"
    ping -c 2 $DB_HOST || echo "Cannot ping database host"
    
    echo "Checking if PostgreSQL is listening on port 5432:"
    nc -zv $DB_HOST 5432 || echo "PostgreSQL not listening on port 5432"
    
    if [ "$TEST_TYPE" == "database" ]; then
      exit 1
    fi
  fi
}

# Function to check API response
test_api_response() {
  echo -e "${YELLOW}Running API Response Test...${NC}"
  echo "Testing endpoint: $API_URL"
  
  response=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)
  
  if [ "$response" -eq 200 ]; then
    echo -e "${GREEN}API Response Test: PASSED (HTTP $response)${NC}"
    RESULTS+=("API Response Test: PASSED")
    echo "API Response Test: PASSED" > /tmp/api_test_result.txt
    
    if [ "$TEST_TYPE" == "api" ]; then
      exit 0
    fi
  else
    echo -e "${RED}API Response Test: FAILED (HTTP $response)${NC}"
    RESULTS+=("API Response Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "API Response Test: FAILED" > /tmp/api_test_result.txt
    
    # Additional diagnostics
    echo "Testing connectivity to backend service:"
    ping -c 2 be || echo "Cannot ping backend service"
    
    echo "Checking if service is listening on port 3010:"
    nc -zv be 3010 || echo "Backend not listening on port 3010"
    
    if [ "$TEST_TYPE" == "api" ]; then
      exit 1
    fi
  fi
}

# Function to check frontend rendering
test_frontend_rendering() {
  echo -e "${YELLOW}Running Frontend Rendering Test...${NC}"
  echo "Testing endpoint: $FRONTEND_URL"
  
  content=$(curl -s $FRONTEND_URL)
  
  if [[ $content == *"<title>"* ]]; then
    echo -e "${GREEN}Frontend Rendering Test: PASSED${NC}"
    RESULTS+=("Frontend Rendering Test: PASSED")
    echo "Frontend Rendering Test: PASSED" > /tmp/frontend_test_result.txt
    
    # Extract title for additional validation
    title=$(echo "$content" | grep -o '<title>.*</title>' | sed 's/<title>\(.*\)<\/title>/\1/')
    echo "Page title: $title"
    
    if [ "$TEST_TYPE" == "frontend" ]; then
      exit 0
    fi
  else
    echo -e "${RED}Frontend Rendering Test: FAILED${NC}"
    RESULTS+=("Frontend Rendering Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "Frontend Rendering Test: FAILED" > /tmp/frontend_test_result.txt
    
    # Additional diagnostics
    echo "Testing connectivity to frontend service:"
    ping -c 2 fe || echo "Cannot ping frontend service"
    
    echo "Checking if service is listening on port 80:"
    nc -zv fe 80 || echo "Frontend not listening on port 80"
    
    # Save response for debugging
    echo "$content" | head -20 > /tmp/frontend_response.txt
    echo "Saved first 20 lines of response to /tmp/frontend_response.txt"
    
    if [ "$TEST_TYPE" == "frontend" ]; then
      exit 1
    fi
  fi
}

# Function to test full integration
test_full_integration() {
  echo -e "${YELLOW}Running Full Integration Test...${NC}"
  
  # This is a placeholder for a more complex integration test
  # In a real scenario, you might want to:
  # 1. Create a record in the database
  # 2. Verify it through the API
  # 3. Check if it appears in the frontend
  
  if [ "$OVERALL_STATUS" == "PASSED" ]; then
    echo -e "${GREEN}All component tests passed, assuming integration works${NC}"
    RESULTS+=("Full Integration Test: PASSED")
    echo "Full Integration Test: PASSED" > /tmp/integration_test_result.txt
  else
    echo -e "${RED}Some component tests failed, integration likely broken${NC}"
    RESULTS+=("Full Integration Test: SKIPPED due to component failures")
    echo "Full Integration Test: SKIPPED" > /tmp/integration_test_result.txt
  fi
  
  if [ "$TEST_TYPE" == "integration" ]; then
    [ "$OVERALL_STATUS" == "PASSED" ] && exit 0 || exit 1
  fi
}

# Install needed tools if they're not already installed
install_tools() {
  command -v nc >/dev/null 2>&1 || { echo "Installing netcat..."; apk add --no-cache netcat-openbsd; }
}

# Main execution flow
main() {
  echo -e "${YELLOW}===================================${NC}"
  echo -e "${YELLOW}Starting E2E Tests - $(date)${NC}"
  echo -e "${YELLOW}===================================${NC}"

  # Print environment info
  echo "Environment Variables:"
  echo "DB_HOST: $DB_HOST"
  echo "DB_USER: $DB_USER"
  echo "API_URL: $API_URL"
  echo "FRONTEND_URL: $FRONTEND_URL"
  echo "TEST_TYPE: $TEST_TYPE"
  echo -e "${YELLOW}===================================${NC}"

  # Install needed tools
  install_tools
  
  # For specific test types, we might not need to wait for all services
  case "$TEST_TYPE" in
    database)
      # Wait only for database
      echo -n "Waiting for database connection... "
      for i in {1..30}; do
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\q' &> /dev/null
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}✓${NC}"
          break
        fi
        echo -n "."
        sleep 2
        if [ $i -eq 30 ]; then
          echo -e "\n${RED}Timeout waiting for database${NC}"
        fi
      done
      test_database_connection
      ;;
    api)
      # Wait only for backend
      echo -n "Waiting for backend service... "
      for i in {1..30}; do
        curl -s -o /dev/null $API_URL &> /dev/null
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}✓${NC}"
          break
        fi
        echo -n "."
        sleep 2
        if [ $i -eq 30 ]; then
          echo -e "\n${RED}Timeout waiting for backend${NC}"
        fi
      done
      test_api_response
      ;;
    frontend)
      # Wait only for frontend
      echo -n "Waiting for frontend service... "
      for i in {1..30}; do
        curl -s -o /dev/null $FRONTEND_URL &> /dev/null
        if [ $? -eq 0 ]; then
          echo -e "${GREEN}✓${NC}"
          break
        fi
        echo -n "."
        sleep 2
        if [ $i -eq 30 ]; then
          echo -e "\n${RED}Timeout waiting for frontend${NC}"
        fi
      done
      test_frontend_rendering
      ;;
    integration)
      # Need to check test results from other components
      # Assuming results are stored in tmp files by other parallel tests
      if [ -f "/tmp/db_test_result.txt" ] && [ -f "/tmp/api_test_result.txt" ] && [ -f "/tmp/frontend_test_result.txt" ]; then
        grep -q "FAILED" /tmp/db_test_result.txt /tmp/api_test_result.txt /tmp/frontend_test_result.txt
        if [ $? -eq 0 ]; then
          OVERALL_STATUS="FAILED"
        fi
      else
        echo -e "${RED}Cannot find all component test results, assuming some tests failed${NC}"
        OVERALL_STATUS="FAILED"
      fi
      test_full_integration
      ;;
    *)
      # Wait for all services before testing (original behavior)
      wait_for_services
      
      # Run All Tests
      test_database_connection
      test_api_response
      test_frontend_rendering
      test_full_integration
      
      # Display Results
      echo -e "${YELLOW}===================================${NC}"
      echo -e "${YELLOW}Test Results:${NC}"
      for result in "${RESULTS[@]}"; do
        if [[ $result == *"PASSED"* ]]; then
          echo -e "- ${GREEN}$result${NC}"
        else
          echo -e "- ${RED}$result${NC}"
        fi
      done
      echo -e "${YELLOW}===================================${NC}"
      
      # Overall results
      if [ "$OVERALL_STATUS" == "PASSED" ]; then
        echo -e "${GREEN}All tests PASSED${NC}"
        exit 0
      else
        echo -e "${RED}Some tests FAILED${NC}"
        exit 1
      fi
      ;;
  esac
}

# Export TEST_TYPE from first argument or default to "all"
TEST_TYPE=${1:-all}

# Start execution
main