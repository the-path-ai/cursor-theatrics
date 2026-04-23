# cursor-theatrics (marketplace listing)

> Every Cursor reply ends (or opens) with a tiny in-character theatrical bookend. One narrator per session, randomly cast from ~75 voices.

This plugin installs a single `sessionStart` hook that injects a short rule into every chat. The rule asks the agent to commit to a single character voice for the entire session and end most replies with a 1-3 line dramatic flourish that's specific to whatever just happened.

## What's in the box

- **One hook** — `hooks/bookend-session-start.py`, ~80 lines of Python (stdlib only).
- **Voice gallery** — `hooks/voices.json`, ~75 named characters with vibe descriptions (Yoda, HAL 9000, the Mandalorian, Walter Sobchak, Bene Gesserit reverend mother, etc.).
- **No MCP servers, no skills, no rules.** Just the hook.

## Why a hook and not a rule

A `sessionStart` hook can shuffle the voice list per chat, so every conversation gets a fresh randomly-chosen pair of voices plus a wildcard. A static rule can't do that — it would always present the same options.

## Permissions

- Reads from disk: `hooks/voices.json` (sibling of the hook script).
- Writes to disk: nothing.
- Network: nothing.
- Subprocess: nothing.

## Install (outside the marketplace)

```bash
curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash
```

See the top-level [README](../README.md) for full options.
