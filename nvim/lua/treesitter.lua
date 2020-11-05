local langs = {
  "python",
  "json",
  "html",
  "bash",
  "lua",
  "rst",
  "verilog"
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = langs,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },

}

for _, l in pairs(langs) do
  vim.cmd(
    'autocmd vimrc FileType '..l..
    ' set'..
    ' foldmethod=expr'..
    ' foldexpr=nvim_treesitter#foldexpr()'
  )
end

vim.cmd('autocmd vimrc FileType systemverilog set foldmethod=expr foldexpr=nvim_treesitter#foldexpr()')
