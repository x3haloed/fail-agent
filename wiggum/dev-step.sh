#!/bin/bash

# Ralph Wiggum Development Step
# Use OpenCode for focused development tasks

echo "🚀 Ralph Wiggum Development Step"
echo "==============================="

cd "$(dirname "$0")/.."

# Check current state
echo "Current project state:"
echo "- Intent: $(cat wiggum/state/intent.json 2>/dev/null | jq -r '.description' 2>/dev/null || echo 'None')"
echo "- Tasks: $(cat wiggum/state/tasks.json 2>/dev/null | jq '.tasks | length' 2>/dev/null || echo '0')"

echo ""
echo "Call OpenCode with a specific development task:"
echo "Example:"
echo "opencode run --model opencode/grok-code 'Improve the todo app by adding [specific feature]'"
echo ""
echo "After making changes, run:"
echo "./wiggum/verify.sh"
echo ""
echo "Ready for your development command..."