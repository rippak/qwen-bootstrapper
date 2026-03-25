#!/bin/bash
set -uo pipefail
ERR_LOG="${QWEN_PROJECT_DIR:-.}/.qwen/memory/.hook-errors.log"
trap 'echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] ERROR in $(basename "$0"):$LINENO" >> "$ERR_LOG" 2>/dev/null; exit 0' ERR

LOG_DIR="$QWEN_PROJECT_DIR/.qwen/memory"
LOG_FILE="$LOG_DIR/usage.jsonl"
mkdir -p "$LOG_DIR"

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
if [ "$TOOL_NAME" != "Task" ]; then
    exit 0
fi

AGENT_NAME=$(echo "$INPUT" | jq -r '
    .tool_input.prompt // "" |
    capture("\\.qwen/agents/(?<name>[^.]+)") // null |
    .name // null
')
if [ -z "$AGENT_NAME" ] || [ "$AGENT_NAME" = "null" ]; then
    AGENT_NAME=$(echo "$INPUT" | jq -r '.tool_input.description // "" | ascii_downcase')
fi
if [ -z "$AGENT_NAME" ]; then
    AGENT_NAME="unknown-agent"
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(cd "$QWEN_PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

jq -n \
    --arg ts "$TIMESTAMP" \
    --arg agent "$AGENT_NAME" \
    --arg branch "$BRANCH" \
    '{timestamp: $ts, agent: $agent, branch: $branch}' >> "$LOG_FILE"

exit 0
