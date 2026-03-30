local M = {}

local api = vim.api

local session = '/tmp/_session_restart.vim'

api.nvim_create_user_command('Restart', function()
  api.nvim_exec_autocmds('User', { pattern = 'RestartPre' })
  vim.cmd.mksession({ session, bang = true })
  local ok, err = pcall(vim.cmd.restart, 'lua require("gizmos.restart").load()')
  if not ok then
    vim.notify('Restart failed: ' .. err, vim.log.levels.ERROR)
  end
end, {})
function M.load()
  if vim.uv.fs_stat(session) then
    vim.cmd.source(session)
    vim.fs.rm(session)
  end
end

return M
