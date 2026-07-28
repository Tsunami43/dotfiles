# Custom key bindings. fish calls this once per interactive session, after its own
# defaults, so anything set here wins over them.
function fish_user_key_bindings
    # Ctrl+Alt+hjkl: a vim layer for the command line.
    #
    # h/l override a fish default: ctrl-alt-h ships as backward-kill-word, which deletes
    # the previous word instead of stepping over it (see fish_default_key_bindings.fish).
    # Alt+hjkl itself is not available here — Hyprland takes it and hands the terminal a
    # plain arrow key (hypr/mine/binds.conf), which is what makes this layer the ctrl one.
    bind ctrl-alt-h backward-word
    bind ctrl-alt-l forward-word
    bind ctrl-alt-k up-or-search
    bind ctrl-alt-j down-or-search

    # What ctrl-alt-h used to do, kept within reach: kill the word before the cursor.
    bind ctrl-alt-backspace backward-kill-word
end
