require 'lewis6991.status'
require 'lewis6991.floating_man'

local o, api = vim.opt, vim.api

local add_command = api.nvim_add_user_command
local autocmd = api.nvim_create_autocmd
local map = vim.keymap.set

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
  autocmd('CursorHold', {
    callback = function()
      require'lewis6991.plugins'
    end,
    once = true,
    desc = 'Load Packer'
  })
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
  autocmd('BufEnter', {
    group = 'vimrc',
    callback = function()
      if vim.bo.buftype == "" then
        vim.fn.matchadd('ColorColumn', '\\s\\+$')
      end
    end,
  })
end

if "Mappings" then
  map('n', '<leader>ev', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/init.lua<CR>'   )
  map('n', '<leader>eV', ':edit $XDG_CONFIG_HOME/nvim/init.lua<CR>'                 )
  map('n', '<leader>el', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua<CR>')
  map('n', '<leader>s' , ':%s/\\<<C-R><C-W>\\>\\C//g<left><left>'                   )
  map('n', '<leader>c' , '1z='                                                      )
  map('n', '<leader>w' , ':execute "resize ".line("$")<cr>'                         )

  map('n', 'k', [[v:count == 0 ? 'gk' : 'k']], {expr=true})
  map('n', 'j', [[v:count == 0 ? 'gj' : 'j']], {expr=true})

  map('n', 'Y', 'y$')

  map('n', 'Q' , ':w<cr>')
  map('v', 'Q' , '<nop>' )
  map('n', 'gQ', '<nop>' )
  map('v', 'gQ', '<nop>' )

  -- delete the current buffer without deleting the window
  map('n', '<leader>b', ':b#|bd#<CR>')

  -- I never use macros and more often mis-hit this key
  map('n', 'q', '<nop>')

  -- Show syntax highlighting groups for word under cursor
  local function syn_stack()
    local c = api.nvim_win_get_cursor(0)
    local stack = vim.fn.synstack(c[1], c[2]+1)
    for i, l in ipairs(stack) do
      stack[i] = vim.fn.synIDattr(l, 'name')
    end
    print(vim.inspect(stack))
  end
  map('n', '<leader>z', syn_stack)

  map('n', '<C-C>', ':nohlsearch<CR>')

  -- Use barbar mappings instead
  -- map('n', '<Tab>'  , ':bnext<CR>', {})
  -- map('n', '<S-Tab>', ':bprev<CR>', {})

  map('n', '|', [[!v:count ? "<C-W>v<C-W><Right>" : '|']], {expr=true, silent=true})
  map('n', '_', [[!v:count ? "<C-W>s<C-W><Down>"  : '_']], {expr=true, silent=true})

  map('c', '<C-P>', '<up>'  )
  map('c', '<C-N>', '<down>')
  map('c', '<C-A>', '<Home>')
  map('c', '<C-D>', '<Del>' )

  map('n', ']d', vim.diagnostic.goto_next)
  map('n', '[d', vim.diagnostic.goto_prev)
  map('n', 'go', vim.diagnostic.open_float)
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
    autocmd('BufWritePost', {
      buffer = 0,
      once = true,
      command = 'silent !chmod u+x %'
    })
  end
end, {force = true})

add_command('L', "lua vim.pretty_print(<args>)", {nargs = 1, complete = 'lua', force = true})

autocmd('VimResized', {group='vimrc', command='wincmd ='})

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

return M

-- vim: foldminlines=0:
