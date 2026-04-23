#!/usr/bin/env bash
# Local pre-flight that mirrors the Cursor review-plugin-submission skill criteria:
# https://github.com/cursor/plugins/blob/main/create-plugin/skills/review-plugin-submission/SKILL.md
#
# Run before opening a PR or submitting to the marketplace.
#
# Usage: ./scripts/publish-checklist.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0

ok()   { printf "  \033[32mPASS\033[0m  %s\n" "$1"; PASS=$((PASS+1)); }
bad()  { printf "  \033[31mFAIL\033[0m  %s\n" "$1"; FAIL=$((FAIL+1)); }
section() { printf "\n\033[1m%s\033[0m\n" "$1"; }

require_file() {
  if [ -f "$1" ]; then ok "exists: $1"; else bad "missing: $1"; fi
}

section "Required top-level files"
require_file README.md
require_file LICENSE
require_file install.sh
require_file .gitignore

section "Marketplace plugin layout"
require_file .cursor-plugin/plugin.json
require_file .cursor-plugin/README.md
require_file hooks/hooks.json
require_file hooks/bookend-session-start.py
require_file hooks/voices.json

section "plugin.json schema sanity"
if python3 - <<'PYEOF'
import json, sys
required = ["name", "version", "description", "author", "license"]
m = json.load(open(".cursor-plugin/plugin.json"))
missing = [k for k in required if not m.get(k)]
assert not missing, f"missing fields: {missing}"
assert m["name"].islower() and "-" in m["name"] or m["name"].isalnum(), "name should be kebab-case lowercase"
hooks_path = m.get("components", {}).get("hooks", "")
assert hooks_path and not hooks_path.startswith("/"), f"hooks path must be relative, got: {hooks_path!r}"
import os
assert os.path.exists(hooks_path), f"hooks path does not exist: {hooks_path}"
PYEOF
then ok "plugin.json has all required fields and shape"
else bad "plugin.json failed schema check"
fi

section "hooks.json schema sanity"
if python3 - <<'PYEOF'
import json, os, sys
h = json.load(open("hooks/hooks.json"))
assert h.get("version") == 1, "version should be 1"
assert "sessionStart" in h.get("hooks", {}), "must register sessionStart"
for entry in h["hooks"]["sessionStart"]:
    assert "command" in entry, "each entry needs a command"
    cmd = entry["command"]
    assert os.path.exists(cmd), f"referenced script missing: {cmd}"
PYEOF
then ok "hooks.json valid + all referenced scripts exist"
else bad "hooks.json failed schema check"
fi

section "Hook smoke test (runs the actual script)"
if echo "" | python3 hooks/bookend-session-start.py | python3 -c "
import json, sys
d = json.loads(sys.stdin.read())
assert 'additional_context' in d, 'hook output missing additional_context'
assert len(d['additional_context']) > 500, 'context suspiciously short'
" 2>/dev/null
then ok "bookend-session-start.py emits valid JSON with non-trivial additional_context"
else bad "bookend-session-start.py smoke test failed"
fi

section "voices.json sanity"
if python3 - <<'PYEOF'
import json
v = json.load(open("hooks/voices.json"))
assert isinstance(v, list) and len(v) >= 10, "should be a list with at least 10 voices"
for entry in v:
    assert "name" in entry and "vibe" in entry, f"bad voice entry: {entry}"
print(f"  {len(v)} voices loaded")
PYEOF
then ok "voices.json well-formed"
else bad "voices.json failed sanity check"
fi

section "Installer syntax"
if bash -n install.sh; then ok "install.sh parses as valid bash"; else bad "install.sh has syntax errors"; fi

section "README required sections"
for needle in "## Install" "## How it works" "## License" "curl -fsSL"; do
  if grep -q "$needle" README.md; then ok "README contains: $needle"; else bad "README missing: $needle"; fi
done

printf "\n=================================\n"
printf "Passed: %d   Failed: %d\n" "$PASS" "$FAIL"
printf "=================================\n"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
