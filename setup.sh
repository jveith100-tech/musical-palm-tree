#!/bin/bash

# One-Click Setup for Phone AI Automation + Video Generator
# Run this in Termux: bash setup.sh

echo "🚀 Installing Phone AI Automation System..."
echo ""

# Update package manager
echo "📦 Updating packages..."
pkg update -y
pkg upgrade -y

# Install system dependencies
echo "📥 Installing system dependencies..."
pkg install -y python python-pip git ffmpeg imagemagick

# Install Python dependencies
echo "🐍 Installing Python libraries..."
pip install --upgrade pip
pip install -r requirements.txt

# Install termux-api (for phone control)
echo "📱 Setting up termux-api..."
pkg install -y termux-api

# Create directories
mkdir -p output videos frames audio

echo ""
echo "✅ Installation complete!"
echo ""
echo "📖 Quick Start:"
echo "   1. Run: python video_generator.py --help"
echo "   2. Run: python phone_automation.py --help"
echo ""
echo "🎬 Generate a video:"
echo "   python video_generator.py --prompt 'A cat jumping' --output output/video.mp4"
echo ""
echo "📱 Automate your phone:"
echo "   python phone_automation.py --tap 500 500"
echo ""
