#!/bin/bash

# This script will run a simple application that prints the current time.
# It will intentionally exit after a few seconds to simulate an application crash.
# Supervisor should automatically restart it.

while true; do
    echo "Current time: $(date)"
    sleep 500000000000  # Simulate the application running for a while
    echo "Exiting..."
    exit 1  # Simulate a crash by exiting with a non-zero status code
done