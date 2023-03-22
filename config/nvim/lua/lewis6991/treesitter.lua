local api = vim.api

---@return string?
local function get_lang()
  local ok, parser = pcall(vim.treesitter.get_parser)
  if not ok then
    return
  end

  local cpos = api.nvim_win_get_cursor(0)
  local row, col = cpos[1] - 1, cpos[2]
  local range = { row, col, row, col + 1 }

  local lang ---@type string?
  parser:for_each_child(function(tree, lang_)
    if lang_ ~= 'comment' and tree:contains(range) then
      lang = lang_
      return
    end
  end)

  return lang
end

local function enable_commenstrings()
  api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    buffer = 0,
    callback = function()
      local lang = get_lang() or vim.bo.filetype
      vim.bo.commentstring = vim.filetype.get_option(lang, 'commentstring') --[[@as string]]
    end
  })
end

local function enable_foldexpr()
  vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.opt_local.foldmethod = 'expr'
  vim.cmd.normal'zx'
end

vim.treesitter.language.add('bash', { filetype = { 'bash', 'sh' } })
vim.treesitter.language.add('diff')

api.nvim_create_autocmd('FileType', {
  callback = function()
    if not pcall(vim.treesitter.start) then
      return
    end

    enable_foldexpr()
    enable_commenstrings()
  end
})

require'treesitter-context'.setup {
  enable = true,
  max_lines = 5,
  trim_scope = 'outer'
}

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
