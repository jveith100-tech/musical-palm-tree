#!/usr/bin/env python3
"""
Webhook Server for Musical Palm Tree
Listens on Termux HTTP server and receives prompts from MacroDroid
Triggers video generation pipeline
"""

import os
import sys
import json
import logging
import asyncio
from datetime import datetime
from flask import Flask, request, jsonify
from dotenv import load_dotenv
import subprocess

# Load environment variables
load_dotenv()

# Setup logging
log_dir = os.getenv('LOG_DIR', os.path.expanduser('~/.logs/musical-palm-tree'))
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(log_dir, 'webhook_server.log')),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

class VideoGenerator:
    def __init__(self):
        self.pixelle_api = os.getenv('PIXELLE_API', 'http://localhost:5000')
        self.output_dir = os.getenv('OUTPUT_DIR', '/sdcard/Movies/musical-palm-tree')
        self.cache_dir = os.getenv('CACHE_DIR', os.path.expanduser('~/.cache/musical-palm-tree'))
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(self.cache_dir, exist_ok=True)
    
    def generate_video(self, prompt, video_id=None):
        """Generate video from prompt"""
        try:
            if not video_id:
                video_id = datetime.now().strftime('%Y%m%d_%H%M%S')
            
            logger.info(f"🎬 Starting video generation for prompt: {prompt}")
            
            # Call local generate script
            script_path = os.path.join(os.path.dirname(__file__), 'generate_video.sh')
            cmd = ['bash', script_path, prompt, video_id]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0:
                logger.info(f"✅ Video generated successfully: {video_id}")
                output_file = os.path.join(self.output_dir, f'video_{video_id}.mp4')
                return {
                    'status': 'success',
                    'video_id': video_id,
                    'output': output_file,
                    'message': 'Video generated successfully'
                }
            else:
                logger.error(f"❌ Video generation failed: {result.stderr}")
                return {
                    'status': 'error',
                    'video_id': video_id,
                    'error': result.stderr,
                    'message': 'Video generation failed'
                }
        except Exception as e:
            logger.error(f"❌ Exception during video generation: {str(e)}")
            return {
                'status': 'error',
                'error': str(e),
                'message': 'Exception occurred during video generation'
            }

generator = VideoGenerator()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'musical-palm-tree-webhook',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/generate', methods=['POST'])
def generate():
    """Webhook endpoint to receive prompt and generate video"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'status': 'error', 'message': 'No JSON data provided'}), 400
        
        prompt = data.get('prompt')
        video_id = data.get('video_id')
        
        if not prompt:
            return jsonify({'status': 'error', 'message': 'No prompt provided'}), 400
        
        logger.info(f"📨 Received webhook request: {prompt}")
        
        result = generator.generate_video(prompt, video_id)
        
        status_code = 200 if result['status'] == 'success' else 500
        return jsonify(result), status_code
    
    except Exception as e:
        logger.error(f"❌ Webhook error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/prompt', methods=['POST'])
def handle_prompt():
    """Alternative endpoint for text input"""
    try:
        data = request.get_json()
        prompt = data.get('text') or data.get('prompt')
        
        if not prompt:
            return jsonify({'status': 'error', 'message': 'No text provided'}), 400
        
        logger.info(f"📝 Processing prompt: {prompt}")
        result = generator.generate_video(prompt)
        
        return jsonify(result), 200 if result['status'] == 'success' else 500
    
    except Exception as e:
        logger.error(f"❌ Prompt handler error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/status/<video_id>', methods=['GET'])
def get_status(video_id):
    """Get status of a video generation job"""
    try:
        log_file = os.path.join(generator.cache_dir, f'{video_id}.log')
        
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                content = f.read()
            
            status = 'completed' if 'COMPLETED' in content else 'processing'
            return jsonify({
                'video_id': video_id,
                'status': status,
                'log': content[-500:]  # Last 500 chars
            }), 200
        else:
            return jsonify({
                'video_id': video_id,
                'status': 'not_found'
            }), 404
    
    except Exception as e:
        logger.error(f"❌ Status check error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/list', methods=['GET'])
def list_videos():
    """List all generated videos"""
    try:
        videos = []
        for file in os.listdir(generator.output_dir):
            if file.endswith('.mp4'):
                filepath = os.path.join(generator.output_dir, file)
                size = os.path.getsize(filepath)
                mtime = os.path.getmtime(filepath)
                videos.append({
                    'filename': file,
                    'size': size,
                    'created': datetime.fromtimestamp(mtime).isoformat()
                })
        
        return jsonify({
            'status': 'ok',
            'count': len(videos),
            'videos': sorted(videos, key=lambda x: x['created'], reverse=True)
        }), 200
    
    except Exception as e:
        logger.error(f"❌ List error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('LOCAL_SERVER_PORT', 9000))
    host = os.getenv('LOCAL_SERVER_HOST', '0.0.0.0')
    
    logger.info(f"🚀 Starting Musical Palm Tree Webhook Server on {host}:{port}")
    logger.info(f"📍 Pixelle API: {generator.pixelle_api}")
    logger.info(f"📁 Output Dir: {generator.output_dir}")
    
    app.run(host=host, port=port, debug=True)
