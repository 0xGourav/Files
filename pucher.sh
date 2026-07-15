#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}======================================${RESET}"
echo -e "${CYAN}      🚀 Git Auto Push Started${RESET}"
echo -e "${CYAN}======================================${RESET}"

echo -e "\n${BLUE}[1/4] 📂 Copying files...${RESET}"
cp -rv ~/storage/shared/GITHUB/CARGO/* .

echo -e "\n${BLUE}[2/4] 📦 Staging changes...${RESET}"
git add .

echo -e "\n${BLUE}[3/4] 📝 Creating commit...${RESET}"
git commit -m "Auto update: $(date '+%Y-%m-%d %H:%M:%S')"

echo -e "\n${BLUE}[4/4] ☁️ Pushing to GitHub...${RESET}"
git push origin main

echo -e "\n${GREEN}======================================${RESET}"
echo -e "${GREEN}✅ Git Auto Push Completed!${RESET}"
echo -e "${YELLOW}🕒 Finished at: $(date '+%I:%M:%S %p')${RESET}"
echo -e "${GREEN}======================================${RESET}"
