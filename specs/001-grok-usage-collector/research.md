# Research

## Omarchy collector contract

`omarchy-agent-usage-update` globs `$OMARCHY_PATH/bin/omarchy-agent-usage-*`,
runs each collector, and writes `~/.local/state/omarchy/agents/usage/<id>.json`.
The panel watches that directory. A record that appears is an agent, whoever
wrote it — so a user-space writer is enough to light the tab.

Packaged collectors today: `claude`, `codex`, `fireworks`. No `grok`.

## Grok Build session format

Sessions live at `~/.grok/sessions/<url-encoded-cwd>/<session-id>/`.
Billed usage is on `updates.jsonl` rows:

```
params.update.sessionUpdate == "turn_completed"
params.update.usage.{inputTokens,outputTokens,cachedReadTokens,cacheCreationTokens,reasoningTokens,modelUsage}
params.update.prompt_id
```

`inputTokens` includes cache. Split cache out so the four panel buckets stay
exclusive. `events.jsonl` / `chat_history.jsonl` are not the billed ledger.

## Billing

Grok `/usage` uses ACP `_x.ai/billing` over `grok agent --no-leader stdio`.
`creditUsagePercent` is 0–100. `Money.val` is integer cents (488 → $4.88).
A weekly pool with a $0 prepaid ledger is a meter, not `$0.00 remaining`.

Plan label prefers the display string (`SuperGrok Heavy`); `SuperGrokPro`
rewrites to `SuperGrok Pro`.

## Prior art

Open PRs on `omacom/omarchy` already attempt this (`#7200`, `#6902`, others).
plugins.omarchy.org also lists collector-style Grok plugins (`calmasacow.grok-usage`,
`vt.grok-usage`, `dougfour.grok-usage`) and bar forks (`rlimberger.grokbar-omarchy`,
`othavi0.agent-bar`). This collector borrows product-split meters, `task-completed`
skip, and CLI-proxy billing fallback from those listings without forking QML.

## User-space discovery

Because update only scans `$OMARCHY_PATH/bin`, a PATH-only collector is not
picked up on panel refresh. Install writes `grok.json` directly and a systemd
user timer regenerates it. Packaged update does not delete unknown records.
