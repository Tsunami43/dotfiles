# Worktree state for the pane's current path.
#
# This is the one segment that cannot be answered by reading a file, so it is
# built around not paying for git more often than the repo actually changes: one
# git invocation, a short-lived cache, and a stale value served immediately
# while the refresh happens out of band. A cold cache is the only time anything
# waits for git.

GIT_TTL=5 # seconds — the bar redraws every second for the clock, but a worktree
          # does not change that fast, and this keeps the real git work at the
          # rate it ran at before seconds were on screen

# Font Awesome rather than codicons: it is the oldest range in Nerd Fonts and
# the most reliably patched, which is the range ccmux draws from too. A forge is
# only named when the remote really is one — a GitHub mark over a GitLab or a
# remote-less repo would just be a lie, so the branch glyph carries those alone.
ICON_BRANCH=$'\357\204\246' # nf-fa-code_branch U+F126
ICON_GITHUB=$'\357\202\233' # nf-fa-github      U+F09B

# ── the one git call ───────────────────────────────────────────

_git_render() {
	local path=$1 out forge
	# --no-optional-locks keeps the status bar off .git/index.lock, which would
	# otherwise race the lazygit running in the popup right next to it.
	out=$(git --no-optional-locks -C "$path" status \
		--porcelain=v2 --branch --untracked-files=normal 2>/dev/null) || return 1

	# Reading the remote is a second process, but it only runs on a cache miss,
	# which is the same rate the status call already pays for.
	forge=
	case $(git -C "$path" config --get remote.origin.url 2>/dev/null) in
	*github.com*) forge=$ICON_GITHUB ;;
	esac

	printf '%s\n' "$out" | awk -v forge="$forge" -v branch_icon="$ICON_BRANCH" \
		-v c_branch="$C_BRANCH" -v c_dirty="$C_DIRTY" -v c_sync="$C_SYNC" '
		/^# branch\.oid /  { oid = substr($3, 1, 7); next }
		/^# branch\.head / { head = $3; next }
		/^# branch\.ab / {
			ahead = $3; sub(/^\+/, "", ahead); ahead += 0
			behind = $4; sub(/^-/, "", behind); behind += 0
			next
		}
		# XY on a tracked entry: X is the index, Y is the worktree.
		/^[12] / {
			if (substr($2, 1, 1) != ".") staged++
			if (substr($2, 2, 1) != ".") modified++
			next
		}
		/^u /  { conflict++; next }
		/^\? / { untracked++; next }
		END {
			if (head == "") exit 0
			# A detached HEAD has no name to show, so it wears its oid instead.
			# A bare name on the right edge could be anything; this is the one
			# label in the bar that genuinely has to be drawn. The forge mark
			# joins the branch glyph rather than replacing it, and takes the
			# wider gap: the two glyphs are not one word, and the forge mark
			# draws heavier than the branch, so a single column between them
			# leaves it looking wedged against a hairline.
			s = c_branch " " (forge != "" ? forge "  " : "") branch_icon " " \
				((head == "(detached)") ? oid : head)

			# The counts share one colour, so the tag is emitted once for the
			# whole run rather than in front of every number.
			if (staged)    dirt = dirt " +" staged
			if (modified)  dirt = dirt " ~" modified
			if (untracked) dirt = dirt " ?" untracked
			if (conflict)  dirt = dirt " !" conflict
			if (dirt != "") s = s c_dirty dirt

			if (ahead)  sync = sync " \342\206\221" ahead
			if (behind) sync = sync " \342\206\223" behind
			if (sync != "") s = s c_sync sync
			printf "%s", s
		}'
}

# A directory that is not a repo is cached as an empty entry on purpose, so the
# next redraw does not pay for git just to be told the same thing again.
_git_refresh() {
	local path=$1 cache=$2 body
	body=$(_git_render "$path")
	cache_put "$cache" "$body"
}

segment_git() { # -> REPLY
	local path=$1 cache lock stale rc
	cache_key "git$path"
	cache=$REPLY
	lock=$cache.lock

	cache_get "$cache" "$GIT_TTL"
	rc=$?
	[ $rc -eq 0 ] && return 0 # fresh: REPLY is already the rendered segment

	if [ $rc -eq 1 ]; then
		# Stale but usable: print it now and refresh behind the bar's back. The
		# redirect matters — a child holding the inherited stdout open would
		# keep tmux waiting for output this script has already finished
		# producing.
		stale=$REPLY
		if cache_claim "$lock"; then
			(
				_git_refresh "$path" "$cache"
				cache_release "$lock"
			) >/dev/null 2>&1 &
		fi
		REPLY=$stale
		return 0
	fi

	# Cold cache: there is nothing to show yet, so this one call is paid up front.
	_git_refresh "$path" "$cache"
	cache_get "$cache" "$GIT_TTL"
	return 0
}
