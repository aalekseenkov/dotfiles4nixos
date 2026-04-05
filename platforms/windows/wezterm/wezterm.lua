local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

wezterm.on('gui-startup', function(spawn_cmd)
  local tab, pane, window = mux.spawn_window(spawn_cmd or {})
  window:gui_window():toggle_fullscreen()
end)

config.enable_tab_bar = false
config.window_decorations = "NONE"
-- config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.color_scheme = 'Kanagawa (Gogh)'
-- config.color_scheme = 'Wez'

config.font = wezterm.font("IntoneMono Nerd Font Mono")
-- config.font = wezterm.font("IosevkaTermSlab Nerd Font")

config.font_size = 16
config.line_height = 1.1
-- config.cell_width = 1.05

config.window_background_opacity = 0.95
config.win32_system_backdrop = 'Acrylic'

config.scrollback_lines = 10000
config.animation_fps = 120
config.term = "xterm-256color"
config.front_end = "WebGpu"

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    config.default_domain = 'local'    -- Родное поведение в Windows
end

config.keys = {
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },
}

return config
