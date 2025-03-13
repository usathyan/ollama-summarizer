#!/bin/bash

# Validate that the argument is an integer
if [[ ! $1 =~ ^[0-9]+$ ]]; then
  echo "Please provide a valid integer as the argument."
  exit 1
fi

# Make API call, parse and summarize the discussion
text=$(curl -s "https://hn.algolia.com/api/v1/items/$1" | jq -r '
  [recurse(.children[]?) | select(.text != null) | .text] | join("\n\n")
')

# Run ollama with the text, properly quoted
printf '%s' "$text" | ollama run gemma3 "Summarize the themes of the opinions expressed here, in a bulleted list with some more additional details, and a final summary including quotes where appropriate."
