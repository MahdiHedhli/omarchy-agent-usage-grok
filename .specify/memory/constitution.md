# Omarchy Grok Usage Collector Constitution

## Core Principles

### I. Record Contract First

The agents panel is a display. This project MUST print one display-ready JSON
record on stdout that matches the Omarchy `schemaVersion` 1 usage contract
used by `omarchy.agents`. The panel MUST never learn Grok session formats,
ACP methods, or credential paths. Adding Grok MUST NOT require QML changes.

### II. Collector Shape

The deliverable is `omarchy-agent-usage-grok`, a Python 3 CLI matching the
Claude and Codex collectors: `--force` and `--limits-only`, stderr for
diagnostics, stdout for the JSON record, no interactive prompts. Discovery
for the packaged updater is `$OMARCHY_PATH/bin/omarchy-agent-usage-*`. A
user-space install MUST still be able to write
`~/.local/state/omarchy/agents/usage/grok.json` so the panel can light up
before Omarchy ships the collector.

### III. Test-First Against Fixtures (NON-NEGOTIABLE)

Scanner and billing behavior MUST be covered by a shell test that never
talks to live xAI endpoints. Fixtures MUST use dummy ids, not live UUIDv7s.
A live SuperGrok account is for manual verification only.

### IV. Local Stats Plus Account Limits

Local token stats come from billed `turn_completed` rows under `$GROK_HOME`
(plus pi/omp/opencode xAI sessions). Rate limits and prepaid balance come
from Grok ACP `_x.ai/billing` — the same source `/usage` uses. Cache read
MUST be split out of input. Subagent sessions MUST be skipped. ACP
`Money.val` is integer cents.

### V. Credentials Stay Off the Record

`auth.json` and access tokens MUST never appear in the printed record, the
cache, or tests. Missing or expired sign-in keeps local stats and asks for
`grok login`. Transport misses MAY set `retryAdvised`; HTTP auth failures
MUST NOT.

## Constraints

- Python 3 stdlib only. No third-party Python packages.
- Match Omarchy collector style: 2-space indent, hidden `omarchy:` headers.
- Do not edit `/usr/share/omarchy/` as the source of truth. Upstream
  contribution is a PR to `omacom/omarchy` that adds this collector to `bin/`.
- Official Grok mark (from grok.com favicon paths) for optional panel assets.

## Workflow

1. Spec Kit constitution, spec, plan, and tasks live in this repository.
2. `./test/agent-usage-grok-scanner-test.sh` MUST pass before push.
3. Local install writes `grok.json` and keeps it fresh without requiring a
   packaged Omarchy update.
4. Upstream PRs stay scoped to the collector, tests, assets, manifest
   enablement, and agents-panel docs.

## Governance

This constitution supersedes informal shortcuts. Amendments require a
version bump and a dated note here. PRs MUST keep the record contract
stable: adding fields is fine; renaming or dropping panel-read fields is not.

**Version**: 1.0.0 | **Ratified**: 2026-09-02 | **Last Amended**: 2026-09-02
