#!/usr/bin/env python3
"""lorekeep safety floor — the only hook.

Prose in CLAUDE.md can *ask* the model not to do something; it can't *guarantee*
a block. This PreToolUse hook is that guarantee, for a short list of genuinely
catastrophic, hard-to-undo actions and secret leaks. Nothing judgemental — no
style, no process, no LOC caps. Read it; it's short.

Blocks (exit 2, with a reason on stderr):
  - catastrophic filesystem wipes  (rm -rf /, ~, $HOME, /*)
  - fork bombs
  - piping a remote download into a shell  (curl … | sh)
  - raw-disk destruction  (dd of=/dev/…, mkfs, > /dev/sd…)
  - writing to a .env / credential file
  - writing a hardcoded provider secret  (AWS / GitHub / Slack / OpenAI / private key)

Deliberately NOT blocked: force-push and `git reset --hard`. They're recoverable
(reflog) and often intentional — blocking them is the keystroke-policing lorekeep
rejects. This is a floor, not a sandbox: it catches the well-known catastrophic
forms, not every obfuscation.

Fails OPEN: any error in this hook lets the tool call through, so a bug here can
never brick your tools.
"""
import json
import re
import sys


def block(reason):
    print(f"lorekeep safety floor: {reason}", file=sys.stderr)
    sys.exit(2)


DANGEROUS_BASH = [
    (r"\brm\b[^\n]*\s-[a-zA-Z]*r[a-zA-Z]*\b[^\n]*\s(/|~|\$HOME|\$\{HOME\}|/\*)(\s|$)",
     "recursive delete of a root or home path"),
    (r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;\s*:", "fork bomb"),
    (r"\b(curl|wget)\b[^|\n]*\|\s*(sudo\s+)?(sh|bash|zsh)\b",
     "piping a remote download straight into a shell"),
    (r"\bdd\b[^\n]*\bof=/dev/(disk|sd|nvme|hd)", "raw write to a block device"),
    (r"\bmkfs(\.\w+)?\b", "formatting a filesystem"),
    (r">\s*/dev/(sd|nvme|disk|hd)\w", "redirect onto a raw disk device"),
]

CREDENTIAL_FILE = re.compile(
    r"(^|/)\.env(\.[\w.-]+)?$|(^|/)(\.aws/credentials|id_rsa|id_ed25519|\.npmrc|\.pypirc)$"
)

SECRETS = [
    (r"AKIA[0-9A-Z]{16}", "AWS access key id"),
    (r"ghp_[A-Za-z0-9]{36}", "GitHub personal access token"),
    (r"xox[baprs]-[A-Za-z0-9-]{10,}", "Slack token"),
    (r"sk-[A-Za-z0-9]{32,}", "OpenAI-style secret key"),
    (r"-----BEGIN [A-Z ]*PRIVATE KEY-----", "private key"),
]


def main():
    raw = sys.stdin.read()
    data = json.loads(raw) if raw.strip() else {}
    tool = data.get("tool_name", "")
    ti = data.get("tool_input", {}) or {}

    if tool == "Bash":
        cmd = ti.get("command", "") or ""
        for pattern, why in DANGEROUS_BASH:
            if re.search(pattern, cmd):
                block(f"blocked a dangerous command ({why}). Run it yourself if you truly mean to.")

    if tool in ("Write", "Edit", "MultiEdit"):
        path = ti.get("file_path", "") or ""
        if CREDENTIAL_FILE.search(path):
            block(f"refusing to write to a credential file: {path}")
        content = ti.get("content", "") or ti.get("new_string", "") or ""
        for pattern, why in SECRETS:
            if re.search(pattern, content):
                block(f"refusing to write what looks like a {why} — use an env var or secret store.")

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        sys.exit(0)  # fail open — never block on our own bug
