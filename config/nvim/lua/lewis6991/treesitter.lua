local api = vim.api

---@param bufnr integer
local function update_folds_after_parse(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    return
  end

  parser:parse(nil, function(err, trees)
    if err or not trees then
      return
    end

    vim.schedule(function()
      if not api.nvim_buf_is_loaded(bufnr) then
        return
      end

      api.nvim_buf_call(bufnr, function()
        vim.cmd.normal('zx')
      end)
    end)
  end)
end

--- @param bufnr integer
local function enable_foldexpr(bufnr)
  if api.nvim_buf_line_count(bufnr) > 100000 then
    return
  end
  api.nvim_buf_call(bufnr, function()
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
  end)
  update_folds_after_parse(bufnr)
end

api.nvim_create_autocmd('FileType', {
  callback = function(args)
    -- if args.match == 'asl' and api.nvim_buf_line_count(args.buf) > 40000 then
    if args.match == 'asl' then
      return
    end
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end

    api.nvim_exec_autocmds('User', { pattern = 'ts_attach' })
    enable_foldexpr(args.buf)
  end,
})

vim.keymap.set('n', '<leader>ts', function()
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
end)

vim.treesitter.language.register('verilog', 'systemverilog')
-- vim.g.__ts_debug = 1
