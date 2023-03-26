
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'bash',
    'c',
    'comment',
    'diff',
    'gitcommit',
    'help',
    'html',
    'json',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'rst',
    'teal',
    'yaml',
  },
  indent = {
    enable = true,
    -- is_supported = function(lang)
    --   return ({
    --     lua = true,
    --     c = true,
    --     tcl = true
    --   })[lang] or false
    -- end
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
local c_info = parser_config.c.install_info
-- url = 'https://github.com/nvim-treesitter/tree-sitter-c',
c_info.url = '~/projects/tree-sitter-c'
c_info.revision = 'nvimc'
