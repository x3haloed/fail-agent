#!/bin/bash

# Ralph Wiggum Trunk Agent - The Infinite Loop
# This is the "bash loop" that Geoffrey Huntley described
# It never exits until the application is 100% perfect

set -e

# Setup logging
LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/ralph-wiggum-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Stream logging function for capturing OpenCode output in real-time
stream_log() {
    local prefix="$1"
    while IFS= read -r line; do
        log "STREAM" "[$prefix] $line"
    done
}

# Redirect all output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

log "INFO" "🎯 Ralph Wiggum Trunk Agent Activated"
log "INFO" "====================================="
log "INFO" "The infinite loop that never exits until perfection..."
log "INFO" "Log file: $LOG_FILE"
echo ""

cd "$(dirname "$0")/.."

# Read user intent
if [ -f "wiggum/state/intent.json" ]; then
    INTENT=$(cat wiggum/state/intent.json | jq -r '.description')
    log "INFO" "User Intent: $INTENT"
else
    log "ERROR" "No user intent found. Run initialization first."
    exit 1
fi

log "INFO" "Starting Ralph Wiggum development loop..."
log "INFO" "This loop will continue until the application is 100% perfect."
log "INFO" "Monitoring available at: tail -f $LOG_FILE"

iteration=0
max_iterations=50  # Safety limit to prevent infinite loops

while [ $iteration -lt $max_iterations ]; do
    log "INFO" "🔄 Ralph Loop Iteration $iteration"
    log "INFO" "=================================="

    # Phase 1: Trunk Agent - Plan and Create/Improve Application
    log "INFO" "🎯 Phase 1: Trunk Agent - Development"
    log "INFO" "Building the actual application that meets user requirements..."

    # Create workspace directory if it doesn't exist
    mkdir -p wiggum/workspace

    # Use OpenCode to generate the actual application based on user intent
    if [ ! -d "workspace/client" ] || [ ! -d "workspace/server" ]; then
        echo "Generating application based on user intent: $INTENT"

        # Create workspace subdirectories
        mkdir -p workspace/server workspace/client/src/components workspace/client/src/assets workspace/client/public

        # Generate the full-stack application using OpenCode in the workspace
        log "INFO" "Generating backend server with OpenCode..."
        cd workspace

        # Generate server files
        log "INFO" "Starting server generation with OpenCode..."
        opencode run --model opencode/grok-code "
        You are a senior full-stack developer. The user wants: '$INTENT'

        Create a Node.js/Express backend server that perfectly satisfies this requirement.

        Requirements:
        - Express.js server with REST API
        - SQLite database for data persistence
        - Proper error handling and middleware
        - Clean, maintainable code

        Generate these server files:
        - package.json with all necessary dependencies
        - index.js with the complete server implementation

        The server should work immediately when 'npm install && npm start' is run.
        Focus on creating exactly what the user requested for the backend.
        " 2>&1 | stream_log "SERVER_GEN"

        log "INFO" "Generating frontend client with OpenCode..."
        # Generate client files
        opencode run --model opencode/grok-code "
        You are a senior frontend developer. The user wants: '$INTENT'

        Create a Vue 3 frontend application that perfectly satisfies this requirement.

        Requirements:
        - Vue 3 with Composition API
        - Modern responsive design
        - Clean, maintainable code
        - Professional UI/UX

        Generate these client files:
        - package.json with all necessary dependencies
        - vite.config.js for development
        - index.html as entry point
        - src/main.js for Vue app initialization
        - src/App.vue as the main component
        - src/assets/main.css for styling

        The client should work immediately when 'npm install && npm run dev' is run.
        Focus on creating exactly what the user requested for the frontend.
        " 2>&1 | stream_log "CLIENT_GEN"

        cd ..
        log "SUCCESS" "✅ Application generated successfully"
    else
        log "INFO" "Application exists, analyzing for improvements..."
        log "INFO" "Checking previous verification results to determine what needs fixing..."

        # Read the previous iteration's results from the log to understand what failed
        PREVIOUS_ISSUES=""
        if [ -f "$LOG_FILE" ]; then
            # Extract the most recent verification failures
            EXEC_ISSUES=$(grep -A 10 "EXECUTION VERIFICATION AGENT RESPONSE" "$LOG_FILE" | tail -10)
            CODE_ISSUES=$(grep -A 10 "CODE SLOP AGENT RESPONSE" "$LOG_FILE" | tail -10)
            ARCH_ISSUES=$(grep -A 10 "ARCHITECTURE AGENT RESPONSE" "$LOG_FILE" | tail -10)
            UI_ISSUES=$(grep -A 10 "UI DESIGN SNOB AGENT RESPONSE" "$LOG_FILE" | tail -10)

            PREVIOUS_ISSUES="EXECUTION: $EXEC_ISSUES\nCODE: $CODE_ISSUES\nARCHITECTURE: $ARCH_ISSUES\nUI: $UI_ISSUES"
        fi

        log "INFO" "Previous issues found, requesting targeted improvements..."
        opencode run --model opencode/grok-code "
        You are the Ralph Wiggum Improvement Agent. The application exists but has verification failures.

        USER INTENT: $INTENT
        ITERATION: $iteration

        Previous verification results:
        $PREVIOUS_ISSUES

        Your task: Fix the specific issues found by the verification agents. Do NOT regenerate everything from scratch - only fix the problems reported.

        Instructions:
        1. Analyze the specific failures mentioned in the verification results
        2. Make targeted improvements to address ONLY those issues
        3. Keep all working code intact - only fix what's broken
        4. Focus on the highest priority issues first

        If execution verification failed: Fix core functionality bugs
        If code quality failed: Clean up the specific code quality issues
        If architecture failed: Improve the architectural problems
        If UI design failed: Fix the design and UX issues

        Make surgical, precise changes - not wholesale rewrites.
        " 2>&1 | stream_log "IMPROVEMENT"
    fi

    # Phase 2: Execution Verification Agent
    log "INFO" "🔍 Phase 2: Execution Verification Agent"
    log "INFO" "Using intelligent agent to verify the application works like a human would use it..."

    # Use OpenCode agent to actually verify the application
    log "INFO" "Calling OpenCode Execution Verification Agent..."
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
    " 2>&1 | tee >(stream_log "EXEC_VERIFY"))

    log "AGENT_OUTPUT" "=== EXECUTION VERIFICATION AGENT RESPONSE ==="
    log "AGENT_OUTPUT" "$VERIFICATION_RESULT"
    log "AGENT_OUTPUT" "=== END EXECUTION VERIFICATION ==="

    if echo "$VERIFICATION_RESULT" | grep -q "WORKS_PERFECTLY"; then
        log "SUCCESS" "✅ Execution verification passed - application works as intended!"
        VERIFICATION_PASSED=true
    else
        log "ERROR" "❌ Execution verification failed"
        log "ERROR" "Issues found: $VERIFICATION_RESULT"
        VERIFICATION_PASSED=false
    fi

    # Phase 3: Code Slop Agent (if execution passed)
    if [ "$VERIFICATION_PASSED" = true ]; then
        log "INFO" "🧹 Phase 3: Code Slop Agent"
        log "INFO" "Intelligent code quality analysis for DRY violations, spaghetti code, and maintainability..."

        # Use OpenCode agent for intelligent code quality analysis
        log "INFO" "Calling OpenCode Code Slop Agent..."
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
        " 2>&1 | tee >(stream_log "CODE_SLOP"))

        log "AGENT_OUTPUT" "=== CODE SLOP AGENT RESPONSE ==="
        log "AGENT_OUTPUT" "$SLOP_RESULT"
        log "AGENT_OUTPUT" "=== END CODE SLOP ==="

        if echo "$SLOP_RESULT" | grep -q "CODE_IS_CLEAN"; then
            log "SUCCESS" "✅ Code quality check passed - clean, maintainable code!"
            SLOP_CLEAN=true
        else
            log "ERROR" "❌ Code quality issues found"
            log "ERROR" "Details: $SLOP_RESULT"
            SLOP_CLEAN=false
        fi
    else
        SLOP_CLEAN=false
    fi

    # Phase 4: Architecture Agent (if code is clean)
    if [ "$SLOP_CLEAN" = true ]; then
        log "INFO" "🏗️ Phase 4: Architecture Agent"
        log "INFO" "Evaluating system design, scalability, and architectural elegance..."

        # Use OpenCode agent for intelligent architecture analysis
        log "INFO" "Calling OpenCode Architecture Agent..."
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
        " 2>&1 | tee >(stream_log "ARCHITECTURE"))

        log "AGENT_OUTPUT" "=== ARCHITECTURE AGENT RESPONSE ==="
        log "AGENT_OUTPUT" "$ARCH_RESULT"
        log "AGENT_OUTPUT" "=== END ARCHITECTURE ==="

        if echo "$ARCH_RESULT" | grep -q "ARCHITECTURE_IS_SOLID"; then
            log "SUCCESS" "✅ Architecture check passed - solid, scalable, production-ready design!"
            ARCH_SOLID=true
        else
            log "ERROR" "❌ Architecture issues found"
            log "ERROR" "Details: $ARCH_RESULT"
            ARCH_SOLID=false
        fi
    else
        ARCH_SOLID=false
    fi

    # Phase 5: UI Design Snob Agent (if architecture is solid)
    if [ "$ARCH_SOLID" = true ]; then
        log "INFO" "🎨 Phase 5: UI Design Snob Agent"
        log "INFO" "Evaluating pixel-perfect UI design, user experience, and visual polish..."

        # Use OpenCode agent for intelligent UI/UX analysis
        log "INFO" "Calling OpenCode UI Design Snob Agent..."
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
        " 2>&1 | tee >(stream_log "UI_DESIGN"))

        log "AGENT_OUTPUT" "=== UI DESIGN SNOB AGENT RESPONSE ==="
        log "AGENT_OUTPUT" "$UI_RESULT"
        log "AGENT_OUTPUT" "=== END UI DESIGN ==="

        if echo "$UI_RESULT" | grep -q "UI_IS_PERFECT"; then
            log "SUCCESS" "✅ UI design check passed - pixel-perfect, professional, and delightful!"
            UI_PERFECT=true
        else
            log "ERROR" "❌ UI design issues found"
            log "ERROR" "Details: $UI_RESULT"
            UI_PERFECT=false
        fi
    else
        UI_PERFECT=false
    fi

    # Ralph Wiggum Exit Condition Check
    log "INFO" "🎯 Ralph Wiggum Exit Check"
    log "INFO" "=========================="

    log "INFO" "Verification Status:"
    log "INFO" "  - Execution: $VERIFICATION_PASSED"
    log "INFO" "  - Code Quality: $SLOP_CLEAN"
    log "INFO" "  - Architecture: $ARCH_SOLID"
    log "INFO" "  - UI Design: $UI_PERFECT"

    if [ "$VERIFICATION_PASSED" = true ] && [ "$SLOP_CLEAN" = true ] && [ "$ARCH_SOLID" = true ] && [ "$UI_PERFECT" = true ]; then
        log "SUCCESS" "🎉 ALL VERIFICATION GATES PASSED!"
        log "SUCCESS" "The application meets 100% of Ralph Wiggum standards."
        log "SUCCESS" "✅ Execution: Works perfectly like a human would use it"
        log "SUCCESS" "✅ Code Quality: No slop, DRY, maintainable"
        log "SUCCESS" "✅ Architecture: Scalable, elegant design"
        log "SUCCESS" "✅ UI Design: Pixel-perfect, professional"
        log "SUCCESS" "Ralph Wiggum loop complete. Application is perfect. ✨"
        echo "🎉 SUCCESS: Ralph Wiggum loop completed! Check $LOG_FILE for full details."
        exit 0
    else
        log "WARNING" "❌ Verification gates failed. Continuing Ralph loop..."
        log "WARNING" "Failed gates:"
        [ "$VERIFICATION_PASSED" = false ] && log "WARNING" "  - Execution verification"
        [ "$SLOP_CLEAN" = false ] && log "WARNING" "  - Code quality"
        [ "$ARCH_SOLID" = false ] && log "WARNING" "  - Architecture"
        [ "$UI_PERFECT" = false ] && log "WARNING" "  - UI design"

        log "INFO" "Trunk agent will address these issues in the next iteration."
        echo "🔄 Continuing loop... Monitor progress: tail -f $LOG_FILE"
    fi

    iteration=$((iteration + 1))
    log "INFO" "Iteration $iteration completed. Sleeping 3 seconds before next iteration..."
    sleep 3
done

log "ERROR" "⚠️  Reached maximum iterations ($max_iterations)"
log "ERROR" "The Ralph Wiggum loop could not achieve perfection."
log "ERROR" "Manual intervention may be required."
echo "❌ FAILURE: Ralph Wiggum loop failed after $max_iterations iterations. Check $LOG_FILE for details."
exit 1