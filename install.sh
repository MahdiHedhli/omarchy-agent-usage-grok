#!/usr/bin/env bash
# Install the Grok usage collector for the Omarchy agents panel on this host.
# Writes ~/.local/state/omarchy/agents/usage/grok.json and a user timer so the
# tab stays fresh without waiting for Omarchy to package the collector.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="${HOME}/.local/bin"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
COLLECTOR_DST="${BIN}/omarchy-agent-usage-grok"
REFRESH_DST="${BIN}/omarchy-agent-usage-grok-refresh"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--uninstall]

  (default)  Install collector, write grok.json, enable a 15-minute refresh timer
  --uninstall  Stop the timer and remove user-space files (not grok.json)
EOF
}

write_grok_json() {
  mkdir -p "$STATE"
  local record tmp
  if ! record=$("$COLLECTOR_DST" "$@") || [[ -z $record ]] || ! jq -e . >/dev/null 2>&1 <<<"$record"; then
    echo "omarchy-agent-usage-grok-refresh: collector failed" >&2
    return 1
  fi
  tmp=$(mktemp "$STATE/.grok.XXXXXX")
  printf '%s\n' "$record" >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$STATE/grok.json"
}

uninstall() {
  systemctl --user disable --now omarchy-agent-usage-grok.timer 2>/dev/null || true
  rm -f "$UNIT_DIR/omarchy-agent-usage-grok.service" "$UNIT_DIR/omarchy-agent-usage-grok.timer"
  rm -f "$COLLECTOR_DST" "$REFRESH_DST"
  systemctl --user daemon-reload 2>/dev/null || true
  echo "Removed user-space Grok collector. Left $STATE/grok.json in place."
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi
if [[ ${1:-} == "--uninstall" ]]; then
  uninstall
  exit 0
fi

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

mkdir -p "$BIN" "$STATE" "$UNIT_DIR"
install -m 755 "$ROOT/bin/omarchy-agent-usage-grok" "$COLLECTOR_DST"

cat >"$REFRESH_DST" <<EOF
#!/usr/bin/env bash
set -euo pipefail
STATE="\${XDG_STATE_HOME:-\$HOME/.local/state}/omarchy/agents/usage"
COLLECTOR="${COLLECTOR_DST}"
mkdir -p "\$STATE"
record=\$("\$COLLECTOR" "\$@") || exit 1
[[ -n \$record ]] || exit 1
jq -e . >/dev/null <<<"\$record"
tmp=\$(mktemp "\$STATE/.grok.XXXXXX")
printf '%s\\n' "\$record" >"\$tmp"
chmod 600 "\$tmp"
mv "\$tmp" "\$STATE/grok.json"
EOF
chmod 755 "$REFRESH_DST"

install -m 644 "$ROOT/contrib/systemd/omarchy-agent-usage-grok.service" "$UNIT_DIR/omarchy-agent-usage-grok.service"
install -m 644 "$ROOT/contrib/systemd/omarchy-agent-usage-grok.timer" "$UNIT_DIR/omarchy-agent-usage-grok.timer"

echo "Collecting live Grok usage…"
write_grok_json --force

systemctl --user daemon-reload
systemctl --user enable --now omarchy-agent-usage-grok.timer

if command -v omarchy-shell >/dev/null; then
  omarchy-shell omarchy.agents refresh >/dev/null 2>&1 || true
fi

echo "Installed $COLLECTOR_DST"
echo "Wrote $STATE/grok.json"
jq -r '"ready=" + (.ready|tostring) + " prompts=" + (.totalPrompts|tostring) + " sessions=" + (.totalSessions|tostring) + " todayTokens=" + (.todayTotalTokens|tostring) + " plan=" + (.tierLabel // "")' "$STATE/grok.json"
echo "Timer: systemctl --user status omarchy-agent-usage-grok.timer"
echo "Open the agents panel (left-click the bar icon) and press r if Grok is not visible yet."
