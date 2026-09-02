# Quickstart

## Run the collector

```bash
./bin/omarchy-agent-usage-grok --force | jq .
```

## Tests

```bash
./test/agent-usage-grok-scanner-test.sh
```

## Install on this Omarchy host

```bash
./install.sh
omarchy-shell omarchy.agents refresh
```

Left-click the agents icon on the bar. A Grok tab should appear when
`~/.local/state/omarchy/agents/usage/grok.json` is ready and has data.

Uninstall:

```bash
./install.sh --uninstall
```

## Upstream drop-in

Copy `bin/omarchy-agent-usage-grok` to Omarchy `bin/`, add `assets/grok.svg`
and `grok-light.svg` next to the other agent marks, enable `grok` in
`shell/plugins/agents/manifest.json`, and add
`test/shell.d/agent-usage-grok-scanner-test.sh` against Omarchy's
`base-test.sh`.
