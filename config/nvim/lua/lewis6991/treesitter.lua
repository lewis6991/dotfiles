
require'nvim-treesitter'.setup {
  ensure_install = {
    'bash',
    'c',
    -- 'comment',
    'gitcommit',
    'vimdoc',
    'html',
    'json',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'rst',
    'scala',
    'teal',
    'vim',
    'vimdoc',
    'yaml',
  }
}

local parser_config = require "nvim-treesitter.parsers".configs
local c_info = parser_config.c.install_info
c_info.url = 'https://github.com/nvim-treesitter/tree-sitter-c'
-- c_info.url = '~/projects/tree-sitter-c'
c_info.revision = 'nvimc'
