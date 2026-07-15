echo -e "\n${BLUE}[1/4] 📂 Copying files...${RESET}"
if cp -r ~/storage/shared/GITHUB/CARGO/* .; then
    echo -e "${GREEN}✓ Files copied successfully.${RESET}"
else
    echo -e "${RED}✗ Failed to copy files.${RESET}"
    exit 1
fi

echo -e "\n${BLUE}[2/4] 📦 Staging changes...${RESET}"
if git add .; then
    echo -e "${GREEN}✓ Changes staged.${RESET}"
else
    echo -e "${RED}✗ Failed to stage changes.${RESET}"
    exit 1
fi

echo -e "\n${BLUE}[3/4] 📝 Creating commit...${RESET}"
if git commit -m "Auto update: $(date '+%Y-%m-%d %H:%M:%S')"; then
    echo -e "${GREEN}✓ Commit created.${RESET}"
else
    echo -e "${YELLOW}⚠ Nothing to commit or commit failed.${RESET}"
    exit 1
fi

echo -e "\n${BLUE}[4/4] ☁️ Pushing to GitHub...${RESET}"
if git push origin main; then
    echo -e "${GREEN}✓ Push successful.${RESET}"
else
    echo -e "${RED}✗ Push failed.${RESET}"
    exit 1
fi
