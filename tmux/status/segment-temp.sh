# CPU package temperature.
#
# Not thermal_zone0: on this box that zone is acpitz, a firmware-reported number
# that barely moves and has nothing to do with what the cores are doing. The
# real sensor is a hwmon whose number is assigned at probe time and can differ
# between boots, so it is resolved by driver name and the answer is remembered —
# the same trade the quickshell Sys service makes for its GPU paths.

ICON_TEMP=$'\357\213\211' # nf-fa-thermometer-half U+F2C9
TEMP_HOT=80               # celsius — above this the readout warms up

# Preference order, best first: the CPU's own die sensor, then anything the
# firmware is willing to claim. A machine with none of these shows no segment
# rather than a number that means nothing.
_temp_rank() {
	case $1 in
	k10temp | zenpower) REPLY=0 ;; # AMD die (Tctl)
	coretemp)           REPLY=1 ;; # Intel package
	acpitz)             REPLY=2 ;; # firmware's guess — last resort
	*)                  return 1 ;;
	esac
}

# Walk /sys/class/hwmon once and cache the winner. The scan is nine or so reads,
# which is cheap but not free, and the answer cannot change while the machine is
# up — and neither can the cache, which lives in XDG_RUNTIME_DIR.
_temp_source() { # -> REPLY
	local memo hwmon name best= best_rank=99
	cache_key "temp-source"
	memo=$REPLY
	if cache_read "$memo"; then
		# An entry of "-" is a resolved answer too: this machine has no sensor
		# worth reading, and rescanning every second will not grow one.
		[ "$REPLY" != "-" ] && [ -r "$REPLY" ]
		return
	fi

	for hwmon in /sys/class/hwmon/hwmon*; do
		[ -r "$hwmon/name" ] && [ -r "$hwmon/temp1_input" ] || continue
		read -r name <"$hwmon/name" 2>/dev/null || continue
		_temp_rank "$name" || continue
		if [ "$REPLY" -lt "$best_rank" ]; then
			best_rank=$REPLY
			best=$hwmon/temp1_input
		fi
	done

	cache_write "$memo" "${best:--}"
	REPLY=$best
	[ -n "$best" ]
}

segment_temp() { # -> REPLY
	local source raw
	_temp_source || return 1
	source=$REPLY
	read -r raw <"$source" 2>/dev/null || return 1
	case $raw in '' | *[!0-9]*) return 1 ;; esac

	local celsius=$((raw / 1000)) tint=$C_METRIC value
	[ "$celsius" -gt 0 ] || return 1
	[ "$celsius" -ge "$TEMP_HOT" ] && tint=$C_HOT
	# Three columns: a CPU that reaches three digits has the bar's attention for
	# reasons a column of padding is not going to help with.
	printf -v value '%d°' "$celsius"
	metric "$tint" "$ICON_TEMP" "$value" 3
}
