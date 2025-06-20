#!/usr/bin/env bash
# =============================================================================
# Cursor AI Test Mode - Comprehensive Testing Focus
# Specializovaný skript pro testování a quality assurance
# =============================================================================

set -euo pipefail

# ----- TESTING A QA PROMPTY --------------------------------------------

declare -a TEST_PROMPTS=(
    "run all unit tests and analyze results"
    "run integration tests and fix any failures"
    "execute end-to-end test suite"
    "run TypeScript type checking and fix errors"
    "perform npm audit and security check"
    "run linting and code style validation"
    "test Docker build and container startup"
    "verify API endpoints with manual testing"
    "check test coverage and improve where needed"
    "validate all package.json scripts work correctly"
)

# Test-specifické prompty s referenčními soubory
declare -a SPECIFIC_TEST_PROMPTS=(
    "@jest.config.js verify Jest configuration and test setup"
    "@package.json run all defined test scripts sequentially"
    "run 'npm run test:unit' and fix failing unit tests"
    "run 'npm run test:integration' and resolve issues"
    "run 'npm run test:e2e' and fix end-to-end test failures"
    "@tsconfig.json verify TypeScript configuration for tests"
    "@Dockerfile test Docker build process thoroughly"
    "create missing test files for uncovered code"
    "update test snapshots if needed"
    "verify all environment variables are properly mocked in tests"
)

# Quality gates - posloupnost kontrol
declare -a QUALITY_GATES=(
    "ensure all tests pass before proceeding"
    "verify code coverage meets minimum threshold"
    "check that build process completes without errors"
    "validate that Docker image builds successfully"  
    "confirm API documentation is up to date"
    "verify no security vulnerabilities exist"
    "ensure code style standards are met"
    "check that all TODO items in tests are resolved"
)

TEST_DELAY=90  # 1.5 minuty pro testovací operace

# ----- UTILITY ----------------------------------------------------------

beep() { echo -ne '\a'; }

countdown_test() {
    echo "🧪 Připravuji test operaci..."
    for s in 5 4 3 2 1; do
        printf "\r🧪 Spouštím za %d sekund..." "$s"
        beep
        sleep 1
    done
    echo -e "\n🚀 Testing!"
}

paste_clipboard() {
    local text="$1"
    local old="$(xclip -o -selection clipboard 2>/dev/null || echo '')"
    printf '%s' "$text" | xclip -selection clipboard
    xdotool key --clearmodifiers 'ctrl+shift+v'
    xdotool key Return
    sleep 0.4
    printf '%s' "$old" | xclip -selection clipboard
}

wait_test() {
    local remaining=$TEST_DELAY
    echo "🧪 Testing - čekám $TEST_DELAY s (Enter = zrychlit)"
    
    while (( remaining > 0 )); do
        if read -r -s -n 1 -t 1 key 2>/dev/null; then
            if [[ -z "$key" ]]; then
                echo -e "\n⚡ Zrychleno!"
                remaining=15
            fi
        fi
        ((remaining--))
        
        if (( remaining % 15 == 0 && remaining > 0 )); then
            echo "⏱️  Test pokračuje - zbývá $remaining s"
        fi
    done
}

# ----- TEST WORKFLOW ---------------------------------------------------

run_test_phase() {
    local phase_name="$1"
    shift
    local prompts=("$@")
    
    echo "🧪 $phase_name - $(date '+%H:%M:%S')"
    echo "────────────────────────────────────────"
    
    for prompt in "${prompts[@]}"; do
        echo "🔬 $prompt"
        countdown_test
        paste_clipboard "$prompt"
        wait_test
        echo ""
    done
    
    echo "✅ $phase_name dokončena"
    echo ""
}

comprehensive_test_cycle() {
    echo "🧪 KOMPREHENSIVNÍ TEST CYKLUS"
    echo "============================"
    echo ""
    
    # Fáze 1: Základní testy
    run_test_phase "ZÁKLADNÍ TESTY" "${TEST_PROMPTS[@]}"
    
    # Fáze 2: Specifické testování
    run_test_phase "SPECIFICKÉ TESTY" "${SPECIFIC_TEST_PROMPTS[@]}"
    
    # Fáze 3: Quality Gates
    run_test_phase "QUALITY GATES" "${QUALITY_GATES[@]}"
    
    echo "🎉 Kompletní test cyklus dokončen!"
}

main() {
    echo "🧪 Cursor AI Test Mode"
    echo "====================="
    echo "Komplexní testování a quality assurance"
    echo "Zaměřuje se na unit testy, integraci, E2E a code quality"
    echo ""
    
    local cycle=1
    
    while true; do
        echo "🔄 Test Cyklus #$cycle"
        comprehensive_test_cycle
        
        echo "⏸️  Pauza před dalším test cyklem (5 minut)"
        echo "Stiskni Ctrl+C pro ukončení"
        sleep 300
        
        ((cycle++))
    done
}

# Kontrola závislostí
command -v xdotool >/dev/null || { echo "❌ Nainstaluj xdotool"; exit 1; }
command -v xclip >/dev/null || { echo "❌ Nainstaluj xclip"; exit 1; }

main "$@"