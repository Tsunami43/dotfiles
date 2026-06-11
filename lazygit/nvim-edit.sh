#!/bin/sh
# Open a file from lazygit (os.edit/os.editAtLine in config.yml).
# Inside nvim's terminal ($NVIM set) delegate to the parent instance via
# LazyGitEditFromFloat() defined in ~/.config/nvim/plugins/lazygit.lua;
# otherwise just run nvim. Usage: nvim-edit.sh <file> [line]
file=$1
line=$2

if [ -z "$NVIM" ]; then
    exec nvim ${line:++"$line"} -- "$file"
fi

# escape single quotes for the vimscript string literal
file_esc=$(printf '%s' "$file" | sed "s/'/''/g")
exec nvim --server "$NVIM" \
    --remote-expr "v:lua.LazyGitEditFromFloat('$file_esc'${line:+, $line})" \
    >/dev/null 2>&1
