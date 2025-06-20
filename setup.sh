#!/usr/bin/env bash
# =============================================================================
# Setup Script for Cursor AI Autopilot
# Automaticky nastaví prostředí pro cursor autopilot skripty
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Barvy pro výstup
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Kontrola závislostí
check_dependencies() {
    print_info "Kontroluji závislosti..."
    
    local missing_deps=()
    
    if ! command -v xdotool &> /dev/null; then
        missing_deps+=("xdotool")
    fi
    
    if ! command -v xclip &> /dev/null; then
        missing_deps+=("xclip")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Chybí následující závislosti: ${missing_deps[*]}"
        echo "Nainstaluj je pomocí:"
        echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "  Fedora/RHEL:   sudo dnf install ${missing_deps[*]}"
        echo "  Arch Linux:    sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
    
    print_status "Všechny závislosti jsou nainstalovány"
}

# Vytvoření TODO souborů
create_todo_files() {
    print_info "Vytvářím TODO soubory..."
    
    # TODO-workspace-setup.mdc
    cat > "$PROJECT_ROOT/TODO-workspace-setup.mdc" << 'EOF'
---
description: Inicializace npm workspace a monorepo struktury
globs:
  alwaysApply: false
---

# Workspace Setup Phase

## Úkoly k implementaci:

1. **Vytvořit feature branch**
   - `git checkout -b feature/monorepo-refactor`
   - Commitovat všechny změny do tohoto branch

2. **Nastavit npm workspaces**
   - Přidat do root package.json: `"workspaces": ["packages/*"]`
   - Vytvořit .npmrc s `workspaces=true`
   - Vytvořit složku `packages/`

3. **Inicializovat workspace packages**
   - Vytvořit `packages/mcp-prompts-catalog/`
   - Vytvořit `packages/mcp-prompts-contracts/`
   - V každé složce spustit `npm init -y`
   - Nastavit správné názvy balíčků (@sparesparrow/mcp-prompts-catalog, @sparesparrow/mcp-prompts-contracts)

4. **Aktualizovat root dependencies**
   - Přidat workspace dependencies do root package.json
   - Spustit `npm install` pro propojení balíčků

5. **Ověřit workspace setup**
   - Spustit `npm ls --workspace` pro kontrolu
   - Otestovat že workspace linking funguje
EOF

    # TODO-catalog-extraction.mdc
    cat > "$PROJECT_ROOT/TODO-catalog-extraction.mdc" << 'EOF'
---
description: Extrakce prompt katalogu do samostatného balíčku
globs:
  alwaysApply: false
---

# Catalog Extraction Phase

## Úkoly k implementaci:

1. **Přesunout existující prompty**
   - Vytvořit `packages/mcp-prompts-catalog/prompts/`
   - Přesunout všechny .json a .jsonl soubory s prompty
   - Organizovat do podkategorií (code-review/, copywriting/, system-design/)

2. **Vytvořit catalog package**
   - Nastavit package.json s "files": ["prompts", "index.js"]
   - Vytvořit index.js s exporty prompt paths
   - Přidat helper funkce pro načítání promptů

3. **Refaktorovat prompt loading**
   - Upravit src/adapters/file.ts pro načítání z catalog package
   - Použít require.resolve() pro nalezení package path
   - Zachovat backward compatibility

4. **Implementovat catalog CLI**
   - Přidat příkaz `mcp-prompts catalog install <category>`
   - Přidat příkaz `mcp-prompts catalog list`
   - Přidat flag `--all` pro instalaci všech kategorií

5. **Testovat catalog integration**
   - Ověřit že server načte prompty z catalog package
   - Otestovat CLI příkazy
   - Spustit existující testy
EOF

    # TODO-contracts-creation.mdc
    cat > "$PROJECT_ROOT/TODO-contracts-creation.mdc" << 'EOF'
---
description: Vytvoření sdíleného contracts balíčku s OpenAPI
globs:
  alwaysApply: false
---

# Contracts Creation Phase

## Úkoly k implementaci:

1. **Přesunout TypeScript interfaces**
   - Přesunout src/interfaces.ts do packages/mcp-prompts-contracts/src/
   - Aktualizovat všechny importy v hlavním src/
   - Přidat contracts package jako dependency

2. **Implementovat OpenAPI generování**
   - Nainstalovat tsoa nebo express-openapi
   - Přidat dekorátory/anotace k Express routerům
   - Vytvořit script scripts/generate-openapi.ts
   - Generovat openapi.json do contracts package

3. **Vytvořit Golden Test Suite**
   - Přesunout tests/integration/ do packages/mcp-prompts-contracts/tests/
   - Přejmenovat na golden.test.ts
   - Parametrizovat BASE_URL (default http://localhost:3003)
   - Přidat strict kontroly pro JSON casing a null/undefined

4. **Nastavit pre-commit hooks**
   - Nainstalovat husky a lint-staged
   - Přidat hook pro automatické generování OpenAPI
   - Zajistit že spec je vždy aktuální

5. **Cross-platform type generation**
   - Nastavit generování Rust typů z OpenAPI
   - Přidat validaci že TS a Rust typy jsou konzistentní
   - Připravit základ pro budoucí Rust implementaci
EOF

    # TODO-pipeline-automation.mdc
    cat > "$PROJECT_ROOT/TODO-pipeline-automation.mdc" << 'EOF'
---
description: Automatizace CI/CD pipeline pro monorepo
globs:
  alwaysApply: false
---

# Pipeline Automation Phase

## Úkoly k implementaci:

1. **Multi-stage Dockerfile**
   - Přepsat Dockerfile na multi-stage build
   - Builder stage: všechny dependencies včetně devDependencies
   - Runner stage: pouze production dependencies a compiled kód
   - Přidat HEALTHCHECK a security best practices

2. **GitHub Actions workflow**
   - Upravit .github/workflows/release.yml
   - Přidat kroky pro workspace install (npm install)
   - Spouštět golden.test.ts z contracts package
   - Automatické generování OpenAPI spec

3. **Automated versioning a publishing**
   - Nainstalovat changeset pro version management
   - Nastavit `npm version --workspaces` pro synchronní versioning
   - Publikovat packages v správném pořadí: catalog → contracts → main
   - Upload openapi.json jako release artifact

4. **Security a quality gates**
   - Přidat `npm audit signatures` do CI
   - Nastavit dependency scanning (dependabot.yml)
   - Přidat automated container scanning
   - Implementovat quality gates (test coverage, lint, security)

5. **Release automation**
   - Automatické generování release notes
   - GitHub release při publikaci npm packages
   - Docker image tagging a multi-arch build
   - Integration s MCP Easy Installer manifest
EOF

    # TODO-docs-update.mdc
    cat > "$PROJECT_ROOT/TODO-docs-update.mdc" << 'EOF'
---
description: Aktualizace dokumentace na novou architekturu
globs:
  alwaysApply: false
---

# Documentation Update Phase

## Úkoly k implementaci:

1. **Zkrácení hlavního README**
   - Odstranit TODO sekce z README.md
   - Zkrátit na ≤300 řádků s focus na end-user
   - Přidat badges (CI, npm, Docker pulls, roadmap)
   - Vytvořit clear value proposition

2. **Vytvoření CONTRIBUTING.md**
   - Dokumentovat novou workspace architekturu
   - Popsat "contracts-first" development process
   - Návod na spuštění testů v workspace prostředí
   - Instrukce pro AI agent setup (Cursor)

3. **Package-specific dokumentace**
   - README pro mcp-prompts-catalog package
   - README pro mcp-prompts-contracts package
   - API dokumentace generovaná z OpenAPI
   - Migration guide pro uživatele

4. **Aktualizace JSDoc komentářů**
   - Kompletní JSDoc pro všechny API endpoints
   - Příprava pro kvalitní OpenAPI generování
   - Type annotations pro lepší developer experience
   - Examples a usage patterns

5. **License a legal**
   - Přidat LICENSE soubor do všech packages
   - Ověřit kompatibilitu open-source licencí
   - Aktualizovat copyright notices
   - Package.json metadata (description, keywords, repository)
EOF

    print_status "TODO soubory vytvořeny"
}

# Nastavení execute permissions
set_permissions() {
    print_info "Nastavuji execute permissions pro skripty..."
    
    local scripts=(
        "cursor-autopilot-improved.sh"
        "cursor-quick-mode.sh"
        "cursor-debug-mode.sh"
        "cursor-test-mode.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$SCRIPT_DIR/$script" ]; then
            chmod +x "$SCRIPT_DIR/$script"
            print_status "Permissions nastaveny pro $script"
        else
            print_warning "Skript $script nenalezen"
        fi
    done
}

# Kontrola Cursor workspace
check_cursor_setup() {
    print_info "Kontroluji Cursor workspace setup..."
    
    if [ ! -d "$PROJECT_ROOT/.cursor" ]; then
        mkdir -p "$PROJECT_ROOT/.cursor/rules"
        print_status "Vytvořena .cursor/rules složka"
    fi
    
    if [ ! -f "$PROJECT_ROOT/.cursor/rules/.gitkeep" ]; then
        touch "$PROJECT_ROOT/.cursor/rules/.gitkeep"
        print_status "Vytvořen .gitkeep pro .cursor/rules"
    fi
}

# Vytvoření quick start skriptu
create_quick_start() {
    cat > "$PROJECT_ROOT/start-cursor-autopilot.sh" << 'EOF'
#!/usr/bin/env bash
# Quick start script pro cursor autopilot

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Cursor AI Autopilot - Quick Start"
echo "===================================="
echo ""
echo "Dostupné režimy:"
echo "1. 🔄 Hlavní refaktoring (15 kroků, 5 fází)"
echo "2. ⚡ Rychlý vývoj (krátké intervaly)"  
echo "3. 🐛 Debug režim (troubleshooting)"
echo "4. 🧪 Test režim (QA & testing)"
echo ""

read -p "Vyber režim (1-4): " choice

case $choice in
    1)
        echo "Spouštím hlavní refaktoringový autopilot..."
        exec "$SCRIPT_DIR/scripts/cursor-autopilot-improved.sh"
        ;;
    2)
        echo "Spouštím rychlý vývoj režim..."
        exec "$SCRIPT_DIR/scripts/cursor-quick-mode.sh"
        ;;
    3)
        echo "Spouštím debug režim..."
        exec "$SCRIPT_DIR/scripts/cursor-debug-mode.sh"
        ;;
    4)
        echo "Spouštím test režim..."
        exec "$SCRIPT_DIR/scripts/cursor-test-mode.sh"
        ;;
    *)
        echo "❌ Neplatná volba"
        exit 1
        ;;
esac
EOF
    
    chmod +x "$PROJECT_ROOT/start-cursor-autopilot.sh"
    print_status "Vytvořen quick start script"
}

# Hlavní funkce
main() {
    echo "🔧 Setup Cursor AI Autopilot"
    echo "============================="
    echo ""
    
    check_dependencies
    create_todo_files
    set_permissions
    check_cursor_setup
    create_quick_start
    
    echo ""
    print_status "Setup dokončen!"
    echo ""
    print_info "Nyní můžeš spustit:"
    echo "  ./start-cursor-autopilot.sh     # Quick start menu"
    echo "  ./scripts/cursor-autopilot-improved.sh  # Hlavní refaktoring"
    echo ""
    print_warning "Před spuštěním se ujisti, že:"
    echo "  - Cursor editor je otevřený a má focus"
    echo "  - Jsi v správném workspace/projektu"
    echo "  - Máš možnost přerušit skript (Ctrl+C)"
}

main "$@"