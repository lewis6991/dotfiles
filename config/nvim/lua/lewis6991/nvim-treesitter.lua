
require'nvim-treesitter'.setup {
  ensure_install = {
    'bash',
    'c',
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
    'vim',
    'vimdoc',
    'yaml',
  }
}

-- local parser_config = require "nvim-treesitter.parsers".configs
-- local make_info = parser_config.make
-- make_info.install_info.url = '~/projects/tree-sitter-make'
-- make_info.install_info.requires_generate_from_grammar = '~/projects/tree-sitter-make'
