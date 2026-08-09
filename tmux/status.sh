#!/usr/bin/env bash
# The right-hand region of the tmux status bar.
#
# tmux re-runs this for every attached client on every status interval, and the
# expensive part of that is the process, not the work: an empty script already
# costs ~2.7ms to start, while reading /proc/meminfo inside one costs ~0.2ms. So
# the bar gets exactly one #() and every segment lives in this same process. The
# files under status/ are sourced, never executed — giving each of them its own
# script would be a fork per segment, per client, per second, and would cost
# more than fifteen times what the readouts themselves take.
#
# The output carries tmux #[fg=] tags, so what a colour means is decided in
# status/theme.sh rather than spread across the format string in tmux.conf.

set -u

STATUS_HOME=${BASH_SOURCE[0]%/*}/status
source "$STATUS_HOME/theme.sh"
source "$STATUS_HOME/cache.sh"
source "$STATUS_HOME/layout.sh"
source "$STATUS_HOME/segment-cpu.sh"
source "$STATUS_HOME/segment-mem.sh"
source "$STATUS_HOME/segment-temp.sh"
source "$STATUS_HOME/segment-git.sh"

path=${1:-}
[ -n "$path" ] && [ -d "$path" ] || exit 0

# Second argument is the client width, which turns this into the thing that
# positions the clock. See emit() in status/layout.sh.
client_width=${2:-0}
case $client_width in
'' | *[!0-9]*) client_width=0 ;;
esac

cache_init

# The branch leads, and the machine readouts trail it out to the right edge.
# That order also settles which of them is allowed to move: the region is
# right-aligned, so the readouts stay pinned to the edge at a fixed width while
# a longer branch name grows leftward into the padding instead of shoving three
# numbers around every time the worktree changes. A segment that has nothing to
# say — no sensor, no first CPU sample yet — returns non-zero and takes no room.
line=
for segment in git cpu mem temp; do
	REPLY=
	"segment_$segment" "$path" && line+=$REPLY
done

emit "$line"
