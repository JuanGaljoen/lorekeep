#!/usr/bin/env bash
#
# Install lorekeep for all personal projects.
#
#   - Symlinks the six phase skills into ~/.claude/skills/ (globally available).
#   - Symlinks the agents into ~/.claude/agents/ (globally available).
#   - Symlinks the spine to ~/projects/personal/CLAUDE.md so Claude Code auto-loads
#     it for anything under ~/projects/personal/ — but not globally.
#   - Symlinks the safety-floor hook and the status line into ~/.claude/ and registers
#     both in settings.json.
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

DEST_AGENTS="$HOME/.claude/agents"
mkdir -p "$DEST_AGENTS"

echo "Linking agents into $DEST_AGENTS"
for target in "$REPO_DIR"/agents/*.md; do
  [ -f "$target" ] || continue
  a="$(basename "$target")"
  link="$DEST_AGENTS/$a"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "  ! $link exists and is not a symlink — leaving it alone" >&2
    continue
  fi
  ln -sfn "$target" "$link"
  echo "  $a -> $target"
done

echo "Linking spine"
if [ -e "$SPINE_LINK" ] && [ ! -L "$SPINE_LINK" ]; then
  echo "  ! $SPINE_LINK exists and is not a symlink — leaving it alone" >&2
else
  ln -sfn "$REPO_DIR/CLAUDE.md" "$SPINE_LINK"
  echo "  $SPINE_LINK -> $REPO_DIR/CLAUDE.md"
fi

echo "Linking safety-floor hook"
DEST_HOOKS="$HOME/.claude/hooks"
mkdir -p "$DEST_HOOKS"
chmod +x "$REPO_DIR/hooks/pre_tool_use.py"
ln -sfn "$REPO_DIR/hooks/pre_tool_use.py" "$DEST_HOOKS/pre_tool_use.py"
echo "  pre_tool_use.py -> $REPO_DIR/hooks/pre_tool_use.py"

echo "Linking status line"
STATUS_LINK="$HOME/.claude/statusline.sh"
chmod +x "$REPO_DIR/statusline/statusline.sh"
if [ -e "$STATUS_LINK" ] && [ ! -L "$STATUS_LINK" ]; then
  mv "$STATUS_LINK" "$STATUS_LINK.pre-lorekeep.bak"
  echo "  backed up your existing statusline.sh -> statusline.sh.pre-lorekeep.bak"
fi
ln -sfn "$REPO_DIR/statusline/statusline.sh" "$STATUS_LINK"
echo "  statusline.sh -> $REPO_DIR/statusline/statusline.sh"

echo "Registering the hook and status line in ~/.claude/settings.json (idempotent)"
python3 - "$HOME/.claude/settings.json" <<'PY'
import json, os, sys
path = sys.argv[1]
data = {}
if os.path.exists(path):
    with open(path) as f:
        try: data = json.load(f)
        except Exception: data = {}
cmd = "~/.claude/hooks/pre_tool_use.py"
pre = data.setdefault("hooks", {}).setdefault("PreToolUse", [])
already = any(h.get("command") == cmd for e in pre for h in e.get("hooks", []))
if already:
    print("  hook already registered")
else:
    pre.append({"matcher": "Bash|Edit|Write",
                "hooks": [{"type": "command", "command": cmd}]})
    print("  registered PreToolUse -> " + cmd)

status = {"type": "command", "command": "~/.claude/statusline.sh"}
if data.get("statusLine") == status:
    print("  status line already registered")
else:
    data["statusLine"] = status
    print("  registered statusLine -> " + status["command"])

with open(path, "w") as f:
    json.dump(data, f, indent=2); f.write("\n")
PY

echo "Done. Start a session under ~/projects/personal/ and the workflow is live."
