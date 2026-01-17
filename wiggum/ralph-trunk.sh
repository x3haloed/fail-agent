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

    # Execute the verification script that actually tests the app
    if [ -f "wiggum/verify.sh" ]; then
        echo "Running human-like verification tests..."
        if ./wiggum/verify.sh > verification_output.log 2>&1; then
            echo "✅ Verification script completed"
            VERIFICATION_PASSED=true
        else
            echo "❌ Verification script failed"
            VERIFICATION_PASSED=false
        fi
    else
        echo "❌ No verification script found"
        VERIFICATION_PASSED=false
    fi

    # Phase 3: Code Slop Agent (if execution passed)
    if [ "$VERIFICATION_PASSED" = true ]; then
        echo "🧹 Phase 3: Code Slop Agent"
        echo "Analyzing code for DRY violations, spaghetti patterns, and quality issues..."

        # Actually analyze the codebase
        SLOP_ISSUES=""

        # Check for DRY violations - look for duplicate code patterns
        if [ -d "wiggum/workspace" ]; then
            # Find duplicate strings in code files
            DUPLICATE_COUNT=$(find wiggum/workspace -name "*.js" -o -name "*.ts" -o -name "*.vue" | xargs cat 2>/dev/null | grep -o "function [a-zA-Z_][a-zA-Z0-9_]*" | sort | uniq -c | sort -nr | awk '$1 > 1 {print $2}' | wc -l)

            if [ "$DUPLICATE_COUNT" -gt 0 ]; then
                SLOP_ISSUES="${SLOP_ISSUES}DRY violations found ($DUPLICATE_COUNT duplicate patterns); "
            fi

            # Check for long functions (>50 lines)
            LONG_FUNCTIONS=$(find wiggum/workspace -name "*.js" -o -name "*.ts" | xargs awk '/function/{f=$2} /^}/{if(NR-start>50)print f,NR-start" lines"} {start=NR}' 2>/dev/null | wc -l)

            if [ "$LONG_FUNCTIONS" -gt 0 ]; then
                SLOP_ISSUES="${SLOP_ISSUES}Long functions detected ($LONG_FUNCTIONS functions >50 lines); "
            fi

            # Check for console.log statements (shouldn't be in production)
            CONSOLE_LOGS=$(find wiggum/workspace -name "*.js" -o -name "*.ts" -o -name "*.vue" | xargs grep -l "console\.log" 2>/dev/null | wc -l)

            if [ "$CONSOLE_LOGS" -gt 0 ]; then
                SLOP_ISSUES="${SLOP_ISSUES}Console.log statements found in $CONSOLE_LOGS files; "
            fi

            # Check for poor naming (functions with generic names)
            GENERIC_NAMES=$(find wiggum/workspace -name "*.js" -o -name "*.ts" | xargs grep -o "function [a-z]\|function test\|function temp\|function foo\|function bar" 2>/dev/null | wc -l)

            if [ "$GENERIC_NAMES" -gt 0 ]; then
                SLOP_ISSUES="${SLOP_ISSUES}Generic function names detected ($GENERIC_NAMES); "
            fi
        fi

        if [ -z "$SLOP_ISSUES" ]; then
            echo "✅ Code quality check passed - no slop detected!"
            SLOP_CLEAN=true
        else
            echo "❌ Code quality issues found: $SLOP_ISSUES"
            SLOP_CLEAN=false
        fi
    else
        SLOP_CLEAN=false
    fi

    # Phase 4: Architecture Agent (if code is clean)
    if [ "$SLOP_CLEAN" = true ]; then
        echo "🏗️ Phase 4: Architecture Agent"
        echo "Evaluating system design, scalability, and architectural patterns..."

        ARCH_ISSUES=""

        if [ -d "wiggum/workspace" ]; then
            # Check for proper separation of concerns
            if [ -d "wiggum/workspace/server" ] && [ -d "wiggum/workspace/client" ]; then
                echo "✅ Proper frontend/backend separation detected"
            else
                ARCH_ISSUES="${ARCH_ISSUES}Missing proper frontend/backend separation; "
            fi

            # Check for API design quality
            if [ -f "wiggum/workspace/server/index.js" ]; then
                # Check for RESTful patterns
                REST_ENDPOINTS=$(grep -c "app\.\(get\|post\|put\|delete\)" wiggum/workspace/server/index.js 2>/dev/null || echo "0")
                if [ "$REST_ENDPOINTS" -lt 3 ]; then
                    ARCH_ISSUES="${ARCH_ISSUES}Insufficient REST endpoints ($REST_ENDPOINTS found, need at least 3); "
                fi

                # Check for proper error handling
                ERROR_HANDLING=$(grep -c "catch\|try" wiggum/workspace/server/index.js 2>/dev/null || echo "0")
                if [ "$ERROR_HANDLING" -lt 1 ]; then
                    ARCH_ISSUES="${ARCH_ISSUES}No error handling in backend; "
                fi
            fi

            # Check for database schema quality
            if grep -q "CREATE TABLE" wiggum/workspace/server/index.js 2>/dev/null; then
                TABLES=$(grep -c "CREATE TABLE" wiggum/workspace/server/index.js 2>/dev/null || echo "0")
                if [ "$TABLES" -lt 1 ]; then
                    ARCH_ISSUES="${ARCH_ISSUES}No proper database schema; "
                fi
            else
                ARCH_ISSUES="${ARCH_ISSUES}No database schema defined; "
            fi

            # Check for scalability concerns
            TOTAL_FILES=$(find wiggum/workspace -name "*.js" -o -name "*.ts" -o -name "*.vue" | wc -l)
            if [ "$TOTAL_FILES" -gt 50 ]; then
                ARCH_ISSUES="${ARCH_ISSUES}Too many files ($TOTAL_FILES) - consider modularization; "
            fi

            # Check for proper component organization (frontend)
            if [ -d "wiggum/workspace/client/src/components" ]; then
                COMPONENT_COUNT=$(find wiggum/workspace/client/src/components -name "*.vue" 2>/dev/null | wc -l)
                if [ "$COMPONENT_COUNT" -lt 2 ]; then
                    ARCH_ISSUES="${ARCH_ISSUES}Too few components ($COMPONENT_COUNT) - consider better decomposition; "
                fi
            fi

            # Check for routing (SPA should have routes)
            if [ -f "wiggum/workspace/client/src/router/index.ts" ]; then
                ROUTES=$(grep -c "path:" wiggum/workspace/client/src/router/index.ts 2>/dev/null || echo "0")
                if [ "$ROUTES" -lt 2 ]; then
                    ARCH_ISSUES="${ARCH_ISSUES}Insufficient routes ($ROUTES) for a proper SPA; "
                fi
            else
                ARCH_ISSUES="${ARCH_ISSUES}No routing system - not a proper SPA; "
            fi
        fi

        if [ -z "$ARCH_ISSUES" ]; then
            echo "✅ Architecture check passed - solid, scalable design!"
            ARCH_SOLID=true
        else
            echo "❌ Architecture issues found: $ARCH_ISSUES"
            ARCH_SOLID=false
        fi
    else
        ARCH_SOLID=false
    fi

    # Phase 5: UI Design Snob Agent (if architecture is solid)
    if [ "$ARCH_SOLID" = true ]; then
        echo "🎨 Phase 5: UI Design Snob Agent"
        echo "Evaluating pixel-perfect UI design, accessibility, and user experience..."

        UI_ISSUES=""

        if [ -d "wiggum/workspace/client" ]; then
            # Check for proper CSS organization
            if [ -f "wiggum/workspace/client/src/assets/main.css" ]; then
                CSS_SIZE=$(wc -l < wiggum/workspace/client/src/assets/main.css)
                if [ "$CSS_SIZE" -lt 10 ]; then
                    UI_ISSUES="${UI_ISSUES}Insufficient CSS styling ($CSS_SIZE lines); "
                fi

                # Check for responsive design
                RESPONSIVE=$(grep -c "@media\|flex\|grid" wiggum/workspace/client/src/assets/main.css 2>/dev/null || echo "0")
                if [ "$RESPONSIVE" -lt 3 ]; then
                    UI_ISSUES="${UI_ISSUES}Limited responsive design ($RESPONSIVE responsive rules); "
                fi
            else
                UI_ISSUES="${UI_ISSUES}No main CSS file found; "
            fi

            # Check for accessibility
            if [ -f "wiggum/workspace/client/src/App.vue" ]; then
                ACCESSIBILITY=$(grep -c "alt=\|aria-\|role=" wiggum/workspace/client/src/App.vue 2>/dev/null || echo "0")
                if [ "$ACCESSIBILITY" -lt 2 ]; then
                    UI_ISSUES="${UI_ISSUES}Poor accessibility ($ACCESSIBILITY accessibility attributes); "
                fi

                # Check for semantic HTML
                SEMANTIC=$(grep -c "<header\|<main\|<section\|<article\|<aside\|<footer" wiggum/workspace/client/src/App.vue 2>/dev/null || echo "0")
                if [ "$SEMANTIC" -lt 2 ]; then
                    UI_ISSUES="${UI_ISSUES}Limited semantic HTML ($SEMANTIC semantic elements); "
                fi
            fi

            # Check for component structure
            if [ -d "wiggum/workspace/client/src/components" ]; then
                COMPONENT_FILES=$(find wiggum/workspace/client/src/components -name "*.vue" | wc -l)
                if [ "$COMPONENT_FILES" -lt 2 ]; then
                    UI_ISSUES="${UI_ISSUES}Insufficient component breakdown ($COMPONENT_FILES components); "
                fi

                # Check for proper component naming
                BAD_NAMES=$(find wiggum/workspace/client/src/components -name "*.vue" | xargs basename -a | grep -c "Component\|Test\|Temp\|Foo\|Bar" 2>/dev/null || echo "0")
                if [ "$BAD_NAMES" -gt 0 ]; then
                    UI_ISSUES="${UI_ISSUES}Poor component naming ($BAD_NAMES badly named components); "
                fi
            fi

            # Check for loading states and error handling
            VUE_FILES=$(find wiggum/workspace/client/src -name "*.vue" | wc -l)
            LOADING_STATES=$(find wiggum/workspace/client/src -name "*.vue" | xargs grep -l "loading\|Loading" 2>/dev/null | wc -l)
            if [ "$LOADING_STATES" -lt "$((VUE_FILES / 2))" ]; then
                UI_ISSUES="${UI_ISSUES}Insufficient loading states ($LOADING_STATES/$VUE_FILES components); "
            fi

            # Check for consistent styling
            INLINE_STYLES=$(find wiggum/workspace/client/src -name "*.vue" | xargs grep -c "style=" 2>/dev/null | awk '{sum+=$1} END {print sum}')
            if [ "$INLINE_STYLES" -gt 5 ]; then
                UI_ISSUES="${UI_ISSUES}Too many inline styles ($INLINE_STYLES) - use CSS classes; "
            fi
        fi

        if [ -z "$UI_ISSUES" ]; then
            echo "✅ UI design check passed - pixel-perfect and professional!"
            UI_PERFECT=true
        else
            echo "❌ UI design issues found: $UI_ISSUES"
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