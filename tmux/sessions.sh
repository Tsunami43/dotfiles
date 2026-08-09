#!/usr/bin/env bash
# Tmux session popup: browse, switch, pin, rename, create and kill sessions.
#
# Pinned sessions are sorted to the top of the list. The pin lives in the
# session's own @pinned option, so it dies with the session and survives a
# rename by any means. Renaming through this popup pins the session: an
# explicit name means the session matters.
#
# Called without arguments it renders the fzf UI; the subcommands below exist
# so the fzf key bindings can call back into this same script.

set -u

# Cursor hint handed from an action to the following list reload. fzf keeps the
# row number across a reload, not the item, so the row has to be named here.
FOCUS_FILE="${XDG_RUNTIME_DIR:-/tmp}/tmux-session-popup.focus"
SELF="${BASH_SOURCE[0]}"
case "$SELF" in /*) ;; *) SELF="$PWD/$SELF" ;; esac

PIN_ICON='◆' # single-width on purpose: the marker column must stay aligned

# Cendre · hard — same palette as tmux.conf. The pin marker and the current
# session must not share a colour, or one reads as the other.
C_ACCENT=$'\033[1;38;2;234;152;117m' # ember   #ea9875 · pins
C_CURRENT=$'\033[1;38;2;67;177;106m' # ok      #43b16a · the session this client sits in
C_DIM=$'\033[38;2;115;102;91m'       # comment #73665b
C_RESET=$'\033[0m'

TMUX_FMT=$'#{session_name}\t#{session_windows}\t#{session_attached}\t#{@pinned}'

# ── pin storage: the session's own @pinned option ──────────────

is_pinned() {
	[ -n "$1" ] || return 1
	[ "$(tmux show-options -qv -t "$1" @pinned 2>/dev/null)" = 1 ]
}

pin() {
	[ -n "$1" ] || return 0
	tmux set-option -t "$1" @pinned 1 2>/dev/null
	tmux refresh-client -S 2>/dev/null # redraw the status bar's ◆ right away
}

unpin() {
	[ -n "$1" ] || return 0
	tmux set-option -t "$1" -u @pinned 2>/dev/null
	tmux refresh-client -S 2>/dev/null
}

# tmux forbids '.' and ':' in session names; spaces make the list unreadable.
# Trim first, substitute second — otherwise blanks turn into a name of '___'.
sanitize() {
	printf '%s' "$1" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '.: ' '___'
}

# ── rendering ──────────────────────────────────────────────────

render_row() {
	local name=$1 windows=$2 attached=$3 pinned=$4 current=$5
	local mark=' ' label meta

	[ "$pinned" = 1 ] && mark="${C_ACCENT}${PIN_ICON}${C_RESET}"
	label=$(printf '%-22s' "$name")
	[ "$name" = "$current" ] && label="${C_CURRENT}${label}${C_RESET}"

	meta="${windows} win"
	[ "$attached" -gt 0 ] 2>/dev/null && meta="$meta · attached"
	[ "$name" = "$current" ] && meta="$meta · current"

	# field 1 is the session name fzf hands back to the bindings
	printf '%s\t %s %s%s%s%s\n' "$name" "$mark" "$label" "$C_DIM" "$meta" "$C_RESET"
}

cmd_list() {
	local current pinned_rows=() others=() name windows attached pinned
	current=$(tmux display-message -p '#S' 2>/dev/null || true)

	# @pinned comes straight from the session list — no probing per session.
	while IFS=$'\t' read -r name windows attached pinned; do
		[ -n "$name" ] || continue
		if [ "$pinned" = 1 ]; then
			pinned_rows+=("$(render_row "$name" "$windows" "$attached" 1 "$current")")
		else
			others+=("$(render_row "$name" "$windows" "$attached" '' "$current")")
		fi
	done < <(tmux list-sessions -F "$TMUX_FMT" 2>/dev/null)

	# No group captions — the marker column already tells the two groups apart.
	[ ${#pinned_rows[@]} -gt 0 ] && printf '%s\n' "${pinned_rows[@]}"
	[ ${#others[@]} -gt 0 ] && printf '%s\n' "${others[@]}"
	return 0
}

# ── actions ────────────────────────────────────────────────────

# Session names in display order.
list_names() {
	cmd_list | cut -f1 | grep -v '^$'
}

# Row to focus once NAME is gone: the one below it, or the one above if it was last.
successor_of() {
	local name=$1 n next='' prev='' found=0
	while IFS= read -r n; do
		if [ "$found" = 1 ]; then
			next=$n
			break
		fi
		if [ "$n" = "$name" ]; then found=1; else prev=$n; fi
	done < <(list_names)
	printf '%s' "${next:-$prev}"
}

set_focus() {
	printf '%s\n' "$1" >"$FOCUS_FILE"
}

# Printed as fzf actions by a transform binding: refresh the list, then put the
# cursor back on a meaningful row instead of whatever row number it held.
cmd_focus() {
	local target=$1 pos
	if [ -f "$FOCUS_FILE" ]; then
		target=$(cat "$FOCUS_FILE")
		rm -f "$FOCUS_FILE"
	fi
	printf 'reload(%s list)' "$SELF"
	[ -n "$target" ] || return 0
	pos=$(cmd_list | awk -F'\t' -v n="$target" '$1 == n { print NR; exit }')
	[ -n "$pos" ] && printf '+pos(%s)' "$pos"
	return 0
}

# Preview pane: what the session's windows are and what its active pane shows.
cmd_preview() {
	local name=$1
	[ -n "$name" ] || return 0

	tmux list-windows -t "$name" \
		-F "#{?window_active,${C_ACCENT}▸${C_RESET},${C_DIM}·${C_RESET}} #{window_index} #{window_name}${C_DIM} #{pane_current_command}${C_RESET}" 2>/dev/null
	printf '%s%s%s\n' "$C_DIM" '─────────────────────────────' "$C_RESET"
	# -e keeps the colours; trailing blank lines would just pad the preview out
	tmux capture-pane -ep -t "$name" 2>/dev/null | sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}'
}

cmd_toggle_pin() {
	local name=$1
	[ -n "$name" ] || return 0
	if is_pinned "$name"; then unpin "$name"; else pin "$name"; fi
}

# One-line input drawn inside the popup. Enter accepts, Esc backs out and
# returns 1, so every step that asks something can be abandoned.
prompt_input() {
	local label=$1 initial=$2 out status
	out=$(printf '' | fzf \
		--print-query \
		--query="$initial" \
		--prompt="$label" \
		--layout=reverse \
		--info=hidden \
		--no-scrollbar \
		--pointer=' ' \
		--header=$'  ↵ confirm   esc cancel\n' \
		--header-first \
		--color='fg:#e6d5c2,bg:-1,query:#e6d5c2,prompt:#d1766e,header:#73665b')
	status=$?
	[ "$status" -ge 130 ] && return 1 # Esc / interrupt
	printf '%s' "$out"
}

cmd_rename() {
	local old=$1 new
	[ -n "$old" ] || return 0
	# The field opens empty — the old name is in the prompt, not in the way.
	new=$(prompt_input "rename '$old' ❯ " '') || return 0
	new=$(sanitize "$new")
	# Empty input (or whitespace only, which sanitize strips) renames nothing.
	[ -n "$new" ] && [ "$new" != "$old" ] || return 0
	tmux rename-session -t "$old" -- "$new" || return 0
	pin "$new" # an explicit name means the session matters — pin it
	set_focus "$new"
}

cmd_new() {
	local name
	name=$(prompt_input 'new session (empty = numbered) ❯ ' '') || return 0
	name=$(sanitize "$name")

	# No name given: let tmux pick the next free number, as it does by default.
	if [ -z "$name" ]; then
		name=$(tmux new-session -d -P -F '#{session_name}') || return 0
		tmux switch-client -t "$name"
		return 0
	fi
	tmux has-session -t="$name" 2>/dev/null || tmux new-session -d -s "$name"
	pin "$name" # named on purpose, same rule as rename
	tmux switch-client -t "$name"
}

cmd_kill() {
	local name=$1 count answer successor
	[ -n "$name" ] || return 0
	count=$(tmux list-sessions 2>/dev/null | wc -l)
	if [ "$count" -le 1 ]; then
		printf '\n  refusing to kill the last session — press any key' >&2
		read -r -n1 -s
		return 0
	fi
	printf '\n'
	# Enter confirms, anything else (Esc included) backs out — read -n1 comes
	# back empty on Enter.
	read -r -n1 -p "  kill session '$name'? [↵ = kill, esc = cancel] " answer
	printf '\n'
	[ -z "$answer" ] || return 0
	successor=$(successor_of "$name") # resolved while the row still exists

	# Killing the session this client is attached to would throw the client out
	# of tmux — move it onto the successor first, then kill.
	if [ -n "$successor" ] && [ "$name" = "$(tmux display-message -p '#S' 2>/dev/null)" ]; then
		tmux switch-client -t "$successor"
	fi

	tmux kill-session -t "$name" || return 0 # @pinned dies with the session
	set_focus "$successor"
}

cmd_switch() {
	local name=$1
	[ -n "$name" ] || return 0
	tmux switch-client -t "$name"
}

# ── entry point ────────────────────────────────────────────────

case "${1:-}" in
list) cmd_list; exit 0 ;;
toggle-pin) cmd_toggle_pin "${2:-}"; exit 0 ;;
rename) cmd_rename "${2:-}"; exit 0 ;;
new) cmd_new; exit 0 ;;
kill) cmd_kill "${2:-}"; exit 0 ;;
switch) cmd_switch "${2:-}"; exit 0 ;;
focus) cmd_focus "${2:-}"; exit 0 ;;
preview) cmd_preview "${2:-}"; exit 0 ;;
esac

command -v fzf >/dev/null || {
	printf 'fzf is required for the session popup\n' >&2
	read -r -n1 -s
	exit 1
}

rm -f "$FOCUS_FILE" # a hint left over from an interrupted run

# Open on the current session's row rather than on whatever sorted first.
start_pos=$(cmd_list | awk -F'\t' -v n="$(tmux display-message -p '#S' 2>/dev/null)" '
	$1 != "" && first == 0 { first = NR }
	$1 == n { print NR; found = 1; exit }
	END { if (!found) print first }
')

selected=$(cmd_list | fzf \
	--ansi \
	--sync \
	--delimiter=$'\t' \
	--with-nth=2.. \
	--no-multi \
	--no-sort \
	--no-scrollbar \
	--layout=reverse \
	--info=inline-right \
	--pointer='▌' \
	--prompt='❯ ' \
	--header=$'  ↵ switch   ^j/^k move   ^p pin   ^r rename   ^n new   ^d kill\n' \
	--header-first \
	--preview="$SELF preview {1}" \
	--preview-window='right,60%,border-left,nowrap' \
	--color='fg:#a09384,bg:-1,hl:#ea9875,fg+:#e6d5c2,bg+:#201b19,hl+:#fcba81' \
	--color='info:#73665b,prompt:#d1766e,pointer:#ea9875,header:#73665b,border:#362f2c' \
	--bind="start:pos(${start_pos:-1})" \
	--bind='ctrl-j:down,ctrl-k:up' \
	--bind="ctrl-p:execute-silent($SELF toggle-pin {1})+transform($SELF focus {1})" \
	--bind="ctrl-r:execute($SELF rename {1})+transform($SELF focus {1})" \
	--bind="ctrl-d:execute($SELF kill {1})+transform($SELF focus {1})" \
	--bind="ctrl-n:execute($SELF new)+abort" \
	--bind='esc:abort' |
	cut -f1)

cmd_switch "$selected"
