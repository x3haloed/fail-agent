#!/bin/bash

# Ralph Wiggum Autonomous Development System - Trunk Loop
# This is the infinite loop that drives the entire system

set -e  # Exit on any error

echo "Starting Ralph Wiggum Autonomous Development System..."
echo "Press Ctrl+C to force stop (will be graceful if supervisor approves)"

# Change to the supervisor directory
cd "$(dirname "$0")/supervisor"

# The infinite loop - this is the heart of the system
while true; do
    echo "=== Ralph Loop Iteration $(date '+%Y-%m-%d %H:%M:%S') ==="

    # Run one tick of the supervisor
    if ! ./target/debug/supervisor tick; then
        echo "Supervisor returned error. Checking if this is an approved exit..."
        exit_code=$?

        if [ $exit_code -eq 42 ]; then
            echo "Supervisor approved exit. System complete."
            exit 0
        else
            echo "Supervisor error (code: $exit_code). Continuing loop..."
            sleep 1  # Brief pause before retry
        fi
    fi

    # Optional: Add a small delay to prevent thrashing
    sleep 0.1
done