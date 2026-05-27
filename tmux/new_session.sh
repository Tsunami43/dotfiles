#!/usr/bin/env bash

NAMES_FILE="$HOME/.config/tmux/session_names.txt"

# Make sure the file exists and is not empty
if [ ! -s "$NAMES_FILE" ]; then
  echo "Error: $NAMES_FILE is empty or missing"
  exit 1
fi

# Count current sessions
SESSION_COUNT=$(tmux ls 2>/dev/null | wc -l)

# Read names into an array
NAMES=()
while IFS= read -r line; do
  NAMES+=("$line")
done < "$NAMES_FILE"

NUM_NAMES=${#NAMES[@]}

# Pick a name by modulo
INDEX=$(( SESSION_COUNT % NUM_NAMES ))
SESSION_NAME="${NAMES[$INDEX]}"

# Create the session if it does not exist yet
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
fi

tmux switch -t $SESSION_NAME
