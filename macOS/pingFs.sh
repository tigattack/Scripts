#!/bin/zsh

# Utility script to determine closest server by latency.
# Note: not very reusable; this was quickly put together for a single, specific use case.

endpoints=("$@")
max=5

for i in {1..2}; do
  t="$(ping -c 1 -i 0.5 ${endpoints[$i]} | sed -ne '/.*time=/{;s///;s/\..*//;p;}')"
  if [ "$t" -lt "$max" ]; then
    echo ${endpoints[$i]}
  fi
done

# ./pingFs.sh fs1 fs2
