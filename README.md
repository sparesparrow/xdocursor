# Cursor AI Autopilot Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)

> **Automatizované skripty pro řízení Cursor AI agenta při refaktoringu a vývoji MCP Prompts projektu**

Kolekce bash skriptů, které automatizují interakci s Cursor AI editorem pomocí xdotool a xclip. Umožňují hands-free vývoj s možností manuálního zásahu a zrychlení procesů.

## 🎯 Účel a Motivace

Tyto skripty byly vytvořeny pro automatizaci komplexního refaktoringu [MCP Prompts Server](https://github.com/sparesparrow/mcp-prompts) projektu. Místo manuálního zadávání stovek promptů do Cursor AI editoru tyto skripty:

- ⚡ **Automatizují opakující se prompty** - žádné více copy-paste
- 🔄 **Následují logickou posloupnost** - strukturovaný workflow 
- ⏱️ **Respektují časování** - dávají AI agentovi dostatek času na práci
- 🎛️ **Umožňují interaktivní zásah** - můžete zrychlit nebo přeskočit kroky
- 📊 **Sledují pokrok** - vizuální indikace postupu refaktoringu

## 📁 Struktura Skriptů

### 🚀 `cursor-autopilot-improved.sh` - Hlavní Refaktoringový Skript

**Účel**: Komplexní automatizace refaktoringu MCP Prompts na monorepo architekturu

**Klíčové vlastnosti**:
- 15 strukturovaných kroků rozdělených do 5 fází
- Každá fáze má: **start** → **continue** → **finalize** 
- Inteligentní časování: 5 min pro start, 3 min pro continue, 4 min pro finalize
- Referenční TODO.mdc soubory pro přesné instrukce
- Progress indikátor a cycle tracking

**Konfigurace PROMPTS**:
```bash
# Strukturované prompty pro každou fázi
declare -A PHASE_PROMPTS=(
    ["workspace-setup-start"]="@TODO-workspace-setup.mdc implement workspace initialization..."
    ["catalog-extraction-start"]="@TODO-catalog-extraction.mdc implement prompt catalog separation..."
    # ... další fáze
)

# Sekvenční workflow
declare -a WORKFLOW_SEQUENCE=(
    "workspace-setup-start"
    "workspace-setup-continue" 
    "workspace-setup-finalize"
    # ... pokračuje dalšími fázemi
)
```

### ⚡ `cursor-quick-mode.sh` - Rychlý Iterativní Vývoj

**Účel**: Rychlé iterace s krátkými intervaly pro aktivní development

**Klíčové vlastnosti**:
- 8 obecných promptů pro pokračování práce
- Krátké 30s intervaly mezi kroky
- 3-sekundové odpočítávání (vs. 5s u hlavního skriptu)
- Ideální pro fine-tuning a bug fixing

**Použití**:
- Když potřebujete rychle iterovat na konkrétní problém
- Pro testování drobných změn
- Když je AI agent "v flow" a nepotřebuje dlouhé pauzy

### 🐛 `cursor-debug-mode.sh` - Debugging a Troubleshooting

**Účel**: Specializované řešení problémů, testování a opravy

**Klíčové vlastnosti**:
- Dva typy promptů: obecné debugging + file-focused kontroly
- 2-minutové intervaly pro důkladnou analýzu
- Zaměřuje se na TypeScript, testy, Docker, CI/CD
- Systematická kontrola konfiguračních souborů

**Debugging Workflow**:
1. **Fáze 1**: Obecná analýza problémů (errors, tests, compilation)
2. **Fáze 2**: Kontrola specifických souborů (`@package.json`, `@tsconfig.json`, etc.)

### 🧪 `cursor-test-mode.sh` - Komprehensivní Testování

**Účel**: Quality assurance a kompletní testovací workflow

**Klíčové vlastnosti**:
- Tři fáze testování: Základní → Specifické → Quality Gates
- 1.5 minutové intervaly (rychlejší než debugging)
- Pokrývá unit testy, integraci, E2E, security, coverage
- Automatické postupné zpřísňování kontrol

**Test Workflow**:
1. **Základní testy**: Unit, integration, TypeScript, linting
2. **Specifické testy**: Jest config, test scripts, Docker
3. **Quality Gates**: Coverage, security, dokumentace

## 🔧 Instalace a Příprava

### Systémové Požadavky

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install xdotool xclip

# Fedora/RHEL
sudo dnf install xdotool xclip

# Arch Linux  
sudo pacman -S xdotool xclip
```

### Příprava Projektové Struktury

Všechny skripty očekávají tyto TODO soubory v root projektu:

```
mcp-prompts/
├── TODO-workspace-setup.mdc
├── TODO-catalog-extraction.mdc  
├── TODO-contracts-creation.mdc
├── TODO-pipeline-automation.mdc
├── TODO-docs-update.mdc
└── scripts/
    ├── cursor-autopilot-improved.sh
    ├── cursor-quick-mode.sh
    ├── cursor-debug-mode.sh
    └── cursor-test-mode.sh
```

### Spuštění Skriptů

```bash
# Přidej execute práva
chmod +x scripts/*.sh

# Spusť hlavní refaktoringový skript
./scripts/cursor-autopilot-improved.sh

# Rychlý vývoj
./scripts/cursor-quick-mode.sh

# Debugging problémů
./scripts/cursor-debug-mode.sh

# Testování a QA
./scripts/cursor-test-mode.sh
```

## 🎮 Ovládání během Běhu

### Základní Ovládání

- **Enter**: Zkrátí aktuální čekání na 5 sekund
- **Ctrl+C**: Ukončí skript
- **🔊 Zvukové signály**: Systémové pípnutí před každým prompt

### Interaktivní Funkce

Všechny skripty podporují:

```bash
# Během čekání
🛌 Čekám 180 s (Enter = zkrátit na 5 s)...
⏱️  Zbývá 150 sekund...

# Po stisku Enter
↩️  Enter zachycen – zkracuji čekání na 5 s!
⚡ Zrychleno!
```

### Vizuální Feedback

```bash
📊 Pokrok: 3/15 kroků (20%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 Cyklus #1 - 14:30:22
📋 Krok: workspace-setup-start
💬 Prompt: @TODO-workspace-setup.mdc implement workspace initialization...
```

## 🏗️ Architektura Skriptů

### Společné Komponenty

Všechny skripty sdílejí tyto utility funkce:

```bash
# Bezpečné vložení přes clipboard
paste_via_clipboard() {
    local text="$1"
    local old_clipboard="$(xclip -o -selection clipboard 2>/dev/null || echo '')"
    printf '%s' "$text" | xclip -selection clipboard
    xdotool key --clearmodifiers 'ctrl+shift+v'
    xdotool key Return
    sleep 0.5
    printf '%s' "$old_clipboard" | xclip -selection clipboard
}

# Interaktivní čekání s možností zrychlení  
wait_with_acceleration() {
    local total_seconds=$1
    local remaining=$total_seconds
    while (( remaining > 0 )); do
        if read -r -s -n 1 -t 1 key 2>/dev/null; then
            if [[ -z "$key" ]]; then
                echo -e "\n⚡ Enter zachycen - zkracuji čekání!"
                remaining=5
            fi
        fi
        ((remaining--))
    done
}
```

### Bezpečnostní Opatření

- **Backup clipboard**: Automatické obnovení původního obsahu schránky
- **Error handling**: `set -euo pipefail` pro robustní chování
- **Dependency checking**: Kontrola xdotool a xclip před spuštěním
- **Clear modifiers**: Vyčištění klávesových modifikátorů před akcemi

## 📊 Časování a Performance

### Doporučené Intervaly

| Typ Operace | Interval | Důvod |
|-------------|----------|--------|
| **Initialization** (start) | 5 min | Složité setup operace |
| **Implementation** (continue) | 3 min | Standardní kódování | 
| **Finalization** | 4 min | Testování + dokumentace |
| **Quick iterations** | 30 s | Rychlé úpravy |
| **Debugging** | 2 min | Analýza problémů |
| **Testing** | 1.5 min | Test execution + fixes |

### Optimalizace Workflow

- **Cycle pauzy**: 1-5 minut mezi cykly podle komplexity
- **Progress tracking**: Vizuální indikátory pokroku
- **Adaptive timing**: Různé intervaly podle typu úkolu
- **Human override**: Možnost zrychlení kdykoliv

## 🔍 Troubleshooting

### Časté Problémy

**Problem**: Skript nereaguje na Enter
```bash
# Řešení: Zkontroluj terminál focus
xdotool getactivewindow getwindowname
# Přepni na správný terminál před spuštěním
```

**Problem**: xdotool píše do špatného okna
```bash
# Řešení: Ujisti se, že Cursor má focus při spuštění
# Případně přidej delay před první akcí
sleep 5  # dá čas na přepnutí oken
```

**Problem**: Clipboard se neobnovuje
```bash
# Řešení: Zkontroluj xclip permissions
xclip -o -selection clipboard  # test read
echo "test" | xclip -selection clipboard  # test write
```

### Debug Režim

Pro debugging přidej do skriptů:

```bash
set -x  # zapne verbose output
# nebo
echo "DEBUG: Sending prompt: $prompt" >&2
```

## 🤝 Přispívání

### Přidání Nového Skriptu

1. **Vytvoř nový .sh soubor** podle konvence `cursor-{purpose}-mode.sh`
2. **Použij společné utility funkce** (paste_clipboard, wait_with_acceleration)
3. **Definuj PROMPTS array** s logickou posloupností
4. **Přidej do README** s popisem účelu a použití

### Úprava Postojíčích Skriptů

**Úprava promptů**:
```bash
# Edituj příslušný PROMPTS nebo PHASE_PROMPTS array
declare -a QUICK_PROMPTS=(
    "váš nový prompt zde"
    # ... existující prompty
)
```

**Úprava časování**:
```bash
# Změň delay konstanty
QUICK_DELAY=45  # zvýšit z 30 na 45 sekund
```

## 📄 Licence

MIT License - viz [LICENSE](LICENSE) soubor.

## 🙏 Poděkování

Vytvořeno pro automatizaci refaktoringu [MCP Prompts Server](https://github.com/sparesparrow/mcp-prompts) projektu. Inspirováno potřebou efektivní spolupráce s AI agenty při velkých refaktoringových projektech.

---

**⚠️ Upozornění**: Tyto skripty přebírají kontrolu nad klávesnicí a myší. Spouštějte pouze v izolovaném prostředí a ujistěte se, že máte možnost přerušit provádění (Ctrl+C).