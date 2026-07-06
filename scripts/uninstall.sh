#!/usr/bin/env bash
#
# Uninstall lorekeep. Removes only the symlinks this repo created — never the repo
# itself, and never anything that isn't a symlink pointing back here.

set -euo pipefail

REPO_DIR="$HOME/projects/personal/.claude"
SKILLS=(recall understand design forge verify chronicle)
DEST_SKILLS="$HOME/.claude/skills"
SPINE_LINK="$HOME/projects/personal/CLAUDE.md"

for s in "${SKILLS[@]}"; do
  link="$DEST_SKILLS/$s"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$REPO_DIR/skills/$s" ]; then
    rm "$link"
    echo "unlinked skill: $s"
  fi
done

if [ -L "$SPINE_LINK" ] && [ "$(readlink "$SPINE_LINK")" = "$REPO_DIR/CLAUDE.md" ]; then
  rm "$SPINE_LINK"
  echo "unlinked spine"
fi

echo "Done."
