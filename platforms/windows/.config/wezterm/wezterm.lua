local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- 1. START IN FULLSCREEN
wezterm.on('gui-startup', function(spawn_cmd)
  local tab, pane, window = mux.spawn_window(spawn_cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- 2. ZEN MODE
config.enable_tab_bar = false
config.window_decorations = "NONE"
config.window_padding = { left = 50, right = 40, top = 30, bottom = 10 }

-- 3. THEMES AND FONTS
config.color_scheme = 'Kanagawa Dragon (Gogh)'
-- config.color_scheme = 'Butrin (Gogh)'
-- config.color_scheme = 'Nova (base16)'
-- config.color_scheme = 'Borland'

config.font = wezterm.font("iMWritingMono Nerd Font Mono")
-- config.font = wezterm.font("IntoneMono Nerd Font Mono")
-- config.font = wezterm.font("ZedMono Nerd Font Mono")
-- config.font = wezterm.font("IosevkaTermSlab Nerd Font")

config.font_size = 18
config.line_height = 1.12
config.cell_width = 1.05
config.window_background_opacity = 0.95
config.win32_system_backdrop = 'Acrylic'

-- 4. TECHNICAL BASES
config.scrollback_lines = 10000
config.animation_fps = 120
config.term = "xterm-256color"
config.front_end = "WebGpu"

-- 5. WINDOWS ADAPTATION
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    config.default_domain = 'local'
end

-- 6. SHORTCUTS
config.keys = {
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },
}

return config
