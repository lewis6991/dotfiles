require 'lewis6991.status'
require 'lewis6991.floating_man'

local o, api = vim.opt, vim.api

local add_command = api.nvim_add_user_command

local function autocmd(name)
  return function(opts)
    vim.api.nvim_create_autocmd(name, opts)
  end
end

local function map(mode)
  return function(first)
    return function(second)
      local opts
      if type(second) == 'table' then
        opts = second
        second = opts[1]
        opts[1] = nil
      end
      vim.keymap.set(mode, first, second, opts)
    end
  end
end

local function nmap(first) return map 'n' (first) end
local function vmap(first) return map 'v' (first) end
local function cmap(first) return map 'c' (first) end

local M = {}

if 'Plugins' then
  -- Load any plugins which are work sensitive.
  for _, f in ipairs(vim.fn.globpath('~/gerrit/', '*', false, true)) do
    o.rtp:prepend(f)
  end

  -- Stop loading built in plugins
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_gzip = 1


  api.nvim_create_augroup('vimrc', {})

  -- Plugins are 'start' plugins so are loaded automatically, but to enable packer
  -- commands we need to require plugins at some point
  autocmd 'CursorHold'  {
    callback = function()
      require'lewis6991.plugins'
    end,
    once = true,
    desc = 'Load Packer'
  }
end

if 'Options' then
  o.backup         = true
  o.backupdir:remove('.')
  o.breakindent    = true -- Indent wrapped lines to match start
  o.clipboard      = 'unnamedplus'
  o.expandtab      = true
  o.fillchars      = 'eob: ' -- Remove tilda from signcolumn
  o.hidden         = true
  o.ignorecase     = true
  o.inccommand     = 'split'
  o.number         = true
  o.previewheight  = 30
  o.pumblend       = 10
  o.relativenumber = true
  o.scrolloff      = 6
  o.shiftwidth     = 4
  o.sidescroll     = 6
  o.sidescrolloff  = 6
  o.signcolumn     = 'auto:3'
  o.smartcase      = true
  o.softtabstop    = 4
  o.startofline    = false
  o.swapfile       = false
  o.tabstop        = 4
  o.termguicolors  = true
  o.textwidth      = 80
  o.updatetime     = 200
  o.virtualedit    = 'block' -- allow cursor to exist where there is no character
  o.winblend       = 10
  o.wrap           = false
  o.lazyredraw     = true

  -- Avoid showing message extra message when using completion
  o.shortmess:append('c')
  -- o.shortmess:append('I')
  -- o.shortmess:remove('F')
  o.completeopt:append{'noinsert','menuone','noselect','preview'}
  -- o.completeopt = 'noinsert,menuone,noselect,preview'
  o.showbreak   = '↳ '
  -- o.showbreak   = '    ↳ '
  o.mouse       = 'a'

  o.diffopt:append('vertical')  -- Show diffs in vertical splits
  o.diffopt:append('foldcolumn:0')  -- Show diffs in vertical splits
  o.diffopt:append('indent-heuristic')

  o.undolevels = 10000
  o.undofile   = true
  o.splitright = true
  o.splitbelow = true
  o.spell      = true

  local xdg_cfg = os.getenv('XDG_CONFIG_HOME')
  if xdg_cfg then
    o.spellfile = xdg_cfg..'/nvim/spell/en.utf-8.add'
  end

  o.formatoptions:append('r') -- Automatically insert comment leader after <Enter> in Insert mode.
  o.formatoptions:append('o') -- Automatically insert comment leader after 'o' or 'O' in Normal mode.
  o.formatoptions:append('l') -- Long lines are not broken in insert mode.
  o.formatoptions:remove('t') -- Do not auto wrap text
  o.formatoptions:append('n') -- Recognise lists
end

if 'ftplugin' then
  vim.g.vimsyn_folding  = 'af' --Fold augroups and functions
  vim.g.vim_indent_cont = vim.opt.shiftwidth:get()
  vim.g.xml_syntax_folding = 1
  vim.g.man_hardwrap = 1
  vim.g.yaml_recommended_style = 0
end

if 'Folding' then
  vim.g.sh_fold_enabled = 1

  o.foldmethod='syntax'
  o.foldcolumn='0'
  o.foldnestmax=3
  o.foldopen:append('jump')
  -- o.foldminlines=10
end

if 'Whitespace' then
  o.list = true
  o.listchars = 'tab:▸ ' -- Show tabs as '▸   ▸   '

  -- Highlight trailing whitespace
  autocmd 'BufEnter' {
    group = 'vimrc',
    callback = vim.schedule_wrap(function()
      if vim.bo.buftype == "" then
        vim.fn.matchadd('ColorColumn', '\\s\\+$')
      end
    end)
  }
end

if "Mappings" then
  nmap '<leader>ev' ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/init.lua<CR>'
  nmap '<leader>eV' ':edit $XDG_CONFIG_HOME/nvim/init.lua<CR>'
  nmap '<leader>el' ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua<CR>'
  nmap '<leader>s'  ':%s/\\<<C-R><C-W>\\>\\C//g<left><left>'
  nmap '<leader>c'  '1z='
  nmap '<leader>w'  ':execute "resize ".line("$")<cr>'

  nmap 'k' {[[v:count == 0 ? 'gk' : 'k']], expr=true}
  nmap 'j' {[[v:count == 0 ? 'gj' : 'j']], expr=true}

  nmap 'Y' 'y$'

  nmap 'Q'  ':w<cr>'
  vmap 'Q'  '<nop>'
  nmap 'gQ' '<nop>'
  vmap 'gQ' '<nop>'

  -- delete the current buffer without deleting the window
  nmap '<leader>b' ':b#|bd#<CR>'

  -- I never use macros and more often mis-hit this key
  nmap 'q' '<nop>'

  -- Show syntax highlighting groups for word under cursor
  local function syn_stack()
    local c = api.nvim_win_get_cursor(0)
    local stack = vim.fn.synstack(c[1], c[2]+1)
    for i, l in ipairs(stack) do
      stack[i] = vim.fn.synIDattr(l, 'name')
    end
    print(vim.inspect(stack))
  end
  nmap '<leader>z' (syn_stack)

  nmap '<C-C>' ':nohlsearch<CR>'

  -- map('n', '<Tab>'  , ':bnext<CR>', {})
  -- map('n', '<S-Tab>', ':bprev<CR>', {})
  nmap '<Tab>'   {':tabnext<CR>', silent=true}
  nmap '<S-Tab>' {':tabprev<CR>', silent=true}

  nmap '|' {[[!v:count ? "<C-W>v<C-W><Right>" : '|']], expr=true, silent=true}
  nmap '_' {[[!v:count ? "<C-W>s<C-W><Down>"  : '_']], expr=true, silent=true}

  cmap '<C-P>' '<up>'
  cmap '<C-N>' '<down>'
  cmap '<C-A>' '<Home>'
  cmap '<C-D>' '<Del>'

  nmap ']d' (vim.diagnostic.goto_next)
  nmap '[d' (vim.diagnostic.goto_prev)
  nmap 'go' (vim.diagnostic.open_float)
end

add_command('Hashbang', function()
  local shells = {
    sh    = {'#! /usr/bin/env bash'},
    py    = {'#! /usr/bin/env python3'},
    scala = {'#! /usr/bin/env scala'},
    tcl   = {'#! /usr/bin/env tclsh'},
    lua = {
        '#! /bin/sh',
        '_=[[',
        'exec lua "$0" "$@"',
        ']]'
      }
  }

  local extension = vim.fn.expand('%:e')

  if shells[extension] then
    local hb = shells[extension]
    hb[#hb+1] = ''

    api.nvim_buf_set_lines(0, 0, 0, false, hb)
    autocmd 'BufWritePost' {
      buffer = 0,
      once = true,
      command = 'silent !chmod u+x %'
    }
  end
end, {force = true})

add_command('L', "lua vim.pretty_print(<args>)", {nargs = 1, complete = 'lua', force = true})

autocmd 'VimResized' {group='vimrc', command='wincmd ='}

vim.cmd[[
  iabbrev :rev: <c-r>=printf(&commentstring, ' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>
  iabbrev :todo: <c-r>=printf(&commentstring, ' TODO(lewis6991):')<CR>

  iabbrev funciton function
]]


if "Diagnostics" then
  local orig_signs_handler = vim.diagnostic.handlers.signs

  -- Override the built-in signs handler to aggregate signs
  vim.diagnostic.handlers.signs = {
    show = function(ns, bufnr, _, opts)
      local diagnostics = vim.diagnostic.get(bufnr)

      -- Find the "worst" diagnostic per line
      local max_severity_per_line = {}
      for _, d in pairs(diagnostics) do
        local m = max_severity_per_line[d.lnum]
        if not m or d.severity < m.severity then
          max_severity_per_line[d.lnum] = d
        end
      end

      -- Pass the filtered diagnostics (with our custom namespace) to
      -- the original handler
      local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
      orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,

    hide = orig_signs_handler.hide
  }
end

if 'Tabline' then
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

  local function modified(bufnr)
    return vim.bo[bufnr].modified and '[+] ' or ''
  end

  -- local function windowCount(index)
  --   local nwins = 0
  --   local success, wins = pcall(vim.api.nvim_tabpage_list_wins, index)
  --   if success then
  --     for _ in pairs(wins) do nwins = nwins + 1 end
  --   end
  --   return nwins > 1 and '(' .. nwins .. ') ' or ''
  -- end

  local function devicon(bufnr, is_selected)
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
      icon, devhl = devicons.get_icon(file, vim.fn.expand('#'..bufnr..':e'))
    end

    if icon then
      local hl_start = ''
      local hl_end = ''

      if is_selected then
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
    local hl = isSelected and '%#TabLineSel#' or '%#TabLine#'

    return hl .. '%' .. index .. 'T' .. ' ' ..
      -- windowCount(index) ..
      title(bufnr) .. ' ' ..
      modified(bufnr) ..
      devicon(bufnr, isSelected) .. '%T' ..
      separator(index)
  end

  M.tabline = function()
    local line = ''
    for i = 1, vim.fn.tabpagenr('$'), 1 do
      line = line .. cell(i)
    end
    line = line .. '%#TabLineFill#%='
    return line
  end

  vim.opt.tabline = '%!v:lua.require\'lewis6991\'.tabline()'
end

return M

-- vim: foldminlines=0:
