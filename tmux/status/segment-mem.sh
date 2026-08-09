# Memory in use, as a percentage.
#
# MemAvailable rather than MemFree: free memory on a machine that has been up a
# while is nearly always small and nearly always meaningless, because the kernel
# spends it on cache it will hand back on demand. Available is the figure that
# answers the question the reader is actually asking.

ICON_MEM=$'\357\207\200' # nf-fa-database U+F1C0
MEM_HOT=85               # percent — above this the readout warms up

segment_mem() { # -> REPLY
	local key value total= avail=
	# The two fields sit in the first three lines, so the read stops there
	# instead of walking the fifty-odd that follow.
	while read -r key value _; do
		case $key in
		MemTotal:) total=$value ;;
		MemAvailable:)
			avail=$value
			break
			;;
		esac
	done </proc/meminfo 2>/dev/null

	[ -n "$total" ] && [ -n "$avail" ] && [ "$total" -gt 0 ] || return 1

	local used=$(((total - avail) * 100 / total)) tint=$C_METRIC value
	[ "$used" -ge "$MEM_HOT" ] && tint=$C_HOT
	printf -v value '%d%%' "$used"
	metric "$tint" "$ICON_MEM" "$value" 4
}
