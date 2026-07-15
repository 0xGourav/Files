#!/data/data/com.termux/files/usr/bin/bash

echo "📂 Copying files..."
cp -r ~/storage/shared/GITHUB/CARGO/* .
echo "✅ Files copied."

echo "📦 Adding changes..."
git add .
echo "✅ Changes added."

echo "📝 Creating commit..."
git commit -m "Auto update $(date '+%Y-%m-%d %H:%M:%S')"
echo "✅ Commit created."

echo "🚀 Pushing to GitHub..."
git push origin main

echo "🎉 Done!"
