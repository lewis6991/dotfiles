
function MakeFolds()
  local line1 = vim.fn.getline(vim.v.lnum)
  local line2 = vim.fn.getline(vim.v.lnum+1)
  if line1:match('^# %w+') and line2:match('^#%-+$') then
    return '>1'
  end
  return '='
end

vim.b.sleuth_automatic = 0
vim.opt_local.expandtab  = false
vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr   = 'v:lua.MakeFolds()'
