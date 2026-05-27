#!/data/data/com.termux/files/usr/bin/bash

# Musical Palm Tree - Termux Installation Script
# Run this to fully setup the system on your phone

echo "🚀 Musical Palm Tree - Termux Setup"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the repo directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
echo -e "${GREEN}📁 Repository: $REPO_DIR${NC}"
echo ""

# Step 1: Update packages
echo -e "${YELLOW}📦 Step 1: Updating package manager...${NC}"
pkg update -y
pkg upgrade -y

# Step 2: Install system dependencies
echo -e "${YELLOW}📥 Step 2: Installing system dependencies...${NC}"
pkg install -y \
    python \
    python-pip \
    git \
    ffmpeg \
    imagemagick \
    curl \
    wget \
    termux-api

# Step 3: Create .env if doesn't exist
echo -e "${YELLOW}⚙️  Step 3: Setting up configuration...${NC}"
if [ ! -f "$REPO_DIR/.env" ]; then
    echo -e "${GREEN}Creating .env file...${NC}"
    cp "$REPO_DIR/.env.example" "$REPO_DIR/.env"
    echo -e "${YELLOW}⚠️  Edit .env with your settings: nano $REPO_DIR/.env${NC}"
else
    echo -e "${GREEN}.env already exists${NC}"
fi

# Step 4: Install Python dependencies
echo -e "${YELLOW}🐍 Step 4: Installing Python libraries...${NC}"
cd "$REPO_DIR"
pip install --upgrade pip
pip install -r requirements.txt

# Step 5: Create directories
echo -e "${YELLOW}📁 Step 5: Creating directories...${NC}"
mkdir -p "$HOME/.cache/musical-palm-tree"
mkdir -p "$HOME/.logs/musical-palm-tree"
mkdir -p "/sdcard/Movies/musical-palm-tree"

# Step 6: Make scripts executable
echo -e "${YELLOW}🔧 Step 6: Setting permissions...${NC}"
chmod +x "$REPO_DIR/termux/"*.sh
chmod +x "$REPO_DIR/termux/"*.py
chmod +x "$REPO_DIR/setup.sh"

# Step 7: Create convenient symlink
echo -e "${YELLOW}🔗 Step 7: Creating symlinks...${NC}"
ln -sf "$REPO_DIR/termux/webhook_server.py" "$HOME/webhook_server.py"
ln -sf "$REPO_DIR/termux/prompt_handler.py" "$HOME/prompt_handler.py"

echo ""
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo ""
echo "📖 Quick Start:"
echo ""
echo "1. Start the webhook server (runs in background):"
echo -e "   ${YELLOW}python3 $REPO_DIR/termux/webhook_server.py &${NC}"
echo ""
echo "2. Test the webhook:"
echo -e "   ${YELLOW}curl -X POST http://localhost:9000/generate -H 'Content-Type: application/json' -d '{\"prompt\":\"a cat jumping\"}'${NC}"
echo ""
echo "3. Or use prompt handler directly:"
echo -e "   ${YELLOW}python3 $REPO_DIR/termux/prompt_handler.py --prompt 'a cat jumping'${NC}"
echo ""
echo "4. Configure MacroDroid webhook to POST to:"
echo -e "   ${YELLOW}http://localhost:9000/generate${NC}"
echo ""
echo "📝 Logs saved to: $HOME/.logs/musical-palm-tree"
echo "📁 Videos saved to: /sdcard/Movies/musical-palm-tree"
echo "💾 Cache stored in: $HOME/.cache/musical-palm-tree"
echo ""
echo -e "${GREEN}🎉 Ready to generate videos!${NC}"
