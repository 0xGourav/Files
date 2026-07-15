#!/data/data/com.termux/files/usr/bin/bash

echo "======================================"
echo "      🚀 Git Auto Push Started"
echo "======================================"

echo "[1/4] 📂 Copying files..."
cp -rv ~/storage/shared/GITHUB/CARGO/* .

echo
echo "[2/4] 📦 Staging changes..."
git add .

echo
echo "[3/4] 📝 Creating commit..."
git commit -m "Auto update: $(date '+%Y-%m-%d %H:%M:%S')"

echo
echo "[4/4] ☁️ Pushing to GitHub..."
git push origin main

echo
echo "======================================"
echo "✅ Git Auto Push Completed!"
echo "🕒 Finished at: $(date '+%I:%M:%S %p')"
echo "======================================"
