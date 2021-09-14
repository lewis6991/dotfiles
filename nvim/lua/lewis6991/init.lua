require'lewis6991.status'

local o = vim.opt

local api = vim.api

if 'Plugins' then
  -- Load any plugins which are work sensitive.
  for _, f in ipairs(vim.fn.globpath('~/gerrit/', '*', false, true)) do
    o.rtp:prepend(f)
  end

  o.rtp:prepend('~/projects/dotfiles/modules/moonlight.vim')
  o.rtp:prepend('~/projects/tcl.vim')

  -- Stop loading built in plugins
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_gzip = 1

  -- Plugins are 'start' plugins so are loaded automatically, but to enable packer
  -- commands we need to require plugins at some point
  vim.cmd[[
  augroup vimrc
    autocmd CursorHold * ++once lua require'lewis6991.plugins'
  augroup END
  ]]
end

if 'Options' then
  o.backup         = true
  o.backupdir:remove('.')
  o.breakindent = true -- Indent wrapped lines to match start
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
  o.termguicolors = true
  o.textwidth      = 80
  o.updatetime     = 200
  o.virtualedit    = 'block' -- allow cursor to exist where there is no character
  o.winblend       = 10
  o.wrap           = false

  -- When this option is set, the screen will not be redrawn while executing
  -- macros, registers and other commands that have not been typed.  Also,
  -- updating the window title is postponed.  To force an
  o.lazyredraw = true

  -- o.shortmess:append('I')

  -- Only insert one space after a period when formatting.
  o.joinspaces = true

  -- Avoid showing message extra message when using completion
  o.shortmess:append('c')
  o.completeopt:append{'noinsert','menuone','noselect','preview'}
  -- o.completeopt = 'noinsert,menuone,noselect,preview'
  o.showbreak   = '    ↳ '
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
  o.foldminlines=10
end

if 'Theme' then
  vim.cmd[[silent! colorscheme moonlight]]
  vim.cmd'hi SpellBad guisp=#663333'
end

if 'Whitespace' then
  o.list = true
  o.listchars = 'tab:▸ ' -- Show tabs as '▸   ▸   '

  -- Highlight trailing whitespace
  vim.cmd[[autocmd vimrc BufEnter * call matchadd('ColorColumn', '\s\+$')]]
end

if "Mappings" then
  local map = api.nvim_set_keymap

  map('n', '<leader>ev', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/init.lua<CR>'   , {noremap=true})
  map('n', '<leader>eV', ':edit $XDG_CONFIG_HOME/nvim/init.vim<CR>'                 , {noremap=true})
  map('n', '<leader>el', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua<CR>', {noremap=true})
  map('n', '<leader>s' , ':%s/\\<<C-R><C-W>\\>\\C//g<left><left>'                   , {noremap=true})
  map('n', '<leader>c' , '1z='                                                      , {noremap=true})
  map('n', '<leader>w' , ':execute "resize ".line("$")<cr>'                         , {noremap=true})

  map('n', 'k', [[v:count == 0 ? 'gk' : 'k']], {noremap=true, expr=true})
  map('n', 'j', [[v:count == 0 ? 'gj' : 'j']], {noremap=true, expr=true})

  map('n', 'Y', 'y$', {noremap=true})

  map('n', 'Q' , ':w<cr>', {})
  map('v', 'Q' , '<nop>' , {})
  map('n', 'gQ', '<nop>' , {})
  map('v', 'gQ', '<nop>' , {})

  -- I never use macros and more often mis-hit this key
  map('n', 'q', '<nop>' , {noremap=true})

  -- Show syntax highlighting groups for word under cursor
  function Syn_stack()
    local c = api.nvim_win_get_cursor(0)
    local stack = vim.fn.synstack(c[1], c[2]+1)
    for i, l in ipairs(stack) do
      stack[i] = vim.fn.synIDattr(l, 'name')
    end
    print(vim.inspect(stack))
  end
  map('n', '<leader>z', ':lua Syn_stack()<CR>', {noremap=true})

  map('n', '<leader>:', ':lua<space>', {noremap=true})

  map('n', '<C-C>', ':nohlsearch<CR>', {noremap=true})

  -- Use barbar mappings instead
  -- map('n', '<Tab>'  , ':bnext<CR>', {})
  -- map('n', '<S-Tab>', ':bprev<CR>', {})

  map('n', '|', [[!v:count ? "<C-W>v<C-W><Right>" : '|']], {noremap=true, expr=true, silent=true})
  map('n', '_', [[!v:count ? "<C-W>s<C-W><Down>"  : '_']], {noremap=true, expr=true, silent=true})

  map('c', '<C-P>', '<up>'  , {noremap=true})
  map('c', '<C-N>', '<down>', {noremap=true})
  map('c', '<C-A>', '<Home>', {noremap=true})
  map('c', '<C-D>', '<Del>' , {noremap=true})
end

P = function(v)
  print(vim.inspect(v))
  return v
end

local M = {}

if 'Hashbang' then
  function M.hashbang()
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
      vim.cmd[[autocmd vimrc BufWritePost <buffer> silent !chmod u+x %]]
    end
  end

  vim.cmd[[command! Hashbang call v:lua.package.loaded.lewis6991.hashbang()]]
end

if "Floating Man" then
  local function createCenteredFloatingWindow()
    local width  = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local buf = api.nvim_create_buf(true, true)

    api.nvim_open_win(buf, true, {
      relative = 'editor',
      style    = 'minimal',
      border   = 'single',
      row      = ((vim.o.lines - height) / 2) - 1,
      col      = (vim.o.columns - width) / 2,
      width    = width,
      height   = height,
    })

    return buf
  end

  function M.floatingMan(id)
    local buf = createCenteredFloatingWindow()
    vim.api.nvim_buf_set_option(buf, 'filetype', 'man')

    vim.cmd('Man '..id)

    api.nvim_buf_set_keymap(buf, 'n', 'q'    , ':bwipeout!<cr>', {silent=true})
    api.nvim_buf_set_keymap(buf, 'n', '<esc>', ':bwipeout!<cr>', {silent=true})
    vim.cmd('autocmd BufLeave <buffer> :bwipeout!')
  end

  vim.cmd([[command! -nargs=* FloatingMan call v:lua.package.loaded.lewis6991.floatingMan(<f-args>)]])
  o.keywordprg = ':FloatingMan'
end

vim.cmd[[command! -complete=lua -nargs=1 L lua print(vim.inspect(<args>))]]

vim.cmd[[autocmd vimrc VimResized * wincmd =]]

vim.cmd[[command! LspDisable lua vim.lsp.stop_client(vim.lsp.get_active_clients())]]

return M

-- vim: foldminlines=0:
