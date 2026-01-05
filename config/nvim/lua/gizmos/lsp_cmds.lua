local api, lsp = vim.api, vim.lsp

-- lsp.log.set_level(lsp.log.levels.DEBUG)
-- lsp.log.set_level(lsp.log.levels.TRACE)

do -- lsp log format
  local log_date_format = '%F %H:%M:%S'

  local vimruntime = vim.pesc(vim.env.VIMRUNTIME)

  --- Default formatting function.
  --- @param level? string
  --- @return string?
  local function format_func(level, ...)
    if lsp.log.levels[level] < lsp.log.get_level() then
      return
    end

    local info = debug.getinfo(3, 'Sl')
    local header = string.format(
      '[%s][%s] %s:%s',
      level,
      os.date(log_date_format),
      info.source:gsub(vimruntime, '<VIMRUNTIME>'),
      info.currentline
    )

    local parts = {} --- @type string[]
    for i = 1, select('#', ...) do
      local arg = select(i, ...)
      if type(arg) == 'string' then
        table.insert(parts, arg)
      elseif type(arg) == 'table' then
        table.insert(parts, vim.json.encode(arg, { indent = '  ' }))
      else
        table.insert(parts, arg == nil and 'nil' or vim.inspect(arg))
      end
    end

    local msg = table.concat(parts, '\t')
    local msg1 = '\t' .. vim.trim(msg:gsub('\n', '\n\t')) .. '\n'
    return header .. '\n' .. msg1
  end

  lsp.log.set_format_func(format_func)
end

do -- LspLog
  local path = lsp.log.get_filename()
  vim.fn.delete(path)

  api.nvim_create_user_command('LspLog', function()
    vim.cmd.tabnew(path)
    local buf = api.nvim_get_current_buf()
    local win = api.nvim_get_current_win()
    vim.bo[buf].filetype = 'log'
    vim.bo[buf].bufhidden = 'wipe'
    vim.wo.foldmethod = 'indent'
    api.nvim_create_autocmd('User', {
      pattern = 'RestartPre',
      callback = function()
        api.nvim_win_close(win, true)
      end,
    })
  end, {})
end
