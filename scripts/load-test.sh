#!/bin/bash

# Load test script for the trading simulator using k6

# Variables
TRADING_APP_URL="http://localhost:8000"  # TODO: update with actual URL
USERS=100  # Number of concurrent users
DURATION="1m"  # Duration of the test

echo "Starting load test with $USERS users for $DURATION..."

# Run k6 load test
k6 run --vus $USERS --duration $DURATION - <(cat <<EOF
import http from 'k6/http';
import { check, sleep } from 'k6';

export default function () {
  // Simulate a trade request
  const tradePayload = JSON.stringify({
    action: "buy",
    symbol: "AAPL",
    quantity: 10,
    price: 150.0
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post(\`${TRADING_APP_URL}/trades\`, tradePayload, params);

  // Check if the request was successful
  check(res, {
    'Trade request succeeded': (r) => r.status === 200,
  });

  // Simulate some think time
  sleep(1);
}
EOF
)

echo "Load test completed."