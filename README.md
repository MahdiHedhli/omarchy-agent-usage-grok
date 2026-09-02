# omarchy-agent-usage-grok

Grok usage collector for the [Omarchy](https://omarchy.org/) agents bar.

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
  `turn_completed` rows in `updates.jsonl`
- SuperGrok weekly (or monthly) pool and leftover prepaid credits from Grok
  ACP `_x.ai/billing` — the same source `/usage` uses
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

## Upstream

The collector is a drop-in for `omacom/omarchy` (`bin/omarchy-agent-usage-grok`
plus optional `shell/plugins/agents/assets/grok.svg` / `grok-light.svg` and
`providers.grok` in the agents manifest). Several open PRs already cover this
gap (`#7200`, `#6902`, …). This repo is the standalone, installable form with
omp `xai-oauth` included.

## License

MIT
