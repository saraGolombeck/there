#!/bin/bash

# Test Results Storage
RESULTS=()

# Function to check database connectivity
test_database_connection() {
  echo "Running Database Connectivity Test..."
  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -c '\q' &> /dev/null
  if [ $? -eq 0 ]; then
    echo "Database Connectivity Test: PASSED"
    RESULTS+=("Database Connectivity Test: PASSED")
  else
    echo "Database Connectivity Test: FAILED"
    RESULTS+=("Database Connectivity Test: FAILED")
  fi
}

# Function to check API response
test_api_response() {
  echo "Running API Response Test..."
  response=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)
  if [ "$response" -eq 200 ]; then
    echo "API Response Test: PASSED"
    RESULTS+=("API Response Test: PASSED")
  else
    echo "API Response Test: FAILED (HTTP $response)"
    RESULTS+=("API Response Test: FAILED")
  fi
}

# Function to check frontend rendering
test_frontend_rendering() {
  echo "Running Frontend Rendering Test..."
  content=$(curl -s $FRONTEND_URL)
  if [[ $content == *"<title>"* ]]; then
    echo "Frontend Rendering Test: PASSED"
    RESULTS+=("Frontend Rendering Test: PASSED")
  else
    echo "Frontend Rendering Test: FAILED"
    RESULTS+=("Frontend Rendering Test: FAILED")
  fi
}

# Run Tests
test_database_connection
test_api_response
test_frontend_rendering

# Display Results
echo -e "\nTest Results:"
for result in "${RESULTS[@]}"; do
  echo "- $result"
done