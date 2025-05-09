local api, lsp = vim.api, vim.lsp
local get_clients = vim.lsp.get_clients

local function client_complete()
  --- @param c vim.lsp.Client
  --- @return string
  return vim.tbl_map(function(c)
    return c.name
  end, get_clients())
end

api.nvim_create_user_command('LspRestart', function(kwargs)
  local bufnr = vim.api.nvim_get_current_buf()
  local name = kwargs.fargs[1] --- @type string
  for _, client in ipairs(get_clients({ bufnr = bufnr, name = name })) do
    local bufs = vim.deepcopy(client.attached_buffers)
    client:stop()
    vim.wait(30000, function()
      return lsp.get_client_by_id(client.id) == nil
    end)
    local client_id = lsp.start(client.config)
    if client_id then
      for buf in pairs(bufs) do
        lsp.buf_attach_client(buf, client_id)
      end
    end
  end
end, {
  nargs = '*',
  complete = client_complete,
})

api.nvim_create_user_command('LspStop', function(kwargs)
  local bufnr = vim.api.nvim_get_current_buf()
  local name = kwargs.fargs[1] --- @type string
  for _, client in ipairs(get_clients({ bufnr = bufnr, name = name })) do
    client:stop()
  end
end, {
  nargs = '*',
  complete = client_complete,
})

do -- LspLog
  local path = vim.lsp.get_log_path()
  vim.fn.delete(path)
  vim.lsp.set_log_level(vim.lsp.log.levels.TRACE)
  -- vim.lsp.log.set_format_func(vim.inspect)

  api.nvim_create_user_command('LspLog', function()
    vim.cmd.split(path)
  end, {})
end
