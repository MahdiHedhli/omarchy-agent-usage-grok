# Contract: omarchy-agent-usage-grok CLI

## Invocation

```
omarchy-agent-usage-grok [--force] [--limits-only]
```

Exit 0 on a printable record, including empty installs.

## Output

One JSON object on stdout, `sort_keys=True`, compact separators.
No trailing diagnostic on stdout. Diagnostics on stderr.

## Flags

| Flag | Scan cache | Billing |
|---|---|---|
| (none) | reuse ≤ 20s | probe |
| `--limits-only` | reuse ≤ 900s if `scanDate` is today | probe |
| `--force` | ignore | probe |

## Environment

| Var | Default |
|---|---|
| GROK_HOME | ~/.grok |
| XDG_CACHE_HOME | ~/.cache |
| XDG_DATA_HOME | ~/.local/share (OpenCode DB) |
| PATH | must include `grok` for limits |

## Forbidden

- Access tokens, refresh tokens, emails, or raw `auth.json` in stdout/cache
- Network except via the `grok` ACP child for billing
