# Data model

## Usage record (stdout / grok.json)

| Field | Type | Notes |
|---|---|---|
| schemaVersion | 1 | |
| id | `"grok"` | |
| name | `"Grok"` | |
| updatedAt | ISO-8601 UTC | |
| ready | bool | local data, signed-in, or limits/balance |
| hasLocalStats | true | |
| hasPromptStats | true | |
| todayPrompts / todaySessions / todayTotalTokens | int | |
| todayTokensByModel | {model: tokens} | |
| recentDays | [{date, messageCount}] | last 7 local dates; messageCount is tokens |
| totalPrompts / totalSessions / activeDays | int | |
| activeDates | [YYYY-MM-DD] | unioned across machines when synced |
| modelUsage | {model: {inputTokens, outputTokens, cacheReadInputTokens, cacheCreationInputTokens}} | exclusive buckets |
| limits | [{label, percent 0–1, resetsAt}] | weekly/monthly pool |
| tierLabel | string | |
| balance | {remaining, funded, spent, currency} or omitted | cents→dollars |
| usageStatusText / authHelpText | string | |
| retryAdvised | bool optional | transport miss only |

## Turn

Native: one `turn_completed` after prompt_id dedupe, cache split, subagent skip.
Pi/omp: assistant JSONL with provider in `{xai, xai-auth, xai-oauth}`.
OpenCode: `message.role=assistant` and `providerID=xai` (exact).

## Scan cache envelope

```json
{"schemaVersion": 3, "scanDate": "YYYY-MM-DD", "stats": {…local stats…}}
```

Do not cache an interrupted OpenCode scan.
