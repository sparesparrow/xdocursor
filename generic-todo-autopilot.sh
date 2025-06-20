#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
#
# Generic TODO Autopilot for Cursor AI
#
# Description:
#   This script automates the entire development lifecycle for tasks listed
#   in a TODO.md file. It instructs the Cursor AI agent to implement a task,
#   build, test, fix bugs, and commit the changes. The script then handles
#   pushing to Git and updating the TODO list.
#
# Author:
#   [Your Name/Alias] - Based on concepts by sparesparrow
#
# Repository:
#   https://github.com/sparesparrow/xdocursor
#
# Usage:
#   1. Configure the variables in the _config section below.
#   2. Ensure your project has a TODO.md with tasks like "- [ ] My new feature".
#   3. Open the Cursor editor.
#   4. Run the script: ./generic-todo-autopilot.sh
#
# -----------------------------------------------------------------------------

# --- UTILITY FUNCTIONS ---

# Centralized logging with timestamps
log_info() {
    echo -e "\n[$(date +'%H:%M:%S')] \e[34mINFO\e[0m: $1"
}

log_success() {
    echo -e "[$(date +'%H:%M:%S')] \e[32mSUCCESS\e[0m: $1"
}

log_warn() {
    echo -e "[$(date +'%H:%M:%S')] \e[33mWARN\e[0m: $1"
}

log_error() {
    echo -e "[$(date +'%H:%M:%S')] \e[31mERROR\e[0m: $1" >&2
}

# --- CONFIGURATION (EDIT THIS SECTION FOR YOUR PROJECT) ---

# -- Window & Input Settings --
# Part of the window title or class to identify Cursor. Use `wmctrl -lx` to find it.
WINDOW_ID_QUERY="Cursor"
# X and Y coordinates of the Cursor chat input field.
# Use `xdotool getmouselocation --shell` to find these.
# Tip: Using relative coordinates with `--window` is more robust if you can identify the window ID.
CLICK_X=850
CLICK_Y=1350

# -- Project & File Settings --
# The file containing your tasks.
TODO_FILE="TODO.md"
# Name of the project, used in prompts.
PROJECT_NAME="My Awesome Project"

# -- Build & Test Commands --
# How to build/compile your project. Leave empty if not needed.
BUILD_COMMAND="npm run build"
# How to run tests for your project.
TEST_COMMAND="npm test"

# -- Git Settings --
# The remote repository to push to.
GIT_REMOTE="origin"
# The branch to push to.
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD) # Auto-detects current branch

# -- Timing Settings (in seconds) --
# An associative array mapping prompt type to delay time.
declare -A PROMPT_DELAYS=(
    ["implement"]=600  # 10 minutes for implementation
    ["build"]=120      # 2 minutes for build
    ["test_and_fix"]=480 # 8 minutes for testing and fixing
    ["commit"]=180     # 3 minutes for git commit
    ["update_todo"]=60 # 1 minute for updating TODO
)

# --- SCRIPT CORE ---

# Check for required dependencies
check_dependencies() {
    local missing=0
    for cmd in xdotool wmctrl xclip git; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command '$cmd' is not installed."
            missing=1
        fi
    done
    [[ $missing -eq 1 ]] && exit 1
}

# Focuses the Cursor window and clicks the chat input
focus_and_prepare_chat() {
    log_info "Attempting to focus Cursor window matching '$WINDOW_ID_QUERY'..."
    local win_id
    win_id=$(wmctrl -lx | grep -i "$WINDOW_ID_QUERY" | awk '{print $1}' | head -n 1)

    if [[ -z "$win_id" ]]; then
        log_error "Could not find a window matching '$WINDOW_ID_QUERY'. Is Cursor running?"
        exit 1
    fi

    wmctrl -ia "$win_id"
    sleep 0.5 # Give the window manager time to react
    xdotool mousemove "$CLICK_X" "$CLICK_Y" click 1
    sleep 0.2
    log_success "Cursor window focused and chat input clicked."
}

# Sends a prompt to Cursor with an interactive wait
# Usage: send_prompt "Your prompt here" <delay_type>
send_prompt() {
    local prompt_text="$1"
    local delay_key="$2"
    local delay_seconds=${PROMPT_DELAYS[$delay_key]}

    focus_and_prepare_chat

    # Backup and set clipboard
    local old_clipboard
    old_clipboard=$(xclip -o -selection clipboard 2>/dev/null || echo '')
    printf '%s' "$prompt_text" | xclip -i -selection clipboard

    # Paste and send
    xdotool key --clearmodifiers "ctrl+shift+v"
    xdotool key Return
    sleep 0.5
    # Restore clipboard
    printf '%s' "$old_clipboard" | xclip -i -selection clipboard

    log_info "Prompt sent. Waiting for $delay_seconds seconds. Press [Enter] to shorten."

    # Interactive wait
    if read -t "$delay_seconds" -s -n 1 key; then
        if [[ -z "$key" ]]; then # Enter key pressed
            log_warn "Wait skipped by user! Waiting for 5 seconds instead."
            sleep 5
        fi
    fi
}

# Retrieves the first unfinished task from the TODO file
get_next_task() {
    grep -m 1 -- '- \[ \]' "$TODO_FILE" | sed -e 's/- \[ \] //g'
}

# Marks a task as completed in the TODO file
mark_task_as_done() {
    local task_text="$1"
    # Use sed to replace the task line. Using a different delimiter to avoid issues with slashes.
    sed -i "s|- \[ \] $task_text|- [x] $task_text|" "$TODO_FILE"
    log_success "Marked task as done in $TODO_FILE: $task_text"
}

# --- MAIN WORKFLOW ---
main() {
    check_dependencies
    log_info "Starting Generic TODO Autopilot for project: $PROJECT_NAME"
    log_info "Branch: $GIT_BRANCH | Remote: $GIT_REMOTE"
    log_info "To stop, press Ctrl+C in this terminal."
    sleep 3

    local cycle_count=1
    while true; do
        local task
        task=$(get_next_task)

        if [[ -z "$task" ]]; then
            log_success "All tasks in $TODO_FILE are completed. Autopilot finished."
            break
        fi

        log_info "--- Cycle #$cycle_count | Starting new task ---"
        log_info "TASK: $task"

        # 1. Implementation
        local implement_prompt="I am working on the '$PROJECT_NAME' project. Please implement the following task from my @$TODO_FILE file: \"$task\". Make sure your implementation is robust and follows best practices."
        send_prompt "$implement_prompt" "implement"

        # 2. Build (if command is set)
        if [[ -n "$BUILD_COMMAND" ]]; then
            local build_prompt="Now that the implementation should be done, please run the build command to check for any compilation errors. The command is: \`$BUILD_COMMAND\`"
            send_prompt "$build_prompt" "build"
        fi

        # 3. Test & Fix
        local test_prompt="The build seems okay. Now, run the test suite to verify the changes. The command is: \`$TEST_COMMAND\`. IMPORTANT: Analyze the test output. If any tests fail, please fix the underlying code and re-run the tests until they all pass. Describe the fixes you made."
        send_prompt "$test_prompt" "test_and_fix"

        # 4. Commit
        local commit_prompt="All tests are passing. Excellent! Now, please stage all the relevant changes and commit them. Use the conventional commit standard to write a clear and descriptive commit message for the task: \"$task\"."
        send_prompt "$commit_prompt" "commit"

        # 5. Git Push (handled by the script for safety)
        log_info "AI was instructed to commit. Now pushing to remote..."
        if git push "$GIT_REMOTE" "$GIT_BRANCH"; then
            log_success "Successfully pushed changes to $GIT_REMOTE/$GIT_BRANCH."
        else
            log_error "Failed to push changes. Please check git output and repository status."
            # Decide if to continue or stop. For now, we'll stop.
            exit 1
        fi

        # 6. Mark Task as Done (handled by the script for reliability)
        mark_task_as_done "$task"

        ((cycle_count++))
        log_info "Task cycle complete. Looking for the next task..."
        sleep 10 # Short pause between tasks
    done
}

# Run the main function
main


