# 🚀 Installation Guide - Musical Palm Tree

## Prerequisites
You need these apps installed on your Android phone:
- ✅ **Termux** (from F-Droid or GitHub)
- ✅ **MacroDroid** (already have this)
- ✅ **Pixelle-Video** (running on your phone or local PC)

---

## Step 1: Install Termux

### Option A: F-Droid (Recommended - Latest)
1. Install F-Droid app from https://f-droid.org
2. Open F-Droid
3. Search for "Termux"
4. Install it

### Option B: GitHub Release
1. Go to https://github.com/termux/termux-app/releases
2. Download the latest `.apk` file
3. Open it on your phone to install

---

## Step 2: Grant Termux Permissions

When Termux opens for the first time:
1. Allow all permissions it asks for
2. Run this command to get storage access:
```bash
termux-setup-storage
```

---

## Step 3: Clone the Repository

Copy and paste this into Termux:

```bash
pkg install git
cd ~
git clone https://github.com/jveith100-tech/musical-palm-tree.git
cd musical-palm-tree
```

**What this does:**
- `pkg install git` - Installs Git
- `cd ~` - Goes to home folder
- `git clone` - Downloads your repo
- `cd musical-palm-tree` - Enters the folder

---

## Step 4: Run the Installation Script

Copy and paste this into Termux:

```bash
bash termux/install.sh
```

**This will:**
- ✅ Update all packages
- ✅ Install Python, FFmpeg, ImageMagick
- ✅ Install all Python libraries from `requirements.txt`
- ✅ Create folders for videos, logs, and cache
- ✅ Make scripts executable
- ✅ Create configuration file

Wait for it to finish. You'll see green checkmarks (✅) when each step completes.

---

## Step 5: Edit Configuration

After installation completes, edit your `.env` file:

```bash
nano ~/.env
```

Or navigate to your repo folder and edit:

```bash
cd ~/musical-palm-tree
nano .env
```

**You'll see this:**
```env
# Pixelle-Video API (running on your phone or local PC)
PIXELLE_API=http://localhost:5000
PIXELLE_PORT=5000
PIXELLE_KEY=

# Local HTTP Server (Termux webhook receiver)
LOCAL_SERVER_PORT=9000
LOCAL_SERVER_HOST=0.0.0.0

# Output directories
OUTPUT_DIR=/sdcard/Movies/musical-palm-tree
CACHE_DIR=$HOME/.cache/musical-palm-tree
LOG_DIR=$HOME/.logs/musical-palm-tree

# Video generation settings
VIDEO_FORMAT=short
VIDEO_LENGTH=60
VIDEO_RESOLUTION=1080p
AUDIO_LANG=en

# Phone control
DEVICE_MODEL=android
ENABLE_NOTIFICATIONS=true
```

**What to change:**
- `PIXELLE_API` - Where Pixelle-Video is running
  - If on same phone: `http://localhost:5000`
  - If on PC: `http://192.168.1.XXX:5000` (your PC's IP)
  - If on cloud: `http://your-server.com:5000`

**How to edit in nano:**
1. Use arrow keys to move
2. Type to change values
3. Press `Ctrl+X` then `Y` then `Enter` to save

---

## Step 6: Start the Webhook Server

Run this command in Termux:

```bash
bash ~/musical-palm-tree/termux/start_server.sh
```

**You should see:**
```
🚀 Starting Musical Palm Tree Webhook Server
📁 Repository: /data/data/com.termux/files/home/musical-palm-tree
🌐 Listening on: http://localhost:9000
```

**Leave this running!** Keep Termux open or let it run in the background.

---

## Step 7: Test It Works

Open a NEW Termux window/tab (don't close the server):

```bash
curl -X POST http://localhost:9000/health
```

If working, you'll see:
```json
{"status":"ok","service":"musical-palm-tree-webhook","timestamp":"2026-05-27T..."}
```

---

## Step 8: Test Video Generation

Try generating a video:

```bash
curl -X POST http://localhost:9000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"a cat jumping"}'
```

You should see:
```json
{"status":"success","video_id":"20260527_161234","output":"/sdcard/Movies/musical-palm-tree/video_20260527_161234.mp4"}
```

Check `/sdcard/Movies/musical-palm-tree/` for your video!

---

## Step 9: Configure MacroDroid

Now connect MacroDroid to the webhook server:

1. Open **MacroDroid**
2. Edit your **Agent Mode Handler** macro
3. Add a new action: **Perform HTTP Request**
4. Set:
   - **Method:** POST
   - **URL:** `http://localhost:9000/generate`
   - **Content-Type:** application/json
   - **Body:** 
     ```json
     {"prompt":"${your_prompt_variable}"}
     ```

Or if you want to test with a hardcoded prompt:
   ```json
   {"prompt":"a dog running"}
   ```

5. **Save** the macro

---

## Step 10: Create a Test Macro

Create a simple test in MacroDroid:

1. Create new macro: **Video Test**
2. **Trigger:** Tap when screen is on (any location)
3. **Action 1:** Show notification "Starting video generation..."
4. **Action 2:** Perform HTTP Request:
   - URL: `http://localhost:9000/generate`
   - Method: POST
   - Content-Type: application/json
   - Body: `{"prompt":"a cat dancing"}`
5. **Action 3:** Wait 2 seconds
6. **Action 4:** Show notification "Check /sdcard/Movies/musical-palm-tree/"

Test it by tapping your screen!

---

## 🎯 Full Workflow

```
MacroDroid Tap → Webhook Server (Termux)
                 ↓
          Flask receives POST
                 ↓
          generate_video.sh runs
                 ↓
          Calls Pixelle-Video API
                 ↓
          Video saved to /sdcard/Movies/
                 ↓
          Notification sent to phone
```

---

## ⚠️ Troubleshooting

### "Command not found: git"
Run: `pkg install git` first

### "requirements.txt not found"
Make sure you're in the right directory:
```bash
cd ~/musical-palm-tree
pwd  # Should show: /data/data/com.termux/files/home/musical-palm-tree
```

### "Permission denied" on .sh files
Run:
```bash
chmod +x ~/musical-palm-tree/termux/*.sh
```

### Webhook server won't start
Check if port 9000 is already in use:
```bash
netstat -tulnp | grep 9000
```

Or use a different port by editing `.env`:
```
LOCAL_SERVER_PORT=9001
```

### Videos not generating
1. Check logs:
   ```bash
   tail -f ~/.logs/musical-palm-tree/webhook_server.log
   ```

2. Make sure Pixelle-Video is running
3. Check `.env` has correct PIXELLE_API address

### Can't find videos
They're saved to: `/sdcard/Movies/musical-palm-tree/`

Use file manager to navigate or:
```bash
ls /sdcard/Movies/musical-palm-tree/
```

---

## 📱 Keep Server Running

To keep the webhook server running even when closing Termux:

### Option 1: Use nohup (Simple)
```bash
nohup python3 ~/musical-palm-tree/termux/webhook_server.py > ~/webhook.log 2>&1 &
```

### Option 2: Use screen (Better)
```bash
pkg install screen
screen -S mpt-server
bash ~/musical-palm-tree/termux/start_server.sh
# Press Ctrl+A then D to detach
# Use "screen -r mpt-server" to reattach
```

### Option 3: Run at Termux startup
Create `~/.bashrc`:
```bash
nano ~/.bashrc
```

Add at the end:
```bash
# Start musical-palm-tree server if not running
if ! pgrep -f webhook_server.py > /dev/null; then
    bash ~/musical-palm-tree/termux/start_server.sh &
fi
```

---

## ✅ You're Done!

You now have:
- ✅ Full Musical Palm Tree system installed
- ✅ Webhook server listening on port 9000
- ✅ MacroDroid configured to send prompts
- ✅ Videos generating to `/sdcard/Movies/musical-palm-tree/`

**Next:** Create more complex MacroDroid tasks to automate everything!

---

## 🆘 Need Help?

Check the logs:
```bash
# Webhook server logs
tail -f ~/.logs/musical-palm-tree/webhook_server.log

# Prompt handler logs
tail -f ~/.logs/musical-palm-tree/prompt_handler.log

# Video generation logs
tail -f ~/.logs/musical-palm-tree/video_*.log
```

Or run tests:
```bash
# Test health
curl http://localhost:9000/health

# Test video generation
curl -X POST http://localhost:9000/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test video"}'

# List all videos
curl http://localhost:9000/list
```
