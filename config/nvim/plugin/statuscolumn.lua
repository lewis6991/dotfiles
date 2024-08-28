do return end

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
  local foldcolumn = '' or getfoldcolumn()
  local gs = require'gitsigns'.statuscolumn()
  local lnum = vim.v.relnum ~= 0 and vim.v.relnum or vim.v.lnum
  return string.format('%d%s%s ', lnum, foldcolumn, gs)
end

vim.opt.statuscolumn = '%s%=%{%v:lua.statuscolumn()%}'
