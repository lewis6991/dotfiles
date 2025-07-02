return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.git',
  },
  root_dir = function(buf, on_root_dir)
    if vim.fs.root(buf, '.emmyrc.json') then
      return
    end
    on_root_dir(vim.fs.root(buf, {
      '.luarc.json',
      '.luarc.jsonc',
      '.git',
    }))
  end,
}
