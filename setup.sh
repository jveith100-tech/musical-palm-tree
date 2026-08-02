#!/bin/bash
# One-Click Setup for Phone AI Automation + Video Generator
# Run this in Termux: bash setup.sh

# --- Configuration ---
# Use $HOME instead of hardcoded path for better portability
LOG_FILE="$HOME/.logs/musical-palm-tree/setup.log"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Helper function for cross-platform package installation
install_packages() {
    if command -v pkg &> /dev/null; then
        # Termux environment
        pkg update -y | tee -a "$LOG_FILE"
        pkg upgrade -y | tee -a "$LOG_FILE"
        pkg install -y "$@" | tee -a "$LOG_FILE"
    elif command -v apt-get &> /dev/null; then
        # Debian/Ubuntu environment
        sudo apt-get update -y | tee -a "$LOG_FILE"
        sudo apt-get install -y "$@" | tee -a "$LOG_FILE"
    else
        log_error "Unsupported package manager. Please install dependencies manually: $@"
        return 1
    fi
}

# Step 1 & 2: Update and Install system dependencies
log_info "📦 Installing system dependencies..."
install_packages python3 python3-pip git ffmpeg imagemagick

# Step 3: Install Python dependencies
log_info "🐍 Installing Python libraries..."
python3 -m pip install --upgrade pip | tee -a "$LOG_FILE"
if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt | tee -a "$LOG_FILE"
else
    log_warn "requirements.txt not found, skipping python dependencies."
fi

# Step 4: Install termux-api (only if in Termux)
if command -v pkg &> /dev/null; then
    log_info "📱 Setting up termux-api..."
    pkg install -y termux-api | tee -a "$LOG_FILE"
fi


# Create directories
log_info "📁 Creating directories..."
mkdir -p output videos frames audio
if command -v pkg &> /dev/null; then
    # Only try creating /sdcard directories in Termux
    mkdir -p "/sdcard/Movies/musical-palm-tree" || log_warn "Could not create /sdcard directory. Ensure storage permissions are granted."
fi

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
