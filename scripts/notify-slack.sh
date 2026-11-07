#!/bin/bash
# Send a message to your Slack channel via an incoming webhook.
# Usage: notify-slack.sh "Your message here"
#
# Config file (default ~/.config/agent-ceo/slack.env, override with SLACK_CONFIG=...):
#   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...

set -uo pipefail

MESSAGE="${1:-No message provided}"
SLACK_CONFIG="${SLACK_CONFIG:-$HOME/.config/agent-ceo/slack.env}"

if [ ! -f "$SLACK_CONFIG" ]; then
  echo "ERROR: Slack config not found at $SLACK_CONFIG" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$SLACK_CONFIG"

if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "ERROR: SLACK_WEBHOOK_URL not set in $SLACK_CONFIG" >&2
  exit 1
fi

# Build JSON safely: quotes, backslashes, and newlines in MESSAGE must be escaped.
PAYLOAD=$(python3 -c 'import json, sys; print(json.dumps({"text": sys.argv[1]}))' "$MESSAGE")

if ! curl -sf -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "$PAYLOAD" >/dev/null; then
  echo "ERROR: Slack webhook request failed" >&2
  exit 1
fi
