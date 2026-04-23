# cursor-theatrics

> Every Cursor reply ends (or opens) with a tiny in-character theatrical bookend. One narrator per session, randomly cast from **138 voices**.

A single Cursor `sessionStart` hook that injects a short rule into every chat. The rule asks the agent to pick a character voice for the session and end most replies with a 1-3 line dramatic flourish that's specific to whatever just happened.

It's silly. It's also weirdly useful — it makes long agent sessions feel like a story instead of a wall of monospace, and a teammate scrolling Slack from the other room can tell at a glance that the agent finished without reading a word.

## Install

One line, into your Cursor user config (`~/.cursor/`), affecting every Cursor session for your account:

```bash
curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash
```

Open a new Cursor chat. That's it.

### Per-project install instead

If you only want bookends in one repo (e.g. you're committing them so your whole team gets them), run from the project root with `--project`:

```bash
curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash -s -- --project
```

This writes into `./.cursor/hooks/` and `./.cursor/hooks.json` in the current directory. Commit them and your teammates get bookends with zero install on their end.

### Uninstall

Same one-liner, with `--uninstall`:

```bash
curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash -s -- --uninstall
```

(Add `--project` if that's where you installed it.)

## A few examples

> *Slams the rulebook on the lane* — "MARK IT ZERO. Three retries, a `setTimeout(0)` and ONE proper `await flushPromises()` later, the test is GREEN, Donny. THIS IS NOT 'NAM. THIS IS UNIT TESTING. THERE ARE RULES."

— **Walter Sobchak**, after fixing a flaky test

> *Soft red glow holds steady* — "I'm sorry, Dave. I cannot `rm -rf node_modules` while the dev server is still attached to its file handles. This conversation can serve no purpose anymore if you lose your work tree. Goodbye."

— **HAL 9000**, after declining a destructive command

> *Helmet tilts at the merge button, Grogu cooing in the satchel* — "One commit. No console.logs. Ten lines down, four lines added, all of them earned. This is the way."

— **The Mandalorian**, after a clean PR

More in [examples/sample-bookends.md](examples/sample-bookends.md).

## How it works

Cursor supports [hooks](https://cursor.com/docs/hooks) — short scripts that run at lifecycle events and can return JSON to the agent. This package ships exactly one hook on `sessionStart`:

```
~/.cursor/
├── hooks.json                       Registers the hook
└── hooks/
    ├── bookend-session-start.py     ~80 lines, stdlib only
    └── voices.json                  138 named characters
```

Every time you open a Cursor chat, the hook:
1. Loads the voice gallery.
2. Randomly samples 2 voices for this session.
3. Returns `{"additional_context": "..."}` containing the bookend rule plus those 2 voices and a wildcard slot.

The agent picks one (or invents its own from the wildcard prompt) and rides it for the entire conversation. The voice is consistent within a chat and randomly different next time.

The whole hook is here: [hooks/bookend-session-start.py](hooks/bookend-session-start.py).

## Configuration

### Add your own voices

Edit `~/.cursor/hooks/voices.json` (or `./.cursor/hooks/voices.json` for project installs). Format:

```json
{
  "name": "Tony Stark in the workshop",
  "vibe": "Holographic schematics swiped aside, JARVIS roasting from the rafters, repulsor gauntlet half-built on the bench, sarcasm at 110% throttle."
}
```

The `name` shows up in the bullet list the agent sees. The `vibe` is a one-sentence character brief — it's the only thing the agent has to riff on, so make it physical, specific, and a little weird.

### Change how many voices are sampled per session

In [hooks/bookend-session-start.py](hooks/bookend-session-start.py), this line:

```python
session_voices = random.sample(voices, min(2, len(voices)))
```

Bump `2` to `3` or `4` if you want more options per session. The wildcard slot is always added on top.

### Disable temporarily

Easiest: comment out the `sessionStart` entry in `~/.cursor/hooks.json`. Or just `--uninstall` and reinstall later — your custom voices in `voices.json` will be wiped, so back that file up first if you've added any.

## The voice gallery

138 characters across film, TV, history, archetypes, and pure absurdity. A small sample:

| Tier 1 (the heavyweights) | Tier 2 (specific energy) | Tier 3 (deep cuts) |
| --- | --- | --- |
| Yoda | Walter Sobchak | Anti-Whig pamphleteer |
| HAL 9000 | Werner Herzog narrating | Renaissance plague doctor |
| The Mandalorian | Hercule Poirot | Macbeth's three witches |
| Gandalf the Grey | Bob Ross | Carnival barker |
| Don Vito Corleone | Larry David | Soviet propaganda poster |
| Jack Sparrow | Statler & Waldorf | Old bluesman on a porch |

Full list: [hooks/voices.json](hooks/voices.json).

## Marketplace

This plugin is also packaged for the [Cursor Marketplace](https://cursor.com/marketplace) — see [.cursor-plugin/plugin.json](.cursor-plugin/plugin.json). Marketplace listings are curated, so the install one-liner above is the fastest path until/unless we get accepted there.

## Contributing

PRs to [hooks/voices.json](hooks/voices.json) very welcome. Bar for a new voice:

1. **Specific.** "A philosopher" is a no. "Diogenes shouting from inside a barrel, masturbating in the agora to make a point" is a yes.
2. **Physical.** Hands, posture, props, costume. Something the agent can mime around.
3. **A little absurd.** The voice should make a teammate snort if they read it in a Slack screenshot, before the bookend even lands.

Run the local pre-flight check before opening a PR:

```bash
./scripts/publish-checklist.sh
```

## License

[MIT](LICENSE). Have fun. Remix it. Ship it as `cursor-melodrama` if you want.
