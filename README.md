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
octo-code start                  # Start a new session (opens TUI automatically)
octo-code ui                     # Reattach TUI to a running session
octo-code status                 # Check if a session is running
octo-code stop                   # Stop a session and clean up
```

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
- **Notifications** — status messages (config reloaded, SSH reconnected, errors).
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

#### Sharing remote tmux state across machines

When the same project + agent names are configured on a powerful server (running OctoCode locally with full agents + Slack) and a laptop (SSHing out to the same server), both ends touch the same per-agent tmux sessions on the server. Use `octo-code start --remote` (`-r`) on whichever side starts second — instead of replacing the existing tmux state, it attaches to the running daemon.

```sh
# server (first):
octo-code start --instance shared

# laptop (second), with sshCommand pointing at the server:
octo-code start --remote --instance shared
```

Behavior of `--remote`:
- If a healthy daemon is already running for that instance, exit successfully without touching tmux state. Run `octo-code ui` to attach.
- If no daemon (or only a stale PID file), spawn a fresh daemon **but skip remote SSH agent-session teardown** — the existing remote tmux sessions on the other side stay alive.
- If a daemon process is alive but its IPC is unresponsive, error out and instruct you to run plain `octo-code start` (the destructive recovery path).

When the daemon was started with `--remote`, the matching `octo-code stop` preserves the remote SSH agent sessions on teardown so the co-tenant daemon keeps working. Use `octo-code stop --force` (`-f`) to override and tear down everything.

### Slack Integration

OctoCode can forward agent activity to Slack — permission requests and ask-user questions appear in per-agent channels. You can approve tool use directly from Slack (or your phone).

#### 1. Create a Slack Workspace

Go to https://slack.com/get-started#/createnew — any free workspace works.

#### 2. Create the OctoCode Slack App

Go to https://api.slack.com/apps, click **Create New App** > **From an app manifest**, select your workspace, switch to the **JSON** tab, and paste:

```json
{
  "display_information": {
    "name": "OctoCode",
    "description": "Voice-driven multi-agent dev environment"
  },
  "features": {
    "bot_user": {
      "display_name": "OctoCode",
      "always_online": false
    }
  },
  "oauth_config": {
    "scopes": {
      "bot": [
        "channels:manage",
        "channels:join",
        "channels:read",
        "channels:history",
        "groups:history",
        "chat:write",
        "reactions:read",
        "reactions:write",
        "files:read",
        "files:write"
      ]
    }
  },
  "settings": {
    "event_subscriptions": {
      "bot_events": [
        "message.channels",
        "message.groups",
        "reaction_added"
      ]
    },
    "socket_mode_enabled": true,
    "org_deploy_enabled": false,
    "token_rotation_enabled": false
  }
}
```

Click **Create**, then **Install to Workspace**, and collect two tokens:

1. **OAuth & Permissions** page > copy **Bot User OAuth Token** (`xoxb-...`)
2. **Basic Information** page > **App-Level Tokens** > **Generate Token and Scopes** > add scope `connections:write` > **Generate** > copy the token (`xapp-...`)

#### 3. Get Your Slack User ID

In Slack: click your avatar > **Profile** > click the **...** menu > **Copy member ID**.

#### 4. Add Slack Config

Add the `remote` block to your `~/.octo-code/config.json`:

```json
{
  "tabs": [ ... ],
  "remote": {
    "slack": {
      "botToken": "xoxb-...",
      "appToken": "xapp-...",
      "ownerUserId": "U0..."
    }
  }
}
```

Restart OctoCode and it will connect to Slack automatically.

### Claude Code Hooks

These hooks let OctoCode show a context/cost status line in the agent's shell and forward permission requests + ask-user questions to Slack. They are **optional** — OctoCode works without them — but recommended for the full experience.

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
    "Stop": [{
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

The `hooks` entries (`PermissionRequest`, `PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit`) use file-based delivery — each writes a JSONL line to the file specified by `OCTO_HOOK_FILE`. The same shell one-liner (`flock + jq + >>`) is used for every event: `flock` (POSIX advisory lock on `$OCTO_HOOK_FILE.lock`) serializes against concurrent writers and the daemon's read+truncate poll cycle, making the append race-free at any payload size; `jq` adds the writer's `OCTO_AGENT_ID` to the raw Claude Code stdin so the daemon can route the line to the right agent. When Claude Code runs outside OctoCode, the hooks silently no-op (the `OCTO_HOOK_FILE` env var is only set by OctoCode). The matcherless `PreToolUse` and `PostToolUse` entries fire on every tool call — OctoCode uses them to flip the agent's status signal to flashing-green after a permission approval (which Claude Code doesn't surface as a hook event), so the dashboard returns to "working" the moment the next tool runs. The second `PreToolUse` entry (matcher `AskUserQuestion|ExitPlanMode`) carries the rich payload OctoCode renders in Slack with sub-second latency. The `Stop` hook fires when Claude finishes a response, triggering an `@`-mention in the agent's Slack channel so you get notified that the agent is idle and may need input. The `UserPromptSubmit` hook fires when you submit a new prompt — OctoCode uses it to flip the agent's status signal to flashing-green so the dashboard reflects "this agent is now working" without waiting for screen output.

**Dependencies on the agent host (local Mac + every remote SSH host):** the hook command needs `flock` and `jq` on `PATH`. Linux distros ship `flock` in util-linux and `jq` in their default package manager. macOS users install both via Homebrew (`brew install flock jq`); OctoCode's `scripts/install_dependencies.sh` does this automatically.

The `statusLine` is local-only — it prints context usage, lines changed, and (for Claude.ai subscribers) 5-hour and weekly rate limit usage with reset times directly inside the agent's shell. Nothing is forwarded to Slack.

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
            "command": "python3 -c \"\nimport sys,json,os,re\nd=json.load(sys.stdin)\nc=d.get('tool_input',{}).get('command','')\nkws=sys.argv[1:]\ndef chk(t):\n for k in kws:\n  if re.search(r'\\b'+re.escape(k)+r'\\b',t):return k\nhit=chk(c)\nif not hit:\n for w in c.split():\n  p=w.strip(\\\"';\\\")\n  if p.endswith('.sh') and os.path.isfile(p):\n   try:\n    hit=chk(open(p).read())\n    if hit:break\n   except:pass\nif hit:\n json.dump({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'ask','permissionDecisionReason':hit+' requires approval'}},sys.stdout)\n\" rm sudo kill pkill"
          }
        ]
      }
    ]
  }
}
```

The hook checks whether any keyword appears in the command or in any `.sh` file it references. To gate additional commands, append them to the end: `\" rm sudo kill pkill chmod mv`.

### Peer Messaging Skill (optional)

Lets one agent send messages directly to another agent in the same session — useful when a client agent wants to delegate validation to a server-side agent without you copy-pasting between panes. This is opt-in: if the skill is not installed, agents simply can't send peer messages, and nothing fails.

The skill is a self-contained Claude Code skill folder shipped in this release archive. Install it once per machine:

```bash
cp -r release/skills/octo-peer ~/.claude/skills/
chmod +x ~/.claude/skills/octo-peer/peer.sh
```

For SSH-remote agents, run the same command on each remote host (the skill must live in `~/.claude/skills/octo-peer/` wherever Claude Code runs).

To enable peer messaging between specific agents, add a `peers` field (and optionally a `description`) to your agent configs:

```json
{
  "name": "frontend",
  "startCommand": "claude",
  "description": "Owns the React/TypeScript frontend.",
  "peers": ["backend"]
}
```

`peers` is auto-bidirectional: declaring `frontend.peers: ["backend"]` makes `backend` see `frontend` as a peer too. Agent names must match `^[a-zA-Z][a-zA-Z0-9_-]*$` (start with letter; then alphanumerics, underscore, or dash) and be unique within a session.

Once installed and configured, agents can use the skill via `bash ~/.claude/skills/octo-peer/peer.sh {list|send <name> <msg>|send-with-callback <name> <msg>}`. See `~/.claude/skills/octo-peer/SKILL.md` for the full agent-facing documentation.

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
| `remote` | object | `null` | Remote bridge config (see Slack Integration) |

#### Tab

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Display name (must be unique, non-empty) |
| `agentConfigs` | array | 1-3 agents per tab |

#### Agent

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Label shown in status bar |
| `startCommand` | string | yes | Command to launch the agent |
| `projectPath` | string | for SSH | Directory to start in |
| `sshCommand` | string | no | SSH connection command for remote agents |

#### Slack (`remote.slack`)

| Field | Type | Description |
|-------|------|-------------|
| `botToken` | string | Bot User OAuth Token (`xoxb-...`) |
| `appToken` | string | App-Level Token (`xapp-...`) |
| `ownerUserId` | string | Your Slack user ID for auto-invite to channels |

### CLI Reference

```
octo-code <subcommand> [options]
```

| Subcommand | Description |
|------------|-------------|
| `start` | Start a new session (runs in background, opens TUI) |
| `stop` | Stop a session and clean up |
| `status` (alias: `ps`) | Check if a session is running |
| `ui` | Reattach TUI to a running session |

Flags for `start`:

| Flag | Description |
|------|-------------|
| `-c, --config <FILE>` | Config file path (default: `~/.octo-code/config.json`) |
| `--instance <ID>` | Session name — tmux session becomes `octo-code-<ID>` |
| `--no-audio` | Skip audio initialization (for testing) |
| `--debug` | Enable debug logging |

Flags for `stop`, `status`, `ui`:

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

- `release_docs/slack-bot-setup.md` — Step-by-step Slack app + manifest setup for the phone-control bridge.
- `release_docs/gpu-acceleration.md` — Enabling CUDA/Metal for Whisper on your machine.
- `release_docs/wsl2-audio.md` — PulseAudio + ALSA wiring for WSL2 microphone capture.

## License

MIT
