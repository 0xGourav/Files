#!/data/data/com.termux/files/usr/bin/bash

# ========= Colors =========
RESET="\033[0m"
BOLD="\033[1m"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"

# ========= Configuration =========
SOURCE="$HOME/storage/shared/GITHUB"

# ========= Banner =========
echo -e "${BOLD}${CYAN}======================================${RESET}"
echo -e "${BOLD}${CYAN}      🚀 Git Auto Push Started${RESET}"
echo -e "${BOLD}${CYAN}======================================${RESET}"

# ========= Check Source =========
if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}✗ Source folder not found:${RESET} $SOURCE"
    exit 1
fi

# ========= Sync =========
echo -e "\n${BOLD}${BLUE}[1/4] 🔄 Syncing Files...${RESET}"

if rsync -a --delete \
    --exclude=".git/" \
    --exclude="pucher.sh" \
    "$SOURCE/" .; then
    echo -e "${GREEN}✓ Files synchronized.${RESET}"
else
    echo -e "${RED}✗ Synchronization failed.${RESET}"
    exit 1
fi

# ========= Stage =========
echo -e "\n${BOLD}${BLUE}[2/4] 📦 Staging changes...${RESET}"

if git add -A; then
    echo -e "${GREEN}✓ Changes staged.${RESET}"
else
    echo -e "${RED}✗ Failed to stage changes.${RESET}"
    exit 1
fi

# ========= Check Changes =========
echo -e "\n${BOLD}${BLUE}[3/4] 🔍 Checking for changes...${RESET}"

if git diff --cached --quiet; then
    echo -e "${YELLOW}⚠ No changes detected. Repository is already up to date.${RESET}"
    exit 0
fi

# ========= Commit =========
echo -e "${BOLD}${BLUE}📝 Creating commit...${RESET}"

if git commit -m "Auto update: $(date '+%Y-%m-%d %H:%M:%S')"; then
    echo -e "${GREEN}✓ Commit created.${RESET}"
else
    echo -e "${RED}✗ Commit failed.${RESET}"
    exit 1
fi

# ========= Push =========
echo -e "\n${BOLD}${BLUE}[4/4] ☁️ Pushing to GitHub...${RESET}"

if git push origin main; then
    echo -e "${GREEN}✓ Push successful.${RESET}"
else
    echo -e "${RED}✗ Push failed.${RESET}"
    exit 1
fi

# ========= Finish =========
echo
echo -e "${BOLD}${GREEN}======================================${RESET}"
echo -e "${BOLD}${GREEN}✅ GitHub repository updated successfully!${RESET}"
echo -e "${BOLD}${CYAN}🕒 Finished: $(date '+%d-%m-%Y %I:%M:%S %p')${RESET}"
echo -e "${BOLD}${GREEN}======================================${RESET}"
