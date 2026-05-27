#!/usr/bin/env python3
"""
Prompt Handler - Formats prompts and sends to video generator
Can be called from MacroDroid via am command or used standalone
"""

import os
import sys
import json
import logging
import argparse
import subprocess
from datetime import datetime
from dotenv import load_dotenv

# Load environment
load_dotenv()

# Setup logging
log_dir = os.getenv('LOG_DIR', os.path.expanduser('~/.logs/musical-palm-tree'))
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(log_dir, 'prompt_handler.log')),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class PromptHandler:
    def __init__(self):
        self.pixelle_api = os.getenv('PIXELLE_API', 'http://localhost:5000')
        self.output_dir = os.getenv('OUTPUT_DIR', '/sdcard/Movies/musical-palm-tree')
        self.cache_dir = os.getenv('CACHE_DIR', os.path.expanduser('~/.cache/musical-palm-tree'))
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(self.cache_dir, exist_ok=True)
    
    def validate_prompt(self, prompt):
        """Validate and clean prompt"""
        if not prompt or not isinstance(prompt, str):
            return None
        
        prompt = prompt.strip()
        if len(prompt) < 3:
            logger.warning(f"Prompt too short: {prompt}")
            return None
        
        if len(prompt) > 500:
            logger.warning(f"Prompt too long, truncating to 500 chars")
            prompt = prompt[:500]
        
        return prompt
    
    def handle_prompt(self, prompt, video_id=None, options=None):
        """Handle incoming prompt and trigger generation"""
        try:
            # Validate
            validated_prompt = self.validate_prompt(prompt)
            if not validated_prompt:
                logger.error(f"Invalid prompt: {prompt}")
                return {'status': 'error', 'message': 'Invalid prompt'}
            
            if not video_id:
                video_id = datetime.now().strftime('%Y%m%d_%H%M%S')
            
            logger.info(f"📝 Processing prompt: {validated_prompt}")
            logger.info(f"🎯 Video ID: {video_id}")
            
            # Generate video via script
            script_path = os.path.join(os.path.dirname(__file__), 'generate_video.sh')
            cmd = ['bash', script_path, validated_prompt, video_id]
            
            logger.info(f"🚀 Executing: {' '.join(cmd)}")
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0:
                logger.info(f"✅ Video generation successful")
                output_file = os.path.join(self.output_dir, f'video_{video_id}.mp4')
                return {
                    'status': 'success',
                    'video_id': video_id,
                    'prompt': validated_prompt,
                    'output': output_file,
                    'message': 'Video generated successfully'
                }
            else:
                logger.error(f"❌ Generation failed: {result.stderr}")
                return {
                    'status': 'error',
                    'video_id': video_id,
                    'error': result.stderr,
                    'message': 'Video generation failed'
                }
        
        except subprocess.TimeoutExpired:
            logger.error(f"❌ Generation timed out")
            return {
                'status': 'error',
                'message': 'Generation timed out after 10 minutes'
            }
        except Exception as e:
            logger.error(f"❌ Exception: {str(e)}")
            return {
                'status': 'error',
                'error': str(e),
                'message': 'Exception during generation'
            }

def main():
    parser = argparse.ArgumentParser(
        description='Musical Palm Tree - Prompt Handler'
    )
    parser.add_argument('--prompt', '-p', required=True, help='Video prompt')
    parser.add_argument('--video-id', '-v', help='Custom video ID')
    parser.add_argument('--json', '-j', action='store_true', help='Output JSON')
    
    args = parser.parse_args()
    
    handler = PromptHandler()
    result = handler.handle_prompt(args.prompt, args.video_id)
    
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Status: {result['status']}")
        if result['status'] == 'success':
            print(f"Video ID: {result['video_id']}")
            print(f"Output: {result['output']}")
        else:
            print(f"Error: {result.get('error', result.get('message'))}")
    
    return 0 if result['status'] == 'success' else 1

if __name__ == '__main__':
    sys.exit(main())
