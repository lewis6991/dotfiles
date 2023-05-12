local M = {}

local api = vim.api

local function highlight(num, active)
  if active == 1 then
    if num == 1 then
      return '%#PmenuSel#'
    end
    return '%#StatusLine#'
  end
  return '%#StatusLineNC#'
end

local DIAG_ATTRS = {
  { 'Error', '', 'DiagnosticErrorStatus' },
  { 'Warn', '', 'DiagnosticWarnStatus' },
  { 'Hint', '', 'DiagnosticHintStatus' },
  { 'Info', 'I', 'DiagnosticInfoStatus' },
}

local function hldefs()
  local bg = api.nvim_get_hl_by_name('StatusLine', true).background
  for _, attrs in ipairs(DIAG_ATTRS) do
    local hl = api.nvim_get_hl_by_name('Diagnostic'..attrs[1], true)
    api.nvim_set_hl(0, attrs[3], { fg = hl.foreground, bg = bg})
  end

  local dhl = api.nvim_get_hl_by_name('Debug', true)
  api.nvim_set_hl(0, 'LspName', { fg = dhl.foreground, bg = bg})
end

local function hl(name, active)
  if active == 0 then
    return ''
  end
  return '%#'..name..'#'
end

function M.lsp_status(active)
  local status = {} ---@type string[]

  for _, attrs in ipairs(DIAG_ATTRS) do
    local n = vim.diagnostic.get(0, {severity=attrs[1]})
    if #n > 0 then
      table.insert(status, ('%s %s %d'):format(
        hl(attrs[3], active),
        attrs[2],
        #n
      ))
    end
  end

  if vim.g.metals_status then
    status[#status+1] = vim.g.metals_status:gsub('%%', '%%%%')
  end

  local names = {} ---@type string[]
  local attached = vim.lsp.get_active_clients({bufnr=0})
  for _, c in ipairs(attached) do
    names[#names+1] = c.name
  end

  local name = ''
  if #names > 0 then
    name = hl('LspName', active)..table.concat(names, ',')
  end

  return name ..' '.. table.concat(status, ' ')
end

function M.hunks()
  if vim.b.gitsigns_status then
    local status = vim.b.gitsigns_head
    if vim.b.gitsigns_status ~= '' then
      status = status ..' '..vim.b.gitsigns_status
    end
    return status
  end

  if vim.g.gitsigns_head then
    return vim.g.gitsigns_head
  end

  return ''
end

local function filetype_symbol()
  local res = vim.F.npcall(vim.fn.WebDevIconsGetFileTypeSymbol)
  if res then
    return res
  end
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if ok then
    local name = api.nvim_buf_get_name(0)
    return devicons.get_icon(name, vim.bo.filetype, {default = true})
  end
  return ''
end

local function is_treesitter()
  local bufnr = api.nvim_get_current_buf()
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end

function M.filetype()
  return table.concat({
    vim.bo.filetype,
    filetype_symbol(),
    -- Causes artifacts in ruler section
    -- is_treesitter() and '🌴' or nil
    is_treesitter() and '' or nil
  } , ' ')
end

function M.encodingAndFormat()
  local e = vim.bo.fileencoding and vim.bo.fileencoding or vim.o.encoding

  local r = {} ---@type string[]
  if e ~= 'utf-8' then
    r[#r+1] = e
  end

  local f = vim.bo.fileformat
  if f ~= 'unix' then
    r[#r+1] = '['..f..']'
    local ok, res = pcall(api.nvim_call_function, 'WebDevIconsGetFileFormatSymbol')
    if ok then
      r[#r+1] = res
    end
  end

  return table.concat(r, ' ')
end

local function recording()
  local reg = vim.fn.reg_recording()
  if reg ~= '' then
    return '%#ModeMsg#  RECORDING['..reg..']  '
  else
    return ''
  end
end

function M.bufname()
  local name = vim.api.nvim_eval_statusline('%f', {}).str
  local buf_name = vim.api.nvim_buf_get_name(0)
  if vim.startswith(buf_name, 'fugitive://') then
    local _, _, commit, relpath = buf_name:find([[^fugitive://.*/%.git.*/(%x-)/(.*)]])
    name = relpath..'@'..commit:sub(1, 7)
  end
  if vim.startswith(buf_name, 'gitsigns://') then
    local _, _, revision, relpath = buf_name:find([[^gitsigns://.*/%.git.*/(.*):(.*)]])
    name = relpath..'@'..revision:sub(1, 7)
  end

  return name
end

local function pad(x)
  return '%( '..x..' %)'
end

local F = setmetatable({}, {
  __index = function(_, name)
    return function(active, mods)
      active = active or 1
      mods = mods or ''
      return '%'..mods..'{%v:lua.statusline.'..name..'('..tostring(active)..')%}'
    end
  end
})

---@param sections string[][]
local function parse_sections(sections)
  local result = {} ---@type string[]
  for _, s in ipairs(sections) do
    local sub_result = {} ---@type string[]
    for _, part in ipairs(s) do
      sub_result[#sub_result+1] = part
    end
    result[#result+1] = table.concat(sub_result)
  end
  -- Leading '%=' reeded for first highlight to work
  return '%=' .. table.concat(result, '%=')
end

local function set(active, global)
  local scope = global and 'o' or 'wo'
  vim[scope].statusline = parse_sections{
    {
      highlight(1, active),
      recording(),
      pad(F.hunks()),
      highlight(2, active),
      pad(F.lsp_status(active)),
      highlight(2, active),
    },
    {
      '%<',
      pad(F.bufname(nil, '0.60')..'%m%r%h%q'),
    },
    {
      pad(F.filetype()),
      pad(F.encodingAndFormat()),
      highlight(1, active),
      ' %3p%% %2l(%02c)/%-3L ', -- 80% 65[12]/120
    }
  }
end

-- Only set up WinEnter autocmd when the WinLeave autocmd runs
local group = api.nvim_create_augroup('statusline', {})
api.nvim_create_autocmd({'WinLeave', 'FocusLost'}, {
  group = group,
  callback = function()
    api.nvim_create_autocmd({'BufWinEnter', 'WinEnter', 'FocusGained'}, {
      group = group,
      callback = function()
        set(1)
      end
    })
    set(0)
  end
})

api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    set(1, true)
  end
})

api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = hldefs
})

_G.statusline = M

return M
