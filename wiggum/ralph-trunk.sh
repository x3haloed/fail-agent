#!/bin/bash

# Ralph Wiggum Trunk Agent - The Infinite Loop
# This is the "bash loop" that Geoffrey Huntley described
# It never exits until the application is 100% perfect

set -e

echo "🎯 Ralph Wiggum Trunk Agent Activated"
echo "====================================="
echo "The infinite loop that never exits until perfection..."
echo ""

cd "$(dirname "$0")/.."

# Read user intent
if [ -f "wiggum/state/intent.json" ]; then
    INTENT=$(cat wiggum/state/intent.json | jq -r '.description')
    echo "User Intent: $INTENT"
else
    echo "❌ No user intent found. Run initialization first."
    exit 1
fi

echo ""
echo "Starting Ralph Wiggum development loop..."
echo "This loop will continue until the application is 100% perfect."
echo ""

iteration=0
max_iterations=50  # Safety limit to prevent infinite loops

while [ $iteration -lt $max_iterations ]; do
    echo "🔄 Ralph Loop Iteration $iteration"
    echo "=================================="

    # Phase 1: Trunk Agent - Plan and Create/Improve Application
    echo "🎯 Phase 1: Trunk Agent - Development"
    echo "Calling trunk agent to plan and implement improvements..."

    opencode run --model opencode/grok-code "
    You are the Ralph Wiggum Trunk Agent - the primary orchestrator.

    ITERATION: $iteration
    USER INTENT: $INTENT

    Your mission: Build a complete, working application that perfectly matches the user's intent.

    Ralph Wiggum Rules:
    1. You are the boss - coordinate all subagents
    2. NEVER consider anything 'done' unless it actually works 100%
    3. If subagents find issues, you MUST fix them
    4. Keep iterating until perfection

    Current status:
    $([ -d "wiggum/workspace" ] && echo "- Application exists" || echo "- No application yet")

    Instructions:
    - Analyze what needs to be built/improved
    - Plan the implementation steps
    - Generate/modify the application code
    - Be prepared for subagent feedback
    - If this is iteration 0, start from scratch

    Remember: This is an infinite loop. You don't get to quit until it's perfect.
    "

    # Phase 2: Execution Verification Agent
    echo "🔍 Phase 2: Execution Verification Agent"
    echo "Testing if the application actually works like a human would use it..."

    VERIFICATION_RESULT=$(opencode run --model opencode/grok-code "
    You are the Execution Verification Agent - the truth anchor.

    Your job: Verify that the application works exactly as intended by actually using it like a human.

    USER INTENT: $INTENT

    Verification Requirements:
    1. Can you start all necessary servers?
    2. Can you perform the core user workflows?
    3. Does the application behave as specified?
    4. Are there any functional bugs or missing features?

    Testing Instructions:
    - Actually run the application servers
    - Simulate real user interactions (API calls, UI interactions)
    - Check that ALL requirements from user intent are met
    - Report any discrepancies clearly

    Response Format:
    If everything works perfectly: SUCCESS
    If issues found: FAILURE: [detailed description of problems]

    Be ruthless - if it doesn't work like a human expects, it's not good enough.
    " 2>/dev/null)

    echo "Verification Result: $VERIFICATION_RESULT"

    if echo "$VERIFICATION_RESULT" | grep -q "SUCCESS"; then
        echo "✅ Execution verification passed!"
        VERIFICATION_PASSED=true
    else
        echo "❌ Execution verification failed"
        VERIFICATION_PASSED=false
    fi

    # Phase 3: Code Slop Agent (if execution passed)
    if [ "$VERIFICATION_PASSED" = true ]; then
        echo "🧹 Phase 3: Code Slop Agent"
        echo "Checking for code quality issues..."

        SLOP_RESULT=$(opencode run --model opencode/grok-code "
        You are the Code Slop Agent - entropy controller.

        Your job: Detect and prevent code quality degradation.

        Analyze the codebase for:
        1. DRY (Don't Repeat Yourself) violations
        2. Spaghetti code patterns
        3. Poor naming conventions
        4. Dead code
        5. Overly complex functions
        6. Missing error handling
        7. Inconsistent code style

        Focus areas:
        - wiggum/workspace/ (the application code)

        Response Format:
        If code is clean: CLEAN
        If issues found: SLOP: [detailed list of problems to fix]

        Be thorough - clean code is maintainable code.
        " 2>/dev/null)

        echo "Code Quality Result: $SLOP_RESULT"

        if echo "$SLOP_RESULT" | grep -q "CLEAN"; then
            echo "✅ Code quality check passed!"
            SLOP_CLEAN=true
        else
            echo "❌ Code quality issues found"
            SLOP_CLEAN=false
        fi
    else
        SLOP_CLEAN=false
    fi

    # Phase 4: Architecture Agent (if code is clean)
    if [ "$SLOP_CLEAN" = true ]; then
        echo "🏗️ Phase 4: Architecture Agent"
        echo "Evaluating system design and scalability..."

        ARCH_RESULT=$(opencode run --model opencode/grok-code "
        You are the Architecture Agent - system designer.

        Your job: Ensure the application has elegant, scalable architecture.

        Evaluate:
        1. Proper separation of concerns (frontend/backend/data)
        2. API design quality
        3. Database schema appropriateness
        4. Component organization
        5. Error handling patterns
        6. Performance considerations
        7. Future extensibility

        Focus: How would this scale to 10k lines? Is it maintainable?

        Response Format:
        If architecture is sound: SOLID
        If issues found: ARCH: [architectural improvements needed]

        Think big - this should be production-ready architecture.
        " 2>/dev/null)

        echo "Architecture Result: $ARCH_RESULT"

        if echo "$ARCH_RESULT" | grep -q "SOLID"; then
            echo "✅ Architecture check passed!"
            ARCH_SOLID=true
        else
            echo "❌ Architecture issues found"
            ARCH_SOLID=false
        fi
    else
        ARCH_SOLID=false
    fi

    # Phase 5: UI Design Snob Agent (if architecture is solid)
    if [ "$ARCH_SOLID" = true ]; then
        echo "🎨 Phase 5: UI Design Snob Agent"
        echo "Ensuring pixel-perfect, professional UI..."

        UI_RESULT=$(opencode run --model opencode/grok-code "
        You are the UI Design Snob Agent - pixel-perfect enforcer.

        Your job: Ensure the user interface is professionally polished.

        Evaluate:
        1. Visual consistency and branding
        2. Responsive design across screen sizes
        3. Accessibility compliance
        4. User experience flow
        5. Loading states and error handling
        6. Mobile-first design principles

        Be picky - if it's 'off by two pixels', it's not good enough.

        Response Format:
        If UI is perfect: BEAUTIFUL
        If issues found: UGLY: [specific UI/UX problems]

        Remember: Users judge books by covers. Make it gorgeous.
        " 2>/dev/null)

        echo "UI Design Result: $UI_RESULT"

        if echo "$UI_RESULT" | grep -q "BEAUTIFUL"; then
            echo "✅ UI design check passed!"
            UI_PERFECT=true
        else
            echo "❌ UI design issues found"
            UI_PERFECT=false
        fi
    else
        UI_PERFECT=false
    fi

    # Ralph Wiggum Exit Condition Check
    echo ""
    echo "🎯 Ralph Wiggum Exit Check"
    echo "=========================="

    if [ "$VERIFICATION_PASSED" = true ] && [ "$SLOP_CLEAN" = true ] && [ "$ARCH_SOLID" = true ] && [ "$UI_PERFECT" = true ]; then
        echo "🎉 ALL VERIFICATION GATES PASSED!"
        echo "The application meets 100% of Ralph Wiggum standards."
        echo ""
        echo "✅ Execution: Works perfectly like a human would use it"
        echo "✅ Code Quality: No slop, DRY, maintainable"
        echo "✅ Architecture: Scalable, elegant design"
        echo "✅ UI Design: Pixel-perfect, professional"
        echo ""
        echo "Ralph Wiggum loop complete. Application is perfect. ✨"
        exit 0
    else
        echo "❌ Verification gates failed. Continuing Ralph loop..."
        echo ""
        echo "Failed gates:"
        [ "$VERIFICATION_PASSED" = false ] && echo "  - Execution verification"
        [ "$SLOP_CLEAN" = false ] && echo "  - Code quality"
        [ "$ARCH_SOLID" = false ] && echo "  - Architecture"
        [ "$UI_PERFECT" = false ] && echo "  - UI design"
        echo ""
        echo "Trunk agent will address these issues in the next iteration."
    fi

    iteration=$((iteration + 1))
    echo "Sleeping 3 seconds before next iteration..."
    sleep 3
done

echo "⚠️  Reached maximum iterations ($max_iterations)"
echo "The Ralph Wiggum loop could not achieve perfection."
echo "Manual intervention may be required."
exit 1