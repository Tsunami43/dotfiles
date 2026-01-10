if status is-interactive
    # RUN on session sh
end

# PATH
set -gx PATH $HOME/bin $PATH
set -gx PATH $PATH (go env GOPATH)/bin
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.pyenv/shims $PATH
set -gx PATH $HOME/develop/flutter/bin $PATH

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx GIT_EDITOR nvim

# Starship prompt
set -gx STARSHIP_CONFIG $HOME/.config/starship/starship.toml
starship init fish | source

# Alias
# vim/nvim
alias vi="nvim"
alias vim="nvim"
alias nv="nvim"
# neofetch
alias neofetch="fastfetch"
alias nf="fastfetch"
# lazygit
alias lg="lazygit"
# eza/ls
alias ls="eza -l --tree --level=1 --icons=always --no-user --no-permissions"
# fast open
alias hosts="nvim ~/.ssh/config"

# Tmux
function tmux
    if test (count $argv) -eq 0
        set NAMES_FILE $HOME/.config/tmux/session_names.txt
        set LINES (cat $NAMES_FILE)
        set SESSION_NAME $LINES[(math "1 + random % " (count $LINES))]
        command tmux new-session -s $SESSION_NAME
    else
        command tmux $argv
    end
end

# Homebrew
set -gx HOMEBREW_NO_ENV_HINTS 1

# Yazi
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Zoxide
zoxide init fish | source
