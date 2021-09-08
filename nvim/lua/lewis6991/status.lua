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
  elseif vim.g.gitsigns_head then
    return vim.g.gitsigns_head
  end
  return ''
end

function M.blame()
  if vim.b.gitsigns_blame_line_dict then
    local info = vim.b.gitsigns_blame_line_dict
    local date_time = require('gitsigns.util').get_relative_time(tonumber(info.author_time))
    return string.format('%s - %s', info.author, date_time)
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

local function padded_func(name)
  return '%( %{v:lua.statusline.'..name..'()} %)'
end

function M.statusline(active)
  local s = {}

  s[#s+1] = '%#StatusLine#'..highlight(1, active)
  s[#s+1] = recording()
  s[#s+1] = padded_func('hunks')
  s[#s+1] = highlight(2, active)
  s[#s+1] = padded_func('lsp_status')
  s[#s+1] = '%( %{v:lua.statusline.blame()} %)'
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
vim.cmd[[
  augroup statusline
    autocmd WinLeave,FocusLost * autocmd BufWinEnter,WinEnter,FocusGained * let &l:statusline=v:lua.statusline.statusline(1)
    autocmd WinLeave,FocusLost * let &l:statusline=v:lua.statusline.statusline(0)
    autocmd VimEnter           * let &l:statusline=v:lua.statusline.statusline(1)
  augroup END
]]

_G.statusline = M

return M
