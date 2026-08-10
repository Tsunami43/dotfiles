# tmux

Alt-driven tmux: a modifier instead of a prefix, one mode where a mode earns its
keep, and a status bar that says which mode you are in.

Colours come from [cendre](https://github.com/Aejkatappaja/cendre) (`hard`), the
same palette the editor and the terminal use.

## Layout

| file | what it is |
| --- | --- |
| `tmux.conf` | options, key bindings, palette, status bar |
| `utility.conf` | the two popups — lazygit and the session switcher |
| `sessions.sh` | the session switcher itself, an fzf tree over sessions and windows |
| `status.sh` + `status/` | the right-hand region of the bar: git, cpu, memory, temperature |

Requires `fzf` for the session switcher, `lazygit` for `Alt+g`, and
[tpm](https://github.com/tmux-plugins/tpm) in `plugins/` for `tmux-sensible` and
`tmux-yank`.

## Alt is the modifier

There is no prefix to press and release. Every binding below is `-n`, so Alt is
simply part of the chord, the way Super is in a window manager.

The cost: these combinations no longer reach whatever runs inside the pane — in
fish that means losing `Alt+h` and `Alt+l`. The list is deliberately short for
that reason. `Ctrl+B` stays bound as tmux's prefix with its stock bindings,
unclaimed by anything here, as a way back in if a chord is ever swallowed
upstream.

### Windows

| key | |
| --- | --- |
| `Alt+c` | new window, in the active pane's directory |
| `Alt+Tab` / `Alt+Shift+Tab` | next / previous window |
| `Alt+1` … `Alt+9` | window by number |
| `Alt+n` | new session |

### Panes

| key | |
| --- | --- |
| `Alt+v` / `Alt+Shift+V` | split vertically / horizontally |
| `Alt+h/j/k/l` | move to the pane in that direction |
| `Ctrl+h/j/k/l` | the same moves, kept from before Alt |
| `Alt+Shift+H/J/K/L` | swap this pane with the one in that direction |
| `Alt+z` | zoom, and back |
| `Alt+q` | close the pane |

### Everything else

| key | |
| --- | --- |
| `Alt+s` | session switcher |
| `Alt+g` | lazygit, where there is a repository |
| `Alt+t` | copy mode |
| `Alt+m` | resize mode |
| `Alt+r` | reload the config |
| `Ctrl+Shift+K` | clear the pane's scrollback |

## Modes

Two of them, plus the two tmux has of its own. The bar names whichever is
current in the slot at its right edge.

### Resize — `Alt+m`

The one thing here that is a mode rather than a chord: a size is arrived at over
several steps, and one chord per step is the wrong unit of work.

| key | |
| --- | --- |
| `h j k l` | move the border, growing the pane that way |
| `z` | zoom without leaving |
| `Esc` / `q` | out |

### Copy — `Alt+t`

vi keys. `v` starts a selection, `Ctrl+v` makes it rectangular, `y` copies and
leaves. The selection uses the same tint the editor draws Visual in.

## Session switcher — `Alt+s`

A tree of sessions and their windows, in a popup that drops out from under the
clock. **Moving the cursor moves the client**: the window a row points at is on
screen around the popup as you walk the list, which is why there is no preview.

The list is modal, the way an editor is — typing does not search until asked.

| key | |
| --- | --- |
| `j` / `k` | move |
| `l` | open a session |
| `h` | shut it — from a window row, shuts the session and lands on it |
| `Enter` | keep where the cursor took you, close |
| `q` / `Esc` | close and go back to where you started |
| `/` | search; `Esc` leaves the search without closing the popup |
| `r` | rename the session |
| `n` | new session — switches to it and closes |
| `d` | kill the window or session under the cursor |

`d` says what it is about to cost when the cost is more than the row itself: the
last window takes its session with it. It refuses to kill the last session, and
moves the client somewhere else before killing the session it is sitting in.

Sessions are not in the tree twice and panes are not in it at all — a pane is a
region of a window rather than a place to be sent to. The window row carries the
pane count instead.

## Status bar

```
 session │ windows                    12:34:56   git · cpu · mem · temp   READY
```

The clock is held on the bar's centre column: `status.sh` is told the client
width and emits exactly enough leading space, so nothing in the window list can
push it. The readouts trail it out to the right edge, at comment weight, warming
up only when a figure wants attention — a dirty worktree, a hot core.

The right edge is the mode slot, ten columns wide in every state so the readouts
beside it never shift:

| | |
| --- | --- |
| `READY` | nothing in the way |
| `SESSIONS` | the session switcher is open |
| `GIT` | lazygit is open |
| `COPY` | copy mode |
| `RESIZE` | resize mode |
| `PREFIX` | `Ctrl+B` is held |

`READY` rather than `NORMAL`: this bar sits directly above an editor that uses
`NORMAL` for something else.

The two popup states exist because tmux has no format for "a popup is open" — an
overlay leaves no trace in any flag a format can reach, so each popup sets
`@overlay` itself and clears it on the way out, under a trap, so that a run
killed outright still releases it.

## Sessions outlive their terminals

Closing a terminal detaches the client and nothing more. A session ends only on
purpose — `d` in the switcher, or `kill-session`.

## Cost

The bar redraws every second, because the clock shows seconds. That is one
`#()` for the whole right-hand region, not one per readout: tmux runs each in
its own shell, and starting that shell costs an order of magnitude more than
anything the segments compute. `status.sh` sources them into one process and
caches the expensive ones — git work still runs at its own rate, and the CPU
sample closes its window every two seconds.
