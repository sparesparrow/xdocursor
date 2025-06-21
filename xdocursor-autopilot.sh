#!/usr/bin/env bash
# =======================================================================================
# xdocursor Autopilot v2.0 - MCP Workflow Engine Orchestrator
#
# Autor: Sparrow AI Tech
# Popis:
#   Tato nová verze skriptu zásadně mění přístup k automatizaci v editoru Cursor.
#   Opouští křehkou a nespolehlivou metodu simulace GUI (pomocí xdotool a xclip)
#   a přechází na robustní, na protokolu založený model.
#
#   Využívá sílu Model Context Protocol (MCP) a workflow enginu z projektu
#   `sparesparrow/mcp-prompts` k provádění komplexních, stavových a spolehlivých
#   automatizačních procesů.
#
# Princip fungování:
#   1. WORKFLOW DEFINICE: Jednotlivé refaktoringové fáze jsou definovány ve
#      formátu JSON (`.workflow.json` soubory). To umožňuje verzování, snadnou
#      úpravu a sdílení komplexních workflow.
#   2. WORKFLOW ENGINE: Skript již neobsahuje logiku pro provádění kroků. Místo
#      toho volá specializovaný CLI nástroj (`workflow-cli.ts` z `mcp-prompts`),
#      který je zodpovědný za parsování a provádění workflow.
#   3. ROBUSTNOST: Odstraněním závislosti na `xdotool` a `sleep` získáváme systém
#      s uzavřenou smyčkou. Každý krok je proveden a jeho výsledek je znám před
#      spuštěním dalšího kroku. To eliminuje chyby časování a závislost na UI.
#   4. ROZŠIŘITELNOST: JSON workflow může obsahovat kroky typu "shell", "http"
#      nebo "prompt", což umožňuje orchestraci nejen AI, ale i externích nástrojů
#      a API.
#
# =======================================================================================

set -euo pipefail

# ----- KONFIGURACE ---------------------------------------------------------------------

# Cesta k projektu mcp-prompts, který obsahuje workflow engine.
# Upravte podle umístění na vašem systému.
MCP_PROMPTS_DIR="${HOME}/mcp/mcp-prompts"

# Adresář obsahující definice workflow.
# Každý soubor .workflow.json reprezentuje jednu ucelenou fázi refaktoringu.
WORKFLOWS_DIR="./workflows"

# Sekvence, ve které se mají workflow spouštět.
# Názvy odpovídají souborům v adresáři WORKFLOWS_DIR.
declare -a WORKFLOW_SEQUENCE=(
    "01-workspace-setup.workflow.json"
    "02-catalog-extraction.workflow.json"
    "03-contracts-creation.workflow.json"
    "04-pipeline-automation.workflow.json"
    "05-docs-update.workflow.json"
)

# ----- UTILITY FUNKCE ------------------------------------------------------------------

# Funkce pro logování s časovou značkou a úrovní
log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] - $message"
}

# Zobrazí úvodní hlavičku skriptu
print_header() {
    echo "================================================="
    log "INFO" "xdocursor Autopilot v2.0 - MCP Workflow Engine"
    echo "================================================="
    echo "🚀 Spouštím robustní automatizaci řízenou workflow enginem."
    echo "🛑 Pro ukončení stiskněte Ctrl+C."
    echo
}

# ----- JÁDRO ORCHESTRACE ---------------------------------------------------------------

# Zkontroluje, zda existují potřebné závislosti a konfigurace.
check_dependencies() {
    log "INFO" "Kontroluji závislosti..."
    if ! command -v node &> /dev/null; then
        log "ERROR" "Node.js není nainstalován. Prosím, nainstalujte jej."
        exit 1
    fi
    if [ ! -d "$MCP_PROMPTS_DIR" ]; then
        log "ERROR" "Adresář projektu mcp-prompts nebyl nalezen na cestě: $MCP_PROMPTS_DIR"
        exit 1
    fi
    if [ ! -f "$MCP_PROMPTS_DIR/src/scripts/workflow-cli.ts" ]; then
        log "ERROR" "Workflow CLI (workflow-cli.ts) nebylo nalezeno v projektu mcp-prompts."
        exit 1
    fi
    if [ ! -d "$WORKFLOWS_DIR" ]; then
        log "ERROR" "Adresář s workflow definicemi ($WORKFLOWS_DIR) neexistuje."
        exit 1
    fi
    log "SUCCESS" "Všechny závislosti jsou v pořádku."
    echo
}

# Spustí konkrétní workflow pomocí CLI nástroje z mcp-prompts.
# Nahrazuje původní křehkou logiku `paste_via_clipboard` a `sleep`.
run_workflow() {
    local workflow_file="$1"
    local full_path_to_workflow="${WORKFLOWS_DIR}/${workflow_file}"

    if [ ! -f "$full_path_to_workflow" ]; then
        log "WARN" "Workflow soubor '$workflow_file' byl přeskočen, protože nebyl nalezen."
        return
    fi

    log "INFO" "Spouštím workflow: $workflow_file"
    echo "-------------------------------------------------"

    # Zde je klíčová změna: místo simulace UI voláme přímo CLI nástroj,
    # který provede celé workflow. Je to stabilní, rychlé a spolehlivé.
    # Používáme `ts-node` pro přímé spuštění TypeScript souboru.
    (
        cd "$MCP_PROMPTS_DIR" || exit
        npx ts-node src/scripts/workflow-cli.ts --workflow "$full_path_to_workflow"
    )

    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "Workflow '$workflow_file' bylo úspěšně dokončeno."
    else
        log "ERROR" "Workflow '$workflow_file' selhalo s chybovým kódem $exit_code."
        # Zde můžete přidat logiku pro zastavení celého procesu při chybě
        # exit 1
    fi
    echo "-------------------------------------------------"
    echo
}

# Hlavní funkce skriptu, která orchestruje celý proces.
main() {
    print_header
    check_dependencies

    local cycle=1
    while true; do
        log "INFO" "Zahajuji automatizační cyklus #$cycle"
        local total_steps=${#WORKFLOW_SEQUENCE[@]}
        local current_step=0

        for workflow_name in "${WORKFLOW_SEQUENCE[@]}"; do
            ((current_step++))
            log "INFO" "Zpracovávám krok $current_step/$total_steps"
            run_workflow "$workflow_name"

            # Krátká pauza mezi workflow pro přehlednost logů
            if [ "$current_step" -lt "$total_steps" ]; then
                 log "INFO" "Pauza 10 sekund před dalším workflow..."
                 sleep 10
            fi
        done

        log "SUCCESS" "Cyklus #$cycle byl dokončen!"
        log "INFO" "Další cyklus se spustí za 5 minut. Stiskněte Ctrl+C pro ukončení."
        sleep 300
        ((cycle++))
    done
}

# ----- SPUŠTĚNÍ ------------------------------------------------------------------------

main "$@"
