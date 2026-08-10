#!/usr/bin/env bash
# Session switcher: a two-level tree of sessions and their windows, drawn in a
# small tmux popup. Bound to Alt+s; see README.md for the keys.
#
# Moving the cursor moves the client, so the window a row points at is on screen
# around the popup as you walk the list. That is why there is no preview: a copy
# of the window inside the list would cover the original to show it to you.
#
# The list is modal, the way an editor is. It opens with fzf's input hidden, so
# hjkl are navigation rather than characters and / is what hands the keyboard
# back to a query. Esc reads the mode it is in: the query first, the popup only
# on the second press. Esc and q both put the client back where it started —
# the cursor moved it while walking, and neither key meant to go anywhere.
#
# Panes are not in the tree. A pane is a region of a window rather than a place
# to be sent to; the window row carries the count, which is the part worth
# reading.
#
# Called without arguments it renders the fzf UI. The subcommands exist so the
# key bindings can call back into this same script.

set -u

# Cursor hint handed from an action to the following list reload. fzf keeps the
# row number across a reload, not the item, so the row has to be named here.
FOCUS_FILE="${XDG_RUNTIME_DIR:-/tmp}/tmux-session-popup.focus"

# Which rows are open. Reset on every launch: a tree that reopens in the shape
# it held days ago is one you have to read before you can use it.
EXPAND_FILE="${XDG_RUNTIME_DIR:-/tmp}/tmux-session-popup.expanded"

# Where the cursor was when a search was left. See cmd_esc_enter.
MARK_FILE="${XDG_RUNTIME_DIR:-/tmp}/tmux-session-popup.mark"

# Where the client stood when the popup opened, so backing out has somewhere to
# go back to.
ORIGIN_FILE="${XDG_RUNTIME_DIR:-/tmp}/tmux-session-popup.origin"

SELF="${BASH_SOURCE[0]}"
case "$SELF" in /*) ;; *) SELF="$PWD/$SELF" ;; esac

# Tell the bar an overlay is up; tmux has no format for "a popup is open".
# Claimed here rather than around the display-popup so that a run killed
# outright still releases it — a stuck flag reports a popup that has gone.
claim_overlay() {
	tmux set -g @overlay sessions 2>/dev/null
	tmux refresh-client -S 2>/dev/null # redraw now, not at the next interval
	trap 'tmux set -gu @overlay 2>/dev/null; tmux refresh-client -S 2>/dev/null' EXIT INT TERM HUP
}

# Nerd-font glyphs, same family the status bar segments draw from, so the popup
# and the bar cannot end up on two different icon sets.
ICON_SESSION=$'\357\206\263' # nf-fa-cubes            U+F1B3
ICON_WINDOW=$'\357\213\220'  # nf-fa-window_maximize  U+F2D0

# Disclosure state, and the guides that carry the eye down a level. Kept to
# single-width glyphs — a double-width arrow here shifts every row beneath it.
CHEV_OPEN='▾'
CHEV_SHUT='▸'
CHEV_LEAF=' '

# Cendre · hard — same palette as tmux.conf.
C_ACCENT=$'\033[1;38;2;234;152;117m' # ember   #ea9875 · session icons
C_CURRENT=$'\033[1;38;2;67;177;106m' # ok      #43b16a · the session this client sits in
C_FG=$'\033[38;2;230;213;194m'       # fg      #e6d5c2 · window names
C_DIM=$'\033[38;2;115;102;91m'       # comment #73665b · metadata
C_GUTTER=$'\033[38;2;78;70;65m'      # gutter  #4e4641 · tree guides, quietest ink there is
C_FROST=$'\033[38;2;78;137;162m'     # frost   #4e89a2 · pane rows
C_RESET=$'\033[0m'

TMUX_FMT=$'#{session_name}\t#{session_windows}\t#{session_attached}'

# ── row keys ───────────────────────────────────────────────────
#
# Every row carries a key in field 1, which is what the bindings hand back.
#   s:NAME            a session
#   w:NAME:WINDOW     a window inside it
# ':' is safe as the separator because tmux forbids it in session names and
# sanitize() strips it from anything this popup creates.

key_kind() { printf '%s' "${1%%:*}"; }

# The session a row belongs to, whatever depth it sits at — rename and kill
# both act on the session, not on the row.
key_session() {
	local rest=${1#*:}
	printf '%s' "${rest%%:*}"
}

# ── disclosure state ───────────────────────────────────────────

is_expanded() {
	[ -f "$EXPAND_FILE" ] && grep -qxF -- "$1" "$EXPAND_FILE" 2>/dev/null
}

expand_add() {
	is_expanded "$1" || printf '%s\n' "$1" >>"$EXPAND_FILE"
}

expand_del() {
	[ -f "$EXPAND_FILE" ] || return 0
	grep -vxF -- "$1" "$EXPAND_FILE" >"$EXPAND_FILE.new" 2>/dev/null
	mv -f "$EXPAND_FILE.new" "$EXPAND_FILE" 2>/dev/null
	return 0
}

# tmux forbids '.' and ':' in session names; spaces make the list unreadable.
# Trim first, substitute second — otherwise blanks turn into a name of '___'.
sanitize() {
	printf '%s' "$1" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '.: ' '___'
}

# ── rendering ──────────────────────────────────────────────────

# A session, and the whole subtree under it when it is open.
render_session() {
	local name=$1 windows=$2 attached=$3 current=$4
	local key="s:$name" chev label meta

	if [ "$windows" -gt 0 ] 2>/dev/null; then
		is_expanded "$key" && chev=$CHEV_OPEN || chev=$CHEV_SHUT
	else
		chev=$CHEV_LEAF
	fi

	# Pad before colouring: the escape bytes are not columns, and %-Ns counts
	# bytes, so a coloured string padded afterwards comes out short.
	label=$(printf '%-15s' "$name")
	if [ "$name" = "$current" ]; then
		label="${C_CURRENT}${label}${C_RESET}"
	else
		label="${C_FG}${label}${C_RESET}"
	fi

	# Abbreviated: the popup is narrow, and "3 windows · attached" spelled out
	# would push the name off its own row.
	meta="${windows}w"
	[ "$attached" -gt 0 ] 2>/dev/null && meta="$meta ·a"

	printf '%s\t %s%s%s %s%s%s %s %s%s%s\n' \
		"$key" "$C_GUTTER" "$chev" "$C_RESET" \
		"$C_ACCENT" "$ICON_SESSION" "$C_RESET" \
		"$label" "$C_DIM" "$meta" "$C_RESET"

	is_expanded "$key" || return 0
	render_windows "$name"
}

# Windows are the leaves; the pane count is all a row says about what is inside.
render_windows() {
	local name=$1 rows=() i=0 guide key label
	local idx wname panes active cmd meta

	mapfile -t rows < <(tmux list-windows -t "$name" \
		-F $'#{window_index}\t#{window_name}\t#{window_panes}\t#{window_active}\t#{pane_current_command}' \
		2>/dev/null)

	for row in "${rows[@]}"; do
		IFS=$'\t' read -r idx wname panes active cmd <<<"$row"
		i=$((i + 1))
		[ "$i" -eq "${#rows[@]}" ] && guide='└' || guide='├'

		key="w:$name:$idx"
		label=$(printf '%-2s %-12s' "$idx" "$wname")
		[ "$active" = 1 ] && label="${C_FG}${label}${C_RESET}" || label="${C_DIM}${label}${C_RESET}"

		# The pane count only earns its space when there is more than one; a
		# window that is a single pane is the ordinary case and says nothing.
		meta=''
		[ "$panes" -gt 1 ] 2>/dev/null && meta="${panes}p"

		printf '%s\t %s%s%s %s%s%s %s %s%s%s\n' \
			"$key" \
			"$C_GUTTER" "$guide" "$C_RESET" \
			"$C_FROST" "$ICON_WINDOW" "$C_RESET" \
			"$label" \
			"$C_DIM" "$meta" "$C_RESET"
	done
}

cmd_list() {
	local current name windows attached
	current=$(tmux display-message -p '#S' 2>/dev/null || true)

	# tmux's own order, which is by name — one order you can build a habit on.
	while IFS=$'\t' read -r name windows attached; do
		[ -n "$name" ] || continue
		render_session "$name" "$windows" "$attached" "$current"
	done < <(tmux list-sessions -F "$TMUX_FMT" 2>/dev/null)
	return 0
}

# ── actions ────────────────────────────────────────────────────

# Row keys in display order.
list_keys() {
	cmd_list | cut -f1 | grep -v '^$'
}

# The row number a key sits on, for fzf's pos().
row_of() {
	cmd_list | awk -F'\t' -v k="$1" '$1 == k { print NR; exit }'
}

# Row to focus once NAME is gone: the one below it, or the one above if it was
# last.
successor_of() {
	local name=$1 k next='' prev='' found=0 n
	while IFS= read -r k; do
		case $k in s:*) ;; *) continue ;; esac
		n=${k#s:}
		if [ "$found" = 1 ]; then
			next=$n
			break
		fi
		if [ "$n" = "$name" ]; then found=1; else prev=$n; fi
	done < <(list_keys)
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
		# A session name arrives here from kill/rename; rows are keyed, not named.
		case $target in s:* | w:*) ;; *) [ -n "$target" ] && target="s:$target" ;; esac
	fi
	printf 'reload(%s list)' "$SELF"
	[ -n "$target" ] || return 0
	pos=$(row_of "$target")
	[ -n "$pos" ] && printf '+pos(%s)' "$pos"
	return 0
}

# l — open a session, or step into one already open. A window is a leaf now, so
# l on one is not a move.
cmd_expand() {
	local key=$1 pos
	[ -n "$key" ] || return 0
	[ "$(key_kind "$key")" = s ] || return 0

	# Already open: l walks inward, which is the only sensible thing left for
	# it to mean and saves a j.
	if is_expanded "$key"; then
		printf 'down'
		return 0
	fi
	expand_add "$key"
	printf 'reload(%s list)' "$SELF"
	pos=$(row_of "$key")
	[ -n "$pos" ] && printf '+pos(%s)' "$pos"
	return 0
}

# h — leave the level you are in. On a window that is the whole way out: the
# session folds shut and the cursor lands on it, in one press rather than two.
cmd_collapse() {
	local key=$1 target pos
	[ -n "$key" ] || return 0

	case $(key_kind "$key") in
	w) target="s:$(key_session "$key")" ;;
	s)
		is_expanded "$key" || return 0 # already shut, and nowhere above it to go
		target=$key
		;;
	*) return 0 ;;
	esac

	expand_del "$target"
	printf 'reload(%s list)' "$SELF"
	pos=$(row_of "$target")
	[ -n "$pos" ] && printf '+pos(%s)' "$pos"
	return 0
}

# Leaving a search drops the filter and the list grows back under the cursor,
# which fzf keeps by position rather than by row. So the row is noted on the way
# out and looked up again once the list is whole.
#
# Two halves, and the second hangs off the result event rather than the same
# key. A pos() queued behind clear-query is spent before the list it aims at
# exists — the filter is still lifting, and the redraw wins. result fires after
# that, the only moment a row number means anything. It also fires on every
# search keystroke, so the note is what marks the firing that matters.
cmd_esc_enter() {
	if [ "${FZF_INPUT_STATE:-hidden}" = hidden ]; then
		printf 'abort'
		return 0
	fi
	printf '%s\n' "${1:-}" >"$MARK_FILE"
	return 0
}

cmd_esc_leave() {
	local key pos
	[ -f "$MARK_FILE" ] || return 0
	key=$(cat "$MARK_FILE" 2>/dev/null)
	rm -f "$MARK_FILE"
	[ -n "$key" ] || return 0
	pos=$(row_of "$key")
	[ -n "$pos" ] && printf 'pos(%s)' "$pos"
	return 0
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
	local old new
	old=$(key_session "${1:-}")
	[ -n "$old" ] || return 0
	# The field opens empty — the old name is in the prompt, not in the way.
	new=$(prompt_input "rename '$old' ❯ " '') || return 0
	new=$(sanitize "$new")
	# Empty input (or whitespace only, which sanitize strips) renames nothing.
	[ -n "$new" ] && [ "$new" != "$old" ] || return 0
	tmux rename-session -t "$old" -- "$new" || return 0
	set_focus "s:$new"
}

cmd_new() {
	local name
	name=$(prompt_input 'new session (empty = numbered) ❯ ' '') || return 0
	name=$(sanitize "$name")

	# No name given: let tmux pick the next free number, as it does by default.
	if [ -z "$name" ]; then
		name=$(tmux new-session -d -P -F '#{session_name}') || return 0
		enter_new "$name"
		return 0
	fi
	tmux has-session -t="$name" 2>/dev/null || tmux new-session -d -s "$name"
	enter_new "$name"
}

# Switching to a session that was just made is not a walk through the tree, so
# it must not be undone like one. The binding closes the popup by aborting, and
# an abort is otherwise Esc, which puts the client back where it started —
# dropping the origin is what tells the exit path there is nothing to go back
# to. Making a session and being returned from it would make the command
# useless.
enter_new() {
	rm -f "$ORIGIN_FILE"
	tmux switch-client -t "$1" 2>/dev/null
}

# Enter confirms, anything else (Esc included) backs out — read -n1 comes back
# empty on Enter.
confirm() {
	local answer
	printf '\n'
	read -r -n1 -p "  $1 [↵ = kill, esc = cancel] " answer
	printf '\n'
	[ -z "$answer" ]
}

refuse() {
	printf '\n  refusing: %s — press any key' "$1" >&2
	read -r -n1 -s
	return 0
}

# Killing the session this client sits in would throw the client out of tmux.
# Move it somewhere else first, and say whether there was anywhere to move to.
step_off() {
	local name=$1 successor
	[ "$name" = "$(tmux display-message -p '#S' 2>/dev/null)" ] || return 0
	successor=$(successor_of "$name")
	[ -n "$successor" ] || return 1
	tmux switch-client -t "$successor"
}

# d kills what the cursor is on, not what the row belongs to, and says what that
# is about to cost when the cost is more than the row itself — the last window
# takes its session with it.
cmd_kill() {
	local IFS=: kind name win
	read -r kind name win <<<"${1:-}"
	[ -n "$name" ] || return 0
	case $kind in
	w) kill_window_row "$name" "$win" ;;
	s) kill_session_row "$name" ;;
	esac
}

kill_window_row() {
	local name=$1 win=$2 windows sessions note=''

	windows=$(tmux list-windows -t "$name" 2>/dev/null | wc -l)
	if [ "$windows" -le 1 ]; then
		sessions=$(tmux list-sessions 2>/dev/null | wc -l)
		[ "$sessions" -le 1 ] && {
			refuse "the last window of the last session"
			return 0
		}
		note=' — the last window, the session goes with it'
		confirm "kill window $name:$win$note?" || return 0
		step_off "$name" || return 0
	else
		confirm "kill window $name:$win?" || return 0
	fi

	tmux kill-window -t "$name:$win" 2>/dev/null || return 0
	expand_del "w:$name:$win"
	if [ "$windows" -le 1 ]; then
		expand_del "s:$name"
		set_focus "$(successor_of "$name")"
	else
		set_focus "s:$name"
	fi
}

kill_session_row() {
	local name=$1 count successor
	count=$(tmux list-sessions 2>/dev/null | wc -l)
	if [ "$count" -le 1 ]; then
		refuse "the last session"
		return 0
	fi
	confirm "kill session '$name'?" || return 0
	successor=$(successor_of "$name") # resolved while the row still exists
	step_off "$name" || return 0
	tmux kill-session -t "$name" 2>/dev/null || return 0
	expand_del "s:$name"
	set_focus "$successor"
}

# Bound to cursor movement rather than to Enter: the window is the preview, and
# the only way to show it is to be standing in it. Enter is then left with
# nothing to do but close the popup where you already are.
cmd_open() {
	local IFS=: kind name win
	[ -n "${1:-}" ] || return 0
	read -r kind name win <<<"$1"
	[ -n "$name" ] || return 0
	tmux switch-client -t "$name" 2>/dev/null || return 0
	# A session row lands on whichever window that session was last in, which is
	# what it means to switch to a session rather than to a place inside one.
	[ "$kind" = w ] && tmux select-window -t "$name:$win" 2>/dev/null
	return 0
}

# Esc after walking the tree has to undo the walking, or backing out would
# leave the client wherever the cursor last passed through — which is the one
# place it was never asked to go.
save_origin() {
	tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' \
		2>/dev/null >"$ORIGIN_FILE"
}

restore_origin() {
	local origin session rest
	[ -f "$ORIGIN_FILE" ] || return 0
	origin=$(cat "$ORIGIN_FILE" 2>/dev/null)
	rm -f "$ORIGIN_FILE"
	[ -n "$origin" ] || return 0
	session=${origin%%:*}
	rest=${origin#*:}
	tmux switch-client -t "$session" 2>/dev/null || return 0
	tmux select-window -t "$session:${rest%%.*}" 2>/dev/null
	tmux select-pane -t "$session:$rest" 2>/dev/null
	return 0
}

# ── entry point ────────────────────────────────────────────────

case "${1:-}" in
list) cmd_list; exit 0 ;;
rename) cmd_rename "${2:-}"; exit 0 ;;
new) cmd_new; exit 0 ;;
kill) cmd_kill "${2:-}"; exit 0 ;;
open) cmd_open "${2:-}"; exit 0 ;;
focus) cmd_focus "${2:-}"; exit 0 ;;
expand) cmd_expand "${2:-}"; exit 0 ;;
collapse) cmd_collapse "${2:-}"; exit 0 ;;
esc-enter) cmd_esc_enter "${2:-}"; exit 0 ;;
esc-leave) cmd_esc_leave; exit 0 ;;
esac

command -v fzf >/dev/null || {
	printf 'fzf is required for the session popup\n' >&2
	read -r -n1 -s
	exit 1
}

rm -f "$FOCUS_FILE" "$MARK_FILE" # hints left over from an interrupted run
claim_overlay
save_origin

# Everything closed, cursor on the current session: opening it would show the
# windows you are already looking at and push every other session down to do it.
current_session=$(tmux display-message -p '#S' 2>/dev/null || true)
: >"$EXPAND_FILE"

start_pos=$(row_of "s:$current_session")
[ -n "$start_pos" ] || start_pos=1

# Modal keys. fzf binds a bare letter unconditionally, so every one of them has
# to ask which mode it is in before deciding — otherwise a query could never
# contain the letter j. FZF_INPUT_STATE is 'hidden' exactly while the input is
# not showing, which is the popup's normal mode.
#
# Esc cannot be settled inside a transform. A query cleared from within one does
# not take — the filter fzf applies afterwards is the one that was live when the
# transform started, leaving the list cut down to a search just abandoned, with
# no visible input to explain why. Only the abort half is decided there; the
# clearing is appended as plain actions, which do take. Both are harmless in
# normal mode: no query to clear, input already hidden.
# Whatever the command prints becomes the actions fzf runs, so each key gets
# whichever of the three shapes fits it:
#
#   j k /   echo a fixed action — nothing to decide
#   h l p   run the script, because the action depends on the row, and because
#           none of these three need a terminal to do their work
#   r d n   echo an execute(), because they ask something and a transform runs
#           with no terminal to ask it on
#
# {1} is substituted before the command runs either way, so the echoed actions
# carry the row key already resolved.
nav() { # key command -> a --bind argument
	printf '%s:transform:[ "$FZF_INPUT_STATE" = hidden ] && %s || echo "put(%s)"' "$1" "$2" "$1"
}

selected=$(cmd_list | fzf \
	--ansi \
	--sync \
	--delimiter=$'\t' \
	--with-nth=2.. \
	--no-multi \
	--no-sort \
	--no-scrollbar \
	--layout=reverse \
	--no-input \
	--info=hidden \
	--pointer='▌' \
	--prompt='search ❯ ' \
	--padding='0,1' \
	--footer=$' ↵ open   q close   / search   hjkl move\n r rename   n new   d kill' \
	--color='fg:#a09384,bg:-1,hl:#ea9875,fg+:#e6d5c2,bg+:#201b19,hl+:#fcba81' \
	--color='info:#73665b,prompt:#d1766e,pointer:#ea9875,header:#73665b,border:#362f2c' \
	--color='gutter:-1,query:#e6d5c2,footer:#73665b' \
	--bind="start:pos(${start_pos})" \
	--bind="focus:execute-silent($SELF open {1})" \
	--bind="$(nav j 'echo down')" \
	--bind="$(nav k 'echo up')" \
	--bind="$(nav h "$SELF collapse {1}")" \
	--bind="$(nav l "$SELF expand {1}")" \
	--bind="$(nav / 'echo show-input')" \
	--bind="$(nav q 'echo abort')" \
	--bind="esc:transform($SELF esc-enter {1})+clear-query+hide-input" \
	--bind="result:transform($SELF esc-leave)" \
	--bind="$(nav r "echo \"execute($SELF rename {1})+transform($SELF focus {1})\"")" \
	--bind="$(nav d "echo \"execute($SELF kill {1})+transform($SELF focus {1})\"")" \
	--bind="$(nav n "echo \"execute($SELF new)+abort\"")" |
	cut -f1)

# The focus binding already moved the client on the way past. All that is left
# is accepting that or undoing it: a row means stay, an empty selection means
# Esc or q, which means go back to where this started.
if [ -n "$selected" ]; then
	rm -f "$ORIGIN_FILE"
	cmd_open "$selected"
else
	restore_origin
fi
