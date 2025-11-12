#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Kill Replayd
# @raycast.mode inline

# Optional parameters:
# @raycast.icon 💀

# Documentation:
# @raycast.author Andras Kauer

PROCESS_NAME="replayd"

if pgrep "$PROCESS_NAME" >/dev/null; then
  STATUS="🟢 Running"
  pkill -9 "$PROCESS_NAME"
  echo "$PROCESS_NAME was running — now killed"
else
  STATUS="⚫ Not running"
  echo "$PROCESS_NAME is not running"
fi
