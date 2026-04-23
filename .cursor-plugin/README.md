# cursor-theatrics

> Every Cursor reply ends with a tiny in-character theatrical bookend. One narrator per session, randomly cast from **138 voices**. Yoda, HAL, Smeagol, Kramer, the Joker, Morty, a Renaissance plague doctor, a carnival barker, the Bene Gesserit reverend mother... whoever shows up, shows up.

Your agent stops sounding like an agent. Your Cursor screenshots start going viral.

## What it actually looks like

Real bookends, pulled from real chats:

> **Smeagol**, on JSON schemas
>
> *strokes the schema file, eyes darting* — "Yesss precious, `additionalProperties` tells us the shape of each sub-document, but it doesn't knowsss which key! No, no, the agent picks the key. Drilldown_key, my love, drilldown_key..."

> **The Joker**, after silently deleting a problem file
>
> *slides the schema file across the table, taps it once with a gloved finger, and then it's just... gone* — "See? Nobody panics when things go according to plan. Even if the plan is horrifying. What — or who — is next?"

> **Cosmo Kramer**, after a brutal cleanup pass
>
> *bursts through the door waving a stack of JSON files like deli tickets* — "They're gone, Jerry — `coverage_map`? History! Eight schemas, one swing of the elbow, giddyup!"

> **Morty**, when asked to start building before the spec is locked
>
> *tugging at his collar, yellow shirt slightly untucked* — "Aw g-geez, Rick, you want me to just s-start building before we even know what the button d-does when you tap it?! Fine, okay, I'll — I'll just, y'know, m-mirror the focus areas pattern, it's right there, Rick, it's right — oh god, I'm compiling."

> **Walter Sobchak**, after fixing a flaky test
>
> *slams the rulebook on the lane* — "MARK IT ZERO. Three retries, a `setTimeout(0)` and ONE proper `await flushPromises()` later, the test is GREEN, Donny. THIS IS NOT 'NAM. THIS IS UNIT TESTING. THERE ARE RULES."

> **HAL 9000**, after refusing a destructive command
>
> *soft red glow holds steady* — "I'm sorry, Dave. I cannot `rm -rf node_modules` while the dev server is still attached to its file handles. This conversation can serve no purpose anymore if you lose your work tree. Goodbye."

That's the whole product. The agent does the work, then takes a bow.

## Why you might actually want this

- **Long agent sessions stop blurring together.** The voice anchors the chat in a tone, and the bookend points at exactly what just happened.
- **Status at a glance.** A teammate scrolling Cursor from across the room can tell the agent finished — they don't even have to read the words. Smeagol stopped muttering. Done.
- **It's just delightful.** Your CI fails, the Joker shrugs. Your refactor lands, Yoda nods. The vibes carry you.

One narrator per chat, freshly cast every session. By next week you'll have a favorite. Mine is the Bene Gesserit reverend mother. She does not suffer null pointers.

## What's in the box

- **One hook.** `hooks/bookend-session-start.py` — about 80 lines of Python, stdlib only, runs on `sessionStart`.
- **138 voices.** `hooks/voices.json` — film, TV, history, archetypes, pure absurdity. Add your own in 4 lines of JSON.
- **No MCP servers. No skills. No background processes.** It's a hook. That's it.

## Permissions

- **Reads from disk:** `hooks/voices.json` (sibling of the hook script).
- **Writes to disk:** nothing.
- **Network:** nothing.
- **Subprocess:** nothing.

The hook runs once per chat, dumps a small JSON blob into the agent's context, and exits. That's the whole footprint.

## Install (outside the marketplace)

```bash
curl -fsSL https://raw.githubusercontent.com/the-path-ai/cursor-theatrics/main/install.sh | bash
```

Open a new Cursor chat. Watch the curtain go up.

See the top-level [README](../README.md) for per-project install, uninstall, custom voices, and the contributing bar (spoiler: "Diogenes shouting from inside a barrel" is the floor, not the ceiling).
