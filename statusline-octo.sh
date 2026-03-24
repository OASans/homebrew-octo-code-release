#!/usr/bin/env python3
# Claude Code status line script with OctoCode file-based hook forwarding.
#
# Displays context window usage, code change stats, and optional rate limits
# in the Claude Code status line. Forwards status data to OctoCode's Slack
# bridge when OCTO_HOOK_FILE is set, writing JSONL lines to a shared file.
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
# The forwarding only activates when OCTO_HOOK_FILE is set (automatically
# exported by OctoCode in agent sessions). Outside OctoCode, this script
# works as a normal status line with no side effects.

import sys, json, os, time
from datetime import datetime

d = json.load(sys.stdin)

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

# Forward status data to OctoCode via hook file (fire-and-forget, no-op outside OctoCode).
# Uses 5% bucket filtering: only writes a new line when the context usage percentage
# crosses a 5% threshold, reducing file I/O. A .pct sidecar file tracks the last
# written bucket value.
hook_file = os.environ.get('OCTO_HOOK_FILE', '')
if hook_file:
    bucket = int(used_pct // 5) * 5
    sidecar = hook_file + '.pct'

    # Read last written bucket from sidecar
    try:
        last_bucket = int(open(sidecar).read())
    except Exception:
        last_bucket = -1

    # Only write when bucket changes
    if bucket != last_bucket:
        aid = os.environ.get('OCTO_AGENT_ID', '')
        line = json.dumps({'type': 'status', 'aid': aid, 'ts': int(time.time()), 'data': d})
        open(hook_file, 'a').write(line + '\n')

        # Update sidecar with current bucket
        open(sidecar, 'w').write(str(bucket))

        # Truncate hook file if it grows too large: keep last 30 lines when > 200
        lines = open(hook_file).readlines()
        if len(lines) > 200:
            open(hook_file, 'w').writelines(lines[-30:])
