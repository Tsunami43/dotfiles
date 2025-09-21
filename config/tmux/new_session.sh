#!/usr/bin/env bash

NAMES_FILE="$HOME/.config/tmux/session_names.txt"

# Проверяем, что файл существует и не пустой
if [ ! -s "$NAMES_FILE" ]; then
  echo "Error: $NAMES_FILE is empty or missing"
  exit 1
fi

# Считаем количество текущих сессий
SESSION_COUNT=$(tmux ls 2>/dev/null | wc -l)

# Читаем имена в массив
NAMES=()
while IFS= read -r line; do
  NAMES+=("$line")
done < "$NAMES_FILE"

NUM_NAMES=${#NAMES[@]}

# Выбираем имя по модулю
INDEX=$(( SESSION_COUNT % NUM_NAMES ))
SESSION_NAME="${NAMES[$INDEX]}"

# Создаём сессию, если её ещё нет
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux new-session -d -s "$SESSION_NAME"
fi

tmux switch -t $SESSION_NAME
