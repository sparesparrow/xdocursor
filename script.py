# Analyzuji současný bash skript a identifikuji problémy
script_content = """
#!/usr/bin/env bash

set -euo pipefail

# ----- Nastavitelné prompty a defaultní prodlevy ---------------------------

declare -a RULES_PROMPTS=(
"@TODO-workspace-setup.mdc proceed"
"@TODO-catalog-extraction.mdc proceed"
"@TODO-contracts-creation.mdc proceed"
"@TODO-pipeline-automation.mdc proceed"
"@TODO-docs-update.mdc proceed"

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
"""

# Analyzuji problémy
problems = []

# 1. Syntaktické chyby
if "declare -a RULES_PROMPTS=(" in script_content and ")" not in script_content.split("declare -a RULES_PROMPTS=(")[1].split("declare -a PROMPTS=(")[0]:
    problems.append("❌ RULES_PROMPTS array není správně ukončen - chybí uzavírací ')'")

# 2. Opakování v PROMPTS
prompts_section = script_content.split('declare -a PROMPTS=(')[1].split(')')[0]
prompt_lines = [line.strip().strip('"') for line in prompts_section.split('\n') if line.strip() and line.strip() != '"']

# Spočítám duplicity pro každý TODO soubor
todo_files = ['TODO-catalog-extraction.mdc', 'TODO-contracts-creation.mdc', 'TODO-pipeline-automation.mdc', 'TODO-docs-update.mdc']
for todo_file in todo_files:
    count = sum(1 for prompt in prompt_lines if todo_file in prompt)
    if count > 1:
        problems.append(f"⚠️  {todo_file} se opakuje {count}x v PROMPTS array")

# 3. Konzistence názvů
if "workspace-setup" not in prompts_section:
    problems.append("⚠️  workspace-setup fáze chybí v PROMPTS array, ale je v RULES_PROMPTS")

print("🔍 ANALÝZA SOUČASNÉHO SKRIPTU:")
print("=" * 50)
for i, problem in enumerate(problems, 1):
    print(f"{i}. {problem}")

print(f"\n📊 STATISTIKY:")
print(f"• Celkem promptů v PROMPTS array: {len(prompt_lines)}")
print(f"• TODO soubory pokryté: {len(todo_files)}")
print(f"• Průměrný počet promptů na TODO: {len(prompt_lines)/len(todo_files):.1f}")