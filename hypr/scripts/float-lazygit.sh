#!/usr/bin/env bash
# Spawn a floating ghostty running lazygit in the cwd of the focused ghostty
# (resolves tmux active-pane cwd via TTY match when applicable).
# If the cwd is not a git repo, show a notice instead of lazygit's init prompt.
set -euo pipefail

active=$(hyprctl activewindow -j)
pid=$(jq -r '.pid' <<<"$active")
class=$(jq -r '.class' <<<"$active")

resolve_cwd() {
    local p=$1 children c comm tty path first
    while :; do
        children=$(pgrep -P "$p" 2>/dev/null || true)
        [[ -z "$children" ]] && break
        for c in $children; do
            comm=$(tr -d '\0' </proc/"$c"/comm 2>/dev/null || true)
            if [[ "$comm" == "tmux: client" ]]; then
                tty=$(readlink "/proc/$c/fd/0" 2>/dev/null || true)
                if [[ -n "$tty" ]]; then
                    path=$(tmux list-clients -F '#{client_tty}|#{pane_current_path}' 2>/dev/null \
                        | awk -F'|' -v t="$tty" '$1==t {print $2; exit}')
                    if [[ -n "$path" && -d "$path" ]]; then
                        printf '%s' "$path"
                        return 0
                    fi
                fi
            fi
        done
        first=$(printf '%s\n' "$children" | head -n1)
        [[ "$first" == "$p" ]] && break
        p=$first
    done
    if [[ -r "/proc/$p/cwd" ]]; then
        readlink -f "/proc/$p/cwd" 2>/dev/null || printf '%s' "$HOME"
    else
        printf '%s' "$HOME"
    fi
}

case "$class" in
    com.mitchellh.ghostty.lazygit) exit 0 ;;
    com.mitchellh.ghostty*) cwd=$(resolve_cwd "$pid") ;;
    *) exit 0 ;;
esac

quoted=$(printf '%q' "$cwd")
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    hyprctl dispatch exec "ghostty --gtk-single-instance=false --class=com.mitchellh.ghostty.lazygit --working-directory=$quoted -e lazygit"
else
    msg='printf "%s\n%s\n" "Not a git repository: $PWD" "Press any key to close..."; read -n 1'
    msg_quoted=$(printf '%q' "$msg")
    hyprctl dispatch exec "ghostty --gtk-single-instance=false --class=com.mitchellh.ghostty.lazygit --working-directory=$quoted -e sh -c $msg_quoted"
fi
