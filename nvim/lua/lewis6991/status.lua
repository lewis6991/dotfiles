local M = {}

function M.lsp_status()
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    return ''
  end

  local status = {}

  for _, ty in ipairs { 'Warning', 'Error', 'Information', 'Hint' } do
    local n = vim.lsp.diagnostic.get_count(0, ty)
    if n > 0 then
      table.insert(status, ('%s:%s'):format(ty:sub(1,1), n))
    end
  end
  local r = table.concat(status, ' ')

  return r == '' and 'LSP' or r
end

function M.hunks()
  if vim.b.gitsigns_status then
    local status = vim.b.gitsigns_head
    if vim.b.gitsigns_status ~= '' then
      status = status ..' '..vim.b.gitsigns_status
    end
    return status
  end
  return ''
end

function M.encodingAndFormat()
    local e = vim.bo.fileencoding and vim.bo.fileencoding or vim.o.encoding

    local r = {}
    if e ~= 'utf-8' then
      r[#r+1] = e
    end

    local f = vim.bo.fileformat
    if f ~= 'unix' then
      r[#r+1] = '['..f..']'
    end

    return table.concat(r)
end

local function highlight(num, active)
  if active == 1 then
    if num == 1 then
      return '%#PmenuSel#'
    else
      return '%#StatusLine#'
    end
  else
    return '%#StatusLineNC#'
  end
end

local function exists(x)
    return vim.fn.exists(x) == 1
end

local function recording()
    if not exists('*reg_recording') then
        return ''
    end

    local reg = vim.fn.reg_recording()
    if reg ~= '' then
        return '%#ModeMsg#  RECORDING['..reg..']  '
    else
        return ''
    end
end

function M.statusline(active)
  local s = {}

  s[#s+1] = '%#StatusLine#'..highlight(1, active)
  s[#s+1] = recording()
  s[#s+1] = '%( %{v:lua.statusline.hunks()} %)'
  s[#s+1] = highlight(2, active)
  s[#s+1] = '%( %{v:lua.statusline.lsp_status()} %)'
  if exists('*metals#status') then
    s[#s+1] = '%{metals#status()}'
  end
  s[#s+1] = '%='
  s[#s+1] = '%<%0.60f%m%r'  -- file.txt[+][RO]
  s[#s+1] = '%='

  -- filetype
  s[#s+1] = '%( %{&filetype} %)'
  if exists('*WebDevIconsGetFileTypeSymbol') then
    s[#s+1] = '%( %{WebDevIconsGetFileTypeSymbol()} %)'
  end

  s[#s+1] = highlight(1, active)

  -- encoding
  s[#s+1] ='%{v:lua.statusline.encodingAndFormat()}'

  if exists('*WebDevIconsGetFileFormatSymbol') then
    s[#s+1] ='%( %{WebDevIconsGetFileFormatSymbol()} %)'
  end

  s[#s+1] ='%3p%% %2l(%02c)/%-3L' -- 80% 65[12]/120

  return table.concat(s)
end

-- Only set up WinEnter autocmd when the WinLeave autocmd runs
vim.cmd[[augroup statusline]]
vim.cmd[[    autocmd WinLeave,FocusLost * autocmd WinEnter,FocusGained * let &l:statusline=v:lua.statusline.statusline(1)]]
vim.cmd[[    autocmd WinLeave,FocusLost * let &l:statusline=v:lua.statusline.statusline(0)]]
vim.cmd[[    autocmd VimEnter           * let &l:statusline=v:lua.statusline.statusline(1)]]
vim.cmd[[augroup END]]

_G.statusline = M

return M
