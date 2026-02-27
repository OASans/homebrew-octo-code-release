# OctoCode

Run multiple AI coding agents side by side and control them all with your voice.

OctoCode is a terminal-based environment that manages multiple AI coding agents (like Claude Code) in a single tmux session. You speak commands, OctoCode transcribes them with Whisper, and sends them to the agent you're looking at. No more typing the same instructions into multiple terminals.

## Install

```bash
brew tap OASans/octo-code-release
brew install octo-code
```

Requirements: **macOS on Apple Silicon**, **tmux** (installed automatically by Homebrew), and a working AI coding agent (e.g. [Claude Code](https://docs.anthropic.com/en/docs/claude-code)).

## Quick Start

```bash
octo-code
```

That's it. On first run, OctoCode:
1. Creates a default config at `~/.octo-code/config.json` with 2 agents
2. Opens a tmux session with a voice control dashboard and agent panels
3. Downloads the Whisper speech model (~1.5 GB, one-time)
4. Launches your agents

You'll see a grid: the **voice control dashboard** on the left, and your **agent panels** filling the rest. Each agent panel has a status bar (top 2 rows) and the agent's CLI below it.

### Try It

1. Click on an agent in the dashboard's agent monitor to select it
2. Press **Caps Lock** to start recording (the status indicator turns green)
3. Say your command — you'll see it appear in the "Pending Command" area
4. Press **Caps Lock** again to stop recording — the command is automatically sent to the selected agent

That's the core loop: select agent, speak, send.

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

Edit `~/.octo-code/config.json` to customize your setup.

### Minimal: One Agent

```json
{
  "whisperModel": "base",
  "agentConfigs": [
    {
      "description": "my project",
      "startCommand": "claude"
    }
  ]
}
```

### Multiple Local Agents

```json
{
  "whisperModel": "large-v3-turbo",
  "agentConfigs": [
    {
      "description": "frontend",
      "startCommand": "claude",
      "projectPath": "/home/user/frontend"
    },
    {
      "description": "backend",
      "startCommand": "claude --permission-mode plan",
      "projectPath": "/home/user/backend"
    }
  ]
}
```

### Remote Agents via SSH

```json
{
  "whisperModel": "large-v3-turbo",
  "agentConfigs": [
    {
      "description": "gpu server",
      "startCommand": "claude",
      "sshCommand": "ssh user@gpu-server.example.com",
      "projectPath": "/home/user/ml-training"
    }
  ]
}
```

When `sshCommand` is set, OctoCode connects via SSH first, then runs `startCommand` in the remote `projectPath`. SSH sessions auto-reconnect if the connection drops.

### Hot Reload

Press **Ctrl+R** to reload config without restarting. Changes to agent descriptions and VSCode keywords apply instantly. Changes to `startCommand`, `sshCommand`, or `projectPath` respawn the agent's pane. You can even add or remove agents on the fly.

## The Dashboard

The voice control dashboard shows:

- **Agent monitor** — grid of all agents with activity indicators. Green pulse = working, dim = idle. Click to select.
- **Button bar** — Clear (F9), Undo (Ctrl+Z), Redo (Ctrl+Y), Reload (Ctrl+R), Quit (Ctrl+Q). All clickable.
- **Pending command** — editable text area where voice transcripts appear before sending.
- **Notifications** — status messages (config reloaded, SSH reconnected, errors).
- **System metrics** — audio device status, CPU/memory, IPC health, SSH health.

## Agent Status Bar

Each agent has a 2-row status bar at the top of its panel:

**Row 1:** Activity signal, zoom button, VSCode button (if configured), agent name, init button.
**Row 2:** Working directory and current plan name (if detected).

| Button | Action |
|--------|--------|
| **FULL/GRID** | Toggle zoom — maximize this agent's panel or return to grid |
| **VS** | Focus the matching VSCode window (requires `vscodeKeyword` in config) |
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

## All Config Options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `whisperModel` | string | `"large-v3-turbo"` | Whisper model for speech recognition |
| `agentConfigs` | array | — | List of 1–8 agent configurations |
| `autoMuteTimeoutSecs` | number or null | null | Auto-mute after N seconds of silence while recording |
| `pauseMediaOnRecord` | boolean | true | Pause media playback during recording (macOS) |
| `preStartHook` | string or null | null | Shell command to run before session starts (e.g. auth refresh) |
| `sshKeepAliveInterval` | number | 60 | SSH keep-alive interval in seconds |

### Agent Config Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | yes | Display name shown in status bar |
| `startCommand` | string | yes | Command to launch the agent |
| `projectPath` | string | for SSH | Directory to start in |
| `sshCommand` | string | no | SSH connection command for remote agents |
| `vscodeKeyword` | string | no | Match VSCode window title for focus button |

## CLI Flags

| Flag | Description |
|------|-------------|
| `-c, --config <FILE>` | Config file path (default: `~/.octo-code/config.json`) |
| `--instance <ID>` | Session name suffix — tmux session becomes `octo-code-<ID>` |
| `-n, --agents <N>` | Use only the first N agents from config (1–8) |
| `-r, --resume` | Resume previous SSH sessions instead of starting fresh |
| `--debug` | Enable debug logging to files and show agent monitor panel |
| `--detached` | Run in background without attaching to tmux |
| `--no-audio` | Skip audio initialization (for testing) |
| `--snapshot` | Dump current session state as JSON |

### Running Multiple Sessions

Use `--instance` to run separate sessions side by side:

```bash
octo-code --instance work
octo-code --instance personal
```

Each session gets its own tmux session (`octo-code-work`, `octo-code-personal`) and can use a different config with `-c`.

## Whisper Models

Models are downloaded automatically to `~/.octo-code/models/` on first use.

| Model | Size | Speed | Quality | Good for |
|-------|------|-------|---------|----------|
| `tiny` / `tiny.en` | ~75 MB | Fastest | Basic | Quick testing |
| `base` / `base.en` | ~142 MB | Fast | Fair | Low-resource machines |
| `small` / `small.en` | ~466 MB | Moderate | Good | Balanced option |
| `medium` / `medium.en` | ~1.5 GB | Slower | High | Accuracy-focused |
| `large-v3-turbo` | ~1.5 GB | Fast | High | **Default — best balance** |
| `large-v3` | ~2.9 GB | Slowest | Highest | Maximum accuracy |

English-only models (`.en` suffix) are faster and more accurate if you only speak English.

## GPU Acceleration

Whisper uses GPU automatically when available:

- **macOS (Apple Silicon):** Metal — works out of the box, no setup needed.
- **Linux / WSL2 (NVIDIA):** CUDA — requires NVIDIA driver 470.76+ and CUDA toolkit.

Without a GPU, Whisper runs on CPU. Smaller models (`base`, `small`) work well on CPU. Larger models (`large-v3-turbo`) benefit significantly from GPU acceleration.

## Troubleshooting

**"No audio device found"** — Check that your microphone is connected and accessible. On WSL2, ensure PulseAudio/WSLg audio is working.

**Caps Lock not detected** — On Linux, OctoCode tries sysfs, then X11, then WSL2 PowerShell. If none work, check your system's Caps Lock LED support.

**Transcription is slow** — Try a smaller Whisper model (`base` or `small`) or enable GPU acceleration.

**Agent not responding to commands** — Make sure the agent is selected (highlighted in the agent monitor). Click its cell to select it.

**SSH agent keeps disconnecting** — Increase `sshKeepAliveInterval` in config. OctoCode auto-reconnects, but frequent drops may indicate network issues.

**Config changes not applying** — Press Ctrl+R to hot-reload. Some changes (like `whisperModel`) require a full restart.

## License

MIT
