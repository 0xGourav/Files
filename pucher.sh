#!/data/data/com.termux/files/usr/bin/bash

# Auto Git Push Script

echo "Starting Git Auto Push..."

# Move to your project folder

# Show status
git status

# Add all files
git add .

# Commit with timestamp message
git commit -m "Auto update $(date '+%Y-%m-%d %H:%M:%S')"

# Push to GitHub
git push origin main

echo "Push completed!"
