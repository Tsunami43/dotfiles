-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Screenshot on Super+S (was: toggle scratchpad).
o.rebind("SUPER + S", "Screenshot", "omarchy-capture-screenshot")
-- Screen recording on Super+Shift+S (was: Google Maps webapp).
o.rebind("SUPER + SHIFT + S", "Screenrecording", "omarchy-capture-screenrecording --stop-recording || omarchy-menu toggle trigger.capture.screenrecord")

-- Agent picker on Super+Shift+A (was: ChatGPT webapp).
o.rebind("SUPER + SHIFT + A", "Agent", "omarchy-agent --pick")
-- File manager on Super+E (was unbound).
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })

-- Keybindings hints on Super+W (was: close window; Super+Q still closes windows).
o.rebind("SUPER + W", "Keybindings", "omarchy-menu-keybindings")
hl.unbind("SUPER + K")

-- Vim-style window focus and swap on hjkl instead of arrows.
-- Replaces Super+J (toggle split) and Super+L (cycle layout).
for _, k in ipairs({ "LEFT", "RIGHT", "UP", "DOWN" }) do
  hl.unbind("SUPER + " .. k)
  hl.unbind("SUPER + SHIFT + " .. k)
end
local dirs = { H = { "l", "left" }, J = { "d", "below" }, K = { "u", "above" }, L = { "r", "right" } }
for key, d in pairs(dirs) do
  o.rebind("SUPER + " .. key, "Focus on " .. d[2] .. " window", hl.dsp.focus({ direction = d[1] }))
  o.rebind("SUPER + SHIFT + " .. key, "Swap window " .. d[2], hl.dsp.window.swap({ direction = d[1] }))
end

-- Cycle workspace layout (dwindle/scrolling/floating) on Super+R; Super+L now focuses right.
o.bind("SUPER + R", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Clipboard manager on Super+Shift+V (Super+Ctrl+V still works).
o.bind("SUPER + SHIFT + V", "Clipboard manager", { panel = "omarchy.clipboard" })
