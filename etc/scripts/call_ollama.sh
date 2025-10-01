#!/usr/bin/env bash

# Simple script to send a question to Ollama via curl
# Usage: ./script.sh "your question here"

# Exit if no arguments provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 \"your question here\""
  exit 1
fi

# Join all arguments into a single string
QUESTION="$*"

# Call Ollama API
curl -s -X POST http://localhost:11434/api/chat \
  -d "{
    \"model\": \"gpt-oss:latest\",
    \"messages\": [{ \"role\": \"user\", \"content\": \"$QUESTION\" }],
    \"stream\": false
  }" | jq -r '.message.content'

