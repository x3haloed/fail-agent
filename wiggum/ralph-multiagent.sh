#!/bin/bash

# Ralph Wiggum Multi-Agent Orchestration
# Trunk agent (grok-code) coordinates subagents (LM Studio)

set -e

echo "🤖 Ralph Wiggum Multi-Agent System"
echo "=================================="

cd "$(dirname "$0")/.."

# Check that both models are available
echo "Checking model availability..."
opencode models opencode | grep grok-code > /dev/null && echo "✅ Grok-code available" || echo "❌ Grok-code not available"
opencode models lmstudio | grep huihui > /dev/null && echo "✅ LM Studio model available" || echo "❌ LM Studio model not available"

echo ""
echo "Starting Ralph Wiggum development cycle..."
echo ""

# Trunk agent creates initial implementation
echo "🎯 Phase 1: Trunk Agent - Initial Implementation"
echo "Using LM Studio for development (grok-code had different behavior)..."

opencode run --model lmstudio/huihui-qwen3-vl-8b-instruct-abliterated-mlx "
You are the Ralph Wiggum Trunk Agent. Your job is to create an initial implementation of a todo application.

Current project state:
- Backend should be Node.js + Express + SQLite
- Frontend should be Vue 3 + TypeScript
- Full CRUD operations for todos
- Files should be created in wiggum/workspace/

Create the basic structure and implementation. Focus on getting a working foundation.
"

echo ""
echo "🔍 Phase 2: Execution Verification Agent - Testing"
echo "Using LM Studio for detailed verification..."

opencode run --model lmstudio/huihui-qwen3-vl-8b-instruct-abliterated-mlx "
You are the Execution Verification Agent - the truth anchor.

Verify that the todo application implementation actually works:
1. Check if backend server can start (cd wiggum/workspace/server && npm start)
2. Test the API endpoints (GET/POST/PUT/DELETE /todos)
3. Check if frontend can build (cd wiggum/workspace/client && npm run build)

Report your findings clearly. Does it work or not?
"

echo ""
echo "🧹 Phase 3: Code Quality Agent - Review"
echo "Using LM Studio for code quality analysis..."

opencode run --model lmstudio/huihui-qwen3-vl-8b-instruct-abliterated-mlx "
You are the Code Quality Agent.

Review the todo application code for quality issues:
- Check for DRY violations
- Look for poor naming conventions
- Identify potential refactoring opportunities
- Assess code organization

Files to review:
- wiggum/workspace/server/*.js
- wiggum/workspace/client/src/**/*.{vue,ts,js}

Provide specific recommendations but don't modify code.
"

echo ""
echo "🏗️ Phase 4: Architecture Agent - Structural Review"
echo "Using LM Studio for architectural assessment..."

opencode run --model lmstudio/huihui-qwen3-vl-8b-instruct-abliterated-mlx "
You are the Architecture Agent.

Evaluate the todo application architecture:
- Assess separation of concerns (frontend vs backend)
- Check API design and data flow
- Evaluate scalability considerations
- Identify potential design improvements

Consider how this structure would work for a larger application.
"

echo ""
echo "✅ Ralph Wiggum Cycle Complete"
echo ""
echo "Summary of multi-agent collaboration:"
echo "- Trunk Agent (grok-code): High-level planning and implementation"
echo "- Verification Agent (LM Studio): Truth validation"
echo "- Quality Agent (LM Studio): Code hygiene"
echo "- Architecture Agent (LM Studio): System design"
echo ""
echo "The system now has working multi-agent orchestration!"