#!/usr/bin/env bash
# =============================================================================
# Cursor AI Autopilot - Improved Version
# Automatizuje refaktoring MCP Prompts pomocí Cursor AI agenta
# =============================================================================

set -euo pipefail

# ----- KONFIGURACE PROJEKTOVÝCH FÁZÍ ------------------------------------

# Hlavní TODO soubory pro refaktoring
declare -a TODO_FILES=(
    "TODO-workspace-setup.mdc"
    "TODO-catalog-extraction.mdc" 
    "TODO-contracts-creation.mdc"
    "TODO-pipeline-automation.mdc"
    "TODO-docs-update.mdc"
)

# Strukturované prompty pro každou fázi (start -> iterace -> finalizace)
declare -A PHASE_PROMPTS=(
    # Workspace Setup Phase
    ["workspace-setup-start"]="proceed implementation of the tasklist in @TODO.md and regularly commit changes to github and close github issues with explanation if you fix any of them. do not forget to rerun tests to see if tests were not broken by your changes or need an update. when unsure, use @Web for finding the best practices and approaches to decide or move on when you are stuck on something. when a breaking change is implemented, tested and documented, publish all packages, docker images and a new release. now proceed with whatever you are currently working on or continue with the next TODO in @TODO.md and keep this file updated"
    ["workspace-setup-continue"]="proceed"
    ["workspace-setup-finalize"]="proceed"
    
    # Catalog Extraction Phase  
    ["catalog-extraction-start"]="proceed"
    ["catalog-extraction-continue"]="proceed"
    ["catalog-extraction-finalize"]="proceed"
    
    # Contracts Creation Phase
    ["contracts-creation-start"]="proceed implementation of the tasklist in @TODO.md and regularly commit changes to github and close github issues with explanation if you fix any of them. do not forget to rerun tests to see if tests were not broken by your changes or need an update. when unsure, use @Web for finding the best practices and approaches to decide or move on when you are stuck on something. when a breaking change is implemented, tested and documented, publish all packages, docker images and a new release. now proceed with whatever you are currently working on or continue with the next TODO in @TODO.md and keep this file updated"
    ["contracts-creation-continue"]="proceed"
    ["contracts-creation-finalize"]="proceed"
    
    # Pipeline Automation Phase
    ["pipeline-automation-start"]="proceed"
    ["pipeline-automation-continue"]="proceed"
    ["pipeline-automation-finalize"]="proceed"
    
    # Documentation Update Phase
    ["docs-update-start"]="proceed implementation of the tasklist in @TODO.md and regularly commit changes to github and close github issues with explanation if you fix any of them. do not forget to rerun tests to see if tests were not broken by your changes or need an update. when unsure, use @Web for finding the best practices and approaches to decide or move on when you are stuck on something. when a breaking change is implemented, tested and documented, publish all packages, docker images and a new release. now proceed with whatever you are currently working on or continue with the next TODO in @TODO.md and keep this file updated"
    ["docs-update-continue"]="proceed"
    ["docs-update-finalize"]="proceed"
)

# Sekvenční workflow - každá fáze má 3 kroky
declare -a WORKFLOW_SEQUENCE=(
    "workspace-setup-start"
    "workspace-setup-continue" 
    "workspace-setup-finalize"
    "catalog-extraction-start"
    "catalog-extraction-continue"
    "catalog-extraction-finalize"
    "contracts-creation-start"
    "contracts-creation-continue"
    "contracts-creation-finalize"
    "pipeline-automation-start"
    "pipeline-automation-continue"
    "pipeline-automation-finalize"
    "docs-update-start"
    "docs-update-continue"
    "docs-update-finalize"
)

# Časové intervaly pro různé typy úkolů (v sekundách)
declare -A TASK_DELAYS=(
    ["start"]=300      # inicializace fáze - 5 min
    ["continue"]=180   # pokračování - 3 min  
    ["finalize"]=240   # finalizace - 4 min
)

# ----- UTILITY FUNKCE --------------------------------------------------

# Systémové upozornění
beep() { echo -ne '\a'; }

# Vizuální odpočítávání s akustickým varováním
countdown() {
    echo "🎯 Připravuji další krok..."
    for s in 5 4 3 2 1; do
        printf "\r⏳ Spouštím za %d sekund..." "$s"
        beep
        sleep 1
    done
    echo -e "\n🚀 Spouštím!"
}

# Bezpečné vložení přes clipboard
paste_via_clipboard() {
    local text="$1"
    local old_clipboard
    old_clipboard="$(xclip -o -selection clipboard 2>/dev/null || echo '')"
    
    # Nastav nový obsah do clipboardu
    printf '%s' "$text" | xclip -selection clipboard
    
    # Vlož pomocí Ctrl+Shift+V (funguje i v terminálu)
    xdotool key --clearmodifiers --delay 50 'ctrl+shift+v'
    xdotool key Return
    
    # Obnov původní clipboard po krátké pauze
    sleep 0.5
    printf '%s' "$old_clipboard" | xclip -selection clipboard
}

# Interaktivní čekání s možností zkrácení
wait_with_acceleration() {
    local total_seconds=$1
    local remaining=$total_seconds
    
    echo "🛌 Čekám $total_seconds sekund (stiskni Enter pro zrychlení na 5s)"
    
    while (( remaining > 0 )); do
        if read -r -s -n 1 -t 1 key 2>/dev/null; then
            if [[ -z "$key" ]]; then  # Enter key
                echo -e "\n⚡ Enter zachycen - zkracuji čekání na 5 sekund!"
                remaining=5
            fi
        fi
        ((remaining--))
        
        # Progress indikátor každých 30 sekund
        if (( remaining % 30 == 0 && remaining > 0 )); then
            echo "⏱️  Zbývá $remaining sekund..."
        fi
    done
}

# Detekce typu úkolu podle názvu pro výběr správného delay
get_task_delay() {
    local task_name="$1"
    if [[ "$task_name" == *"start"* ]]; then
        echo "${TASK_DELAYS[start]}"
    elif [[ "$task_name" == *"finalize"* ]]; then  
        echo "${TASK_DELAYS[finalize]}"
    else
        echo "${TASK_DELAYS[continue]}"
    fi
}

# ----- HLAVNÍ WORKFLOW LOGIKA ------------------------------------------

show_progress() {
    local current_step=$1
    local total_steps=${#WORKFLOW_SEQUENCE[@]}
    local progress=$((current_step * 100 / total_steps))
    
    echo "📊 Pokrok: $current_step/$total_steps kroků ($progress%)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main() {
    echo "🚀 Cursor AI Autopilot - MCP Prompts Refactoring"
    echo "================================================="
    echo "Automatizuje kompletní refaktoring pomocí strukturovaných promptů"
    echo "Stiskni Ctrl+C pro ukončení"
    echo ""
    
    local cycle=1
    
    while true; do
        echo "🔄 Cyklus #$cycle - $(date '+%H:%M:%S')"
        echo ""
        
        for step_idx in "${!WORKFLOW_SEQUENCE[@]}"; do
            local task_key="${WORKFLOW_SEQUENCE[$step_idx]}"
            local prompt="${PHASE_PROMPTS[$task_key]}"
            local delay
            delay=$(get_task_delay "$task_key")
            
            show_progress $((step_idx + 1))
            
            # Zobraz aktuální krok
            echo "📋 Krok: $task_key"
            echo "💬 Prompt: $prompt"
            echo ""
            
            # Odpočítávání a spuštění
            countdown
            paste_via_clipboard "$prompt"
            
            # Čekání s možností zrychlení
            wait_with_acceleration "$delay"
            echo ""
        done
        
        echo "✅ Cyklus #$cycle dokončen!"
        echo "⏸️  Pauza 2 minuty před dalším cyklem..."
        sleep 120
        
        ((cycle++))
    done
}

# ----- SPUŠTĚNÍ ---------------------------------------------------------

# Kontrola závislostí
if ! command -v xdotool &> /dev/null; then
    echo "❌ Chyba: xdotool není nainstalovaný. Nainstaluj pomocí: sudo apt install xdotool"
    exit 1
fi

if ! command -v xclip &> /dev/null; then
    echo "❌ Chyba: xclip není nainstalovaný. Nainstaluj pomocí: sudo apt install xclip"  
    exit 1
fi

# Spuštění hlavní funkce
main "$@"