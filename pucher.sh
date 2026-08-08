#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

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
BRANCH="${GIT_BRANCH:-main}"
REMOTE="${GIT_REMOTE:-origin}"
LOCKFILE="${TMPDIR:-${PREFIX:-$HOME}/tmp}/git_auto_push.lock"
LOGFILE="$HOME/.git_auto_push.log"
MAX_PUSH_RETRIES=3
DRY_RUN=false
CUSTOM_MSG=""
START_TIME=$(date +%s)

# ========= Parse Args =========
# Usage: ./pucher.sh ["commit message"] [--dry-run]
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        *) CUSTOM_MSG="$arg" ;;
    esac
done

log() {
    echo -e "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $(echo -e "$1" | sed -E 's/\x1B\[[0-9;]*[mK]//g')" >> "$LOGFILE"
}

die() {
    log "${RED}✗ $1${RESET}"
    notify "Git Auto Push" "❌ Failed: $1"
    exit 1
}

notify() {
    # Sends a Termux notification if termux-api is installed; silently skips otherwise.
    command -v termux-notification >/dev/null 2>&1 && \
        termux-notification --title "$1" --content "$2" >/dev/null 2>&1
}

elapsed() {
    local end=$(date +%s)
    echo "$(( end - START_TIME ))s"
}

# ========= Prevent overlapping runs =========
if [ -e "$LOCKFILE" ]; then
    die "Another instance seems to be running (lockfile exists: $LOCKFILE). Remove it if that's not true."
fi
trap 'rm -f "$LOCKFILE"' EXIT
mkdir -p "$(dirname "$LOCKFILE")"
touch "$LOCKFILE"

# ========= Banner =========
log "${BOLD}${CYAN}======================================${RESET}"
log "${BOLD}${CYAN}      🚀 Git Auto Push Started${RESET}"
$DRY_RUN && log "${YELLOW}      (DRY RUN — no changes will be pushed)${RESET}"
log "${BOLD}${CYAN}======================================${RESET}"

# ========= Dependency Checks =========
command -v git   >/dev/null 2>&1 || die "git is not installed."
command -v rsync >/dev/null 2>&1 || die "rsync is not installed."

# ========= Environment Checks =========
[ -d "$SOURCE" ] || die "Source folder not found: $SOURCE"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not inside a git repository."
git remote get-url "$REMOTE" >/dev/null 2>&1 || die "Remote '$REMOTE' not configured."

# ========= Connectivity Check =========
log "\n${BOLD}${BLUE}[1/6] 🌐 Checking internet connection...${RESET}"
if ping -c 1 -W 3 github.com >/dev/null 2>&1; then
    log "${GREEN}✓ Connected.${RESET}"
else
    die "No internet connection detected."
fi

# ========= Sync =========
log "\n${BOLD}${BLUE}[2/6] 🔄 Syncing files...${RESET}"
if rsync -a --delete \
    --exclude=".git/" \
    --exclude="pucher.sh" \
    "$SOURCE/" .; then
    log "${GREEN}✓ Files synchronized.${RESET}"
else
    die "Synchronization failed."
fi

# ========= Pull latest =========
log "\n${BOLD}${BLUE}[3/6] ⬇️  Pulling latest from ${REMOTE}/${BRANCH}...${RESET}"
if git pull --rebase --autostash "$REMOTE" "$BRANCH"; then
    log "${GREEN}✓ Up to date with remote.${RESET}"
else
    die "Pull/rebase failed. Resolve conflicts manually, then re-run."
fi

# ========= Stage =========
log "\n${BOLD}${BLUE}[4/6] 📦 Staging changes...${RESET}"
if git add -A; then
    log "${GREEN}✓ Changes staged.${RESET}"
else
    die "Failed to stage changes."
fi

# ========= Check Changes =========
log "\n${BOLD}${BLUE}[5/6] 🔍 Checking for changes...${RESET}"
if git diff --cached --quiet; then
    log "${YELLOW}⚠ No changes detected. Repository is already up to date.${RESET}"
    exit 0
fi

# Summary of what changed (added/modified/deleted counts + file list)
STAT=$(git diff --cached --stat --stat-width=60 | tail -n +1)
CHANGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
log "${CYAN}📊 ${CHANGED_FILES} file(s) changed:${RESET}"
log "$STAT"

if $DRY_RUN; then
    log "\n${YELLOW}⚠ Dry run complete — skipping commit & push.${RESET}"
    exit 0
fi

# ========= Commit =========
if [ -n "$CUSTOM_MSG" ]; then
    COMMIT_MSG="$CUSTOM_MSG"
else
    COMMIT_MSG="Auto update: $(date '+%Y-%m-%d %H:%M:%S') (${CHANGED_FILES} files changed)"
fi

log "${BOLD}${BLUE}📝 Creating commit...${RESET}"
if git commit -m "$COMMIT_MSG"; then
    log "${GREEN}✓ Commit created: ${COMMIT_MSG}${RESET}"
else
    die "Commit failed."
fi

# ========= Push (with retries) =========
log "\n${BOLD}${BLUE}[6/6] ☁️  Pushing to GitHub...${RESET}"
PUSH_OK=false
for attempt in $(seq 1 "$MAX_PUSH_RETRIES"); do
    if git push "$REMOTE" "$BRANCH"; then
        PUSH_OK=true
        break
    else
        log "${YELLOW}⚠ Push attempt ${attempt}/${MAX_PUSH_RETRIES} failed. Retrying in 5s...${RESET}"
        sleep 5
    fi
done
$PUSH_OK || die "Push failed after ${MAX_PUSH_RETRIES} attempts."
log "${GREEN}✓ Push successful.${RESET}"

# ========= Finish =========
log ""
log "${BOLD}${GREEN}======================================${RESET}"
log "${BOLD}${GREEN}✅ GitHub repository updated successfully!${RESET}"
log "${BOLD}${CYAN}🕒 Finished: $(date '+%d-%m-%Y %I:%M:%S %p') | ⏱ Took $(elapsed)${RESET}"
log "${BOLD}${GREEN}======================================${RESET}"

notify "Git Auto Push ✅" "${CHANGED_FILES} files pushed in $(elapsed)"
