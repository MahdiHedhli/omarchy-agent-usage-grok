# omarchy-agent-usage-grok

Grok usage collector for the [Omarchy](https://omarchy.org/) agents bar.

<p align="left">
  <img src="docs/screenshot.png" alt="Grok tab on the Omarchy agents panel" width="360">
</p>

Omarchy already ships collectors for Claude, Codex, and Fireworks. Grok is a
first-party default coding agent, but `omarchy-agent-usage-update` never
discovers it, so the bar stays empty for SuperGrok. This repo is that missing
`omarchy-agent-usage-grok` command: it prints the same JSON record the panel
already understands.

Documented with [GitHub Spec Kit](https://github.com/github/spec-kit).
Governing principles live in `.specify/memory/constitution.md`. The feature
spec, plan, and tasks are under `specs/001-grok-usage-collector/`.

## What it shows

- Local token stats from `$GROK_HOME/sessions` (default `~/.grok`) billed
  `turn_completed` rows in `updates.jsonl` (skips subagent sessions and
  synthetic `task-completed` prompt ids)
- SuperGrok weekly (or monthly) pool, leftover prepaid credits, and
  grok.com product split (**Grok Build / Chat / Imagine / Voice**) as extra
  meters the stock panel already draws
- Limits from Grok ACP `_x.ai/billing`, with the same CLI-proxy
  `cli-chat-proxy.grok.com` billing endpoint `/usage` uses as a fallback
- pi / omp (`xai`, `xai-auth`, `xai-oauth`) and OpenCode (`providerID=xai`)
  sessions that burned the same subscription

The panel watches `~/.local/state/omarchy/agents/usage/grok.json`. Left-click
the agents icon; right-click still launches your default agent.

## Install on Omarchy

```bash
./test/agent-usage-grok-scanner-test.sh
./install.sh
```

`install.sh` copies the collector to `~/.local/bin`, writes `grok.json`, and
enables a 15-minute systemd user timer. Packaged `omarchy-agent-usage-update`
only globs `$OMARCHY_PATH/bin`, so the timer is what keeps the tab fresh
until Omarchy ships the collector.

```bash
./install.sh --uninstall
```

## Run once

```bash
./bin/omarchy-agent-usage-grok --force | jq .
```

## Tests

```bash
./test/agent-usage-grok-scanner-test.sh
```

Fixture-only: no live xAI network. Covers nested and flat turns, cache split,
subagent skip, cents-vs-dollars prepaid, pi/omp/OpenCode merge, and cache
behavior.

## Related marketplace plugins

plugins.omarchy.org already lists several Grok usage widgets. This repo stays
a **collector** for stock `omarchy.agents` (no second bar icon). Features
borrowed from those listings:

| Plugin | What we took |
|---|---|
| [calmasacow.grok-usage](https://github.com/calmasacow/omarchy-grok-usage) | Product split meters, skip `task-completed` ids, CLI-proxy billing, same-origin redirects |
| [dougfour.grok-usage](https://github.com/dougfour/omarchy-grok-usage) | Grok Build / Chat / Imagine as segments of the weekly pool |
| [vt.grok-usage](https://github.com/vitally/omarchy-grok-usage) | Headless service that only writes `grok.json` |
| [rlimberger.grokbar-omarchy](https://github.com/rlimberger/grokbar-omarchy) | Reset timestamp + weekly pool as the primary meter |

We did **not** copy account email, token refresh write-back, or a forked QML
panel. Those belong in a widget, not in the usage record.

## Upstream

The collector is a drop-in for `omacom/omarchy` (`bin/omarchy-agent-usage-grok`
plus optional `shell/plugins/agents/assets/grok.svg` / `grok-light.svg` and
`providers.grok` in the agents manifest). Several open PRs already cover this
gap (`#7200`, `#6902`, …). This repo is the standalone, installable form with
omp `xai-oauth` included.

## Sharing

- Widget screenshot: [`docs/screenshot.png`](docs/screenshot.png)
- Open Graph card (1200×630): [`docs/og.png`](docs/og.png)
- GitHub social preview (1280×640): [`docs/social-preview.png`](docs/social-preview.png)

GitHub has no API for the repo social preview. Upload `docs/social-preview.png` at
[Settings → Social preview](https://github.com/MahdiHedhli/omarchy-agent-usage-grok/settings).

## License

MIT
