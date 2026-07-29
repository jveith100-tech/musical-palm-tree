#!/data/data/com.termux/files/usr/bin/bash
# Musical Palm Tree - Termux Installation Script
# Run this to fully setup the system on your phone

# --- Configuration ---
LOG_FILE="$HOME/.logs/musical-palm-tree/install.log"

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

if ! confirm_action "This script will install various packages and configure your Termux environment. Do you want to proceed with the full installation?"; then
    log_info "Installation aborted by user."
    exit 0
fi

log_info "🚀 Musical Palm Tree - Termux Setup"
log_info "Log file: $LOG_FILE"

# Get the repo directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
log_info "📁 Repository: $REPO_DIR"

# Step 1: Update packages
log_info "📦 Step 1: Updating package manager..."
pkg update -y | tee -a "$LOG_FILE"
pkg upgrade -y | tee -a "$LOG_FILE"

# Step 2: Install system dependencies
log_info "📥 Step 2: Installing system dependencies..."
pkg install -y \
    python \
    python-pip \
    git \
    ffmpeg \
    imagemagick \
    curl \
    wget \
    termux-api \
    neovim \
    nodejs \
    cronie \
    jq | tee -a "$LOG_FILE"

# Step 2.5: Setup Neovim and GitHub Copilot
log_info "📝 Step 2.5: Setting up Neovim and GitHub Copilot..."
if confirm_action "Do you want to setup Neovim with GitHub Copilot?"; then
    log_info "Installing vim-plug for Neovim..."
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' | tee -a "$LOG_FILE"
    
    mkdir -p "$HOME/.config/nvim"
    if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
        log_info "Creating basic init.vim with Copilot..."
        cat << 'EOF' > "$HOME/.config/nvim/init.vim"
call plug#begin()
Plug 'github/copilot.vim'
call plug#end()
EOF
    fi
    
    log_info "Installing Neovim plugins..."
    nvim --headless +PlugInstall +qall | tee -a "$LOG_FILE"
    log_success "Neovim and Copilot setup complete. Run ':Copilot setup' inside nvim to authenticate."
else
    log_info "Skipping Neovim setup."
fi

# Step 2.7: Setup Cron for scheduling
log_info "⏰ Step 2.7: Setting up Cron..."
if confirm_action "Do you want to setup cron for scheduled tasks? (Requires Termux:Boot app for auto-start)"; then
    log_info "Enabling crond..."
    log_warn "⚠️  Cron requires 'crond' to be running. For auto-start on boot, install Termux:Boot app and add 'crond' to a script in ~/.termux/boot/"
    log_success "Cron setup instructions provided."
else
    log_info "Skipping Cron setup."
fi

# Step 3: Create .env if doesn't exist
log_info "⚙️  Step 3: Setting up configuration..."
if [ ! -f "$REPO_DIR/.env" ]; then
    log_info "Creating .env file..."
    cp "$REPO_DIR/.env.example" "$REPO_DIR/.env"
    log_warn "⚠️  Edit .env with your settings: nano $REPO_DIR/.env"
else
    log_info ".env already exists"
fi

# Step 3.5: Task Integration Setup (Placeholder)
log_info "✅ Step 3.5: Checking for task integration setup..."
log_info "Task integration setup currently not implemented in this script."

# Step 3.6: F-Droid and APK Automation Clarity
log_info "📱 Step 3.6: Clarifying F-Droid and APK automation dependencies..."
log_info "This script does not directly manage F-Droid or APK installations."
if command -v fdroid >/dev/null 2>&1; then
    log_success "F-Droid command found."
else
    log_warn "F-Droid command not found."
fi

# Step 4: Install Python dependencies
log_info "🐍 Step 4: Installing Python libraries..."
cd "$REPO_DIR"
pip install --upgrade pip | tee -a "$LOG_FILE"
pip install -r requirements.txt | tee -a "$LOG_FILE"

# Step 5: Create directories
log_info "📁 Step 5: Creating directories..."
mkdir -p "$HOME/.cache/musical-palm-tree"
mkdir -p "$HOME/.logs/musical-palm-tree"
mkdir -p "/sdcard/Movies/musical-palm-tree"

# Step 6: Make scripts executable
log_info "🔧 Step 6: Setting permissions..."
chmod +x "$REPO_DIR/termux/"*.sh
chmod +x "$REPO_DIR/termux/"*.py
chmod +x "$REPO_DIR/setup.sh"

# Step 7: Create convenient symlink
log_info "🔗 Step 7: Creating symlinks..."
ln -sf "$REPO_DIR/termux/webhook_server.py" "$HOME/webhook_server.py"
ln -sf "$REPO_DIR/termux/prompt_handler.py" "$HOME/prompt_handler.py"

# Step 8: Post-install verification
log_info "🔍 Step 8: Running post-install verification..."
VERIFICATION_DIR="$HOME/.logs/musical-palm-tree/verification"
mkdir -p "$VERIFICATION_DIR"
VERIFICATION_TXT="$VERIFICATION_DIR/verification_latest.txt"
VERIFICATION_JSON="$VERIFICATION_DIR/verification_latest.json"

log_info "Saving verification report to $VERIFICATION_TXT and $VERIFICATION_JSON"

VERIFICATION_REPORT="Python version: $(python -V 2>&1)\n"
VERIFICATION_REPORT+="Pip version: $(pip -V 2>&1)\n"
VERIFICATION_REPORT+="Git version: $(git -V 2>&1)\n"
echo -e "$VERIFICATION_REPORT" | tee "$VERIFICATION_TXT"

JSON_REPORT="{\"python_version\": \"$(python -V 2>&1)\", \"pip_version\": \"$(pip -V 2>&1)\"}"
echo "$JSON_REPORT" | jq . > "$VERIFICATION_JSON"

log_success "Post-install verification complete."

log_success "✅ Installation Complete!"
log_info ""
log_info "📖 Quick Start:"
log_info "1. Start the webhook server: python3 $REPO_DIR/termux/webhook_server.py &"
log_info "2. Test the webhook: curl -X POST http://localhost:9000/generate -H 'Content-Type: application/json' -d '{\"prompt\":\"a cat jumping\"}'"
log_success "🎉 Ready to generate videos!"
