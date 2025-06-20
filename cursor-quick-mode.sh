#!/usr/bin/env bash
# =============================================================================
# Cursor AI Quick Mode - Rapid Development
# Rychlý režim pro okamžité testování a iterace
# =============================================================================

set -euo pipefail

# ----- RYCHLÉ PROMPTY PRO OKAMŽITÉ AKCE --------------------------------

declare -a QUICK_PROMPTS=(
    "proceed with current task"
    "implement next logical step"
    "test and fix any issues"
    "proceed to next TODO item"
    "build and verify changes"
    "update documentation if needed"
    "proceed with implementation"
    "finalize current changes"
)

# Kratší intervaly pro rychlý vývoj
QUICK_DELAY=30  # 30 sekund mezi kroky

# ----- UTILITY ----------------------------------------------------------

beep() { echo -ne '\a'; }

countdown_quick() {
    for s in 3 2 1; do
        printf "\r⚡ Za %d..." "$s"
        beep
        sleep 1
    done
    echo -e "\n🚀"
}

paste_clipboard() {
    local text="$1"
    local old="$(xclip -o -selection clipboard 2>/dev/null || echo '')"
    printf '%s' "$text" | xclip -selection clipboard
    xdotool key --clearmodifiers 'ctrl+shift+v'
    xdotool key Return
    sleep 0.3
    printf '%s' "$old" | xclip -selection clipboard
}

wait_quick() {
    local remaining=$QUICK_DELAY
    echo "⏱️  Čekám $QUICK_DELAY s (Enter = pokračovat hned)"
    
    while (( remaining > 0 )); do
        if read -r -s -n 1 -t 1 key 2>/dev/null; then
            if [[ -z "$key" ]]; then
                echo -e "\n⚡ Pokračuji okamžitě!"
                break
            fi
        fi
        ((remaining--))
    done
}

# ----- HLAVNÍ LOGIKA ---------------------------------------------------

main() {
    echo "⚡ Cursor AI Quick Mode"
    echo "Rychlé iterace s krátkými intervaly"
    echo "Stiskni Ctrl+C pro stop"
    echo ""
    
    local iteration=1
    
    while true; do
        echo "🔥 Iterace #$iteration"
        
        for prompt in "${QUICK_PROMPTS[@]}"; do
            echo "💬 $prompt"
            countdown_quick
            paste_clipboard "$prompt"
            wait_quick
            echo ""
        done
        
        echo "✅ Iterace #$iteration hotová"
        echo "⏸️  Krátká pauza..."
        sleep 10
        ((iteration++))
    done
}

# Kontrola závislostí
command -v xdotool >/dev/null || { echo "❌ Nainstaluj xdotool"; exit 1; }
command -v xclip >/dev/null || { echo "❌ Nainstaluj xclip"; exit 1; }

main "$@"