#!/usr/bin/env bash
# Install Grok and Cursor collectors for the stock Omarchy agents panel.
# Writes ~/.local/state/omarchy/agents/usage/{grok,cursor}.json and a user
# timer so the tabs stay fresh. Packaged omarchy-agent-usage-update only globs
# $OMARCHY_PATH/bin, so the timer is the user-space stand-in until Omarchy
# ships these collectors.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="${HOME}/.local/bin"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
COLLECTOR_DST="${BIN}/omarchy-agent-usage-grok"
CURSOR_DST="${BIN}/omarchy-agent-usage-cursor"
REFRESH_DST="${BIN}/omarchy-agent-usage-grok-refresh"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--uninstall]

  (default)  Install Grok + Cursor collectors, write usage JSON, enable a
             15-minute refresh timer. Feeds stock omarchy.agents (same path
             as Claude and Codex). Does not add a second bar icon.
  --uninstall  Stop the timer and remove user-space files (not grok.json)
EOF
}

write_record() {
  local agent="$1"
  shift
  local collector="$1"
  shift
  local record tmp
  [[ -x $collector ]] || return 0
  if ! record=$("$collector" "$@") || [[ -z $record ]] || ! jq -e . >/dev/null 2>&1 <<<"$record"; then
    echo "omarchy-agent-usage-grok-refresh: $agent collector failed" >&2
    return 1
  fi
  tmp=$(mktemp "$STATE/.$agent.XXXXXX")
  printf '%s\n' "$record" >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$STATE/$agent.json"
}

write_usage_json() {
  mkdir -p "$STATE"
  write_record grok "$COLLECTOR_DST" "$@"
  write_record cursor "$CURSOR_DST" "$@" || true
}

uninstall() {
  systemctl --user disable --now omarchy-agent-usage-grok.timer 2>/dev/null || true
  rm -f "$UNIT_DIR/omarchy-agent-usage-grok.service" "$UNIT_DIR/omarchy-agent-usage-grok.timer"
  rm -f "$COLLECTOR_DST" "$CURSOR_DST" "$REFRESH_DST"
  systemctl --user daemon-reload 2>/dev/null || true
  echo "Removed user-space Grok/Cursor collectors. Left $STATE/*.json in place."
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
install -m 755 "$ROOT/bin/omarchy-agent-usage-cursor" "$CURSOR_DST"

cat >"$REFRESH_DST" <<EOF
#!/usr/bin/env bash
set -euo pipefail
STATE="\${XDG_STATE_HOME:-\$HOME/.local/state}/omarchy/agents/usage"
mkdir -p "\$STATE"
write_one() {
  local agent="\$1" collector="\$2"
  shift 2
  [[ -x \$collector ]] || return 0
  local record tmp
  record=\$("\$collector" "\$@") || return 1
  [[ -n \$record ]] || return 1
  jq -e . >/dev/null <<<"\$record"
  tmp=\$(mktemp "\$STATE/.\$agent.XXXXXX")
  printf '%s\\n' "\$record" >"\$tmp"
  chmod 600 "\$tmp"
  mv "\$tmp" "\$STATE/\$agent.json"
}
write_one grok "${COLLECTOR_DST}" "\$@"
write_one cursor "${CURSOR_DST}" "\$@" || true
EOF
chmod 755 "$REFRESH_DST"

install -m 644 "$ROOT/contrib/systemd/omarchy-agent-usage-grok.service" "$UNIT_DIR/omarchy-agent-usage-grok.service"
install -m 644 "$ROOT/contrib/systemd/omarchy-agent-usage-grok.timer" "$UNIT_DIR/omarchy-agent-usage-grok.timer"

echo "Collecting live Grok and Cursor usage…"
write_usage_json --force

systemctl --user daemon-reload
systemctl --user enable --now omarchy-agent-usage-grok.timer

if command -v omarchy-shell >/dev/null; then
  omarchy-shell omarchy.agents refresh >/dev/null 2>&1 || true
fi

echo "Installed $COLLECTOR_DST"
echo "Installed $CURSOR_DST"
echo "Wrote $STATE/grok.json"
jq -r '"ready=" + (.ready|tostring) + " prompts=" + (.totalPrompts|tostring) + " sessions=" + (.totalSessions|tostring) + " todayTokens=" + (.todayTotalTokens|tostring) + " plan=" + (.tierLabel // "")' "$STATE/grok.json"
if [[ -f $STATE/cursor.json ]]; then
  echo "Wrote $STATE/cursor.json"
  jq -r '"cursor ready=" + (.ready|tostring) + " plan=" + (.tierLabel // "") + " limits=" + ((.limits|length)|tostring) + " " + (.authHelpText // "")' "$STATE/cursor.json"
fi
echo "Timer: systemctl --user status omarchy-agent-usage-grok.timer"
echo "Open the agents panel (left-click the bar icon) and press r if Grok is not visible yet."
echo "Compact bar meters are a separate package; this install only feeds omarchy.agents."
