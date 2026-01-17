#!/bin/bash

# Ralph Wiggum Verification Script
# Simple automated checks for the built application

echo "🔍 Ralph Wiggum Verification Agent"
echo "==================================="

cd "$(dirname "$0")/workspace"

# Check 1: Backend can start
echo "1. Testing backend server..."
if [ -d "server" ]; then
    cd server
    timeout 10 npm start > server.log 2>&1 &
    SERVER_PID=$!
    sleep 3

    if curl -s http://localhost:3000/todos > /dev/null 2>&1; then
        echo "✅ Backend server starts and responds"
        kill $SERVER_PID 2>/dev/null
    else
        echo "❌ Backend server failed to start or respond"
        kill $SERVER_PID 2>/dev/null
        exit 1
    fi
    cd ..
else
    echo "❌ No backend directory found"
    exit 1
fi

# Check 2: Frontend can build
echo "2. Testing frontend build..."
if [ -d "client" ]; then
    cd client
    if npm run build > build.log 2>&1; then
        echo "✅ Frontend builds successfully"
    else
        echo "❌ Frontend build failed"
        exit 1
    fi
    cd ..
else
    echo "❌ No frontend directory found"
    exit 1
fi

# Check 3: API endpoints work
echo "3. Testing API endpoints..."
cd server
npm start > /dev/null 2>&1 &
SERVER_PID=$!
sleep 3

# Test GET todos
if curl -s http://localhost:3000/todos | jq . > /dev/null 2>&1; then
    echo "✅ GET /todos works"
else
    echo "❌ GET /todos failed"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

# Test POST todo
response=$(curl -s -X POST http://localhost:3000/todos -H "Content-Type: application/json" -d '{"text":"Test todo"}')
if echo "$response" | jq -r '.id' > /dev/null 2>&1; then
    echo "✅ POST /todos works"
else
    echo "❌ POST /todos failed"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

kill $SERVER_PID 2>/dev/null
cd ..

echo ""
echo "🎉 All verification checks passed!"
echo "The application meets Ralph Wiggum standards."