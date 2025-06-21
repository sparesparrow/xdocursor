#!/usr/bin/env bash
# =======================================================================================
# xdocursor Autopilot v2.1 - MCP Workflow Engine Orchestrator
#
# Autor: Sparrow AI Tech
# Verze: 2.1
# Popis:
#   Opravená a robustnější verze skriptu pro orchestraci `mcp-prompts` workflow.
#
# Změny ve v2.1:
#   - FIX: Opraveno okamžité ukončování skriptu při chybě v podprocesu (subshell)
#     v kombinaci s `set -e`. Nyní se chyba správně zachytí a zaloguje.
#   - FEATURE: Přidán globální error handler (pomocí `trap`) pro odchycení
#     jakékoli neočekávané chyby. Vypíše přesné místo a příkaz, který selhal,
#     což zásadně usnadňuje budoucí ladění.
#   - REFACTOR: Zjednodušena logika v `run_workflow` pro zachytávání chyb.
#
# =======================================================================================

set -euo pipefail

# ----- KONFIGURACE ---------------------------------------------------------------------

# Cesta k projektu mcp-prompts, který obsahuje workflow engine.
# DŮLEŽITÉ: Upravte podle umístění na vašem systému.
MCP_PROMPTS_DIR="${HOME}/mcp/mcp-prompts" # Příklad cesty

# Adresář obsahující definice workflow.
WORKFLOWS_DIR="./workflows"

# Sekvence, ve které se mají workflow spouštět.
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
    # Používáme >&2 pro logování na standardní chybový výstup, což je best practice.
    echo >&2 "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] - $message"
}

# Globální error handler. Spustí se automaticky při jakékoli chybě díky `trap`.
error_handler() {
  local exit_code=$?
  local line_number=$1
  local command=$2
  log "FATAL" "Skript selhal na řádku ${line_number} při provádění příkazu: '${command}' (exit kód: ${exit_code})"
}

# Nastavení "pasti" na ERR signál, která zavolá naši funkci pro ošetření chyb.
trap 'error_handler ${LINENO} "$BASH_COMMAND"' ERR

# Zobrazí úvodní hlavičku skriptu
print_header() {
    echo "================================================="
    log "INFO" "xdocursor Autopilot v2.1 - MCP Workflow Engine"
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
run_workflow() {
    local workflow_file="$1"
    local full_path_to_workflow
    full_path_to_workflow=$(realpath "${WORKFLOWS_DIR}/${workflow_file}")

    if [ ! -f "$full_path_to_workflow" ]; then
        log "WARN" "Workflow soubor '$workflow_file' byl přeskočen, protože nebyl nalezen."
        return
    fi

    log "INFO" "Spouštím workflow: $workflow_file"
    echo "-------------------------------------------------"

    local exit_code=0
    # KLÍČOVÁ OPRAVA:
    # Subshell `(...)` je nyní součástí `||` podmínky.
    # To znamená, že pokud subshell selže, provede se příkaz napravo od `||`,
    # což "zpracuje" chybu a zabrání `set -e`, aby ukončilo celý skript.
    (
        # Měníme adresář v rámci subshellu, což neovlivní hlavní skript.
        cd "$MCP_PROMPTS_DIR" || exit 1
        # Pro spolehlivost spouštíme workflow CLI s absolutní cestou k souboru.
        npx ts-node src/scripts/workflow-cli.ts --workflow "$full_path_to_workflow"
    ) || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "Workflow '$workflow_file' bylo úspěšně dokončeno."
    else
        # Nyní se tato chybová hláška skutečně zobrazí.
        log "ERROR" "Workflow '$workflow_file' selhalo s chybovým kódem $exit_code."
        # Můžete se rozhodnout, zda zde skript ukončit, nebo pokračovat dalším workflow.
        # Prozatím necháváme pokračovat. Odkomentujte pro zastavení při chybě.
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
            log "INFO" "Zpracovávám krok $current_step/$total_steps: $workflow_name"
            run_workflow "$workflow_name"

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
