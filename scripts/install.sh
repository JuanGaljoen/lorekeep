#!/usr/bin/env bash
#
# Install lorekeep for all personal projects.
#
#   - Symlinks the six phase skills into ~/.claude/skills/ (globally available).
#   - Symlinks the spine to ~/projects/personal/CLAUDE.md so Claude Code auto-loads
#     it for anything under ~/projects/personal/ — but not globally.
#
# Idempotent: safe to re-run after a `git pull`. Symlinks point back into this repo,
# so edits here flow through to your live workflow with no reinstall.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

DEST_SKILLS="$HOME/.claude/skills"
SPINE_LINK="$HOME/projects/personal/CLAUDE.md"

mkdir -p "$DEST_SKILLS"

echo "Linking skills into $DEST_SKILLS"
for target in "$REPO_DIR"/skills/*/; do
  target="${target%/}"                  # strip trailing slash
  [ -f "$target/SKILL.md" ] || continue # only real skills
  s="$(basename "$target")"
  link="$DEST_SKILLS/$s"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "  ! $link exists and is not a symlink — leaving it alone" >&2
    continue
  fi
  ln -sfn "$target" "$link"
  echo "  $s -> $target"
done

echo "Linking spine"
if [ -e "$SPINE_LINK" ] && [ ! -L "$SPINE_LINK" ]; then
  echo "  ! $SPINE_LINK exists and is not a symlink — leaving it alone" >&2
else
  ln -sfn "$REPO_DIR/CLAUDE.md" "$SPINE_LINK"
  echo "  $SPINE_LINK -> $REPO_DIR/CLAUDE.md"
fi

echo "Done. Start a session under ~/projects/personal/ and the workflow is live."
