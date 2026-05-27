#!/data/data/com.termux/files/usr/bin/bash

# Start the Musical Palm Tree webhook server
# Run this in Termux to start listening for MacroDroid webhooks

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
cd "$REPO_DIR"

echo "🚀 Starting Musical Palm Tree Webhook Server"
echo "📁 Repository: $REPO_DIR"
echo "🌐 Listening on: http://localhost:9000"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Load environment
if [ -f ".env" ]; then
    source .env
fi

PORT="${LOCAL_SERVER_PORT:-9000}"

# Start the server
python3 "$REPO_DIR/termux/webhook_server.py" --port $PORT
