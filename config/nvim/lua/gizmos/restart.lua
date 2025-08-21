local session = '/tmp/_session_restart.vim'

vim.api.nvim_create_user_command('Restart', function()
  vim.api.nvim_exec_autocmds('User', { pattern = 'RestartPre' })
  vim.cmd.mksession({ session, bang = true })
  vim.cmd.restart()
end, {})

vim.api.nvim_create_autocmd('VimEnter', {
  group = 'vimrc',
  callback = vim.schedule_wrap(function()
    if vim.uv.fs_stat(session) then
      vim.cmd.source(session)
      vim.fs.rm(session)
    end
  end),
})
