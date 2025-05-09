local api = vim.api

local g = api.nvim_create_augroup('http_file_viewer', {})

api.nvim_create_autocmd('BufReadCmd', {
  pattern = 'https://*',
  group = g,
  callback = function()
    local bufname = api.nvim_buf_get_name(0)
    local text = vim.fn.systemlist({ 'curl', '--silent', bufname })
    api.nvim_buf_set_lines(0, 0, -1, true, text)
    vim.bo.filetype = select(1, vim.filetype.match({ buf = 0 }))
    vim.bo.modified = false
    vim.bo.readonly = true
    vim.bo.buftype = 'nowrite'
  end,
})
