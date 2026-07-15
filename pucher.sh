# Colors
RESET="\033[0m"
BOLD="\033[1m"

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"

echo -e "\n${BOLD}${CYAN}[1/4] 📂 Copying files...${RESET}"
if cp -r ~/storage/shared/GITHUB/CARGO/* CARGO/; then
    echo -e "${GREEN}✓ Files copied successfully.${RESET}"
else
    echo -e "${RED}✗ Failed to copy files.${RESET}"
    exit 1
fi

echo -e "\n${BOLD}${CYAN}[2/4] 📦 Staging changes...${RESET}"
if git add .; then
    echo -e "${GREEN}✓ Changes staged.${RESET}"
else
    echo -e "${RED}✗ Failed to stage changes.${RESET}"
    exit 1
fi

echo -e "\n${BOLD}${CYAN}[3/4] 📝 Creating commit...${RESET}"
if git commit -m "Auto update: $(date '+%Y-%m-%d %H:%M:%S')"; then
    echo -e "${GREEN}✓ Commit created.${RESET}"
else
    echo -e "${YELLOW}⚠ Nothing to commit or commit failed.${RESET}"
    exit 1
fi

echo -e "\n${BOLD}${CYAN}[4/4] ☁️ Pushing to GitHub...${RESET}"
if git push origin main; then
    echo -e "${GREEN}✓ Push successful.${RESET}"
else
    echo -e "${RED}✗ Push failed.${RESET}"
    exit 1
fi
