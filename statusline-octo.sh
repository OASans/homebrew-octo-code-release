#!/usr/bin/env python3
# Claude Code status line script with OctoCode remote hook forwarding.
#
# Displays context window usage, code change stats, and optional rate limits
# in the Claude Code status line. Forwards status data to OctoCode's Slack
# bridge when OCTO_HOOK_SOCK is set.
#
# No external dependencies (no jq, no bc) — only Python 3 standard library.
#
# Setup: This script can be used standalone or the logic can be inlined
# directly into ~/.claude/settings.json (see release/README.md for the
# inline version). For standalone use:
#
#   "statusLine": {
#     "type": "command",
#     "command": "python3 ~/.claude/statusline-octo.sh"
#   }
#
# The forwarding only activates when OCTO_HOOK_SOCK is set (automatically
# exported by OctoCode in SSH agent sessions). Outside OctoCode, this
# script works as a normal status line with no side effects.

import sys, json, os, socket
from datetime import datetime

d = json.load(sys.stdin)
raw = json.dumps(d)

# Context window fields
cw = d.get('context_window', {})
co = d.get('cost', {})
used_pct = cw.get('used_percentage', 0)
ctx_size = cw.get('context_window_size', 0)
lines_added = co.get('total_lines_added', 0)
lines_removed = co.get('total_lines_removed', 0)
ctx_size_fmt = str(ctx_size // 1000) + 'k' if ctx_size >= 1000 else str(ctx_size)

# ANSI colors
RESET = '\x1b[0m'
BOLD = '\x1b[1m'
DIM = '\x1b[2m'
GREEN = '\x1b[32m'
RED = '\x1b[31m'

# Color thresholds: cyan < 50%, yellow 50-79%, red >= 80%
def color_for_pct(v):
    return '\x1b[31m' if v >= 80 else '\x1b[33m' if v >= 50 else '\x1b[36m'

out = (DIM + 'ctx:' + RESET + ' ' + color_for_pct(used_pct) + BOLD + '%.0f%%' % used_pct + RESET
       + DIM + '/' + ctx_size_fmt + RESET + '  ' + DIM + '+' + RESET + GREEN + str(lines_added) + RESET
       + DIM + '/-' + RESET + RED + str(lines_removed) + RESET)

# Optional rate limits (only present for Claude.ai subscribers, not AWS Bedrock)
rl = d.get('rate_limits', {})

def format_rate_limit(key, label):
    tier = rl.get(key, {})
    pct = tier.get('used_percentage')
    if pct is None:
        return ''
    s = '  ' + DIM + label + ':' + RESET + '  ' + color_for_pct(pct) + BOLD + '%.0f%%' % pct + RESET
    resets_at = tier.get('resets_at')
    if resets_at is not None:
        dt = datetime.fromtimestamp(resets_at)
        time_fmt = dt.strftime('%H:%M') if label == '5h' else dt.strftime('%a')
        s += DIM + '\u2192' + time_fmt + RESET
    return s

out += format_rate_limit('five_hour', '5h') + format_rate_limit('seven_day', 'wk')
print(out, end='')

# Forward status data to OctoCode bridge (fire-and-forget, no-op outside OctoCode)
sk = os.environ.get('OCTO_HOOK_SOCK', '')
if sk:
    try:
        s = socket.socket(socket.AF_UNIX)
        s.connect(sk)
        aid = os.environ.get('OCTO_AGENT_ID', '')
        s.sendall(('OCTO:' + aid + ':STATUS\n' + raw).encode())
        s.close()
    except Exception:
        pass
