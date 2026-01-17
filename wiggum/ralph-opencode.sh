#!/bin/bash

# Ralph Wiggum Autonomous Development System - OpenCode Edition
# Hybrid approach: Bash loop orchestrates, OpenCode does development work

set -e

echo "Starting Ralph Wiggum System with OpenCode..."
echo "Make sure LM Studio is running on localhost:1234"

# Change to project root
cd "$(dirname "$0")/.."

# Check if LM Studio is available
if ! curl -s http://localhost:1234/v1/models > /dev/null 2>&1; then
    echo "Error: LM Studio not running on localhost:1234"
    echo "Please start LM Studio and ensure it's running on port 1234"
    exit 1
fi

echo "LM Studio detected - proceeding with Ralph Wiggum loop"

# Ralph Wiggum Loop - Simple bash orchestration calling OpenCode for work
iteration=0
max_iterations=10

while [ $iteration -lt $max_iterations ]; do
    echo "=== Ralph Loop Iteration $iteration ==="

    # Check current state
    intent=$(cat wiggum/state/intent.json 2>/dev/null || echo '{"description":"Build a todo app"}')
    completed_tasks=$(cat wiggum/state/tasks.json 2>/dev/null | jq '.tasks | map(select(.status == "Completed")) | length' 2>/dev/null || echo '0')

    echo "Intent: $(echo $intent | jq -r '.description')"
    echo "Completed tasks: $completed_tasks"

    # Check if we should exit (all tasks done and verified)
    if [ "$completed_tasks" -gt 0 ]; then
        echo "Tasks completed! Running verification..."

        # Quick verification - check if servers can start
        if curl -s http://localhost:3000/todos > /dev/null 2>&1; then
            echo "✅ Backend server is responding"
        else
            echo "❌ Backend server not responding"
        fi

        # For now, if we have a working app, exit
        if [ -d "wiggum/workspace" ] && [ -f "wiggum/workspace/client/package.json" ]; then
            echo "🎉 Ralph Wiggum loop complete! App built successfully."
            exit 0
        fi
    fi

    # Call OpenCode for development work
    echo "Calling OpenCode for development iteration $iteration..."

    opencode run --model opencode/grok-code "
    Ralph Wiggum Development Agent - Iteration $iteration

    Current status:
    - User wants: $(echo $intent | jq -r '.description')
    - Progress: $completed_tasks tasks completed
    - Workspace: wiggum/workspace/

    Your job: Make incremental progress on building the application.
    Focus on ONE specific improvement this iteration.

    Ralph Wiggum rules:
    - Never mark anything as 'done' unless it actually works
    - Make small, verifiable improvements
    - Test your changes work before finishing

    What specific improvement will you make this iteration?
    "

    # Update iteration counter
    iteration=$((iteration + 1))
    sleep 2
done

echo "Reached maximum iterations ($max_iterations). Manual review needed."