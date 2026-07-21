#!/bin/bash
# Claude Code status line: model + token/context usage + Pro/Max rate-limit gauge
# + a live "⚒ pytest 7m35s" segment while a test suite is running.
#
# Rate-limit windows are color-coded: yellow >=75%, red >=90%. Only the 7-day cap
# also gets a ⚠️ (once past 80%), because that's the consequential wall — blowing it
# costs days, whereas the 5-hour window only costs a few hours' wait.
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
USED=$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)')
SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

LINE="[$MODEL] $((USED/1000))k / $((SIZE/1000))k tokens (${PCT}% context)"

FIVE=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
FIVE_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# colorize <intpct> <text> -> REPLY = text wrapped in yellow/red when high
colorize() {
  if   [ "$1" -ge 90 ]; then REPLY="\033[31m${2}\033[0m"   # red
  elif [ "$1" -ge 75 ]; then REPLY="\033[33m${2}\033[0m"   # yellow
  else REPLY="$2"; fi
}

# countdown <epoch-seconds> -> REPLY = "3d4h" / "4h12m" / "12m" until reset, "" if absent/past
countdown() {
  local resets_at="$1" now secs d h m
  REPLY=""
  [ -z "$resets_at" ] && return
  now=$(date +%s)
  secs=$(( resets_at - now ))
  [ "$secs" -le 0 ] && return
  d=$(( secs / 86400 )); h=$(( (secs % 86400) / 3600 )); m=$(( (secs % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then REPLY="${d}d${h}h"
  elif [ "$h" -gt 0 ]; then REPLY="${h}h${m}m"
  else REPLY="${m}m"; fi
}

LIMITS=""
if [ -n "$FIVE" ]; then
  n=$(echo "$FIVE" | cut -d. -f1); countdown "$FIVE_RESET"; cd="${REPLY:+ ($REPLY)}"
  colorize "$n" "5h ${n}%${cd}"
  LIMITS="$REPLY"
fi
if [ -n "$WEEK" ]; then
  n=$(echo "$WEEK" | cut -d. -f1); warn=""; [ "$n" -ge 80 ] && warn="⚠️ "
  countdown "$WEEK_RESET"; cd="${REPLY:+ ($REPLY)}"
  colorize "$n" "${warn}7d ${n}%${cd}"
  LIMITS="${LIMITS:+$LIMITS · }$REPLY"
fi
[ -n "$LIMITS" ] && LINE="$LINE · ⏳ $LIMITS"

# runner -> REPLY = "pytest 7m35s" for the longest-running test suite, "" if none.
#
# The footer's "1 shell" says a shell exists, but not what it is or how long it has
# been going — the one thing you want while waiting on a suite. Test runners only:
# broad "any background command" matching is noisy and hard to label usefully.
runner() {
  REPLY=$(ps -Ao etime=,args= 2>/dev/null | awk '
    # etime is [[dd-]hh:]mm:ss -> seconds
    function secs(e,   n, p, q, s) {
      s = 0
      n = split(e, p, "-")
      if (n == 2) { s = p[1] * 86400; e = p[2] }
      n = split(e, q, ":")
      if (n == 3) return s + q[1] * 3600 + q[2] * 60 + q[3]
      return s + q[1] * 60 + q[2]
    }
    BEGIN {
      n = 0
      pat[++n] = "(^|/)pytest( |$)";          lbl[n] = "pytest"
      pat[++n] = "-m +pytest( |$)";           lbl[n] = "pytest"
      pat[++n] = "(^|/)vitest( |$)";          lbl[n] = "vitest"
      pat[++n] = "(^|/)jest( |$)";            lbl[n] = "jest"
      pat[++n] = "(^|/)mocha( |$)";           lbl[n] = "mocha"
      pat[++n] = "(^|/)rspec( |$)";           lbl[n] = "rspec"
      pat[++n] = "(^|/)go +test( |$)";        lbl[n] = "go test"
      pat[++n] = "(^|/)cargo +test( |$)";     lbl[n] = "cargo test"
      pat[++n] = "(npm|pnpm|yarn)( run)? +test( |$)"; lbl[n] = "npm test"
      count = n; best = -1
    }
    {
      args = $0; sub(/^[^ ]+ +/, "", args)
      if (args ~ /awk|statusline/) next          # never match our own pipeline
      for (i = 1; i <= count; i++)
        if (args ~ pat[i]) {
          t = secs($1)
          if (t > best) { best = t; name = lbl[i] }
          break
        }
    }
    END {
      if (best < 0) exit
      h = int(best / 3600); m = int((best % 3600) / 60); s = best % 60
      if      (h > 0) printf "%s %dh%02dm", name, h, m
      else if (m > 0) printf "%s %dm%02ds", name, m, s
      else            printf "%s %ds", name, s
    }
  ')
}

runner
[ -n "$REPLY" ] && LINE="$LINE · ⚒ $REPLY"

printf '%b\n' "$LINE"
