local api = vim.api

local function title(bufnr)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype

  if buftype == 'help' then
    return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
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
    return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
  elseif file == '' then
    return '[No Name]'
  else
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
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

local function devicon(bufnr, is_main)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype
  local devicons = require'nvim-web-devicons'

  local icon, devhl
  if filetype == 'TelescopePrompt' then
    icon, devhl = devicons.get_icon('telescope')
  elseif filetype == 'fugitive' then
    icon, devhl = devicons.get_icon('git')
  elseif filetype == 'vimwiki' then
    icon, devhl = devicons.get_icon('markdown')
  elseif buftype == 'terminal' then
    icon, devhl = devicons.get_icon('zsh')
  else
    ---@diagnostic disable-next-line:missing-parameter
    icon, devhl = devicons.get_icon(file, vim.fn.expand('#'..bufnr..':e'))
  end

  if icon then
    local hl_start = ''
    local hl_end = ''

    if is_main then
      local hl = 'TabLineDev'..devhl
      vim.api.nvim_set_hl(0, hl, {
        fg = api.nvim_get_hl_by_name(devhl, true).foreground,
        bg = api.nvim_get_hl_by_name('TabLineSel', true).background
      })

      hl_start = '%#'..hl..'#'
      hl_end = '%#TabLineSel#'
    end

    return string.format('%s%s%s ', hl_start, icon, hl_end)
  end
  return ''
end

local function separator(index)
  return index < vim.fn.tabpagenr('$') and '%#TabLine#' or ''
end

local function cell(index)
  local isSelected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]

  local bufnrs = vim.tbl_filter(function(b)
    if vim.bo[b].buftype == 'nofile' then
      return false
    end
    return true
  end, buflist)

  return
    table.concat(vim.tbl_map(function(b)
      local hl
      if isSelected then
        if b == bufnr then
          hl = 'TabLineSel'
        else
          hl = 'TabLine'
        end
      else
        hl = 'TabLineFill'
      end
      return
        '%#' .. hl .. '#%' .. index .. 'T' .. ' ' ..
        devicon(b, isSelected and b == bufnr) .. title(b) .. flags(b)..' '
    end, bufnrs), ' ') .. '%T' ..
    separator(index)
end

local M = {}

M.tabline = function()
  local line = ''
  for i = 1, vim.fn.tabpagenr('$'), 1 do
    line = line .. cell(i)
  end
  line = line .. '%#TabLineFill#%='
  return line
end

vim.opt.tabline = '%!v:lua.require\'lewis6991.tabline\'.tabline()'

return M
