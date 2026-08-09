# Shared cache for the status segments.
#
# Two rules shape this file, both of them about not spawning processes:
#
#   1. Entries carry their own timestamp on the first line instead of leaning on
#      the file's mtime. `stat` is a fork+exec — around 2ms — which is more than
#      every segment in this bar spends computing put together, and all it would
#      buy is a number the file can just as well hold itself.
#   2. `>` under `set -C` is an O_EXCL create done by the shell itself, so it
#      serves as the lock without calling out to mkdir.
#
# Every function returns its result in REPLY, the way `read` does. Command
# substitution would be a subshell per call, and a subshell is a fork.

CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/tmux-status"
LOCK_STALE=30 # seconds — a refresher that died must not wedge a path forever

cache_init() {
	[ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR" 2>/dev/null
}

# Flatten a key into a filename. The tail is the part that differs between
# entries, so that is the end kept when trimming to stay inside NAME_MAX.
cache_key() { # -> REPLY
	local k=${1//\//%}
	[ ${#k} -gt 200 ] && k=${k: -200}
	REPLY=$CACHE_DIR/$k
}

# Read a timestamped entry. REPLY gets the payload with the timestamp line
# stripped; it is left empty on a miss.
# rc: 0 fresh · 1 stale (REPLY still usable) · 2 missing or unreadable
cache_get() {
	local file=$1 ttl=$2 ts now
	REPLY=
	[ -f "$file" ] || return 2
	{
		read -r ts
		IFS= read -r -d '' REPLY
	} <"$file" 2>/dev/null
	case $ts in '' | *[!0-9]*) return 2 ;; esac
	REPLY=${REPLY%$'\n'}
	printf -v now '%(%s)T' -1
	[ $((now - ts)) -lt "$ttl" ]
}

# Replace an entry atomically: a reader must never catch a half-written bar.
# The temp name is built from $$ and $RANDOM rather than mktemp, which would be
# another process on a path that already pays for one.
cache_put() {
	local file=$1 body=$2 tmp=$1.$$.$RANDOM now
	printf -v now '%(%s)T' -1
	printf '%s\n%s' "$now" "$body" >"$tmp" 2>/dev/null || {
		rm -f "$tmp" 2>/dev/null
		return 1
	}
	mv -f "$tmp" "$file" 2>/dev/null || rm -f "$tmp" 2>/dev/null
}

# Untimestamped single-line state, written in place. No temp file and no rename:
# a line this short lands in one write(), and the worst a torn read can cost is
# one skipped sample — which is cheaper than the two forks atomicity would take.
cache_write() { printf '%s' "$2" >"$1" 2>/dev/null; }

cache_read() { # -> REPLY
	REPLY=
	[ -f "$1" ] || return 1
	IFS= read -r REPLY <"$1" 2>/dev/null
	[ -n "$REPLY" ]
}

# One refresher per key. The lock file holds the epoch it was taken at, so
# breaking a stale one is a read rather than another stat.
cache_claim() {
	local lock=$1 held now
	printf -v now '%(%s)T' -1

	set -C
	if printf '%s' "$now" 2>/dev/null >"$lock"; then
		set +C
		return 0
	fi
	set +C

	cache_read "$lock" && held=$REPLY || held=0
	case $held in '' | *[!0-9]*) held=0 ;; esac
	[ $((now - held)) -ge "$LOCK_STALE" ] || return 1

	# Past the stale mark the holder is gone; a race here just means two
	# refreshers run once, which the atomic put already tolerates.
	printf '%s' "$now" >"$lock" 2>/dev/null
}

cache_release() { rm -f "$1" 2>/dev/null; }
