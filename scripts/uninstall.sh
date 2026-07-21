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

# Safety-floor hook: remove our symlink and deregister it, leaving other settings intact.
HOOK_LINK="$HOME/.claude/hooks/pre_tool_use.py"
if [ -L "$HOOK_LINK" ] && [ "$(readlink "$HOOK_LINK")" = "$REPO_DIR/hooks/pre_tool_use.py" ]; then
  rm "$HOOK_LINK"
  echo "unlinked safety-floor hook"
fi
# Status line: remove our symlink, restoring the pre-lorekeep file if we backed one up.
STATUS_LINK="$HOME/.claude/statusline.sh"
if [ -L "$STATUS_LINK" ] && [ "$(readlink "$STATUS_LINK")" = "$REPO_DIR/statusline/statusline.sh" ]; then
  rm "$STATUS_LINK"
  if [ -f "$STATUS_LINK.pre-lorekeep.bak" ]; then
    mv "$STATUS_LINK.pre-lorekeep.bak" "$STATUS_LINK"
    echo "restored your pre-lorekeep statusline.sh"
  else
    echo "unlinked status line"
  fi
fi

python3 - "$HOME/.claude/settings.json" <<'PY'
import json, os, sys
path = sys.argv[1]
if not os.path.exists(path): sys.exit(0)
with open(path) as f:
    try: data = json.load(f)
    except Exception: sys.exit(0)
cmd = "~/.claude/hooks/pre_tool_use.py"
hooks = data.get("hooks", {})
pre = hooks.get("PreToolUse", [])
kept = []
for e in pre:
    e["hooks"] = [h for h in e.get("hooks", []) if h.get("command") != cmd]
    if e["hooks"]: kept.append(e)
dirty = False
if pre:
    if kept: hooks["PreToolUse"] = kept
    else: hooks.pop("PreToolUse", None)
    if not hooks: data.pop("hooks", None)
    dirty = True
    print("deregistered safety-floor hook")

# Only deregister the status line if a real file wasn't restored in its place above.
if data.get("statusLine", {}).get("command") == "~/.claude/statusline.sh" \
        and not os.path.exists(os.path.expanduser("~/.claude/statusline.sh")):
    data.pop("statusLine")
    dirty = True
    print("deregistered status line")

if dirty:
    with open(path, "w") as f:
        json.dump(data, f, indent=2); f.write("\n")
PY

echo "Done."
