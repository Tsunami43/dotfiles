# CPU busy percentage, from the delta between two /proc/stat samples.
#
# The file counts jiffies since boot, so a single reading says nothing — it
# needs a previous one to subtract. Every redraw is a fresh process, so that
# previous one lives in the cache as a single line: "<epoch> <total> <idle> <pct>".

ICON_CPU=$'\357\213\233' # nf-fa-microchip U+F2DB
CPU_HOT=85               # percent — above this the readout warms up
CPU_MIN_DT=2             # seconds — the shortest window worth a percentage of

segment_cpu() { # -> REPLY
	local line total=0 idle field now pct=
	read -r line </proc/stat 2>/dev/null || return 1
	# "cpu user nice system idle iowait irq softirq …" — the aggregate line is
	# always first, so no scan is needed to find it.
	set -- $line
	shift
	[ $# -ge 4 ] || return 1
	idle=$(($4 + ${5:-0})) # idle + iowait: both are the CPU waiting, not working
	for field; do total=$((total + field)); done
	printf -v now '%(%s)T' -1

	local state prev_ts=0 prev_total=0 prev_idle=0 prev_pct=
	cache_key "cpu"
	state=$REPLY
	if cache_read "$state"; then
		set -- $REPLY
		prev_ts=${1:-0} prev_total=${2:-0} prev_idle=${3:-0} prev_pct=${4:-}
	fi

	# Several clients redraw the same second, and each of them would otherwise
	# close the sample window the moment the one before it opened — leaving a
	# delta of nearly nothing to divide by, which turns the reading into noise.
	# Only a sample old enough to mean something is allowed to be consumed; the
	# redraws in between reuse the figure it produced.
	if [ "$prev_total" -gt 0 ] && [ $((now - prev_ts)) -ge "$CPU_MIN_DT" ]; then
		local dt=$((total - prev_total)) di=$((idle - prev_idle))
		if [ "$dt" -gt 0 ]; then
			pct=$(((dt - di) * 100 / dt))
			[ "$pct" -lt 0 ] && pct=0
			[ "$pct" -gt 100 ] && pct=100
		fi
		cache_write "$state" "$now $total $idle $pct"
	elif [ "$prev_total" -eq 0 ]; then
		# First redraw of this boot: open the window, show nothing yet.
		cache_write "$state" "$now $total $idle "
	fi

	[ -n "$pct" ] || pct=$prev_pct
	[ -n "$pct" ] || return 1

	local tint=$C_METRIC value
	[ "$pct" -ge "$CPU_HOT" ] && tint=$C_HOT
	# Four columns holds "100%", which is where this one can genuinely end up.
	printf -v value '%d%%' "$pct"
	metric "$tint" "$ICON_CPU" "$value" 4
}
