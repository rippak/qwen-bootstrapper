{
  "permissions": {
    "allow": [
      "Read(**)",
      "Write(**)",
      "WebSearch",
      "WebFetch",
      "Bash({CONTAINER_CMD}:*)",
      "Bash(make:*)",
      "Bash(git log:*)",
      "Bash(git show:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Bash(git rev-parse:*)",
      "Bash(git branch:*)",
      "Bash(curl:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Task",
        "hooks": [
          {
            "type": "command",
            "command": "bash $QWEN_PROJECT_DIR/.qwen/scripts/hooks/track-agent.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash $QWEN_PROJECT_DIR/.qwen/scripts/hooks/maintain-memory.sh"
          }
        ]
      }
    ]
  }
}
