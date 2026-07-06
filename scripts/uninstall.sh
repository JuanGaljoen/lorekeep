#!/usr/bin/env bash
#
# Uninstall lorekeep. Removes only the symlinks this repo created — never the repo
# itself, and never anything that isn't a symlink pointing back here.

set -euo pipefail

REPO_DIR="$HOME/projects/personal/.claude"
DEST_SKILLS="$HOME/.claude/skills"
SPINE_LINK="$HOME/projects/personal/CLAUDE.md"

# Remove any symlink in ~/.claude/skills that points into this repo — covers every
# lorekeep skill without a hand-maintained list.
for link in "$DEST_SKILLS"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$REPO_DIR"/skills/*) rm "$link"; echo "unlinked skill: $(basename "$link")" ;;
  esac
done

if [ -L "$SPINE_LINK" ] && [ "$(readlink "$SPINE_LINK")" = "$REPO_DIR/CLAUDE.md" ]; then
  rm "$SPINE_LINK"
  echo "unlinked spine"
fi

echo "Done."
