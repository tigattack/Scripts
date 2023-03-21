#!/bin/zsh

# Check that at least one argument was provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [list of endpoints to ping]"
  exit 1
fi

# Initialize variables
min_time=9999
min_endpoint=""

# Loop over all provided endpoints
for endpoint in "$@"; do
  # Ping the endpoint and extract the round-trip time from the output
  time=$(ping -c 1 -n "$endpoint" | ggrep -oP 'time=\K\d+(\.\d+)?')

  # Check if the endpoint responded within the timeout and if its response time is lower than the current minimum
  if [ -n "$time" ] && [ "$(bc <<< "$time < $min_time")" -eq 1 ]; then
    min_time="$time"
    min_endpoint="$endpoint"
  fi
done

# Print the endpoint with the lowest response time
if [ -n "$min_endpoint" ]; then
  echo "$min_endpoint"
else
  echo "No endpoints responded within the timeout."
  exit 1
fi
