local api = vim.api

local function noautocmd(f)
  local ei = vim.o.eventignore
  vim.o.eventignore = 'all'
  f()
  vim.o.eventignore = ei
end

-- Potential bug: some filetypes might not set 'commentstring' so we may end up
-- returning 'commentstring' for another filetype if the buffer is re-used.
local buf = api.nvim_create_buf(false, true)

---@return string
local function get_ft_option(filetype, option)
  -- Change the filetype without triggering any autocmds
  noautocmd(function()
    vim.bo[buf].filetype = filetype
  end)

  -- Trigger the FileType autocmd in ftplugin.vim
  api.nvim_buf_call(buf, function()
    api.nvim_exec_autocmds('FileType', { group = 'filetypeplugin', buffer = buf })
  end)

  return vim.bo[buf][option]
end

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
    if tree:contains(range) then
      lang = lang_
      return
    end
  end)

  return lang
end

local commentstrings = {} ---@type table<string,string>

local function enable_commenstrings()
  api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    buffer = 0,
    callback = function()
      local lang = get_lang() or vim.bo.filetype

      if not commentstrings[lang] then
        commentstrings[lang] = get_ft_option(lang, 'commentstring')
      end

      local cs = commentstrings[lang]
      if vim.bo.commentstring ~= cs then
        vim.bo.commentstring = cs
      end
    end
  })
end

vim.treesitter.language.add('bash', { filetype = { 'bash', 'sh' } })
vim.treesitter.language.add('diff')

api.nvim_create_autocmd('FileType', {
  callback = function()
    if not pcall(vim.treesitter.start) then
      return
    end

    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldmethod = 'expr'
    vim.cmd.normal'zx'

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
    "bash",
    "c",
    "help",
    "html",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "rst",
    "teal",
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
