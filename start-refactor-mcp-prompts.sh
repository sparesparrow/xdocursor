#!/usr/bin/env bash
set -euo pipefail

# ----- Nastavitelné prompty a defaultní prodlevy ---------------------------

declare -a RULES_PROMPTS=(
  "@TODO-workspace-setup.mdc proceed"
  "@TODO-catalog-extraction.mdc proceed"
  "@TODO-contracts-creation.mdc proceed"
  "@TODO-pipeline-automation.mdc proceed"
  "@TODO-docs-update.mdc proceed"
)
declare -a PROMPTS=(
  "proceed next steps in our development and refactoring process described in @TODO-catalog-extraction.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-catalog-extraction.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-catalog-extraction.mdc"
  "@TODO-catalog-extraction.mdc proceed last steps finalizing implementation of the tasks"
  "implement, document and test next steps in our development and refactoring process described in @TODO-contracts-creation.mdc step by step"
  "proceed next steps in our development and refactoring process described in @TODO-contracts-creation.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-contracts-creation.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-contracts-creation.mdc"
  "proceed last steps finalizing implementation of the tasks described in @TODO-contracts-creation.mdc"
  "implement, document and test next steps in our development and refactoring process described in @TODO-pipeline-automation.mdc step by step"
  "proceed next steps in our development and refactoring process described in @TODO-pipeline-automation.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-pipeline-automation.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-pipeline-automation.mdc"
  "proceed last steps finalizing implementation of the tasks described in @TODO-pipeline-automation.mdc"
  "implement, document and test next steps in our development and refactoring process described in @TODO-docs-update.mdc step by step"
  "proceed next steps in our development and refactoring process described in @TODO-docs-update.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-docs-update.mdc"
  "proceed next steps in our development and refactoring process described in @TODO-docs-update.mdc"
  "proceed last steps finalizing implementation of the tasks described in @TODO-docs-update.mdc"
)
declare -a DEFAULT_DELAYS=(180 180 240 120 60)  # sekundy

# ----- Utility -------------------------------------------------------------
beep() { echo -ne '\a'; }            # systémový zvonek

countdown() {                        # 5 s vizuální + zvukový odpočet
  for s in 5 4 3 2 1; do
    echo "⏳ Spouštím xdotool za $s s…"; beep; sleep 1
  done
}

paste_clipboard() {                  # vloží text přes schránku
  local text="$1"
  local old="$(xclip -o -selection clipboard 2>/dev/null || true)"
  printf %s "$text" | xclip -selection clipboard
  xdotool key --clearmodifiers 'ctrl+shift+v'
  sleep 0.4
  printf %s "$old" | xclip -selection clipboard
}

wait_with_enter() {
  # $1 = plánovaná délka odpočtu v sekundách
  local remaining=$1
  while (( remaining > 0 )); do
    # Čekáme maximálně 1 s a zároveň hlídáme klávesu Enter (-n 1), timeout 1 s (-t 1)
    if read -r -s -n 1 -t 1 key; then   # vstup byl zaznamenán
      if [[ -z $key ]]; then           # Enter ⇒ zkrátit na 5 s
        echo -e "\n↩️  Enter zachycen – zkracuji čekání na 5 s!"
        remaining=5
      fi
    fi
    ((remaining--))
  done
}

# Hlavní smyčka
main() {
    echo "🚀 Cursor autopilot s možností zrychlení Enterem"
    while true; do
    for idx in "${!PROMPTS[@]}"; do
        local prompt="${PROMPTS[idx]}"
        local delay="${DEFAULT_DELAYS[idx]}"

        countdown
        echo "📋 Vkládám: $prompt"
        paste_clipboard "$prompt"
        sleep 1
        xdotool key Return
        sleep 1
        echo "🛌 Čekám až $delay s (Enter = zkrátit na 5 s)…"
        wait_with_enter "$delay"
    done
    echo "🔄 Cyklus hotov – pauza 60 s a jedeme znovu."
    sleep 60
    done
}

main
