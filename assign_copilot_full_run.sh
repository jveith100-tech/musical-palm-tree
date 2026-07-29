#!/bin/bash

# Script to create GitHub issues and assign them to Copilot

# --- Configuration ---
REPO="jveith100-tech/musical-palm-tree"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Logging Functions ---
LOG_FILE="$HOME/.logs/musical-palm-tree/copilot_issue_creation.log"
mkdir -p "$(dirname "$LOG_FILE")"

log_info()    { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }

# --- Error Handling ---
error_handler() {
    local last_command="$BASH_COMMAND"
    local last_line="$BASH_LINENO"
    log_error "Script failed at line $last_line: $last_command"
    exit 1
}
trap 'error_handler' ERR

log_info "🚀 Starting GitHub Issue Creation for Copilot..."
log_info "Repository: $REPO"

# Function to create an issue and assign to Copilot
create_copilot_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    log_info "Creating issue: \"$title\""
    # Use only existing labels or no labels if they don't exist
    gh issue create --title "$title" --body "$body" --label "$labels" --assignee "copilot" --repo "$REPO"
}

# --- Issues to Create ---
create_copilot_issue "Harden unified_setup.sh logging and error handling" "Improve logging, child script output visibility, and failure reporting." "bug"
create_copilot_issue "Add safe noninteractive mode to full Termux setup" "Add flags or env vars for unattended execution." "enhancement"
create_copilot_issue "Fix GitHub Copilot and Neovim setup dependencies" "Install vim-plug and improve gh-copilot extension handling." "bug"
create_copilot_issue "Improve cron automation setup for Termux" "Verify cronie, crontab, crond startup, and Termux:Boot docs." "bug"
create_copilot_issue "Improve task integration setup visibility and logging" "Ensure task setup prompts remain visible while logging." "enhancement"
create_copilot_issue "Add comprehensive post-install verification report" "Save verification output as text and JSON." "enhancement"
create_copilot_issue "Create complete setup and recovery documentation" "Add setup, recovery, troubleshooting, and quick-reference docs." "documentation"
create_copilot_issue "Clarify F-Droid and APK automation dependencies" "Fix misleading F-Droid dependency check and messages." "bug"
create_copilot_issue "Add safety checks before full automation run" "Require explicit confirmation before broad setup actions." "bug"
create_copilot_issue "Add script to create GitHub issues and assign them to Copilot" "Create helper script for launching Copilot issue work." "enhancement"

log_success "All Copilot issues created successfully!"
