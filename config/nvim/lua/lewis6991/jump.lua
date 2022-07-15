local ns = vim.api.nvim_create_namespace('jumper')

local win_timer
local key_timer

local win

local buf = vim.api.nvim_create_buf(false, true)
do
  local blank = {}
  for i = 1, 100 do
    blank[i]  = ''
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, blank)
end

local WIN_TIMEOUT = 2000
local KEY_TIMEOUT = 2000
local CONTEXT = 8

-- Autocmd ID for cursor moved
local cmoved_au

local function enable_cmoved_au()
  cmoved_au = vim.api.nvim_create_autocmd('CursorMoved,CursorMovedI', {
    once = true,
    callback = function()
      if win then
        vim.api.nvim_win_close(win, true)
        win = nil
      end
      cmoved_au = nil
    end
  })
end

local function disable_cmoved_au()
  if cmoved_au then
    vim.api.nvim_del_autocmd(cmoved_au)
    cmoved_au = nil
  end
end

local function refresh_win(height, width)
  if win then
    vim.api.nvim_win_set_config(win, {
      width = width,
      height = height,
    })
  else
    win = vim.api.nvim_open_win(buf, false, {
      relative = 'win',
      anchor = 'ne',
      col = vim.api.nvim_win_get_width(0),
      row = 0,
      zindex = 200,
      width = width,
      height = height,
      style = 'minimal',
      border = 'single',
    })
    vim.wo[win].winblend = 15
  end
end

local function refresh_win_timer()
  if not win_timer then
    win_timer = vim.loop.new_timer()
  end

  win_timer:start(WIN_TIMEOUT, 0, function()
    win_timer:close()
    win_timer = nil
    if win then
      vim.schedule(function()
        vim.api.nvim_win_close(win, true)
        win = nil
      end)
    end
  end)
end

local function render_buf(lines, current_line)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, l in ipairs(lines) do
    vim.api.nvim_buf_set_extmark(buf, ns, i-1, 0, {
      virt_text = l,
      hl_mode = 'combine',
      line_hl_group = i == current_line and 'Visual' or nil,
    })
  end
end

local function get_text(jumplist, current)
  local width = 0
  local lines = {}
  local current_line
  for i = current-3, current+10 do
    local j = jumplist[i]
    if j then
      local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(j.bufnr), ':~:.')
      local line = string.format('%s:%d:%d', bufname, j.lnum, j.col)
      if #line > width then
        width = #line
      end
      lines[#lines+1] = {
        { bufname },
        {string.format(':%d:%d', j.lnum, j.col), 'Directory'},
      }
      if current == i then
        current_line = #lines
      end
      if #lines > CONTEXT then
        break
      end
    end
  end
  return lines, current_line, width
end

local show = false

local function do_show()
  -- Only show on second succesive jump within KEY_TIMEOUT
  if not key_timer then
    key_timer = vim.loop.new_timer()
  end
  key_timer:start(KEY_TIMEOUT, 0, function()
    key_timer:close()
    key_timer = nil
    show = false
  end)

  if show then
    return true
  end

  show = true
end

local function show_jumps(forward)
  if not do_show() then
    return
  end

  disable_cmoved_au()

  local jumplist, last_jump_pos = unpack(vim.fn.getjumplist())

  local current = last_jump_pos + 1 + (forward and 1 or -1)
  if current == 0 then
    current = 1
  end

  if current > #jumplist then
    current = #jumplist
  end

  local lines, current_line, width = get_text(jumplist, current)
  render_buf(lines, current_line)

  vim.schedule(function()
    refresh_win(#lines, width+2)
    refresh_win_timer()
    enable_cmoved_au()
  end)
end

vim.keymap.set('n', '<C-o>', function()
  show_jumps()
  return '<C-o>'
end, {expr = true, desc = 'show jumps'})

vim.keymap.set('n', '<C-i>', function()
  show_jumps(true)
  return '<C-i>'
end, {expr = true, desc = 'show jumps'})


