require'nvim-treesitter'.define_modules {
  fold = {
    attach = function()
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.opt_local.foldmethod = 'expr'
      vim.cmd.normal'zx' -- recompute folds
    end,
    detach = function() end,
  }
}

require'treesitter-context'.setup {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
  trim_scope = 'outer',
}

local langs = {
  "bash",
  "c",
  "html",
  "json",
  "lua",
  "make",
  "python",
  "rst",
  "teal",
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = langs,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
    is_supported = function(lang)
      return lang == 'lua'
    end
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
  fold = {
    enable = true,
    disable = {'rst', 'make'}
  },
  playground = { enable = true }, -- EXITFREE lag
  context_commentstring = { enable = true }
}

-- parsers.list.lua.install_info.url = '/Users/lewis/projects/nvim-tree-sitter-lua'
-- parsers.list.lua.install_info.url = '/Users/lewis/.data/nvim/site/pack/packer/start/nvim-treesitter/grammar/lua'
