function YamlFolds()
  local previous_level = vim.fn.indent(vim.fn.prevnonblank(vim.v.lnum - 1)) / vim.bo.shiftwidth
  local current_level = vim.fn.indent(vim.v.lnum) / vim.bo.shiftwidth
  local next_level = vim.fn.indent(vim.fn.nextnonblank(vim.v.lnum + 1)) / vim.bo.shiftwidth

  if vim.fn.getline(vim.v.lnum + 1):match('^%s*$') then
    return '='
  elseif current_level < next_level then
    return next_level
  elseif current_level > next_level then
    return 's' .. (current_level - next_level)
  elseif current_level == previous_level then
    return '='
  end

  return next_level
end

vim.opt_local.foldmethod = 'expr'
vim.opt_local.foldexpr   = 'v:lua.YamlFolds()'

vim.opt_local.spell = false
