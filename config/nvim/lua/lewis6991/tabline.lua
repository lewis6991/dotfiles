local api, fn = vim.api, vim.fn

local function title(bufnr)
  local file = fn.bufname(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype

  if buftype == 'help' then
    return 'help:' .. fn.fnamemodify(file, ':t:r')
  elseif buftype == 'quickfix' then
    return 'quickfix'
  elseif filetype == 'TelescopePrompt' then
    return 'Telescope'
  elseif filetype == 'git' then
    return 'Git'
  elseif filetype == 'fugitive' then
    return 'Fugitive'
  elseif buftype == 'terminal' then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    return mtch ~= nil and mtch or fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    return '[No Name]'
  else
    return fn.pathshorten(fn.fnamemodify(file, ':p:~:t'))
  end
end

local function flags(bufnr)
  local ret = {}
  if vim.bo[bufnr].modified then
    ret[#ret+1] = '[+]'
  end
  if not vim.bo[bufnr].modifiable then
    ret[#ret+1] = '[RO]'
  end
  return table.concat(ret)
end

local devhls = {}

local function devicon(bufnr, hl_base)
  local file = fn.bufname(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype
  local devicons = require'nvim-web-devicons'

  local icon, devhl
  if filetype == 'fugitive' then
    icon, devhl = devicons.get_icon('git')
  elseif filetype == 'vimwiki' then
    icon, devhl = devicons.get_icon('markdown')
  elseif buftype == 'terminal' then
    icon, devhl = devicons.get_icon('zsh')
  else
    ---@diagnostic disable-next-line:missing-parameter
    icon, devhl = devicons.get_icon(file, fn.expand('#'..bufnr..':e'))
  end

  if icon then
    local hl = hl_base..'Dev'..devhl
    if not devhls[hl] then
      devhls[hl] = true
      vim.api.nvim_set_hl(0, hl, {
        fg = api.nvim_get_hl_by_name(devhl, true).foreground,
        bg = api.nvim_get_hl_by_name(hl_base, true).background
      })
    end

    local hl_start = '%#'..hl..'#'
    local hl_end = '%#'..hl_base..'#'

    return string.format('%s%s%s ', hl_start, icon, hl_end)
  end
  return ''
end

local function separator(index)
  local selected = fn.tabpagenr()
  -- Don't add separator before or after selected
  if selected == index or selected - 1 == index then
    return ' '
  end
  return index < fn.tabpagenr('$') and '%#FloatBorder#│' or ''
end

local icons = {
  Error = '',
  Warn  = '',
  Hint  = '',
  Info  = 'I',
}

local function get_diags(buflist, hl_base)
  local diags = {}
  for _, ty in ipairs { 'Error', 'Warn', 'Info', 'Hint' } do
    local n = 0
    for _, bufnr in ipairs(buflist) do
      n = n + #vim.diagnostic.get(bufnr, {severity=ty})
    end
    if n > 0 then
      diags[#diags+1] = ('%%#Diagnostic%s%s#%s %s'):format(ty, hl_base, icons[ty], n)
    end
  end

  return table.concat(diags, ' ')
end

local function cell(index)
  local isSelected = fn.tabpagenr() == index
  local buflist = fn.tabpagebuflist(index)
  local winnr = fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]

  local bufnrs = vim.tbl_filter(function(b)
    return vim.bo[b].buftype ~= 'nofile'
  end, buflist)

  local hl = not isSelected and 'TabLineFill' or 'TabLineSel'
  local common = '%#' .. hl .. '#'
  local ret = string.format('%s%%%dT %s%s%s ',
    common,
    index,
    devicon(bufnr, hl),
    title(bufnr),
    flags(bufnr)
  )

  if #bufnrs > 1 then
    ret = string.format('%s%s(%d) ', ret, common, #bufnrs)
  end

  return ret .. get_diags(bufnrs, hl) .. '%T' .. separator(index)
end

local M = {}

M.tabline = function()
  local line = ''
  for i = 1, fn.tabpagenr('$'), 1 do
    line = line .. cell(i)
  end
  line = line .. '%#TabLineFill#%='
  return line
end

local function hldefs()
  for _, hl_base in ipairs{'TabLineSel', 'TabLineFill'} do
    local bg = api.nvim_get_hl_by_name(hl_base, true).background
    for _, ty in ipairs { 'Warn', 'Error', 'Info', 'Hint' } do
      local hl = api.nvim_get_hl_by_name('Diagnostic'..ty, true)
      local name = ('Diagnostic%s%s'):format(ty, hl_base)
      api.nvim_set_hl(0, name, { fg = hl.foreground, bg = bg})
    end
  end
end

local group = api.nvim_create_augroup('tabline', {})
api.nvim_create_autocmd('ColorScheme', {
  group = group,
  callback = hldefs
})

vim.opt.tabline = '%!v:lua.require\'lewis6991.tabline\'.tabline()'

return M
