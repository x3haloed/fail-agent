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
    echo "Building the actual application that meets user requirements..."

    # Create workspace directory if it doesn't exist
    mkdir -p wiggum/workspace

    # Use OpenCode to generate the actual application based on user intent
    if [ ! -d "workspace/client" ] || [ ! -d "workspace/server" ]; then
        echo "Generating application based on user intent: $INTENT"

        # Generate the full-stack application using OpenCode
        opencode run --model opencode/grok-code "
        You are a senior full-stack developer. The user wants: '$INTENT'

        Create a complete, production-ready full-stack web application that perfectly satisfies this requirement.

        Requirements:
        - Full-stack: Backend API + Frontend UI
        - Modern tech: Node.js/Express backend, Vue 3 frontend
        - Database: SQLite for simplicity
        - Responsive design
        - Error handling
        - Clean, maintainable code

        Generate the complete application structure with all necessary files:
        - server/package.json, server/index.js
        - client/package.json, client/vite.config.js, client/index.html
        - client/src/main.js, client/src/App.vue, client/src/assets/main.css
        - Any additional components needed

        The application should work immediately when 'npm install && npm start' is run in both directories.

        Focus on creating exactly what the user requested - nothing more, nothing less.
        "
    else
        echo "Application exists, analyzing for improvements..."
        # TODO: Implement improvement logic for existing applications
    fi

    # Phase 2: Execution Verification Agent
    echo "🔍 Phase 2: Execution Verification Agent"
    echo "Using intelligent agent to verify the application works like a human would use it..."

    # Use OpenCode agent to actually verify the application
    VERIFICATION_RESULT=$(opencode run --model opencode/grok-code "
    You are the Execution Verification Agent - you must verify that the application actually works as intended by a human user.

    USER INTENT: $INTENT

    Your task is to examine the generated application in 'workspace/' and determine if it meets the user's requirements.

    CRITICAL: You must actually understand what the user wanted and verify it works. Don't just check if servers start - verify the CORE FUNCTIONALITY.

    For '$INTENT', you need to verify:
    - The application does what was requested
    - All core features work as expected
    - The user experience makes sense
    - There are no obvious bugs or missing functionality

    Instructions:
    1. Examine the generated code in workspace/
    2. Understand what the application is supposed to do
    3. Verify that the implementation matches the intent
    4. Check for any obvious issues or missing features

    Response format:
    If the application works correctly: WORKS_PERFECTLY
    If there are issues: NEEDS_FIXES: [detailed description of problems]

    Be thorough - would a human user be satisfied with this application?
    " 2>/dev/null)

    if echo "$VERIFICATION_RESULT" | grep -q "WORKS_PERFECTLY"; then
        echo "✅ Execution verification passed - application works as intended!"
        VERIFICATION_PASSED=true
    else
        echo "❌ Execution verification failed"
        echo "Issues found: $VERIFICATION_RESULT"
        VERIFICATION_PASSED=false
    fi

    # Phase 3: Code Slop Agent (if execution passed)
    if [ "$VERIFICATION_PASSED" = true ]; then
        echo "🧹 Phase 3: Code Slop Agent"
        echo "Intelligent code quality analysis for DRY violations, spaghetti code, and maintainability..."

        # Use OpenCode agent for intelligent code quality analysis
        SLOP_RESULT=$(opencode run --model opencode/grok-code "
        You are the Code Slop Agent - expert code quality analyzer.

        Examine the codebase in 'workspace/' and identify code quality issues that would make it hard to maintain.

        Look for:
        - DRY (Don't Repeat Yourself) violations
        - Spaghetti code patterns
        - Poor naming conventions
        - Dead or unreachable code
        - Overly complex functions/methods
        - Missing error handling
        - Inconsistent code style
        - Hardcoded values that should be constants
        - Functions that do too many things

        Focus on the actual application code, not build files or dependencies.

        Response format:
        If code is clean and maintainable: CODE_IS_CLEAN
        If issues found: CODE_HAS_SLOP: [detailed list of specific problems to fix]

        Be a code quality snob - point out anything that would make another developer groan.
        " 2>/dev/null)

        if echo "$SLOP_RESULT" | grep -q "CODE_IS_CLEAN"; then
            echo "✅ Code quality check passed - clean, maintainable code!"
            SLOP_CLEAN=true
        else
            echo "❌ Code quality issues found"
            echo "Details: $SLOP_RESULT"
            SLOP_CLEAN=false
        fi
    else
        SLOP_CLEAN=false
    fi

    # Phase 4: Architecture Agent (if code is clean)
    if [ "$SLOP_CLEAN" = true ]; then
        echo "🏗️ Phase 4: Architecture Agent"
        echo "Evaluating system design, scalability, and architectural elegance..."

        # Use OpenCode agent for intelligent architecture analysis
        ARCH_RESULT=$(opencode run --model opencode/grok-code "
        You are the Architecture Agent - system design expert.

        Evaluate the application architecture in 'workspace/' for scalability, maintainability, and proper design patterns.

        Consider:
        - Separation of concerns (frontend/backend/data layers)
        - API design quality and RESTful patterns
        - Database schema design and relationships
        - Component organization and reusability
        - Error handling and resilience patterns
        - Performance considerations and scalability
        - Future extensibility and maintainability

        Think about how this would scale:
        - How would this handle 10x more users?
        - How maintainable would this be with 10x more features?
        - Does the architecture make sense for the problem domain?

        Response format:
        If architecture is solid and scalable: ARCHITECTURE_IS_SOLID
        If issues found: ARCHITECTURE_NEEDS_WORK: [specific architectural improvements needed]

        Be an architecture snob - ensure this could become a serious production system.
        " 2>/dev/null)

        if echo "$ARCH_RESULT" | grep -q "ARCHITECTURE_IS_SOLID"; then
            echo "✅ Architecture check passed - solid, scalable, production-ready design!"
            ARCH_SOLID=true
        else
            echo "❌ Architecture issues found"
            echo "Details: $ARCH_RESULT"
            ARCH_SOLID=false
        fi
    else
        ARCH_SOLID=false
    fi

    # Phase 5: UI Design Snob Agent (if architecture is solid)
    if [ "$ARCH_SOLID" = true ]; then
        echo "🎨 Phase 5: UI Design Snob Agent"
        echo "Evaluating pixel-perfect UI design, user experience, and visual polish..."

        # Use OpenCode agent for intelligent UI/UX analysis
        UI_RESULT=$(opencode run --model opencode/grok-code "
        You are the UI Design Snob Agent - pixel-perfect design critic.

        Evaluate the user interface and user experience in 'workspace/client/' for professional quality and user satisfaction.

        Examine:
        - Visual design consistency and aesthetics
        - Responsive design across different screen sizes
        - Accessibility compliance (WCAG guidelines)
        - User experience flow and intuitiveness
        - Loading states and error handling UX
        - Mobile-first design principles
        - Component reusability and consistency

        Be extremely picky about design quality:
        - Is every pixel exactly where it should be?
        - Does the interface feel polished and professional?
        - Would users love using this interface?
        - Are there any jarring visual inconsistencies?

        Response format:
        If UI is perfect and professional: UI_IS_PERFECT
        If issues found: UI_NEEDS_WORK: [specific design and UX problems to fix]

        Be a design snob - if it's 'off by two pixels', demand it be fixed.
        " 2>/dev/null)

        if echo "$UI_RESULT" | grep -q "UI_IS_PERFECT"; then
            echo "✅ UI design check passed - pixel-perfect, professional, and delightful!"
            UI_PERFECT=true
        else
            echo "❌ UI design issues found"
            echo "Details: $UI_RESULT"
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