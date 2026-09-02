# Feature Specification: Grok usage collector for the Omarchy agents bar

**Feature Branch**: `001-grok-usage-collector`

**Created**: 2026-09-02

**Status**: Active

**Input**: Add a Grok usage collector so the Omarchy agents bar shows SuperGrok weekly limits, prepaid credits, and local token stats next to Claude, Codex, and Fireworks. Install it on this machine for testing. Document the work with GitHub Spec Kit. Publish a GitHub repo and prepare an upstream contribution to Omarchy.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Grok tab from local sessions (Priority: P1)

A user who runs Grok Build on Omarchy opens the agents panel and sees a Grok tab with today / last week / all-time token stats taken from billed session turns.

**Why this priority**: Without local stats the widget stays hidden even when Grok is the default coding agent.

**Independent Test**: Point `GROK_HOME` at a fixture tree with `updates.jsonl` `turn_completed` rows and assert prompt, session, and token totals.

**Acceptance Scenarios**:

1. **Given** a Grok session with two billed `turn_completed` events, **When** the collector runs `--force`, **Then** the record has `id=grok`, `todayPrompts=2`, `todaySessions=1`, and cache split out of input.
2. **Given** `session_kind` `subagent` or `subagent_fork`, **When** the collector scans, **Then** those sessions are ignored so parent totals are not doubled.
3. **Given** only `events.jsonl` / `chat_history.jsonl`, **When** the collector scans, **Then** it invents no tokens.

---

### User Story 2 - SuperGrok limits and prepaid credits (Priority: P1)

A signed-in SuperGrok user sees the same plan label and weekly (or monthly) meter that Grok `/usage` shows, plus leftover prepaid credits as a balance when the ledger is non-zero.

**Why this priority**: The panel's meters are the reason people open the widget.

**Independent Test**: Stub `grok agent stdio` `_x.ai/billing` and assert `limits[]`, `tierLabel`, and `balance`.

**Acceptance Scenarios**:

1. **Given** `creditUsagePercent` 31 and a weekly period, **When** billing succeeds, **Then** `limits[0]` is Weekly at 0.31 with the period end as `resetsAt`.
2. **Given** `prepaidBalance.val` 488, **When** billing is parsed, **Then** `balance.remaining` is 4.88 (cents, not dollars).
3. **Given** a zero prepaid ledger, **When** billing is parsed, **Then** there is no `balance` field — only the weekly meter.
4. **Given** billing 401, **When** the collector runs, **Then** status is "Sign-in expired" and `retryAdvised` is absent.

---

### User Story 3 - Other harnesses that burn SuperGrok (Priority: P2)

A SuperGrok subscription used through pi, omp (including `xai-oauth`), or OpenCode still appears on the Grok tab.

**Why this priority**: Claude and Codex already merge those harnesses; Grok must not under-count.

**Independent Test**: Fixture pi/omp JSONL and an OpenCode SQLite DB with `providerID=xai`.

**Acceptance Scenarios**:

1. **Given** pi/omp assistant rows on `xai`, `xai-auth`, or `xai-oauth`, **When** scanned, **Then** those tokens merge into the Grok record and other providers are ignored.
2. **Given** OpenCode messages with `providerID=xai`, **When** scanned, **Then** they count; `xai-proxy` and user rows do not.
3. **Given** a broken OpenCode DB, **When** scanned, **Then** the incomplete result is not cached.

---

### User Story 4 - Install on this machine and keep the panel fresh (Priority: P1)

The collector is installed on this Omarchy host so the live agents bar shows Grok without waiting for an Omarchy package update.

**Why this priority**: The user asked to test it here.

**Independent Test**: Run `./install.sh`, confirm `~/.local/state/omarchy/agents/usage/grok.json` exists with `ready: true` and live session stats.

**Acceptance Scenarios**:

1. **Given** this machine's `~/.grok/sessions`, **When** install runs, **Then** `grok.json` is written atomically and the agents panel can refresh onto it.
2. **Given** a user-space install, **When** Omarchy later ships the collector, **Then** the user-space files can be removed without leftover wrappers breaking packaged update.

---

### Edge Cases

- Empty `$GROK_HOME` still prints a valid record with `authHelpText` asking for `grok login`.
- Unwritable cache still prints a complete record.
- Cache from another local date is a miss.
- Future-dated cache mtime is a miss.
- Mise wrapper noise and ACP notifications on stdio are skipped.
- `SuperGrokPro` rewrites to `SuperGrok Pro`; display strings like `SuperGrok Heavy` pass through.
- Duplicate `prompt_id` in one file counts once.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Print one JSON object on stdout matching Omarchy usage `schemaVersion` 1, `id` `grok`, `name` `Grok`.
- **FR-002**: Honor `--force` (ignore scan cache) and `--limits-only` (reuse same-day scan; billing always fresh).
- **FR-003**: Scan `$GROK_HOME/sessions` (default `~/.grok/sessions`) `updates.jsonl` `turn_completed` rows (nested `usage`, flat token fields, or `event_name`).
- **FR-004**: Subtract cache read/write from input with `max(0, …)` so panel buckets stay exclusive.
- **FR-005**: Skip `session_kind` values that start with `subagent`.
- **FR-006**: Merge pi/omp xAI sessions and OpenCode `providerID=xai` messages.
- **FR-007**: Probe Grok ACP `_x.ai/billing` via `grok agent --no-leader stdio`.
- **FR-008**: Treat ACP money `val` as integer cents.
- **FR-009**: Never write tokens or `auth.json` into the record or cache.
- **FR-010**: Provide `install.sh` that writes `grok.json` on this host and a timer to refresh it.
- **FR-011**: Ship optional `assets/grok.svg` and `assets/grok-light.svg` using the official mark.

### Key Entities

- **Usage record**: the JSON object the panel watches.
- **Turn ledger**: one billed `turn_completed` (or xAI assistant message).
- **Billing payload**: ACP `_x.ai/billing` result (`creditUsagePercent`, period, prepaid/on-demand money, plan label).
- **Scan cache**: `~/.cache/omarchy/agent-usage/grok-scan-*.json` with `schemaVersion` 3 and `scanDate`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Fixture test suite exits 0 with no live network.
- **SC-002**: On this host, `grok.json` exists after install with `ready: true` and `totalPrompts > 0`.
- **SC-003**: Weekly percent matches Grok `/usage` within 1 percentage point on a signed-in SuperGrok account.
- **SC-004**: Collector is a single stdlib Python file drop-in compatible with `omarchy-agent-usage-update`.
