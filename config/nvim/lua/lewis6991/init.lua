require 'lewis6991.status'
require 'lewis6991.tabline'
require 'lewis6991.diagnostic'
require 'lewis6991.jump'
require 'lewis6991.clipboard'
require 'lewis6991.plugins'

local nvim = require 'lewis6991.nvim'

local o, api, lsp = vim.opt, vim.api, vim.lsp

local add_command = api.nvim_create_user_command

local autocmd = nvim.autocmd
local nmap = nvim.nmap
local vmap = nvim.vmap
local cmap = nvim.cmap

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
end

if 'Options' then
  o.backup         = true
  o.backupdir:remove('.')
  o.breakindent    = true -- Indent wrapped lines to match start
  o.clipboard      = 'unnamedplus'
  o.expandtab      = true
  o.fillchars      = {eob=' ', diff = ' '}
  o.hidden         = true
  o.ignorecase     = true
  o.inccommand     = 'split'
  o.number         = true
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
  o.virtualedit    = 'block' -- allow cursor to exist where there is no character
  o.winblend       = 10
  o.wrap           = false
  -- o.lazyredraw     = true

  -- Avoid showing message extra message when using completion
  o.shortmess:append('c')
  o.completeopt:append{
    'noinsert',
    'menuone',
    'noselect',
    'preview'
  }

  o.showbreak   = '↳ '
  -- o.showbreak   = '    ↳ '
  o.mouse       = 'a'

  o.diffopt:append{
    'linematch:50',
    'vertical',
    'foldcolumn:0',
    'indent-heuristic',
  }

  o.undolevels = 10000
  o.undofile   = true
  o.splitright = true
  o.splitbelow = true
  o.spell      = true

  local xdg_cfg = os.getenv('XDG_CONFIG_HOME')
  if xdg_cfg then
    o.spellfile = xdg_cfg..'/nvim/spell/en.utf-8.add'
  end

  o.formatoptions:append{
    r = true, -- Automatically insert comment leader after <Enter> in Insert mode.
    o = true, -- Automatically insert comment leader after 'o' or 'O' in Normal mode.
    l = true, -- Long lines are not broken in insert mode.
    t = true, -- Do not auto wrap text
    n = true, -- Recognise lists
  }
end

if 'Folding' then
  vim.g.sh_fold_enabled = 1

  o.foldmethod  = 'syntax'
  o.foldcolumn  = '0'
  o.foldnestmax = 3
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

  nmap '<C-S-O>' '<C-i>'

  nmap '|' {[[!v:count ? "<C-W>v<C-W><Right>" : '|']], expr=true, silent=true}
  nmap '_' {[[!v:count ? "<C-W>s<C-W><Down>"  : '_']], expr=true, silent=true}

  cmap '<C-P>' '<up>'
  cmap '<C-N>' '<down>'
  cmap '<C-A>' '<Home>'
  cmap '<C-D>' '<Del>'

  nmap ']d' (vim.diagnostic.goto_next)
  nmap '[d' (vim.diagnostic.goto_prev)
  nmap 'go' (vim.diagnostic.open_float)

  autocmd 'LspAttach' {
    desc = 'lsp mappings',
    function(args)
      local bufnr = args.buf
      nmap '<C-]>'      {lsp.buf.definition, desc = 'lsp.buf.definition', buffer = bufnr  }
      nmap '<leader>cl' {lsp.codelens.run  , desc = 'lsp.codelens.run'  , buffer = bufnr    }
      -- map(bufnr, 'K'         , lsp.buf.hover         , 'lsp.buf.hover'         )
      -- map(bufnr, 'gK'        , lsp.buf.signature_help, 'lsp.buf.signature_help')
      nmap '<C-s>'      { lsp.buf.signature_help, desc = 'lsp.buf.signature_help', buffer = bufnr}
      nmap '<leader>rn' { lsp.buf.rename        , desc = 'lsp.buf.rename'        , buffer = bufnr}
      nmap '<leader>ca' { lsp.buf.code_action   , desc = 'lsp.buf.code_action'   , buffer = bufnr}

      -- nmap 'gr' { lsp.buf.references }
      nmap 'gr' '<cmd>Trouble lsp_references<cr>'
      nmap 'gR' '<cmd>Telescope lsp_references layout_strategy=vertical<cr>'

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.server_capabilities.code_lens then
        autocmd {'BufEnter', 'CursorHold', 'InsertLeave'} {
          lsp.codelens.refresh,
          buffer = args.buf,
        }
        lsp.codelens.refresh()
      end
    end
  }
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

-- add_command('L', "lua vim.pretty_print(<args>)", {nargs = 1, complete = 'lua', force = true})
vim.cmd.cabbrev('L', 'lua=')

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
    if not vim.bo.modified and api.nvim_buf_get_name(0) == '' then
      api.nvim_buf_delete(0, {})
    end
  end,
  once = true,
  group = 'vimrc'
}

function print(...)
  for _, x in ipairs{...} do
    api.nvim_out_write(vim.inspect(x, {newline=' ', indent=''}))
  end
  api.nvim_out_write('\n')
end

return M

-- vim: foldminlines=0:
