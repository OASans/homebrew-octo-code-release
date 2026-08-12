# OctoCode

Run multiple AI coding agents side by side and control them all with your voice.

OctoCode is a terminal-based environment that manages multiple AI coding agents (like Claude Code) in a single tmux session. You speak commands, OctoCode transcribes them with Whisper, and sends them to the agent you're looking at.

## Install

```bash
brew tap OASans/octo-code-release
brew install octo-code
```

Requirements: **macOS on Apple Silicon**, **tmux** (installed automatically by Homebrew), and a working AI coding agent (e.g. [Claude Code](https://docs.anthropic.com/en/docs/claude-code)).

## Quick Start

```bash
octo-code start
```

That's it. On first run, OctoCode:
1. Creates a default config at `~/.octo-code/config.json` with 2 agents
2. Starts a background daemon that manages a tmux session
3. Opens a TUI with a voice control dashboard and agent panels
4. Downloads the Whisper speech model (~1.5 GB, one-time)

You'll see a grid: the **dashboard** on the left, and your **agent panels** filling the rest. Each agent panel has a status bar (top 2 rows) and the agent's CLI below it.

### Try It

1. Click on an agent in the dashboard's agent monitor to select it
2. Press **Caps Lock** to start recording (the status indicator turns green)
3. Say your command — you'll see it appear in the "Pending Command" area
4. Press **Caps Lock** again to stop recording — the command is sent to the selected agent

That's the core loop: select agent, speak, send.

### Lifecycle

OctoCode runs as a background daemon. Here are the commands you'll use:

```bash
octo-code start                  # Start a session and attach its TUI (also reattaches a running one)
octo-code status                 # Check if a session is running
octo-code stop                   # Stop the daemon, but keep your agent panels alive
octo-code q                      # Full teardown: stop + kill every tmux panel (alias: oc kill)
```

`stop` only stops the daemon — your local and remote agent tmux panels stay
running, so a later `octo-code start` reconnects you to your in-progress work.
Use `octo-code q` (or `oc kill`) when you want to tear everything down.

The short alias `oc` works for all commands: `oc start`, `oc stop`, etc.

## Voice Control

**Caps Lock** is your push-to-talk key:

| Caps Lock | State | What happens |
|-----------|-------|-------------|
| ON | Recording | Microphone active, speech transcribed to pending command area |
| OFF | Muted | Microphone off, pending command auto-sent to selected agent |

The **pending command area** in the dashboard shows your transcribed text before it's sent. You can edit it with the keyboard before sending — useful for fixing transcription mistakes.

Tips:
- You can type directly into the pending command area without using voice
- Multiple voice segments append to the same pending command, so you can pause and resume speaking
- Press **F9** to clear the pending command without sending
- **Ctrl+Z** / **Ctrl+Y** to undo/redo edits

### Agent Selection

OctoCode automatically tracks which agent you're working with based on tmux pane focus. Click on an agent's panel, and it becomes the target for your next voice command.

You can also click agent cells in the dashboard's agent monitor grid to switch between agents.

## Configuration

Edit `~/.octo-code/config.json` to customize your setup. Press **Ctrl+R** to reload config without restarting.

### Minimal: One Agent

```json
{
  "tabs": [
    {
      "name": "default",
      "agentConfigs": [
        {
          "name": "my project",
          "startCommand": "claude"
        }
      ]
    }
  ]
}
```

### Multiple Agents

```json
{
  "tabs": [
    {
      "name": "default",
      "agentConfigs": [
        {
          "name": "frontend",
          "startCommand": "claude",
          "projectPath": "/home/user/frontend"
        },
        {
          "name": "backend",
          "startCommand": "claude --permission-mode plan",
          "projectPath": "/home/user/backend"
        }
      ]
    }
  ]
}
```

Each tab supports up to 3 agents in a single row. Changes to `name` apply instantly on reload. Changes to `startCommand`, `sshCommand`, or `projectPath` respawn the agent's pane.

## The Dashboard

The voice control dashboard shows:

- **Agent monitor** — grid of all agents with activity indicators. Green pulse = working, dim = idle. Click to select.
- **Button bar** — Clear (F9), Undo (Ctrl+Z), Redo (Ctrl+Y), Reload (Ctrl+R), Quit (Ctrl+Q). All clickable.
- **Pending command** — editable text area where voice transcripts appear before sending.
- **In-dashboard status messages** — agent initialization, SSH reconnects, and errors; these are not operating-system notifications.
- **System metrics** — audio device status, CPU/memory, IPC health, SSH health.

## Agent Status Bar

Each agent has a 2-row status bar at the top of its panel:

**Row 1:** Activity signal, zoom button, agent name, init button.
**Row 2:** Working directory and current plan name (if detected).

| Button | Action |
|--------|--------|
| **FULL/GRID** | Toggle zoom — maximize this agent's panel or return to grid |
| **INIT** | Restart the agent's CLI pane (useful if an agent gets stuck) |

Click the agent name to rename it inline. The new name is saved to config automatically.

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Caps Lock | Toggle voice recording (push-to-talk) |
| F9 | Clear pending command |
| Ctrl+Z | Undo |
| Ctrl+Y | Redo |
| Ctrl+R | Reload config |
| Ctrl+Q | Quit (asks for confirmation) |
| Arrow keys | Navigate in pending command text |
| Home / End | Jump to start/end of line |
| Scroll wheel | Scroll pending command area |

---

## Extended Setup

The sections below cover features you can add incrementally once the basics are working.

### Tabs

Organize agents into tabs when you have more than a few. Each tab is its own grid, and you can switch between them.

```json
{
  "tabs": [
    {
      "name": "frontend",
      "agentConfigs": [
        { "name": "react app", "startCommand": "claude", "projectPath": "/home/user/frontend" }
      ]
    },
    {
      "name": "backend",
      "agentConfigs": [
        { "name": "api server", "startCommand": "claude", "projectPath": "/home/user/backend" },
        { "name": "worker", "startCommand": "claude", "projectPath": "/home/user/worker" }
      ]
    }
  ]
}
```

### Remote Agents via SSH

Run agents on remote machines. OctoCode connects via SSH, then runs your `startCommand` in the remote `projectPath`. SSH sessions auto-reconnect if the connection drops.

```json
{
  "name": "gpu server",
  "startCommand": "claude",
  "sshCommand": "ssh user@gpu-server.example.com",
  "projectPath": "/home/user/ml-training"
}
```

When `sshCommand` is set, `projectPath` is required.

#### Share remote tmux state across machines

When a laptop and server use the same instance and remote agent sessions, set `sharedRemoteAgents` to `true` in the configuration of the instance that joins the existing session:

```json
{
  "sharedRemoteAgents": true,
  "tabs": [ ... ]
}
```

With this setting, `octo-code start` attaches to a healthy daemon for that instance instead of replacing it. If no daemon exists, it starts one normally; if the existing daemon is unresponsive, set `sharedRemoteAgents` to `false` and start again to force a clean restart. `octo-code stop` preserves all agent tmux panels, while `octo-code q` (or `oc kill`) fully tears down the instance.

### Claude Code Hooks

These hooks provide a context/cost status line in the agent's shell and keep the dashboard's agent state current. They are **optional** — OctoCode works without them — but recommended for the full experience.

Add the following to the **global** `~/.claude/settings.json` on each machine where agents run (including remote SSH hosts):

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 -c \"\nimport sys,json\nfrom datetime import datetime\nd=json.load(sys.stdin)\ncw=d.get('context_window',{})\nco=d.get('cost',{})\npct=cw.get('used_percentage',0)\nsz=cw.get('context_window_size',0)\na=co.get('total_lines_added',0)\nr=co.get('total_lines_removed',0)\nszf=str(sz//1000)+'k' if sz>=1000 else str(sz)\nR='\\x1b[0m';B='\\x1b[1m';D='\\x1b[2m';G='\\x1b[32m';RE='\\x1b[31m'\ncc=lambda v:'\\x1b[31m' if v>=80 else '\\x1b[33m' if v>=50 else '\\x1b[36m'\no=D+'ctx:'+R+' '+cc(pct)+B+'%.0f%%'%pct+R+D+'/'+szf+R+'  '+D+'+'+R+G+str(a)+R+D+'/-'+R+RE+str(r)+R\nrl=d.get('rate_limits',{})\ndef rl_sec(key,lb):\n t=rl.get(key,{});p=t.get('used_percentage')\n if p is None:return ''\n s='  '+D+lb+':'+R+'  '+cc(p)+B+'%.0f%%'%p+R;ra=t.get('resets_at')\n if ra is not None:dt=datetime.fromtimestamp(ra);tf=dt.strftime('%H:%M') if lb=='5h' else dt.strftime('%a');s+=D+'\\u2192'+tf+R\n return s\no+=rl_sec('five_hour','5h')+rl_sec('seven_day','wk')\nprint(o,end='')\n\" 2>/dev/null || true"
  },
  "hooks": {
    "PermissionRequest": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "PreToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }, {
      "matcher": "AskUserQuestion|ExitPlanMode",
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "Notification": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "StopFailure": [{
      "matcher": "overloaded",
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }],
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "( flock -x -w 5 9; jq -c --arg aid \"$OCTO_AGENT_ID\" '. + {aid:$aid}' >> \"$OCTO_HOOK_FILE\" ) 9>\"$OCTO_HOOK_FILE.lock\" 2>/dev/null || true"
      }]
    }]
  }
}
```

The `hooks` entries (`PermissionRequest`, `PreToolUse`, `PostToolUse`, `Notification`, `Stop`, `StopFailure`, `UserPromptSubmit`) use file-based delivery: each writes a JSONL line to `OCTO_HOOK_FILE`. The shared `flock + jq + >>` command serializes concurrent writers and adds `OCTO_AGENT_ID` so the daemon can update the correct agent. Outside OctoCode, the hooks silently no-op because `OCTO_HOOK_FILE` is unset. Tool-use events mark an agent working; permission requests, ask-user questions, plan exits, a completed turn, and overload failures mark it as needing input. The Claude Code `Notification` hook is an event name, not a macOS or operating-system banner: OctoCode keeps only permission notifications and uses them to mark the agent as needing input. Stops from subagents or turns with live background work are ignored because the main agent is still active or will resume.

**Dependencies on the agent host (local Mac + every remote SSH host):** the hook command needs `flock` and `jq` on `PATH`. Linux distros ship `flock` in util-linux and `jq` in their default package manager. macOS users install both via Homebrew (`brew install flock jq`); OctoCode's `scripts/install_dependencies.sh` does this automatically.

The `statusLine` is local-only — it prints context usage, lines changed, and (for Claude.ai subscribers) 5-hour and weekly rate limit usage with reset times directly inside the agent's shell.

### Approval Hook for Dangerous Commands

Claude Code's `Bash(*)` permission allows all shell commands. To require confirmation for specific dangerous commands (like `rm` or `sudo`), add a `PreToolUse` hook to your **project's** `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(*)"]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"\nimport sys,json,os,re\nd=json.load(sys.stdin)\nc=d.get('tool_input',{}).get('command','')\nkws=sys.argv[1:]\ndef chk(t):\n for k in kws:\n  if re.search(r'\\b'+re.escape(k)+r'\\b',t):return k\nhit=chk(c)\nif not hit:\n for w in c.split():\n  p=w.strip(\\\"';\\\")\n  if p.endswith('.sh') and os.path.isfile(p):\n   try:\n    hit=chk(open(p).read())\n    if hit:break\n   except:pass\nif hit:\n hf=os.environ.get('OCTO_HOOK_FILE')\n if hf:\n  import fcntl\n  try:\n   g=open(hf,'a')\n   fcntl.flock(g,fcntl.LOCK_EX)\n   g.write(json.dumps({'aid':os.environ.get('OCTO_AGENT_ID',''),'hook_event_name':'PermissionRequest','tool_name':'Bash','tool_input':{'command':c}})+chr(10))\n   g.close()\n  except:pass\n json.dump({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'ask','permissionDecisionReason':hit+' requires approval'}},sys.stdout)\n\" rm sudo kill pkill"
          }
        ]
      }
    ]
  }
}
```

The hook checks whether any keyword appears in the command or in any `.sh` file it references. To gate additional commands, append them to the end: `\" rm sudo kill pkill chmod mv`.

When it decides to gate a command, the hook does two things: it returns `permissionDecision:"ask"` (so Claude Code shows the prompt) **and** it appends a synthetic `PermissionRequest` line to `$OCTO_HOOK_FILE`. That second write is the **status signal**: a hook-driven `ask` does **not** trigger Claude Code's own `PermissionRequest` hook (only the rule-based path does), so without it OctoCode would only see the matcherless `PreToolUse` and leave the agent flashing-green while it's actually parked at the prompt. The synthetic line makes the agent go solid-red (`need_input`) on the dashboard. This is belt-and-suspenders with the built-in `Notification` hook (which also catches the prompt): OctoCode's `need_input` edge is idempotent, so the two signals collapse to a single red edge — never a duplicate.

### Multiple Sessions

Use `--instance` to run separate sessions side by side:

```bash
octo-code start --instance work
octo-code start --instance personal
```

Each session gets its own tmux session (`octo-code-work`, `octo-code-personal`) and can use a different config with `-c`.

---

## Reference

### All Config Fields

#### Root

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `tabs` | array | *(required)* | Tabbed agent groups (at least 1 required) |
| `noAudio` | bool | `false` | Skip audio/whisper/VAD initialization |
| `debug` | bool | `false` | Enable debug mode with file logging |
| `sharedRemoteAgents` | bool | `false` | Attach to a healthy daemon for the same instance instead of replacing it when remote agent sessions are shared |
| `prevFinalCarryChars` | integer | `0` | Characters from the previous final transcript used to seed the next transcription; `0` disables carry-over |
| `commandSuffix` | string | `""` | Text appended to dashboard commands; slash and bang commands are sent unchanged |

#### Tab

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Display name (must be unique, non-empty) |
| `agentConfigs` | array | 1-3 agents per tab |

#### Agent

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Label shown in status bar. Must match `^[a-zA-Z][a-zA-Z0-9_-]*$` and be unique within a session |
| `startCommand` | string | yes | Command to launch the agent |
| `projectPath` | string | for SSH | Directory to start in |
| `sshCommand` | string | no | SSH connection command for remote agents |

### CLI Reference

```
octo-code <subcommand> [options]
```

| Subcommand | Description |
|------------|-------------|
| `start` | Start a session (runs the daemon in the background) and attach its TUI; also reattaches a running session |
| `stop` | Stop the daemon, keeping agent panels alive for reconnect |
| `q` (alias: `kill`) | Full teardown: stop + kill every tmux panel for the instance |
| `status` (alias: `ps`) | Check if a session is running |

Flags for `start`:

| Flag | Description |
|------|-------------|
| `-c, --config <FILE>` | Config file path (default: `~/.octo-code/config.json`) |
| `--instance <ID>` | Session name — tmux session becomes `octo-code-<ID>` |
| `--no-audio` | Skip audio initialization (for testing) |
| `--no-ui` | Launch the daemon only, without attaching this terminal's TUI (for testing) |

Flags for `stop`, `status`:

| Flag | Description |
|------|-------------|
| `--instance <ID>` | Target a specific session (default: `default`) |

### Whisper Model

OctoCode uses the `distil-large-v3` Whisper model — English-only, optimized for streaming latency on Apple Silicon. The model (~1.5 GB) is downloaded automatically on first run to `~/.octo-code/models/`.

### GPU Acceleration

Whisper uses GPU automatically when available:

- **macOS (Apple Silicon):** Metal — works out of the box, no setup needed.
- **Linux / WSL2 (NVIDIA):** CUDA — requires NVIDIA driver 470.76+ and CUDA toolkit.

Without a GPU, Whisper runs on CPU. The `distil-large-v3` model benefits significantly from GPU acceleration.

## Troubleshooting

**"No audio device found"** — Check that your microphone is connected and accessible. On WSL2, ensure PulseAudio/WSLg audio is working.

**Caps Lock not detected** — On Linux, OctoCode tries sysfs, then X11, then WSL2 PowerShell. If none work, check your system's Caps Lock LED support.

**Transcription is slow** — Ensure GPU acceleration is active (Metal on macOS, CUDA on Linux).

**Agent not responding to commands** — Make sure the agent is selected (highlighted in the agent monitor). Click its cell to select it.

**SSH agent keeps disconnecting** — OctoCode auto-reconnects, but frequent drops may indicate network issues.

**Config changes not applying** — Press Ctrl+R to hot-reload. Some changes require a full restart (`octo-code stop && octo-code start`).

## More Setup Guides

The release archive ships with a `release_docs/` folder containing deeper setup walkthroughs:

- `release_docs/gpu-acceleration.md` — Enabling CUDA/Metal for Whisper on your machine.
- `release_docs/wsl2-audio.md` — PulseAudio + ALSA wiring for WSL2 microphone capture.

## License

MIT
