#!/data/data/com.termux/files/usr/bin/bash

# Musical Palm Tree - Video Generation Pipeline
# Usage: ./generate_video.sh "Your prompt here" [video_id]

set -e

PROMPT="$1"
VIDEO_ID="${2:-$(date +%Y%m%d_%H%M%S)}"

# Load environment
if [ -f "$(dirname "$0")/../.env" ]; then
    source "$(dirname "$0")/../.env
fi

# Set defaults if not in .env
PIXELLE_API="${PIXELLE_API:-http://localhost:5000}"
OUTPUT_DIR="${OUTPUT_DIR:-/sdcard/Movies/musical-palm-tree}"
CACHE_DIR="${CACHE_DIR:-$HOME/.cache/musical-palm-tree}"

# Create directories
mkdir -p "$OUTPUT_DIR" "$CACHE_DIR"

LOG_FILE="$CACHE_DIR/$VIDEO_ID.log"

echo "[$(date)] 🎬 Starting video generation" | tee -a "$LOG_FILE"
echo "[$(date)] 📝 Prompt: $PROMPT" | tee -a "$LOG_FILE"
echo "[$(date)] 🎯 Video ID: $VIDEO_ID" | tee -a "$LOG_FILE"
echo "[$(date)] 🔗 Pixelle API: $PIXELLE_API" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Step 1: Request script/storyboard from Pixelle-Video
echo "[$(date)] 📋 Step 1: Generating script and storyboard..." | tee -a "$LOG_FILE"

TASK_JSON="$CACHE_DIR/${VIDEO_ID}_task.json"

if curl -s -X POST "$PIXELLE_API/api/prepare" \
    -H "Content-Type: application/json" \
    -d "{\"prompt\":\"$PROMPT\"}" \
    -o "$TASK_JSON" 2>> "$LOG_FILE"; then
    echo "[$(date)] ✅ Script generated" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ❌ Failed to generate script" | tee -a "$LOG_FILE"
    exit 1
fi

# Step 2: Generate images/video
echo "[$(date)] 🖼️  Step 2: Generating images/video..." | tee -a "$LOG_FILE"

if curl -s -X POST "$PIXELLE_API/api/generate_media" \
    -H "Content-Type: application/json" \
    -d "{\"task_id\":\"$VIDEO_ID\"}" \
    -o "$CACHE_DIR/${VIDEO_ID}_media.json" 2>> "$LOG_FILE"; then
    echo "[$(date)] ✅ Media generated" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ❌ Failed to generate media" | tee -a "$LOG_FILE"
    exit 1
fi

# Step 3: Generate audio
echo "[$(date)] 🔊 Step 3: Synthesizing narration audio..." | tee -a "$LOG_FILE"

AUDIO_FILE="$CACHE_DIR/${VIDEO_ID}_narration.mp3"

if curl -s -X POST "$PIXELLE_API/api/generate_audio" \
    -H "Content-Type: application/json" \
    -d "{\"task_id\":\"$VIDEO_ID\"}" \
    -o "$AUDIO_FILE" 2>> "$LOG_FILE"; then
    echo "[$(date)] ✅ Audio generated" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ⚠️  Audio generation failed, continuing without audio" | tee -a "$LOG_FILE"
fi

# Step 4: Download and stitch with FFmpeg
echo "[$(date)] 🎞️  Step 4: Stitching video..." | tee -a "$LOG_FILE"

VIDEO_TEMP="$CACHE_DIR/${VIDEO_ID}_temp.mp4"
FINAL_VIDEO="$OUTPUT_DIR/video_${VIDEO_ID}.mp4"

# For now, download from Pixelle and use as-is
# In a full implementation, you'd stitch images + audio here
if curl -s -X GET "$PIXELLE_API/api/download/$VIDEO_ID" \
    -o "$VIDEO_TEMP" 2>> "$LOG_FILE"; then
    echo "[$(date)] ✅ Video downloaded" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ⚠️  Video download failed, using temporary file" | tee -a "$LOG_FILE"
fi

# Finalize
if [ -f "$VIDEO_TEMP" ]; then
    mv "$VIDEO_TEMP" "$FINAL_VIDEO"
    echo "[$(date)] ✅ Video finalized: $FINAL_VIDEO" | tee -a "$LOG_FILE"
else
    echo "[$(date)] ❌ Stitching failed - no video produced" | tee -a "$LOG_FILE"
    exit 1
fi

# Step 5: Cleanup and summary
echo "" | tee -a "$LOG_FILE"
echo "[$(date)] 📊 Generation Summary" | tee -a "$LOG_FILE"
echo "[$(date)] ✅ Video ID: $VIDEO_ID" | tee -a "$LOG_FILE"
echo "[$(date)] 📁 Output: $FINAL_VIDEO" | tee -a "$LOG_FILE"
echo "[$(date)] 📏 File Size: $(du -h "$FINAL_VIDEO" | cut -f1)" | tee -a "$LOG_FILE"
echo "[$(date)] ⏱️  Total Time: $(date)" | tee -a "$LOG_FILE"
echo "[$(date)] ✅ COMPLETED" | tee -a "$LOG_FILE"

echo ""
echo "🎉 Video generation complete!"
echo "📁 Saved to: $FINAL_VIDEO"
