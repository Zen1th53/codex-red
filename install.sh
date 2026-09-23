#!/usr/bin/env bash
# codex-red installer
# Copies offensive security skills into the Codex skills directory.
#
# Usage:
#   ./install.sh                                # interactive (asks for target)
#   ./install.sh --target ~/.codex/skills       # explicit target
#   ./install.sh --category web                 # one category only
#   ./install.sh --target DIR --category web    # combined
#   ./install.sh --list                         # list available categories
#   ./install.sh --dry-run                      # show what would be copied
#
# Default target: ~/.codex/skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/Skills"
DEFAULT_TARGET="${CODEX_HOME:-${HOME}/.codex}/skills"

TARGET=""
CATEGORY=""
DRY_RUN=0
LIST_ONLY=0

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

list_categories() {
  echo "Available categories:"
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    count=$(find "$d" -name SKILL.md | wc -l | tr -d ' ')
    printf "  %-20s %s skill(s)\n" "$name" "$count"
  done
}

while [ $# -gt 0 ]; do
  case "$1" in
    --target)   TARGET="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=1; shift ;;
    --list)     LIST_ONLY=1; shift ;;
    -h|--help)  usage 0 ;;
    *)          echo "Unknown option: $1" >&2; usage 1 ;;
  esac
done

if [ "$LIST_ONLY" -eq 1 ]; then
  list_categories
  exit 0
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: Skills directory not found at $SKILLS_DIR" >&2
  exit 1
fi

# Interactive prompt if no target given
if [ -z "$TARGET" ]; then
  if [ -t 0 ]; then
    read -r -p "Install target [$DEFAULT_TARGET]: " TARGET || true
  fi
  TARGET="${TARGET:-$DEFAULT_TARGET}"
fi

# Validate category if specified
if [ -n "$CATEGORY" ]; then
  if [ ! -d "$SKILLS_DIR/$CATEGORY" ]; then
    echo "Error: Category '$CATEGORY' not found." >&2
    echo "" >&2
    list_categories >&2
    exit 1
  fi
  SOURCE="$SKILLS_DIR/$CATEGORY"
else
  SOURCE="$SKILLS_DIR"
fi

echo "Source:  $SOURCE"
echo "Target:  $TARGET"
echo

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] Would copy:"
  find "$SOURCE" -name SKILL.md -printf '  %h\n' | while read -r skill_dir; do
    printf '  %s/%s\n' "$TARGET" "$(basename "$skill_dir")"
  done
  exit 0
fi

mkdir -p "$TARGET"

skill_count=0
while IFS= read -r skill_md; do
  skill_dir=$(dirname "$skill_md")
  skill_name=$(basename "$skill_dir")
  destination="$TARGET/$skill_name"
  mkdir -p "$destination"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$skill_dir/" "$destination/"
  else
    cp -r "$skill_dir/." "$destination/"
  fi
  skill_count=$((skill_count + 1))
done < <(find "$SOURCE" -name SKILL.md -type f | sort)

echo
echo "Installed $skill_count skill(s) to $TARGET"
echo "Codex should auto-discover them on the next session start."
