#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_ROOT/config/openclaw.json"

echo "Validating $CONFIG ..."

# 0. Tool check — jq is required for validation. We surface this explicitly
# because otherwise a missing-jq install would be silently reported below as
# "not valid JSON" (which is misleading and previously cost real debugging
# time during the GHCR build setup).
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required for config validation but is not installed."
  echo "Install with: sudo apt install jq   (Debian/Ubuntu)"
  echo "         or: brew install jq        (macOS)"
  exit 1
fi

# 1. Check valid JSON (don't swallow jq's parse error — it's the most useful
# bit of diagnostic when the file IS actually malformed).
if ! jq empty "$CONFIG"; then
  echo "ERROR: $CONFIG is not valid JSON"
  exit 1
fi

# 2. Check for raw API key patterns that should never appear in config
PATTERNS='sk-ant-|sk-proj-|bot[0-9]|bsc_|xai-|gsk_'
if grep -qE "$PATTERNS" "$CONFIG"; then
  echo "ERROR: Raw API key pattern detected in $CONFIG"
  echo "Use \${ENV_VAR} references instead of plaintext keys."
  grep -nE "$PATTERNS" "$CONFIG"
  exit 1
fi

echo "✓ Config validation passed"
