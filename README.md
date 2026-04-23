# Musical Palm Tree — Android One‑Tap AI Video Agent

## Overview
Musical Palm Tree is an Android-first, one-tap video agent that uses Tasker (or MacroDroid) + Termux to trigger an AI-powered backend for fully automated short video creation. The project leverages Pixelle-Video (AIDC-AI) as a modular backend for script writing, image/video generation, TTS, and video stitching.

## Goals
- Accept a short text prompt on the phone (Tasker input).
- Generate scene images or short clips from the prompt (AI models).
- Synthesize narration audio (TTS).
- Stitch media into a final MP4 (FFmpeg).
- Deliver the final video back to the Android device for preview/sharing.

## Architecture
- Android (Tasker/MacroDroid)
  - Webhook trigger: sends prompt and options to Termux or a local HTTP bridge.
  - UI: one-tap action, simple prompt input, progress notifications.
- Termux (on-device execution)
  - Orchestrates backend calls and local scripts.
  - Runs wrapper scripts that call Pixelle-Video or local ComfyUI/LLM/TTS services.
- Backend (Pixelle-Video or local replacement)
  - LLM for script & storyboard generation.
  - ComfyUI / image/video model for visuals.
  - Edge-TTS / Index-TTS / local TTS for narration audio.
  - FFmpeg for stitching.

## Quick Start (recommended path)
1. Install Termux and Tasker/MacroDroid on your Android device.
2. Clone this repository to a folder readable by Termux:
   ```bash
   pkg install git python ffmpeg
   git clone https://github.com/jveith100-tech/musical-palm-tree.git
   cd musical-palm-tree
   ```
3. Install small helper scripts in Termux (examples provided in `termux/`):
   - `termux/prompt_handler.py` — formats prompts and calls the backend.
   - `termux/generate_video.sh` — orchestrates scene generation, TTS, and ffmpeg stitching.
4. Configure Tasker:
   - Create a one-tap task that collects a prompt (Input -> Variable %prompt).
   - Send the prompt to Termux: am startservice --user 0 -n com.termux/.app.TermuxService --es "cmd" "python3 /data/data/com.termux/files/home/musical-palm-tree/termux/prompt_handler.py --prompt '%prompt%'"
   - Alternatively use an HTTP webhook to a local bridge running in Termux: `python3 -m http.server 9000` and a small Flask script to receive JSON.

## Using Pixelle-Video as backend
Pixelle-Video already implements most of the pipeline (script → images/video → TTS → stitch). You can either run Pixelle-Video on a separate machine (recommended if your phone lacks GPU) or wrap its API and call it from Termux.

Example Termux wrapper (simplified):

termux/wrapper.py
```python
import requests
import sys
prompt = sys.argv[1]
API = 'http://<pixelle-host>:8501/api/generate'
resp = requests.post(API, json={'prompt': prompt, 'format':'short'})
# download result and place into ~/storage/shared/Movies/
```

## Files & Layout
- README.md — this document
- Agent_Mode_Handler.macro...txt — Tasker/MacroDroid macro exported
- hooks.json — pre/post run hooks
- termux/
  - prompt_handler.py (example)
  - generate_video.sh (example shell orchestrator)
  - wrapper.py (calls remote Pixelle-Video)

## Example Termux script: generate_video.sh
```bash
#!/data/data/com.termux/files/usr/bin/bash
PROMPT="$1"
# 1) Request script/storyboard from Pixelle-Video
curl -X POST "http://<pixelle-host>:8501/api/prepare" -H "Content-Type: application/json" -d '{"prompt":"'$PROMPT'"}' -o /tmp/task.json
# 2) Trigger image/video generation (batch)
# 3) Trigger TTS
# 4) Stitch with ffmpeg
# 5) Move final file to shared storage
mv ./output/final.mp4 /sdcard/Movies/musical-palm-tree-$(date +%s).mp4
```

## Tasker Macro: Agent_Mode_Handler
The repo contains an exported Tasker/MacroDroid macro (Agent_Mode_Handler...) that listens on a webhook and controls the phone. Extend it to POST prompts to the Termux bridge or to call `am` commands that run Termux scripts.

## Config Example (.env)
```
PIXELLE_API=http://<pixelle-host>:8501
PIXELLE_KEY=optional_api_key
OUTPUT_DIR=/sdcard/Movies
```

## Development Roadmap (priority order)
1. Expand README and add termux scripts (this change).
2. Create `termux/` example scripts and safe defaults for running on-device.
3. Add a simple Flask bridge that accepts webhook POSTs from Tasker and invokes Termux scripts.
4. Add documentation and a small demo: a Tasker task that sends a sample prompt and saves the video to /sdcard/Movies.

## References
- Pixelle-Video repo: https://github.com/jveith100-tech/Pixelle-Video

## Web UI Preview
![Pixelle Web UI](https://github.com/jveith100-tech/Pixelle-Video/blob/main/resources/webui_en.png)
