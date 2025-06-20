#!/usr/bin/env bash
# =============================================================================
# Cursor AI Debug Mode - Issue Resolution Focus
# Specializovaný skript pro ladění a řešení problémů
# =============================================================================

set -euo pipefail

# ----- DEBUG A TROUBLESHOOTING PROMPTY ---------------------------------

declare -a DEBUG_PROMPTS=(
    "analyze current errors and issues in the codebase"
    "investigate failing tests and their root causes"
    "check for TypeScript compilation errors and fix them"
    "verify all imports and dependencies are correct"
    "run npm audit and fix security vulnerabilities"
    "check for linting errors and resolve them"
    "validate JSON and configuration files"
    "test all API endpoints and fix broken ones"
    "verify Docker build process works correctly"
    "check CI/CD pipeline status and fix any failures"
)

# Debugging zaměřené prompty s reference na soubory
declare -a FILE_FOCUSED_DEBUG=(
    "@package.json fix any dependency issues and version conflicts"
    "@tsconfig.json verify TypeScript configuration is correct"
    "@Dockerfile fix any Docker build issues"
    "@.github/workflows/ check and fix CI/CD pipeline problems"
    "run 'npm test' and fix all failing tests step by step"
    "run 'npm run build' and resolve any build errors"
    "run 'npm run lint' and fix all linting issues"
)

DEBUG_DELAY=120  # 2 minuty pro debug operace

# ----- UTILITY ----------------------------------------------------------

beep() { echo -ne '\a'; }

countdown_debug() {
    echo "🔍 Připravuji debug operaci..."
    for s in 5 4 3 2 1; do
        printf "\r🐛 Spouštím za %d sekund..." "$s"
        beep
        sleep 1
    done
    echo -e "\n🔧 Debugging!"
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

wait_debug() {
    local remaining=$DEBUG_DELAY
    echo "🔍 Debugging - čekám $DEBUG_DELAY s (Enter = zrychlit)"
    
    while (( remaining > 0 )); do
        if read -r -s -n 1 -t 1 key 2>/dev/null; then
            if [[ -z "$key" ]]; then
                echo -e "\n🚀 Zrychleno!"
                remaining=10
            fi
        fi
        ((remaining--))
        
        if (( remaining % 20 == 0 && remaining > 0 )); then
            echo "⏱️  Debug pokračuje - zbývá $remaining s"
        fi
    done
}

# ----- HLAVNÍ DEBUG WORKFLOW -------------------------------------------

debug_cycle() {
    echo "🐛 DEBUG CYKLUS - $(date '+%H:%M:%S')"
    echo "Zaměřeno na identifikaci a řešení problémů"
    echo ""
    
    # Fáze 1: Obecné debugging
    echo "📋 FÁZE 1: Obecná analýza problémů"
    for prompt in "${DEBUG_PROMPTS[@]}"; do
        echo "🔍 $prompt"
        countdown_debug
        paste_clipboard "$prompt"
        wait_debug
        echo ""
    done
    
    echo "✅ Fáze 1 dokončena"
    echo ""
    
    # Fáze 2: Soubor-specifické debugging
    echo "📋 FÁZE 2: Kontrola specifických souborů"
    for prompt in "${FILE_FOCUSED_DEBUG[@]}"; do
        echo "📁 $prompt"
        countdown_debug
        paste_clipboard "$prompt"
        wait_debug
        echo ""
    done
    
    echo "✅ Debug cyklus dokončen"
}

main() {
    echo "🐛 Cursor AI Debug Mode"
    echo "======================="
    echo "Specializovaný režim pro řešení problémů a debugging"
    echo "Zaměřuje se na testy, buildy, linting a CI/CD"
    echo ""
    
    local cycle=1
    
    while true; do
        echo "🔄 Debug Cyklus #$cycle"
        debug_cycle
        
        echo "⏸️  Pauza před dalším debug cyklem (3 minuty)"
        echo "Stiskni Ctrl+C pro ukončení"
        sleep 180
        
        ((cycle++))
    done
}

# Kontrola závislostí
command -v xdotool >/dev/null || { echo "❌ Nainstaluj xdotool"; exit 1; }
command -v xclip >/dev/null || { echo "❌ Nainstaluj xclip"; exit 1; }

main "$@"