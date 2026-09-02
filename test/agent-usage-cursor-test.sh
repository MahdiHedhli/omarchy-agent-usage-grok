#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COLLECTOR="$ROOT/bin/omarchy-agent-usage-cursor"

fail() { echo "FAIL: $1" >&2; [[ -n ${2:-} ]] && echo "$2" | head -c 2000 >&2; exit 1; }
pass() { echo "PASS: $1"; }
require_command() { command -v "$1" >/dev/null || fail "$1 is required"; }

require_command jq
require_command python3
[[ -x $COLLECTOR ]] || fail "collector missing: $COLLECTOR"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

result=$(HOME="$TEST_HOME" XDG_CACHE_HOME="$TEST_HOME/.cache" \
  CURSOR_AUTH_PATH="$TEST_HOME/missing-auth.json" \
  CURSOR_STATE_DB="$TEST_HOME/missing-state.vscdb" \
  "$COLLECTOR" --force)

[[ $(jq -r '.id + "/" + (.ready|tostring) + "/" + (.schemaVersion|tostring)' <<<"$result") == "cursor/false/1" ]] ||
  fail "unsigned Cursor collector should print a not-ready stock record" "$result"
[[ $(jq -r '.limits | length' <<<"$result") == "0" ]] ||
  fail "unsigned Cursor collector should leave limits empty" "$result"
[[ $(jq -r '.authHelpText' <<<"$result") == "Sign in to Cursor to show monthly pools." ]] ||
  fail "unsigned Cursor collector should explain how to sign in" "$result"
[[ $(jq -r '.recentDays | length' <<<"$result") == "7" ]] ||
  fail "unsigned Cursor collector should still emit a 7-day chart skeleton" "$result"
[[ $(jq 'has("email") or has("accessToken") or has("rateLimitPercent")' <<<"$result") == "false" ]] ||
  fail "Cursor collector must not print email, tokens, or grokbar-only keys" "$result"
pass "unsigned Cursor collector matches the stock agents record"

python3 - "$COLLECTOR" <<'PY' || fail "Cursor build_result mapping"
from importlib.machinery import SourceFileLoader
import sys

path = sys.argv[1]
mod = SourceFileLoader("cursor_collector", path).load_module()

out = mod.build_result(
  {"membership": "pro"},
  {
    "planUsage": {"autoPercentUsed": 25, "apiPercentUsed": 10},
    "billingCycleEnd": "2026-10-01T00:00:00Z",
    "membershipType": "pro",
  },
  tier_label="Pro",
)
assert out["id"] == "cursor", out
assert out["ready"] is True, out
assert out["tierLabel"] == "Pro", out
assert out["limits"][0]["title"] == "Cursor Models", out
assert abs(out["limits"][0]["percent"] - 0.25) < 1e-9, out
assert out["limits"][1]["title"] == "Other Models", out
assert abs(out["limits"][1]["percent"] - 0.10) < 1e-9, out
assert "email" not in out, out

sanded = mod.apply_sand(dict(out), {
  "hasNonZeroIncludedLimit": True,
  "usagePercent": 40,
  "nextResetTimestampUtc": "2026-09-08T00:00:00Z",
})
assert sanded["limits"][-1]["title"] == "Grok Bot", sanded
assert abs(sanded["limits"][-1]["percent"] - 0.40) < 1e-9, sanded

empty = mod.apply_sand(dict(out), {"hasNonZeroIncludedLimit": False})
assert len(empty["limits"]) == 2, empty
print("ok")
PY
pass "Cursor Models / Other Models / Grok Bot map onto limits[]"

probe=$(HOME="$TEST_HOME" CURSOR_AUTH_PATH="$TEST_HOME/missing-auth.json" \
  CURSOR_STATE_DB="$TEST_HOME/missing-state.vscdb" "$COLLECTOR" --probe)
[[ $probe == "absent" ]] || fail "probe should be absent without a Cursor session" "$probe"
pass "Cursor --probe reports absent without auth"
