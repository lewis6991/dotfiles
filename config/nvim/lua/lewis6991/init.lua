local o, api, lsp = vim.opt, vim.api, vim.lsp

vim.opt.termguicolors  = true

if 'Plugins' then
  local dir = vim.fn.expand('~/gerrit') --[[@as string]]
  if vim.fn.isdirectory(dir) == 1 then
    for path, t in vim.fs.dir(dir) do
      if t == "directory" then
        o.rtp:prepend('~/gerrit/'..path)
      end
    end
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

--- Same as require() but don't abort on error
--- @param mod string
local function safe_require(mod)
  local ok, r = pcall(require, mod)
  if not ok then
    vim.schedule(function()
      error(r)
    end)
  end
end

safe_require 'lewis6991.plugins'
safe_require 'lewis6991.status'
safe_require 'lewis6991.tabline'
safe_require 'lewis6991.diagnostic'
safe_require 'lewis6991.clipboard'
safe_require 'lewis6991.ts_matchparen'
safe_require 'lewis6991.treesitter'

local nvim = require 'lewis6991.nvim'

local autocmd = nvim.autocmd
local nmap = nvim.nmap
local vmap = nvim.vmap
local cmap = nvim.cmap

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

  o.foldcolumn  = '0'
  o.foldnestmax = 3
  o.foldopen:append('jump')
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

  nmap '<leader>z' '<cmd>Inspect<cr>'

  nmap '<C-C>' ':nohlsearch<CR>'

  -- map('n', '<Tab>'  , ':bnext<CR>', {})
  -- map('n', '<S-Tab>', ':bprev<CR>', {})
  nmap '<Tab>'   {':tabnext<CR>', silent=true}
  nmap '<S-Tab>' {':tabprev<CR>', silent=true}

  nmap '<C-o>' '<nop>'

  nmap '|' {[[!v:count ? "<C-W>v<C-W><Right>" : '|']], expr=true, silent=true}
  nmap '_' {[[!v:count ? "<C-W>s<C-W><Down>"  : '_']], expr=true, silent=true}

  cmap '<C-P>' '<up>'
  cmap '<C-N>' '<down>'
  cmap '<C-A>' '<Home>'
  cmap '<C-D>' '<Del>'

  nmap ']d' (vim.diagnostic.goto_next)
  nmap '[d' (vim.diagnostic.goto_prev)

  nmap ']D' (function() vim.diagnostic.goto_next{severity = 'ERROR'} end)
  nmap '[D' (function() vim.diagnostic.goto_prev{severity = 'ERROR'} end)

  autocmd 'LspAttach' {
    desc = 'lsp mappings',
    function(args)
      local bufnr = args.buf --- @type integer
      -- nmap '<C-]>'      {lsp.buf.definition, desc = 'lsp.buf.definition', buffer = bufnr  }
      nmap '<C-]>'      {'<cmd>Trouble lsp_definitions<cr>' , buffer = bufnr }
      nmap '<M-]>'      {lsp.buf.type_definition, desc = 'lsp.buf.type_definition', buffer = bufnr  }
      nmap '<M-i>'      {function() lsp.buf.inlay_hint(bufnr) end, desc = 'lsp.buf.inlay_hint', buffer = bufnr  }
      nmap '<leader>cl' {lsp.codelens.run  , desc = 'lsp.codelens.run'  , buffer = bufnr    }
      -- map(bufnr, 'K'         , lsp.buf.hover         , 'lsp.buf.hover'         )
      -- map(bufnr, 'gK'        , lsp.buf.signature_help, 'lsp.buf.signature_help')
      nmap '<C-s>'      { lsp.buf.signature_help, desc = 'lsp.buf.signature_help', buffer = bufnr}
      nmap '<leader>rn' { lsp.buf.rename        , desc = 'lsp.buf.rename'        , buffer = bufnr}
      nmap '<leader>ca' { lsp.buf.code_action   , desc = 'lsp.buf.code_action'   , buffer = bufnr}

      -- nmap 'gr' { lsp.buf.references }
      nmap 'gr' '<cmd>Trouble lsp_references<cr>'
      nmap 'gR' '<cmd>Telescope lsp_references layout_strategy=vertical<cr>'
      nmap 'gi' {lsp.buf.implementation, desc = 'lsp.buf.implementation', buffer = bufnr  }

      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client.server_capabilities.code_lens then
        autocmd {'BufEnter', 'CursorHold', 'InsertLeave'} { lsp.codelens.refresh, buffer = bufnr }
        lsp.codelens.refresh()
      end
    end
  }
end

if "Abbrev" then
  local map = vim.keymap.set

  map('ca', 'L', 'lua=')

  map('!a', ':rev:', [[<c-r>=printf(&commentstring, 'REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>]])
  map('!a', ':todo:', [[<c-r>=printf(&commentstring, 'TODO(lewis6991):')<CR>]])
  map('!a', 'funciton', 'function')
  map('ca', 'Q', 'q')

  autocmd 'FileType' {
    pattern = 'lua',
    function()
      map('!a', '--T', '--- @type', {buffer = true})
      map('!a', '--P', '--- @param', {buffer = true})
      map('!a', '--R', '--- @return', {buffer = true})
      map('!a', '--F', '--- @field', {buffer = true})
    end
  }

end

if "Custom print" then
  _G.printf = function(...)
    print(string.format(...))
  end

  local orig_print = print

  function _G.print(...)
    if vim.in_fast_event() then
      return orig_print(...)
    end
    for _, x in ipairs{...} do
      if type(x) == 'string' then
        api.nvim_out_write(x)
      else
        api.nvim_out_write(vim.inspect(x, {newline=' ', indent=''}))
      end
    end
    api.nvim_out_write('\n')
  end
end

autocmd 'VimResized' {'wincmd =', group='vimrc'}

-- vim: foldminlines=0:
