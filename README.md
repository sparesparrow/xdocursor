# Cursor AI Autopilot Scripts
#### License: MIT

A collection of smart Bash scripts to automate and "autopilot" the Cursor AI code editor using xdotool, enabling hands-free development, overnight refactoring, and advanced human-AI collaboration.
These scripts were born from the need to automate large-scale refactoring of the MCP Prompts Server project. Instead of manually typing hundreds of prompts, this toolkit lets you define intelligent workflows and let the AI agent do the heavy lifting while you sleep or focus on other tasks.
🎯 Core Philosophy & Use Cases
This project is built on a simple yet powerful idea: Your AI assistant shouldn't wait for you; it should work for you. By simulating user input, we achieve a platform-agnostic way to drive the AI, opening up new possibilities:
 * 🤖 Overnight Worker: Launch a script before you go to bed and wake up to a refactored codebase, generated documentation, or a suite of new unit tests.
 * ♿ Accessibility Boost: Provide powerful automation for developers who may have difficulty with continuous keyboard and mouse use.
 * 🧪 Prompt Engineering Research: Systematically test how different prompt strategies and sequences ("chains") affect the AI's performance and output quality.
 * ⚡ Parallel Workflows: While you work on a new feature, let the autopilot handle repetitive tasks like clearing tech debt or improving code style in the background.
 * 📚 Learning by Watching: Observe how an AI agent approaches complex problems, providing a unique learning experience.
📁 Script Arsenal
The repository contains several "modes" tailored for different tasks, from slow-and-steady refactoring to rapid-fire debugging.
🚀 cursor-autopilot.sh - The Marathon Runner
The main script, designed for long, complex, multi-step tasks. It operates on a sequence of prompts defined in a workflow file.
 * Key Features:
   * Follows a structured workflow from a PROMPTS array.
   * Intelligent, long delays (e.g., 5-10 minutes) to give the AI ample time for complex generation.
   * Progress indicators and cycle tracking.
   * Graceful interrupt handling.
⚡ cursor-quick-fire.sh - The Sprinter
For when you are actively developing and need the AI to perform a series of short, quick actions.
 * Key Features:
   * Uses a list of generic, iterative prompts ("proceed", "continue", "fix this").
   * Very short delays (e.g., 30-60 seconds).
   * Ideal for fine-tuning, bug fixing, or when the AI is "in the zone."
🐛 cursor-debug-mode.sh - The Detective
A specialized script for troubleshooting. It systematically checks different aspects of your code.
 * Key Features:
   * Prompts focused on finding errors, running tests, and checking configurations (@package.json, @tsconfig.json).
   * Medium delays (e.g., 2-3 minutes) for analysis.
   * Can be configured to focus on specific file types (TypeScript, Docker, CI).
🔧 Installation & Setup
Designed for Linux systems running on X11. Wayland is not supported by xdotool.
1. System Dependencies
# For Debian/Ubuntu
sudo apt update
sudo apt install xdotool wmctrl xclip

# For Fedora/RHEL
sudo dnf install xdotool wmctrl xclip

# For Arch Linux
sudo pacman -S xdotool wmctrl xclip

2. Configuration
All scripts are configured via variables at the top of the file. The most important step is to find the chat input coordinates.
 * Open Cursor and focus the chat input field.
 * Run this command in your terminal and move your mouse over the input field:
   xdotool getmouselocation --shell

 * Note the X and Y values and update the script variables:
# --- User Configuration ---
# Window identifier (use 'wmctrl -lx' to find yours)
WINDOW_ID_QUERY="Cursor" 

# Coordinates for the AI chat input field
CLICK_X=850
CLICK_Y=1350

# Default delay between prompts (in seconds)
DEFAULT_DELAY=300 

3. Creating a Prompt File
Create a file named prompt_workflow.txt. Each line represents one prompt to be executed sequentially.
Example prompt_workflow.txt:
First, analyze the entire project structure and create a summary.
@TODO-workspace-setup.mdc Implement the workspace initialization based on the markdown file.
Refactor the database module to use the new connection pool.
Now, write unit tests for the refactored database module.
Verify that all tests are passing.
Finally, generate documentation for the new module.

4. Running a Script
 * Make the scripts executable:
   chmod +x *.sh

 * Open Cursor.
 * Run the desired autopilot script from your terminal:
   ./cursor-autopilot.sh ./prompt_workflow.txt

The script will now take over, focusing the Cursor window and executing your prompts. You can press Enter in the terminal running the script to shorten the current wait time to 5 seconds. To stop, press Ctrl+C.
🧠 Smart Prompting Strategies (The "Lifehacks")
The true power of this system comes from creative prompt design. Go beyond simple commands.
 * Stateful Prompts: Create different workflow files (refactor.txt, test.txt, docs.txt) and run the autopilot against them based on your current goal.
 * Conditional Logic (External): Wrap the script in another bash script that performs checks.
   # pseudo-code
if git status --porcelain | grep .; then
  ./cursor-autopilot.sh "You have uncommitted changes. Please review them."
fi

 * Chain of Thought: Structure your workflow file to mimic a logical thought process, breaking down large tasks into smaller, dependent steps.
 * Self-Correction Loops:
   Write tests for the login feature.
Run the tests.
If there are any failing tests, analyze the errors and fix the code. Please describe the fix.
Run the tests again to confirm the fix.

🏗️ Script Architecture & Safety
 * Window Focusing: Uses wmctrl and xdotool to reliably find and focus the Cursor window before each action, preventing it from typing into the wrong application.
 * Clipboard Safety: The original clipboard content is backed up before use and restored immediately after, so you don't lose what you were working on.
 * Robust Error Handling: Uses set -euo pipefail to exit cleanly on errors.
 * Interactive Override: The read -t command provides a non-blocking wait that can be interrupted by the user, giving you full control to speed things up.
🤝 How to Contribute
Contributions are welcome! Here are some ideas:
 * Wayland Support: Create a version of the scripts using ydotool or wtype.
 * New Autopilot Modes: Have an idea for a specialized workflow? Create a new script (e.g., cursor-security-audit.sh).
 * Smarter Idling: Implement a mechanism to detect if the AI is still "thinking" (e.g., by watching for CPU usage or UI changes) instead of using a fixed sleep.
 * More Advanced Prompt Strategies: Share your most effective prompt workflows and strategies.
📄 License
This project is licensed under the MIT License. See the LICENSE file for details.
> ⚠️ Warning: These scripts take control of your mouse and keyboard. Run them with caution. Always be prepared to terminate the script with Ctrl+C in the terminal. It is recommended to run them in a controlled environment.
> 
