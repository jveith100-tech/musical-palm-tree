#!/usr/bin/env python3
"""
Phone Automation Module - Controls Android device via Termux API
Supports tapping, swiping, typing, app launches, and more
"""

import os
import sys
import subprocess
import logging
import argparse
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
        logging.FileHandler(os.path.join(log_dir, 'phone_automation.log')),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class PhoneAutomation:
    """Control Android device via Termux API"""
    
    def __init__(self):
        self.check_termux_api()
    
    def check_termux_api(self):
        """Verify termux-api is installed"""
        try:
            subprocess.run(['which', 'termux-open'], capture_output=True, check=True)
            logger.info("✅ Termux API available")
        except subprocess.CalledProcessError:
            logger.warning("⚠️  Termux API not found. Install with: pkg install termux-api")
    
    def tap(self, x, y):
        """Tap at coordinates (x, y)"""
        try:
            cmd = f"input tap {x} {y}"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"👆 Tapped at ({x}, {y})")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Tap failed: {e}")
            return False
    
    def swipe(self, x1, y1, x2, y2, duration=300):
        """Swipe from (x1, y1) to (x2, y2)"""
        try:
            cmd = f"input swipe {x1} {y1} {x2} {y2} {duration}"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"👉 Swiped from ({x1}, {y1}) to ({x2}, {y2})")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Swipe failed: {e}")
            return False
    
    def type_text(self, text):
        """Type text"""
        try:
            # Escape special characters
            safe_text = text.replace('"', '\\"').replace("'", "\\'").replace('$', '\\$')
            cmd = f"input text '{safe_text}'"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"⌨️  Typed: {text}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Type failed: {e}")
            return False
    
    def press_key(self, key):
        """Press a key (e.g., ENTER, BACK, HOME)"""
        key_codes = {
            'enter': 66,
            'back': 4,
            'home': 3,
            'menu': 82,
            'recents': 187,
            'power': 26,
            'volume_up': 24,
            'volume_down': 25,
        }
        
        try:
            key_code = key_codes.get(key.lower(), key)
            cmd = f"input keyevent {key_code}"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"🔑 Pressed key: {key}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Key press failed: {e}")
            return False
    
    def open_app(self, package_name):
        """Open app by package name"""
        try:
            cmd = f"am start -n {package_name}/.MainActivity"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"📱 Opened: {package_name}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Open app failed: {e}")
            return False
    
    def open_url(self, url):
        """Open URL in default browser"""
        try:
            subprocess.run(['termux-open', url], check=True)
            logger.info(f"🌐 Opened URL: {url}")
            return True
        except subprocess.CalledProcessError as e:
            logger.error(f"❌ Open URL failed: {e}")
            return False
    
    def get_battery(self):
        """Get battery level"""
        try:
            result = subprocess.run(['termux-battery-status'], capture_output=True, text=True, check=True)
            import json
            data = json.loads(result.stdout)
            level = data.get('level', 'unknown')
            status = data.get('status', 'unknown')
            logger.info(f"🔋 Battery: {level}% ({status})")
            return level
        except Exception as e:
            logger.warning(f"⚠️  Could not get battery: {e}")
            return None
    
    def get_brightness(self):
        """Get screen brightness"""
        try:
            result = subprocess.run(
                "settings get system screen_brightness",
                shell=True,
                capture_output=True,
                text=True,
                check=True
            )
            brightness = result.stdout.strip()
            logger.info(f"☀️  Brightness: {brightness}")
            return brightness
        except Exception as e:
            logger.warning(f"⚠️  Could not get brightness: {e}")
            return None
    
    def set_brightness(self, value):
        """Set screen brightness (0-255)"""
        try:
            if not 0 <= int(value) <= 255:
                raise ValueError("Brightness must be 0-255")
            cmd = f"settings put system screen_brightness {value}"
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"☀️  Set brightness: {value}")
            return True
        except Exception as e:
            logger.error(f"❌ Set brightness failed: {e}")
            return False
    
    def show_notification(self, title, message):
        """Show notification"""
        try:
            subprocess.run(
                ['termux-notification', '--title', title, '--content', message],
                check=True
            )
            logger.info(f"🔔 Notification: {title} - {message}")
            return True
        except subprocess.CalledProcessError as e:
            logger.warning(f"⚠️  Notification failed: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(
        description='Musical Palm Tree - Phone Automation'
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Tap
    tap_parser = subparsers.add_parser('tap', help='Tap at coordinates')
    tap_parser.add_argument('x', type=int, help='X coordinate')
    tap_parser.add_argument('y', type=int, help='Y coordinate')
    
    # Swipe
    swipe_parser = subparsers.add_parser('swipe', help='Swipe between coordinates')
    swipe_parser.add_argument('x1', type=int, help='Start X')
    swipe_parser.add_argument('y1', type=int, help='Start Y')
    swipe_parser.add_argument('x2', type=int, help='End X')
    swipe_parser.add_argument('y2', type=int, help='End Y')
    swipe_parser.add_argument('--duration', type=int, default=300, help='Duration in ms')
    
    # Type
    type_parser = subparsers.add_parser('type', help='Type text')
    type_parser.add_argument('text', help='Text to type')
    
    # Press key
    key_parser = subparsers.add_parser('key', help='Press key')
    key_parser.add_argument('key', help='Key to press')
    
    # Open app
    app_parser = subparsers.add_parser('app', help='Open app')
    app_parser.add_argument('package', help='Package name')
    
    # Open URL
    url_parser = subparsers.add_parser('url', help='Open URL')
    url_parser.add_argument('url', help='URL to open')
    
    # Battery
    subparsers.add_parser('battery', help='Get battery status')
    
    # Brightness
    bright_parser = subparsers.add_parser('brightness', help='Get/set brightness')
    bright_parser.add_argument('--set', type=int, help='Set brightness (0-255)')
    
    # Notify
    notify_parser = subparsers.add_parser('notify', help='Show notification')
    notify_parser.add_argument('--title', required=True, help='Notification title')
    notify_parser.add_argument('--message', required=True, help='Notification message')
    
    args = parser.parse_args()
    
    automation = PhoneAutomation()
    
    if args.command == 'tap':
        automation.tap(args.x, args.y)
    elif args.command == 'swipe':
        automation.swipe(args.x1, args.y1, args.x2, args.y2, args.duration)
    elif args.command == 'type':
        automation.type_text(args.text)
    elif args.command == 'key':
        automation.press_key(args.key)
    elif args.command == 'app':
        automation.open_app(args.package)
    elif args.command == 'url':
        automation.open_url(args.url)
    elif args.command == 'battery':
        automation.get_battery()
    elif args.command == 'brightness':
        if args.set is not None:
            automation.set_brightness(args.set)
        else:
            automation.get_brightness()
    elif args.command == 'notify':
        automation.show_notification(args.title, args.message)
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
