local _test = [[
hello
<<<<<<<<<<<<<<< head
head
||||||||||||||| ancestor
ancestor
==============
new
>>>>>>>>>>>>>> new
world
]]

local api = vim.api

local M = {}

--- @param row integer
--- @return string
local function getline(row)
  return api.nvim_buf_get_lines(0, row, row + 1, false)[1]
end

--- @param row integer
--- @param end_row? integer
local function delline(row, end_row)
  api.nvim_buf_set_lines(0, row, (end_row or row) + 1, false, {})
end

-- Selects the current git conflict region using Neovim API, handling ancestor conflicts
function M.select_git_conflict()
  local cursor = api.nvim_win_get_cursor(0)
  local cur_row = cursor[1] - 1

  --- @type integer?, integer?, integer?, integer?
  local start_row, ancestor_row, middle_row, end_row

  -- Find start of conflict (<<<<<<<)
  for i = cur_row, 0, -1 do
    local line = getline(i)
    if line:match('^<<<<<<<') then
      start_row = i
      break
    end
  end

  if not start_row then
    vim.notify('No git start conflict region found', vim.log.levels.WARN)
    return
  end

  -- Find ancestor (|||||||) and middle (=======) and end (>>>>>>>)
  for i = start_row, api.nvim_buf_line_count(0) - 1 do
    local line = getline(i)
    if not ancestor_row and line:match('^|||||||') then
      ancestor_row = i
    elseif not middle_row and line:match('^=======') then
      middle_row = i
    elseif line:match('^>>>>>>>') then
      end_row = i
      break
    end
  end

  if not middle_row then
    vim.notify('No git conflict middle found', vim.log.levels.WARN)
    return
  elseif not end_row then
    vim.notify('No git conflict end found', vim.log.levels.WARN)
    return
  end

  if cur_row < (ancestor_row or middle_row) then
    delline(ancestor_row or middle_row, end_row)
    delline(start_row)
  elseif ancestor_row and cur_row < middle_row then
    delline(middle_row, end_row)
    delline(start_row, ancestor_row)
  else
    delline(end_row)
    delline(start_row, middle_row)
  end
end

vim.keymap.set('n', '<leader>hsn', M.select_git_conflict, { desc = 'Select git conflict region' })

return M
