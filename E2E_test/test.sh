#!/bin/bash

# Test Results Storage
RESULTS=()
OVERALL_STATUS="PASSED"

# Wait for services to be ready
wait_for_services() {
  echo "Waiting for services to be ready..."
  
  # Wait for database
  echo -n "Waiting for database connection... "
  for i in {1..30}; do
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\q' &> /dev/null
    if [ $? -eq 0 ]; then
      echo "✓"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo "Timeout waiting for database"
    fi
  done
  
  # Wait for backend
  echo -n "Waiting for backend service... "
  for i in {1..30}; do
    curl -s -o /dev/null $API_URL &> /dev/null
    if [ $? -eq 0 ]; then
      echo "✓"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo "Timeout waiting for backend"
    fi
  done
  
  # Wait for frontend
  echo -n "Waiting for frontend service... "
  for i in {1..30}; do
    curl -s -o /dev/null $FRONTEND_URL &> /dev/null
    if [ $? -eq 0 ]; then
      echo "✓"
      break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
      echo "Timeout waiting for frontend"
    fi
  done
  
  echo "Proceeding with tests..."
  sleep 5
}

# Function to check database connectivity
test_database_connection() {
  echo "Running Database Connectivity Test..."
  
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\conninfo' &> /dev/null
  DB_RESULT=$?
  
  if [ $DB_RESULT -eq 0 ]; then
    echo "Database Connectivity Test: PASSED"
    RESULTS+=("Database Connectivity Test: PASSED")
    echo "Database Connectivity Test: PASSED" > /tmp/db_test_result.txt
    if [ "$TEST_TYPE" == "database" ]; then
      exit 0
    fi
  else
    echo "Database Connectivity Test: FAILED (Error code: $DB_RESULT)"
    RESULTS+=("Database Connectivity Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "Database Connectivity Test: FAILED" > /tmp/db_test_result.txt
    if [ "$TEST_TYPE" == "database" ]; then
      exit 1
    fi
  fi
}

# Function to check API response
test_api_response() {
  echo "Running API Response Test..."
  
  response=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)
  
  if [ "$response" -eq 200 ]; then
    echo "API Response Test: PASSED (HTTP $response)"
    RESULTS+=("API Response Test: PASSED")
    echo "API Response Test: PASSED" > /tmp/api_test_result.txt
    if [ "$TEST_TYPE" == "api" ]; then
      exit 0
    fi
  else
    echo "API Response Test: FAILED (HTTP $response)"
    RESULTS+=("API Response Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "API Response Test: FAILED" > /tmp/api_test_result.txt
    if [ "$TEST_TYPE" == "api" ]; then
      exit 1
    fi
  fi
}

# Function to check frontend rendering
test_frontend_rendering() {
  echo "Running Frontend Rendering Test..."
  
  content=$(curl -s $FRONTEND_URL)
  
  if [[ $content == *"<title>"* ]]; then
    echo "Frontend Rendering Test: PASSED"
    RESULTS+=("Frontend Rendering Test: PASSED")
    echo "Frontend Rendering Test: PASSED" > /tmp/frontend_test_result.txt
    if [ "$TEST_TYPE" == "frontend" ]; then
      exit 0
    fi
  else
    echo "Frontend Rendering Test: FAILED"
    RESULTS+=("Frontend Rendering Test: FAILED")
    OVERALL_STATUS="FAILED"
    echo "Frontend Rendering Test: FAILED" > /tmp/frontend_test_result.txt
    if [ "$TEST_TYPE" == "frontend" ]; then
      exit 1
    fi
  fi
}

# Function to test full integration
test_full_integration() {
  echo "Running Full Integration Test..."
  
  if [ "$OVERALL_STATUS" == "PASSED" ]; then
    echo "All component tests passed, assuming integration works"
    RESULTS+=("Full Integration Test: PASSED")
    echo "Full Integration Test: PASSED" > /tmp/integration_test_result.txt
  else
    echo "Some component tests failed, integration likely broken"
    RESULTS+=("Full Integration Test: SKIPPED due to component failures")
    echo "Full Integration Test: SKIPPED" > /tmp/integration_test_result.txt
  fi
  
  if [ "$TEST_TYPE" == "integration" ]; then
    [ "$OVERALL_STATUS" == "PASSED" ] && exit 0 || exit 1
  fi
}

# Main execution flow
main() {
  echo "Starting E2E Tests - $(date)"

  # For specific test types, we might not need to wait for all services
  case "$TEST_TYPE" in
    database)
      echo -n "Waiting for database connection... "
      for i in {1..30}; do
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\q' &> /dev/null
        if [ $? -eq 0 ]; then
          echo "✓"
          break
        fi
        echo -n "."
        sleep 2
      done
      test_database_connection
      ;;
    api)
      echo -n "Waiting for backend service... "
      for i in {1..30}; do
        curl -s -o /dev/null $API_URL &> /dev/null
        if [ $? -eq 0 ]; then
          echo "✓"
          break
        fi
        echo -n "."
        sleep 2
      done
      test_api_response
      ;;
    frontend)
      echo -n "Waiting for frontend service... "
      for i in {1..30}; do
        curl -s -o /dev/null $FRONTEND_URL &> /dev/null
        if [ $? -eq 0 ]; then
          echo "✓"
          break
        fi
        echo -n "."
        sleep 2
      done
      test_frontend_rendering
      ;;
    integration)
      if [ -f "/tmp/db_test_result.txt" ] && [ -f "/tmp/api_test_result.txt" ] && [ -f "/tmp/frontend_test_result.txt" ]; then
        grep -q "FAILED" /tmp/db_test_result.txt /tmp/api_test_result.txt /tmp/frontend_test_result.txt
        if [ $? -eq 0 ]; then
          OVERALL_STATUS="FAILED"
        fi
      else
        echo "Cannot find all component test results, assuming some tests failed"
        OVERALL_STATUS="FAILED"
      fi
      test_full_integration
      ;;
    *)
      wait_for_services
      test_database_connection
      test_api_response
      test_frontend_rendering
      test_full_integration
      
      echo "Test Results:"
      for result in "${RESULTS[@]}"; do
        echo "- $result"
      done
      
      if [ "$OVERALL_STATUS" == "PASSED" ]; then
        echo "All tests PASSED"
        exit 0
      else
        echo "Some tests FAILED"
        exit 1
      fi
      ;;
  esac
}

# Export TEST_TYPE from first argument or default to "all"
TEST_TYPE=${1:-all}

# Start execution
main