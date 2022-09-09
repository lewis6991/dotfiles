vim.filetype.add {
  extension = {
    tmk = 'tcl',
    conf = 'toml'
  },
  filename = {
    ['gerrit_hooks']  = 'toml',
    ['setup.cfg']     = 'toml',
    ['lit.cfg']       = 'python',
    ['lit.local.cfg'] = 'python',
    ['dotshrc']       = 'sh',
    ['dotsh']         = 'sh',
    ['dotcshrc']      = 'csh',
    ['gitconfig']     = 'gitconfig',
  },
  pattern = {
    ['.*'] = {
      priority = -math.huge,
      function(_, bufnr)
        local content = vim.filetype.getlines(bufnr, 1)
        if vim.filetype.matchregex(content, '^#%Module.*') then
          return 'tcl'
        end
      end,
    },
  },
}

