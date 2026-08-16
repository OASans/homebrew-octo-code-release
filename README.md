# OctoCode

Run multiple AI coding agents side by side and control them all with your voice.

OctoCode is a terminal-based environment that manages multiple OpenAI Codex CLI agents in a single tmux session. You speak commands, OctoCode transcribes them with Whisper, and sends them to the agent you're looking at.

## Install

```bash
brew tap OASans/octo-code-release
brew install octo-code
```

Requirements: **macOS on Apple Silicon**, **tmux** (installed automatically by Homebrew), and the [OpenAI Codex CLI](https://developers.openai.com/codex/cli/) installed and signed in.

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
          "startCommand": "codex"
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
          "startCommand": "codex",
          "projectPath": "/home/user/frontend"
        },
        {
          "name": "backend",
          "startCommand": "codex --full-auto",
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
        { "name": "react app", "startCommand": "codex", "projectPath": "/home/user/frontend" }
      ]
    },
    {
      "name": "backend",
      "agentConfigs": [
        { "name": "api server", "startCommand": "codex", "projectPath": "/home/user/backend" },
        { "name": "worker", "startCommand": "codex", "projectPath": "/home/user/worker" }
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
  "startCommand": "codex",
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

### Agent Status

The dashboard reads each agent's status directly from the Codex App Server, both for local agents and over SSH. No setup is needed: the working signal, approval waits, question prompts, and idle state — including activity from Codex subagents — update automatically.

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
