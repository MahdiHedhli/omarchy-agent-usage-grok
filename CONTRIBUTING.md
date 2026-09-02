# Contributing

This repository is a standalone Grok usage collector. The code that belongs
in Omarchy is `bin/omarchy-agent-usage-grok` (plus tests and optional SVG
assets). Do not treat this repo as a plugin marketplace listing.

## Omarchy channels

Omarchy lives at [omacom/omarchy](https://github.com/omacom/omarchy)
(`basecamp/omarchy` redirects there). Default development branch is `quattro`.

| Kind | Where |
|---|---|
| Feature ideas | [Discussions → Suggestions](https://github.com/omacom/omarchy/discussions/categories/suggestions) |
| This collector | Discussion [#7198](https://github.com/omacom/omarchy/discussions/7198) |
| Code | Pull request against `quattro`, following the repo `AGENTS.md` |
| Validated bugs | GitHub issues (bugs only, not support) |
| Support / "is this a bug?" | [Discord](https://omarchy.org/discord) |

A marketplace plugin cannot register a collector. Discovery is
`$OMARCHY_PATH/bin/omarchy-agent-usage-*`, so Grok support has to land in
Omarchy itself.

Several PRs already implement this (`#7200`, `#6902`, and others). Prefer
reviewing or extending the leading PR over opening another parallel one.

## Local collector work

```bash
./test/agent-usage-grok-scanner-test.sh
```

Keep tests fixture-only. Do not commit `~/.grok`, `auth.json`, usage records,
or host paths.
