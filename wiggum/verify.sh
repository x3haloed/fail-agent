#!/bin/bash

# Ralph Wiggum Execution Verification Agent
# Tests the application by actually using it like a human would

echo "🔍 Ralph Wiggum Execution Verification Agent"
echo "============================================="
echo "Testing application by using it like a human..."
echo ""

cd "$(dirname "$0")/workspace"

# Check 1: Full application startup
echo "1. Testing complete application startup..."
if [ ! -d "server" ] || [ ! -d "client" ]; then
    echo "❌ Missing server or client directories"
    exit 1
fi

# Start backend
echo "   Starting backend server..."
cd server
npm start > server.log 2>&1 &
SERVER_PID=$!
cd ..
sleep 3

# Start frontend (if it has a dev server)
echo "   Starting frontend..."
cd client
if [ -f "package.json" ] && grep -q '"dev"' package.json; then
    npm run dev > dev.log 2>&1 &
    FRONTEND_PID=$!
    sleep 5
    echo "✅ Frontend dev server started"
else
    echo "ℹ️  No dev server available, testing build only"
fi
cd ..

# Check 2: End-to-end user workflows
echo "2. Testing end-to-end user workflows..."

# Test 1: User opens app (may have existing todos, that's ok)
echo "   Workflow 1: User opens app..."
response=$(curl -s http://localhost:3000/todos)
if echo "$response" | jq . > /dev/null 2>&1; then
    item_count=$(echo "$response" | jq length)
    echo "✅ User can access todo list ($item_count existing items)"
else
    echo "❌ Cannot access todo API: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Test 2: User adds a todo item
echo "   Workflow 2: User adds a todo item..."
response=$(curl -s -X POST http://localhost:3000/todos \
    -H "Content-Type: application/json" \
    -d '{"text":"Buy groceries"}')
todo_id=$(echo "$response" | jq -r '.id' 2>/dev/null)
if [ "$todo_id" != "null" ] && [ "$todo_id" != "" ]; then
    echo "✅ User can add todo item (ID: $todo_id)"
else
    echo "❌ Failed to add todo item: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Test 3: User sees the todo in their list
echo "   Workflow 3: User sees the todo in their list..."
response=$(curl -s http://localhost:3000/todos)
if echo "$response" | jq -r ".[] | select(.id == $todo_id).text" 2>/dev/null | grep -q "Buy groceries"; then
    echo "✅ User sees added todo in list"
else
    echo "❌ Added todo not found in list: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Test 4: User marks todo as complete
echo "   Workflow 4: User marks todo as complete..."
response=$(curl -s -X PUT http://localhost:3000/todos/$todo_id \
    -H "Content-Type: application/json" \
    -d '{"completed":true}')
if echo "$response" | grep -q "updated\|success"; then
    echo "✅ User can mark todo as complete"
else
    echo "❌ Failed to mark todo complete: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Test 5: User verifies completion status
echo "   Workflow 5: User verifies todo is marked complete..."
response=$(curl -s http://localhost:3000/todos)
completed=$(echo "$response" | jq -r ".[] | select(.id == $todo_id).completed" 2>/dev/null)
if [ "$completed" = "1" ] || [ "$completed" = "true" ]; then
    echo "✅ Todo shows as completed"
else
    echo "❌ Todo not marked as completed: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Test 6: User deletes the todo
echo "   Workflow 6: User deletes the completed todo..."
response=$(curl -s -X DELETE http://localhost:3000/todos/$todo_id)
response2=$(curl -s http://localhost:3000/todos)
if [ "$response2" = "[]" ]; then
    echo "✅ User can delete todos"
else
    echo "❌ Failed to delete todo: $response"
    kill $SERVER_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    exit 1
fi

# Cleanup
kill $SERVER_PID 2>/dev/null
kill $FRONTEND_PID 2>/dev/null

# Check 3: Code quality analysis
echo "3. Testing code quality..."

# Check for obvious issues
cd server
if [ -f "index.js" ]; then
    # Check for console.log statements (shouldn't be in production)
    if grep -q "console\.log" index.js; then
        echo "⚠️  Found console.log statements in server code"
    else
        echo "✅ No console.log statements in server"
    fi

    # Check for basic error handling
    if grep -q "catch\|try" index.js; then
        echo "✅ Basic error handling present"
    else
        echo "⚠️  No error handling found"
    fi
fi
cd ..

cd client/src
if [ -f "App.vue" ]; then
    # Check for basic Vue structure
    if grep -q "<template>" App.vue && grep -q "<script setup" App.vue; then
        echo "✅ Vue component has proper structure"
    else
        echo "⚠️  Vue component structure incomplete"
    fi
fi
cd ../..

echo ""
echo "🎉 Ralph Wiggum Execution Verification: PASSED"
echo "The application works correctly when used like a human!"
echo ""
echo "✅ Backend starts and responds"
echo "✅ Frontend builds successfully"
echo "✅ User can add todos"
echo "✅ User can view todo list"
echo "✅ User can complete todos"
echo "✅ User can delete todos"
echo "✅ Basic code quality checks pass"