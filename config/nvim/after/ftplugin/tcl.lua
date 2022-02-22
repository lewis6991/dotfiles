
vim.opt_local.keywordprg = ':FloatingTclMan'

vim.cmd[[
  command! -nargs=* FloatingTclMan call ToggleCommand('execute ":r !man -D n '.<q-args>. '" | Man!')
]]
