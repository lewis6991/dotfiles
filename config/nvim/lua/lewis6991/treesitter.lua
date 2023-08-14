local api = vim.api

api.nvim_create_autocmd('FileType', {
  pattern = 'comment',
  callback = function()
    vim.bo.commentstring = ''
  end
})

---@return string?
local function get_injection_filetype()
  local ok, parser = pcall(vim.treesitter.get_parser)
  if not ok then
    return
  end

  local cpos = api.nvim_win_get_cursor(0)
  local row, col = cpos[1] - 1, cpos[2]
  local range = { row, col, row, col + 1 }

  local ft  --- @type string?

  parser:for_each_child(function(tree, lang)
    if tree:contains(range) then
      local fts = vim.treesitter.language.get_filetypes(lang)
      for _, ft0 in ipairs(fts) do
        if vim.filetype.get_option(ft0, 'commentstring') ~= '' then
          ft = fts[1]
          break
        end
      end
    end
  end)

  return ft
end

local ts_commentstring = api.nvim_create_augroup('ts_commentstring', {})

--- @param bufnr integer
local function enable_commenstrings(bufnr)
  api.nvim_clear_autocmds({ buffer = bufnr, group = ts_commentstring })
  api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
    buffer = bufnr,
    group = ts_commentstring,
    callback = function()
      local ft = get_injection_filetype() or vim.bo[bufnr].filetype
      vim.bo[bufnr].commentstring = vim.filetype.get_option(ft, 'commentstring') --[[@as string]]
    end
  })
end

--- @param bufnr integer
local function enable_foldexpr(bufnr)
  if api.nvim_buf_line_count(bufnr) > 40000 then
    return
  end
  api.nvim_buf_call(bufnr, function()
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.cmd.normal'zx'
  end)
end

api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end

    enable_foldexpr(args.buf)
    enable_commenstrings(args.buf)
  end
})

vim.keymap.set('n', '<leader>ts', function()
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
end)

vim.treesitter.language.register('bash', 'zsh')
-- vim.g.__ts_debug = 1
