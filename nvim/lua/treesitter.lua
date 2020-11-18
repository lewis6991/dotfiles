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
    use_languagetree = true,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "gnn",
      node_incremental  = "grn",
      scope_incremental = "grc",
      node_decremental  = "grm",
    },
  },
  -- context = {
  --   disable = { "python" },
  -- }
}

table.insert(langs, 'systemverilog')
table.insert(langs, 'sh')

for _, l in pairs(langs) do
  vim.cmd(
    'autocmd vimrc FileType '..l..
    ' set'..
    ' foldmethod=expr'..
    ' nospell'..
    ' foldexpr=nvim_treesitter#foldexpr()'
  )
end
