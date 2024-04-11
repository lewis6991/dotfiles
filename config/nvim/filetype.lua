vim.filetype.add({
  extension = {
    tmk = 'tcl',
    conf = 'toml',
    v = 'verilog',
    h = 'c',
    cpp = 'cpp',
  },
  filename = {
    ['gerrit_hooks'] = 'toml',
    ['setup.cfg'] = 'toml',
    ['lit.cfg'] = 'python',
    ['lit.local.cfg'] = 'python',
    ['dotshrc'] = 'sh',
    ['dotsh'] = 'sh',
    ['dotcshrc'] = 'csh',
    ['gitconfig'] = 'gitconfig',
  },
  pattern = {
    ['.*'] = {
      priority = -math.huge,
      function(_, bufnr)
        local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)[1]
        if vim.regex('^#%Module.*'):match_str(content) ~= nil then
          return 'tcl'
        end
      end,
    },
  },
})
