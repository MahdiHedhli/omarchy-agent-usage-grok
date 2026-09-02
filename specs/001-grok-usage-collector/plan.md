# Implementation Plan: Grok usage collector

**Branch**: `001-grok-usage-collector` | **Date**: 2026-09-02 | **Spec**: [spec.md](./spec.md)

## Summary

Ship `bin/omarchy-agent-usage-grok`, a Claude/Codex-shaped collector. Local
stats from Grok Build `updates.jsonl` plus pi/omp/OpenCode xAI rows. Limits
from ACP `_x.ai/billing`. User-space `install.sh` writes `grok.json` so the
agents panel lights up before the collector is packaged.

## Technical Context

**Language/Version**: Python 3.12+ (stdlib only; host has 3.14)

**Primary Dependencies**: Grok CLI on PATH for billing; `jq` for tests and atomic install

**Storage**: Session JSONL under `$GROK_HOME`; scan cache under `XDG_CACHE_HOME/omarchy/agent-usage`; panel record under `XDG_STATE_HOME/omarchy/agents/usage/grok.json`

**Testing**: `test/agent-usage-grok-scanner-test.sh` (bash + jq + python3 sqlite fixtures)

**Target Platform**: Omarchy Linux (Hyprland + omarchy-shell)

**Project Type**: CLI collector (drop-in for Omarchy `bin/`)

**Performance Goals**: Full session scan under a few seconds on a typical `~/.grok`; `--limits-only` reuses a same-day scan

**Constraints**: No third-party Python deps; no tokens in output; ACP money is cents

**Scale/Scope**: One collector script, one test file, install helper, two SVG marks, Spec Kit docs

## Constitution Check

- Record contract first: stdout JSON only — PASS
- Collector shape matches Claude/Codex flags — PASS
- Fixture tests, no live xAI in CI — PASS
- Local stats + ACP limits, cents, subagent skip — PASS
- Credentials off the record — PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-grok-usage-collector/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/usage-record.md
└── tasks.md
```

### Source Code (repository root)

```text
bin/omarchy-agent-usage-grok
install.sh
test/agent-usage-grok-scanner-test.sh
assets/grok.svg
assets/grok-light.svg
contrib/systemd/omarchy-agent-usage-grok.{service,timer}
```

## Implementation approach

1. Collector: scan native sessions, merge pi/omp/OpenCode, probe ACP, print record.
2. Tests: port the battle-tested scanner cases (nested/flat turns, cents, cache, pi, OpenCode) and add `xai-oauth`.
3. Install: copy collector to `~/.local/bin`, write `grok.json`, enable a user timer, refresh `omarchy.agents`.
4. Upstream: same `bin/` file is the Omarchy PR payload (`omacom/omarchy` branch `quattro`).
