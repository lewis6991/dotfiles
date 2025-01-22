local wezterm = require('wezterm')

local config = wezterm.config_builder()

--- Make sure to set the shell correctly, otherwise compinit will re-run as
--- fpath is different when we use homebrew's zsh
config.set_environment_variables = {
  SHELL = '/opt/homebrew/bin/zsh',
}

config.font = wezterm.font('Monaco', { weight = 'Bold' })
-- config.font = wezterm.font('Monaco')
config.font_size = 12.5
config.harfbuzz_features = { 'liga=0' }

local color = {
  [0] = '#0d1117',
  [1] = '#161b22',
  [2] = '#21262d',
  [3] = '#30363d',
  [4] = '#484f58',
  [5] = '#6e7681',
  [6] = '#8b949e',
  [7] = '#b1bac4',
  [8] = '#c9d1d9',
  [9] = '#f0f6fc',
}

local select = '#29384b'

config.colors = {
  cursor_bg = color[7],
  cursor_fg = color[0],
  cursor_border = color[7],
  selection_bg = select,

  tab_bar = {
    inactive_tab_edge = color[3],
    inactive_tab = { bg_color = color[0], fg_color = color[8] },
    active_tab = { bg_color = color[2], fg_color = color[7] },
    inactive_tab_hover = { bg_color = color[3], fg_color = color[7] },
    new_tab = { bg_color = color[0], fg_color = color[6] },
    new_tab_hover = { bg_color = color[3], fg_color = color[7] },
  },
}

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.window_frame = {
  font_size = 13,
  active_titlebar_bg = color[0],
  inactive_titlebar_bg = color[0],
}

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

config.term = 'wezterm'

return config
