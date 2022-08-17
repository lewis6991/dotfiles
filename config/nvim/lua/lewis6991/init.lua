require 'lewis6991.status'
require 'lewis6991.tabline'
require 'lewis6991.diagnostic'
require 'lewis6991.jump'
require 'lewis6991.clipboard'

local o, api = vim.opt, vim.api

local add_command = api.nvim_create_user_command

local function autocmd(name)
  return function(opts)
    if opts[1] then
      if type(opts[1]) == 'function' then
        opts.callback = opts[1]
      elseif type(opts[1]) == 'string' then
        opts.command = opts[1]
      end
      opts[1] = nil
    end
    api.nvim_create_autocmd(name, opts)
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
  autocmd 'CursorHold' {
    function()
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
  -- o.cmdheight      = 0
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
  -- setup in VimEnter to stop the intro screen being cleared
  autocmd 'VimEnter' {
    group = 'vimrc',
    function()
      autocmd 'BufEnter' {
        group = 'vimrc',
        vim.schedule_wrap(function()
          if vim.bo.buftype == "" then
            vim.fn.matchadd('ColorColumn', '\\s\\+$')
          end
        end)
      }
    end
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

  vmap 'gQ' {function()
    vim.lsp.buf.range_formatting()
  end}

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

  ---@diagnostic disable-next-line: missing-parameter
  local extension = vim.fn.expand('%:e')

  if shells[extension] then
    local hb = shells[extension]
    hb[#hb+1] = ''

    api.nvim_buf_set_lines(0, 0, 0, false, hb)
    autocmd 'BufWritePost' {
      'silent !chmod u+x %',
      buffer = 0,
      once = true,
    }
  end
end, {force = true})

add_command('L', "lua vim.pretty_print(<args>)", {nargs = 1, complete = 'lua', force = true})

autocmd 'VimResized' {'wincmd =', group='vimrc'}

vim.cmd.abbrev(':rev:', [[<c-r>=printf(&commentstring, ' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>]])
vim.cmd.abbrev(':todo:', [[<c-r>=printf(&commentstring, ' TODO(lewis6991):')<CR>]])
vim.cmd.abbrev('function', 'function')
vim.cmd.cabbrev('Q', 'q')

_G.printf = function(...)
  print(string.format(...))
end

autocmd 'TabNew' {
  function()
    if not vim.bo.modified and vim.api.nvim_buf_get_name(0) == '' then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
  once = true,
  group = 'vimrc'
}

return M

-- vim: foldminlines=0:
