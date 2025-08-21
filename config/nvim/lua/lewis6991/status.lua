--- @class lewis6991.statusline
local M = {}

local api = vim.api

--- @param name string
--- @return table<string,any>
local function get_hl(name)
  return api.nvim_get_hl(0, { name = name })
end

--- @param num integer
--- @param active 0|1
--- @return string
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
  { 'Info', 'I', 'DiagnosticInfoStatus' },
  { 'Hint', '', 'DiagnosticHintStatus' },
}

local function hldefs()
  local bg = get_hl('StatusLine').bg
  for _, attrs in ipairs(DIAG_ATTRS) do
    local fg = get_hl('Diagnostic' .. attrs[1]).fg
    api.nvim_set_hl(0, attrs[3], { fg = fg, bg = bg })
  end

  local dhl = get_hl('Debug')
  api.nvim_set_hl(0, 'LspName', { fg = dhl.fg, bg = bg })

  local fg = get_hl('MoreMsg').fg
  api.nvim_set_hl(0, 'StatusTS', { fg = fg, bg = bg })
end

--- @param name string
--- @param active 0|1
--- @return string
local function hl(name, active)
  if active == 0 then
    return ''
  end
  return '%#' .. name .. '#'
end

--- @param active 0|1
--- @return string
local function lsp_name(active)
  local names = {} ---@type string[]
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = client.name
  end

  if #names == 0 then
    return ''
  end

  return hl('LspName', active) .. table.concat(names, ',')
end

--- @param active 0|1
--- @return string?
local function diagnostics(active)
  local status = {} ---@type string[]
  local diags = vim.diagnostic.count(0)
  for i, attrs in ipairs(DIAG_ATTRS) do
    local n = diags[i] or 0
    if n > 0 then
      table.insert(status, (' %s%s %d'):format(hl(attrs[3], active), attrs[2], n))
    end
  end

  if #status == 0 then
    return
  end

  return table.concat(status, ' ')
end

--- @param active 0|1
--- @return string
function M.lsp_status(active)
  local status = {} ---@type string[]

  status[#status + 1] = lsp_name(active)
  status[#status + 1] = diagnostics(active)

  if vim.g.metals_status then
    status[#status + 1] = vim.g.metals_status:gsub('%%', '%%%%')
  end

  return table.concat(status, ' ')
end

--- @param active 0|1
--- @return string
function M.dap_status(active)
  local ok, dap = pcall(require, 'dap')
  if not ok or not dap.session() then
    return ''
  end

  return hl('Debug', active) .. dap.status()
end

function M.hunks()
  if vim.b.gitsigns_status then
    local status = vim.b.gitsigns_head
    if vim.b.gitsigns_status ~= '' then
      status = status .. ' ' .. vim.b.gitsigns_status
    end
    return status
  end

  if vim.g.gitsigns_head then
    return vim.g.gitsigns_head
  end

  return ''
end

--- @param active 0|1
--- @return string
local function filetype_symbol(active)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    return ''
  end

  local name = api.nvim_buf_get_name(0)
  --- @type string, string
  local icon, iconhl = devicons.get_icon_color(name, vim.bo.filetype, { default = true })

  local hlname = iconhl:gsub('#', 'Status')
  api.nvim_set_hl(0, hlname, { fg = iconhl, bg = get_hl('StatusLine').bg })

  return hl(hlname, active) .. icon
end

local function is_treesitter()
  local bufnr = api.nvim_get_current_buf()
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end

--- @param active 0|1
--- @return string
function M.filetype(active)
  local r = {
    vim.bo.filetype,
    filetype_symbol(active),
  }

  if is_treesitter() then
    r[#r + 1] = hl('StatusTS', active) .. ''
  end

  return table.concat(r, ' ')
end

function M.encodingAndFormat()
  local e = vim.bo.fileencoding and vim.bo.fileencoding or vim.o.encoding

  local r = {} ---@type string[]
  if e ~= 'utf-8' then
    r[#r + 1] = e
  end

  local f = vim.bo.fileformat
  if f ~= 'unix' then
    r[#r + 1] = '[' .. f .. ']'
  end

  return table.concat(r, ' ')
end

local function recording()
  local reg = vim.fn.reg_recording()
  if reg ~= '' then
    return '%#ModeMsg#  RECORDING[' .. reg .. ']  '
  end
  return ''
end

--- @return string
function M.bufname()
  local buf_name = api.nvim_buf_get_name(0)
  if vim.startswith(buf_name, 'fugitive://') then
    local _, _, revision, relpath = buf_name:find([[^fugitive://.*/%.git.*/(%x-)/(.*)]])
    if revision then
      return relpath .. '@' .. revision:sub(1, 8)
    end
  elseif vim.startswith(buf_name, 'gitsigns://') then
    local _, _, revision, relpath = buf_name:find([[^gitsigns://.*/%.git.*/(.*)[:/](.*)]])
    if revision then
      return relpath .. '@' .. (tonumber(revision, 16) and revision:sub(1, 8) or revision)
    end
  end

  return api.nvim_eval_statusline('%f', {}).str
end

--- @param x string
--- @return string
local function pad(x)
  return '%( ' .. x .. ' %)'
end

--- @type lewis6991.statusline
local F = setmetatable({}, {
  __index = function(t, name)
    t[name] = function(active, mods)
      active = active or 1
      mods = mods or ''
      return '%' .. mods .. '{%v:lua.statusline.' .. name .. '(' .. tostring(active) .. ')%}'
    end
    return t[name]
  end,
})

--- @param sections string[][]
--- @return string
local function parse_sections(sections)
  local result = {} ---@type string[]
  for _, s in ipairs(sections) do
    local sub_result = {} ---@type string[]
    for _, part in ipairs(s) do
      sub_result[#sub_result + 1] = part
    end
    result[#result + 1] = table.concat(sub_result)
  end
  return table.concat(result, '%=')
end

--- @param active 0|1
--- @param global? boolean
local function set(active, global)
  local scope = global and 'o' or 'wo'
  vim[scope].statusline = parse_sections({
    {
      -- Unused leading highlight is to avoid neovim/neovim#32259
      highlight(1, active),
      highlight(1, active),
      recording(),
      pad(F.hunks()),
      highlight(2, active),
      pad(F.lsp_status(active)),
      pad(F.dap_status(active)),
      highlight(2, active),
    },
    {
      '%<',
      pad(F.bufname() .. '%m%r%h%q'),
    },
    {
      pad(F.filetype(active)),
      pad(F.encodingAndFormat()),
      highlight(1, active),
      ' %3p%% %2l(%02c)/%-3L ', -- 80% 65[12]/120
    },
  })
end

local group = api.nvim_create_augroup('statusline', {})

-- Only set up WinEnter autocmd when the WinLeave autocmd runs
api.nvim_create_autocmd({ 'WinLeave', 'FocusLost' }, {
  group = group,
  once = true,
  callback = function()
    api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'FocusGained' }, {
      group = group,
      callback = function()
        set(1)
      end,
    })
  end,
})

api.nvim_create_autocmd({ 'WinLeave', 'FocusLost' }, {
  group = group,
  callback = function()
    set(0)
  end,
})

api.nvim_create_autocmd('VimEnter', {
  group = group,
  callback = function()
    set(1, true)
  end,
})

api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = hldefs,
})

hldefs()

local redrawstatus = vim.schedule_wrap(function()
  vim.cmd.redrawstatus()
  -- api.nvim__redraw({ statusline = true })
end)

api.nvim_create_autocmd('User', {
  pattern = 'GitSignsUpdate',
  group = group,
  callback = redrawstatus,
})

api.nvim_create_autocmd('DiagnosticChanged', {
  group = group,
  callback = redrawstatus,
})

api.nvim_create_autocmd('User', {
  pattern = 'DapProgressUpdate',
  group = group,
  callback = redrawstatus,
})

_G.statusline = M

return M
