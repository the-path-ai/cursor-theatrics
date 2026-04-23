#!/usr/bin/env bash
# cursor-theatrics installer
# https://github.com/the-path-ai/cursor-theatrics
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash -s -- --project
#   curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash -s -- --uninstall
#
# Flags:
#   --project    Install into ./.cursor/ in the current directory (default: ~/.cursor/)
#   --uninstall  Remove the bookend hook and clean up hooks.json
#   --help       Show this message

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main"
HOOK_NAME="bookend-session-start.py"
VOICES_NAME="voices.json"

SCOPE="user"
ACTION="install"

for arg in "$@"; do
  case "$arg" in
    --project) SCOPE="project" ;;
    --user) SCOPE="user" ;;
    --uninstall) ACTION="uninstall" ;;
    --help|-h)
      sed -n '2,15p' "$0" 2>/dev/null || head -n 15 "$0"
      exit 0
      ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

if [ "$SCOPE" = "user" ]; then
  CURSOR_DIR="$HOME/.cursor"
else
  CURSOR_DIR="$(pwd)/.cursor"
fi

HOOKS_DIR="$CURSOR_DIR/hooks"
HOOKS_JSON="$CURSOR_DIR/hooks.json"
HOOK_SCRIPT="$HOOKS_DIR/$HOOK_NAME"
VOICES_JSON="$HOOKS_DIR/$VOICES_NAME"

# Pick a python interpreter for the merge step (and for hook execution).
PY=""
for candidate in python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    PY="$candidate"
    break
  fi
done
if [ -z "$PY" ]; then
  echo "cursor-theatrics: python3 is required (the bookend hook is a Python script). Aborting." >&2
  exit 1
fi

# Cross-shell idempotent merge / unmerge of hooks.json. Reads existing JSON,
# adds or removes the bookend entry from sessionStart without touching anything
# else, and writes it back atomically.
merge_hooks_json() {
  local mode="$1"   # "add" or "remove"
  local hook_path="$2"
  "$PY" - "$HOOKS_JSON" "$mode" "$hook_path" <<'PYEOF'
import json
import os
import sys

path, mode, hook_path = sys.argv[1], sys.argv[2], sys.argv[3]
data = {"version": 1, "hooks": {}}
if os.path.exists(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            existing = json.load(f)
        if isinstance(existing, dict):
            data = existing
            data.setdefault("version", 1)
            data.setdefault("hooks", {})
    except Exception as e:
        print(f"cursor-theatrics: existing {path} is not valid JSON ({e}); refusing to overwrite. Fix it and re-run.", file=sys.stderr)
        sys.exit(1)

session = data["hooks"].get("sessionStart", [])
session = [h for h in session if not (isinstance(h, dict) and h.get("command") == hook_path)]

if mode == "add":
    session.append({"command": hook_path, "timeout": 5})

if session:
    data["hooks"]["sessionStart"] = session
elif "sessionStart" in data["hooks"]:
    del data["hooks"]["sessionStart"]

tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
os.replace(tmp, path)
PYEOF
}

download() {
  local url="$1"
  local dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dest" "$url"
  else
    echo "cursor-theatrics: need curl or wget to download files. Aborting." >&2
    exit 1
  fi
}

if [ "$ACTION" = "uninstall" ]; then
  echo "cursor-theatrics: uninstalling from $CURSOR_DIR"
  if [ -f "$HOOKS_JSON" ]; then
    # Remove BOTH possible recorded paths (per-user resolves to absolute,
    # per-project to relative) so uninstall is symmetric with install.
    merge_hooks_json remove "$HOOK_SCRIPT"
    merge_hooks_json remove ".cursor/hooks/$HOOK_NAME"
  fi
  rm -f "$HOOK_SCRIPT" "$VOICES_JSON"
  echo "cursor-theatrics: removed. Open a new Cursor chat to confirm bookends are gone."
  exit 0
fi

echo "cursor-theatrics: installing to $CURSOR_DIR (scope: $SCOPE)"
mkdir -p "$HOOKS_DIR"

download "$REPO_RAW/hooks/$HOOK_NAME"   "$HOOK_SCRIPT"
download "$REPO_RAW/hooks/$VOICES_NAME" "$VOICES_JSON"
chmod +x "$HOOK_SCRIPT"

# For per-user installs, Cursor resolves command paths relative to $HOME, so
# we record an absolute path to be unambiguous. For per-project, a path
# relative to the project root is the convention.
if [ "$SCOPE" = "user" ]; then
  RECORDED_PATH="$HOOK_SCRIPT"
else
  RECORDED_PATH=".cursor/hooks/$HOOK_NAME"
fi

merge_hooks_json add "$RECORDED_PATH"

cat <<EOF
cursor-theatrics: installed.
  hook script: $HOOK_SCRIPT
  voices:      $VOICES_JSON
  registered:  $HOOKS_JSON (sessionStart -> $RECORDED_PATH)

Open a new Cursor chat. Every reply should now end (or open) with a
theatrical bookend in a randomly-chosen character voice.

Uninstall any time with:
  curl -fsSL $REPO_RAW/install.sh | bash -s -- --uninstall$([ "$SCOPE" = "project" ] && echo " --project")
EOF
