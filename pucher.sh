#!/data/data/com.termux/files/usr/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Default configurations
REPO_DIR="$HOME/Files"
SOURCE_DIR="$HOME/storage/shared/GITHUB/CARGO"
DELETE_MODE=false
DRY_RUN=false
DELETE_PATTERN=""

# Display help menu manual
usage() {
    echo "================================================================="
    echo "🚀  GIT AUTO-SYNC CLI MANUAL"
    echo "================================================================="
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s PATH              Specify source directory"
    echo "                       (Current default: $SOURCE_DIR)"
    echo "  -r PATH              Specify Git repository directory"
    echo "                       (Current default: $REPO_DIR)"
    echo "  -l                   List contents of source and repo directories"
    echo "  -d                   Enable global mirror deletion"
    echo "  -x PATTERN           Delete SPECIFIC files matching a pattern"
    echo "                       (No quotes needed! e.g., -x *.log)"
    echo "  -n                   Preview sync changes (Dry run)"
    echo "  -h                   Display this help menu"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                     # Directly displays this manual"
    echo "  $(basename "$0") -l                  # See files in source and repo"
    echo "  $(basename "$0") -x *.log            # Delete all .log files"
    echo "  $(basename "$0") -d                  # Complete mirror sync layout"
    echo "================================================================="
    exit 0
}

# Function to list directory contents cleanly
list_directories() {
    echo "================================================================="
    echo "📂 SOURCE DIRECTORY CONTENTS ($SOURCE_DIR):"
    echo "================================================================="
    if [ -d "$SOURCE_DIR" ]; then
        find "$SOURCE_DIR" -not -path '*/.*' | sed "s|$SOURCE_DIR/||g" | grep -v '^$' || echo "Empty"
    else
        echo "❌ Source directory not found!"
    fi
    
    echo ""
    echo "================================================================="
    echo "🐙 REPOSITORY DIRECTORY CONTENTS ($REPO_DIR):"
    echo "================================================================="
    if [ -d "$REPO_DIR" ]; then
        find "$REPO_DIR" -not -path '*/.*' | sed "s|$REPO_DIR/||g" | grep -v '^$' || echo "Empty"
    else
        echo "❌ Repository directory not found!"
    fi
    exit 0
}

# Parse basic arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -s) SOURCE_DIR="$2"; shift 2 ;;
        -r) REPO_DIR="$2"; shift 2 ;;
        -l) list_directories ;;
        -d) DELETE_MODE=true; shift ;;
        -x) DELETE_PATTERN="$2"; shift 2 ;;
        -n) DRY_RUN=true; shift ;;
        -h|--help) usage ;;
        *) shift ;;
    esac
done

# NEW BEHAVIOR: If absolutely no arguments or flags were passed, default to showing the help manual
if [ -z "$DELETE_PATTERN" ] && [ "$DELETE_MODE" = false ] && [ "$DRY_RUN" = false ] && [ "$SOURCE_DIR" = "$HOME/storage/shared/GITHUB/CARGO" ] && [ "$REPO_DIR" = "$HOME/Files" ]; then
    if [ ! -n "$*" ]; then
        usage
    fi
fi

echo "🚀 Starting Git Auto Sync..."

# Prerequisite Check: Ensure rsync is installed
if ! command -v rsync &> /dev/null; then
    echo "📦 rsync not found. Installing now..."
    pkg install rsync -y
fi

# Verify repository exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "❌ Git repository not found: $REPO_DIR"
    exit 1
fi

# Go to repository
cd "$REPO_DIR"

# Handle Specific Pattern Deletion first if provided
if [ -n "$DELETE_PATTERN" ]; then
    echo "🗑️  Searching and removing target files matching: $DELETE_PATTERN..."
    if [ "$DRY_RUN" = true ]; then
        find . -type f -name "$DELETE_PATTERN" ! -path './.git/*' -print
    else
        find . -type f -name "$DELETE_PATTERN" ! -path './.git/*' -delete
    fi
fi

# Detect current branch
BRANCH=$(git branch --show-current)
if [ -z "$BRANCH" ]; then
    echo "❌ Could not detect current Git branch."
    exit 1
fi

# Setup rsync options dynamically
RSYNC_OPTS="-rtuv --exclude='.git/' --exclude='$(basename "$0")'"
if [ "$DELETE_MODE" = true ]; then
    echo "🛡️  Global deletion sync enabled (mirroring source layout)."
    RSYNC_OPTS="$RSYNC_OPTS --delete"
fi

if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN: Previewing workspace changes only."
    RSYNC_OPTS="$RSYNC_OPTS --dry-run"
fi

echo "📂 Syncing workspace..."
if [ -d "$SOURCE_DIR" ]; then
    rsync $RSYNC_OPTS "$SOURCE_DIR/" .
else
    echo "❌ Source directory not found: $SOURCE_DIR"
    exit 1
fi

# If dry-run, stop safely here
if [ "$DRY_RUN" = true ]; then
    echo "✅ Dry run complete. No modifications were committed."
    exit 0
fi

echo "➕ Staging changes..."
git add -A

# Check if anything changed
if git diff --cached --quiet; then
    echo "✅ No changes detected in working tree."
    exit 0
fi

echo "💾 Committing local variations..."
git commit -m "Auto update $(date '+%Y-%m-%d %H:%M:%S')"

echo "⬇️ Pulling latest changes from remote..."
git pull --rebase -X theirs origin "$BRANCH"

echo "⬆️ Pushing to remote upstream..."
git push origin "$BRANCH"

echo "🎉 Sync completed successfully!"
