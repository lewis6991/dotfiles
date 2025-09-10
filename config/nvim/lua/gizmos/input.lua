local api = vim.api

--- @class (exact) uiinput.InputOptions
--- @field prompt? string
--- @field default? string
--- @field highlight? fun(text: string): [integer,integer,string][]

--- @param winid integer
--- @param mode_to_restore string
local function close_win(winid, mode_to_restore)
  if mode_to_restore ~= 'i' then
    vim.cmd.stopinsert()
  end

  local ok, err = pcall(api.nvim_win_close, winid, true)
  -- If we couldn't close the window because we're in the cmdline,
  -- try again after WinLeave
  if not ok and err and err:match('^E11:') then
    api.nvim_create_autocmd('WinLeave', {
      callback = vim.schedule_wrap(function()
        api.nvim_win_close(winid, true)
      end),
      once = true,
    })
  end
end

---Ensure that the input only has a single line
local function remove_extra_lines(winid)
  local bufnr = api.nvim_win_get_buf(winid)
  if not winid or not api.nvim_win_is_valid(winid) then
    return
  end
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, true)
  if #lines == 1 then
    return
  end
  while #lines > 1 and lines[1]:match('^%s*$') do
    table.remove(lines, 1)
  end
  api.nvim_buf_set_lines(bufnr, 0, -1, true, { lines[1] })
end

local ns = api.nvim_create_namespace('GizmosInputHighlight')

--- @param winid integer
--- @param highlight? fun(text: string): [integer,integer,string][]
local function apply_highlight(winid, highlight)
  local bufnr = api.nvim_win_get_buf(winid)
  local text = api.nvim_buf_get_lines(bufnr, 0, 1, true)[1]

  local highlights = {} --- @type [integer, integer, string][]
  if type(highlight) == 'function' then
    highlights = highlight(text)
  end

  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    local start, stop, group = unpack(hl)
    api.nvim_buf_set_extmark(bufnr, ns, 0, start, {
      end_col = stop,
      hl_group = group,
    })
  end
end

---@param lines string[]
---@return integer
local function get_max_strwidth(lines)
  local max = 0
  for _, line in ipairs(lines) do
    max = math.max(max, api.nvim_strwidth(line))
  end
  return max
end

--- @param winid integer
local function set_win_opts(winid)
  local o = vim.wo[winid]
  -- Disable line wrapping
  o.wrap = false
  -- Indicator for when text exceeds window
  o.list = true
  o.listchars = 'precedes:…,extends:…'
  -- Increase this for more context when text scrolls off the window
  o.sidescrolloff = 0
end

--- @param winid integer
--- @param lines string[]
--- @param opts vim.api.keyset.win_config
local function open_prompt_win(winid, lines, opts)
  local prompt_buf = api.nvim_create_buf(false, true)
  vim.bo[prompt_buf].swapfile = false
  vim.bo[prompt_buf].bufhidden = 'wipe'
  local row = -1 * #lines
  local col = 0
  if opts.border then
    row = row - 2
    col = col - 1
  end
  local prompt_win = api.nvim_open_win(prompt_buf, false, {
    relative = 'win',
    win = winid,
    width = opts.width,
    height = #lines,
    row = row,
    col = col,
    focusable = false,
    zindex = (opts.zindex or 50) - 1,
    style = 'minimal',
    border = opts.border,
    noautocmd = true,
  })
  set_win_opts(prompt_win)
  api.nvim_buf_set_lines(prompt_buf, 0, -1, true, lines)
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(winid),
    once = true,
    nested = true,
    callback = function()
      api.nvim_win_close(prompt_win, true)
    end,
  })
end

--- @param parent_win integer
--- @param prompt_lines string[]
--- @param default string
--- @return integer
local function calc_width(parent_win, prompt_lines, default)
  -- First calculate the desired base width of the modal
  local width = 40
  -- Then expand the width to fit the prompt and default value
  width = math.max(width, 4 + get_max_strwidth(prompt_lines))
  width = math.max(width, 2 + api.nvim_strwidth(default))

  -- Then recalculate to clamp final value to min/max
  local total_size = api.nvim_win_get_width(parent_win or 0)
  local min_width = math.max(20, 0.2 * total_size)
  local max_width = math.max(math.min(total_size, 140), 0.9 * total_size)
  return math.floor(math.max(math.min(width, max_width), min_width))
end

---@param opts uiinput.InputOptions
---@param on_confirm fun(text?: string)
local function input(opts, on_confirm)
  opts = opts or {}

  local prompt = opts.prompt or 'Input'
  local prompt_lines = vim.split(prompt, '\n')
  local default = opts.default or ''

  local parent_win = api.nvim_get_current_win()

  --- @type vim.api.keyset.win_config
  local winopts = {
    relative = 'cursor',
    anchor = 'SW',
    border = 'rounded',
    height = 1,
    style = 'minimal',
    noautocmd = true,
    width = calc_width(parent_win, prompt_lines, default),
    col = 0,
    row = 0,
  }

  if #prompt_lines > 1 then
    -- If we're going to add a multiline prompt window, adjust the positioning down to make room
    winopts.row = winopts.row + #prompt_lines
  else
    winopts.title = (' %s '):format(prompt_lines[1])
    winopts.title_pos = 'left'
  end

  -- If the floating win was already open
  local bufnr = api.nvim_create_buf(false, true)
  local winid = api.nvim_open_win(bufnr, true, winopts)
  local mode_to_restore = api.nvim_get_mode().mode

  if #prompt_lines > 1 then
    open_prompt_win(winid, prompt_lines, winopts)
  end

  set_win_opts(winid)

  -- Finish setting up the buffer
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].filetype = 'GizmosInput'
  vim.bo[bufnr].formatoptions = ''

  local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, nowait = true })
  end

  map({ 'n', 'i' }, '<CR>', function()
    local text = api.nvim_buf_get_lines(0, 0, 1, true)[1]
    close_win(winid, mode_to_restore)
    on_confirm(text)
  end)

  local function close()
    close_win(winid, mode_to_restore)
    on_confirm()
  end

  map('i', '<Esc>', close)
  map('i', '<C-c>', close)

  api.nvim_buf_set_lines(bufnr, 0, -1, true, { default })

  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    desc = 'Update highlights',
    buffer = bufnr,
    callback = function()
      remove_extra_lines(winid)
      apply_highlight(winid, opts.highlight)
    end,
  })

  api.nvim_create_autocmd('BufLeave', {
    desc = 'Cancel vim.ui.input',
    buffer = bufnr,
    nested = true,
    once = true,
    callback = close,
  })

  vim.cmd('startinsert!')

  apply_highlight(winid, opts.highlight)
end

api.nvim_create_autocmd('FileType', {
  pattern = 'GizmosInput',
  callback = function(args)
    -- Configure nvim-cmp if installed
    local has_cmp, cmp = pcall(require, 'cmp')
    if has_cmp then
      cmp.setup.buffer({ enabled = false })
    end

    local function map(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, nowait = true })
    end
    map('i', '<C-a>', '<Home>')
    map('i', '<C-e>', '<End>')
    map('i', '<C-d>', '<Del>')
  end,
})

return input
