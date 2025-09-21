#!/bin/bash

# Имя сессии
SESSION_NAME="legacy"

# Проверяем, запущена ли уже сессия Tmux
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  # Если сессия существует, подключаемся к ней
  tmux attach -t "$SESSION_NAME"
else
  # Если сессии нет, создаем новую
  tmux new-session -s "$SESSION_NAME"
fi

/bin/zsh -c '~/.config/ghostty/start-tmux.sh'
