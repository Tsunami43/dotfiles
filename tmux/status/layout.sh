# Geometry of the right-hand region.
#
# tmux right-aligns status-right as one string, so the region's own width is
# what decides the column it begins at. The clock sits at the head of that
# string and the padding emitted here sits behind it, which pins the clock to
# the bar's centre column no matter what the window list is doing on the other
# side. Nothing on the left is measured, so nothing on the left can push it.

CLOCK_WIDTH=8 # HH:MM:SS
MODE_WIDTH=10 # the mode slot past the right edge of this script's output:
              # READY, PREFIX, COPY, RESIZE, SESSIONS, GIT — ten columns each,
              # which is what the longest of them needs with a space either side.
              # It is emitted by tmux.conf, not here, but it sits inside the
              # same right-aligned string, so its width has to be accounted for
              # or the clock lands eight columns left of the centre.

# Width as the terminal will see it: the tmux #[...] directives are markup, not
# glyphs. Done with the shell's own pattern matching rather than sed, because
# this runs once a second for every attached client and a pipeline here would
# cost two processes to save nothing.
visible_width() { # -> REPLY
	local s=$1 out=
	while [[ $s == *'#['*']'* ]]; do
		out+=${s%%'#['*}
		s=${s#*'#['}
		s=${s#*]}
	done
	out+=$s
	REPLY=${#out}
}

# One readout, formatted so the icon and its figure stay tight together.
#
# A segment has to keep a fixed width or the ones beside it shift every time a
# number gains a digit — but the slack that buys goes in front of the icon, not
# between the icon and the number. Padding inside the pair reads as a gap in the
# middle of one word; the same spaces ahead of it read as the join between two
# segments, which is what they actually are.
metric() { # tint icon value width -> REPLY
	local tint=$1 icon=$2 value=$3 slack=$(($4 - ${#3}))
	[ "$slack" -lt 0 ] && slack=0
	printf -v REPLY '%s%*s %s %s' "$tint" "$slack" '' "$icon" "$value"
}

emit() {
	local s=$1 pad centre
	if [ "$client_width" -gt 0 ]; then
		visible_width "$s"
		centre=$(((client_width - CLOCK_WIDTH) / 2))
		pad=$((client_width - centre - CLOCK_WIDTH - REPLY - MODE_WIDTH))
		# Too narrow, or an unusually long branch: give up the centre rather
		# than the content, and let the clock drift left as it used to.
		[ "$pad" -lt 1 ] && pad=1
		printf '%*s' "$pad" ''
	fi
	printf '%s' "$s"
}
