local function getfoldcolumn()
  if vim.fn.foldlevel(vim.v.lnum) > vim.fn.foldlevel(vim.v.lnum - 1) then
    if vim.fn.foldclosed(vim.v.lnum) == -1 then
      return "%#FoldColumn#▼"
    else
      return "%#FoldColumn#⏵"
    end
  else
    return ' '
  end
end

_G.statuscolumn = function()
  local foldcolumn = getfoldcolumn()
  local lnum = vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum
  return string.format('%d%s', lnum, foldcolumn)
end

vim.opt.statuscolumn = '%s%=%{%v:lua.statuscolumn()%}'
