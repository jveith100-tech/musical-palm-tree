#!/bin/bash

# Script to create GitHub issues and assign them to Copilot

# --- Configuration ---
REPO_OWNER="$(gh repo view --json owner | jq -r .owner.login)"
REPO_NAME="$(gh repo view --json name | jq -r .name)"

# --- Colors ---
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

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
log_info "Repository: $REPO_OWNER/$REPO_NAME"

# Function to create an issue and assign to Copilot
create_copilot_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    log_info "Creating issue: \"$title\""
    gh issue create --title "$title" --body "$body" --label "$labels" --assignee "copilot" --repo "$REPO_OWNER/$REPO_NAME"
}

# --- Issues to Create ---
create_copilot_issue "Harden unified_setup.sh logging and error handling" "Improve logging, child script output visibility, and failure reporting." "bug,automation"
create_copilot_issue "Add safe noninteractive mode to full Termux setup" "Add flags or env vars for unattended execution." "feature,automation"
create_copilot_issue "Fix GitHub Copilot and Neovim setup dependencies" "Install vim-plug and improve gh-copilot extension handling." "bug,github,copilot"
create_copilot_issue "Improve cron automation setup for Termux" "Verify cronie, crontab, crond startup, and Termux:Boot docs." "bug,cron"
create_copilot_issue "Improve task integration setup visibility and logging" "Ensure task setup prompts remain visible while logging." "feature,tasks"
create_copilot_issue "Add comprehensive post-install verification report" "Save verification output as text and JSON." "feature,verification"
create_copilot_issue "Create complete setup and recovery documentation" "Add setup, recovery, troubleshooting, and quick-reference docs." "feature,documentation"
create_copilot_issue "Clarify F-Droid and APK automation dependencies" "Fix misleading F-Droid dependency check and messages." "bug,fdroid"
create_copilot_issue "Add safety checks before full automation run" "Require explicit confirmation before broad setup actions." "bug,security"
create_copilot_issue "Add script to create GitHub issues and assign them to Copilot" "Create helper script for launching Copilot issue work." "feature,github,copilot"

log_success "All Copilot issues created successfully!"
