# Cendre · hard — palette from ~/Projects/me/cendre (lua/cendre/palette.lua),
# mirrored from the role names tmux.conf uses for the bar itself.
#
# Colour lives here rather than in the segments so that "what does warm mean in
# this bar" is one decision in one file. The right end of the bar is the quiet
# end: readouts sit at comment weight, and only a figure that actually wants
# attention is allowed to warm up.

C_BRANCH='#[fg=#e6d5c2]' # fg — the branch is lit, not tucked away
C_DIRTY='#[fg=#f4a21c]'  # warn — a worktree with real dirt in it
C_SYNC='#[fg=#a09384]'   # fg_dim — ahead/behind is information, not a warning

C_METRIC='#[fg=#73665b]' # comment — machine readouts are ambient by default
C_HOT='#[fg=#f4a21c]'    # warn — the same warmth dirt gets, for the same reason
