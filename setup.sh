#!/bin/bash
# One-Click Setup for Phone AI Automation + Video Generator
# Run this in Termux: bash setup.sh

# --- Configuration ---
LOG_FILE="/home/ubuntu/.logs/musical-palm-tree/setup.log"

# --- Colors ---
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m # No Color

# --- Logging Functions ---
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

# --- Non-interactive Mode Check ---
NONINTERACTIVE=${NONINTERACTIVE:-0}

confirm_action() {
    if [ "$NONINTERACTIVE" -eq 1 ]; then
        log_info "Non-interactive mode: Auto-confirming action."
        return 0
    fi
    read -r -p "${YELLOW}$1 (y/N)? ${NC}" response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *) 
            return 1
            ;;
    esac
}

if ! confirm_action "This script will install various packages and configure your environment. Do you want to proceed?"; then
    log_info "Setup aborted by user."
    exit 0
fi

log_info "🚀 Starting Phone AI Automation System Setup..."
log_info "Log file: $LOG_FILE"

# Update package manager
log_info "📦 Updating packages..."
pkg update -y | tee -a "$LOG_FILE"
pkg upgrade -y | tee -a "$LOG_FILE"

# Install system dependencies
log_info "📥 Installing system dependencies..."
pkg install -y python python-pip git ffmpeg imagemagick | tee -a "$LOG_FILE"

# Install Python dependencies
log_info "🐍 Installing Python libraries..."
pip install --upgrade pip | tee -a "$LOG_FILE"
pip install -r requirements.txt | tee -a "$LOG_FILE"

# Install termux-api (for phone control)
log_info "📱 Setting up termux-api..."
pkg install -y termux-api | tee -a "$LOG_FILE"

# Create directories
log_info "📁 Creating directories..."
mkdir -p output videos frames audio

log_success "✅ Installation complete!"
log_info ""
log_info "📖 Quick Start:"
log_info "   1. Run: python video_generator.py --help"
log_info "   2. Run: python phone_automation.py --help"
log_info ""
log_info "🎬 Generate a video:"
log_info "   python video_generator.py --prompt 'A cat jumping' --output output/video.mp4"
log_info ""
log_info "📱 Automate your phone:"
log_info "   python phone_automation.py --tap 500 500"
log_info ""
