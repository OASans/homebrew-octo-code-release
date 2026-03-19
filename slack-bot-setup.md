# Slack Bot Setup Guide

## 1. Create a Slack Workspace

Go to https://slack.com/get-started#/createnew — any free workspace works.

## 2. Create OctoCode App (one per worktree)

Go to https://api.slack.com/apps → **Create New App** → **From an app manifest** → select your workspace → **JSON** tab → paste:

```json
{
  "display_information": {
    "name": "OctoCode-WS1",
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
        "files:read"
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

**Create** → **Install to Workspace** → copy these two tokens:

1. **OAuth & Permissions** → copy **Bot User OAuth Token** (`xoxb-...`)
2. **Basic Information** → **App-Level Tokens** → **Generate Token and Scopes** → add `connections:write` → **Generate** → copy (`xapp-...`)

For additional worktrees, repeat with a different name (e.g., "OctoCode-WS2").

## 3. Create Test Helper App (shared, for E2E tests)

Same workspace, same flow → **Create New App** → **From an app manifest** → paste:

```json
{
  "display_information": {
    "name": "OctoCode Test Helper",
    "description": "Simulates real user actions for OctoCode E2E tests"
  },
  "features": {},
  "oauth_config": {
    "scopes": {
      "user": [
        "chat:write",
        "reactions:write",
        "channels:read",
        "files:write"
      ]
    }
  },
  "settings": {
    "org_deploy_enabled": false,
    "socket_mode_enabled": false,
    "token_rotation_enabled": false
  }
}
```

**Create** → **Install to Workspace** → **OAuth & Permissions** → copy **User OAuth Token** (`xoxp-...`).

Use the same token in all worktrees.

## 4. Get Your Slack User ID

In Slack: click your avatar → **Profile** → click the **⋯** menu → **Copy member ID**.

## 5. Configure `.env`

```
# From this worktree's OctoCode app (e.g., OctoCode-WS1)
SLACK_BOT_TOKEN=xoxb-...
SLACK_APP_TOKEN=xapp-...

# Your Slack user ID (Profile → ⋯ → Copy member ID)
SLACK_OWNER_USER_ID=U0...

# From shared OctoCode Test Helper app (same in all worktrees)
SLACK_TEST_USER_TOKEN=xoxp-...

# Unique per worktree (used as channel name prefix for test isolation)
SLACK_TEST_PREFIX=ws1
```

## 6. Launch

```
octo-code start --slack-bot-token xoxb-... --slack-app-token xapp-...
```

Or via config (`~/.octo-code/config.json`):
```json
{
  "remote": {
    "slack": {
      "botToken": "xoxb-...",
      "appToken": "xapp-...",
      "ownerUserId": "U0..."
    }
  }
}
```

---

## Why One App Per Worktree?

| Problem | Cause | Fix |
|---------|-------|-----|
| Events lost/split | Socket Mode round-robins across connections sharing an `xapp-` token | Separate app per worktree = separate connection |
| Rate limit contention | Limits are per-app | Separate app = separate budget |
| Channel collisions | Same names from different worktrees | `SLACK_TEST_PREFIX` + separate apps |

## Why a Separate Test Helper App?

Slack suppresses events for messages posted by the same app (loop prevention). The Test Helper is a different app, so its messages generate real `message.channels` and `reaction_added` events for OctoCode.

## Token Summary

| Token | Prefix | Source | Required |
|-------|--------|--------|----------|
| Bot User OAuth Token | `xoxb-` | OctoCode-WS* (per worktree) | Yes |
| App-Level Token | `xapp-` | OctoCode-WS* (per worktree) | Yes |
| Test User OAuth Token | `xoxp-` | OctoCode Test Helper (shared) | For E2E tests |

## Free Plan Limits

- 10 app limit (plan for N worktrees + 1 test helper)
- 90-day message retention
- Rate limits same as paid plans
