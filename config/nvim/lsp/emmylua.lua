return {
  cmd = { 'emmylua_ls' },
  -- cmd = {
  --   '/Users/lewrus01/projects/emmylua-analyzer-rust/target/release/emmylua_ls',
  --    -- '--log-level', 'debug',
  -- },
  filetypes = { 'lua' },
  root_markers = {
    { '.emmyrc.lua', '.emmyrc.json' },
    '.git',
  },
  workspace_required = true,
}
