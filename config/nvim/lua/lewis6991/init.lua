vim.opt.termguicolors  = true
require 'lewis6991.plugins'

require 'lewis6991.status'
require 'lewis6991.tabline'
require 'lewis6991.diagnostic'
require 'lewis6991.jump'
require 'lewis6991.clipboard'
require 'lewis6991.luv-hygiene'

local nvim = require 'lewis6991.nvim'

local o, api, lsp = vim.opt, vim.api, vim.lsp

local autocmd = nvim.autocmd
local nmap = nvim.nmap
local vmap = nvim.vmap
local cmap = nvim.cmap

if 'Plugins' then
  local dir = vim.fn.expand('~/gerrit')
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

  nmap '<leader>ts' {function()
    if vim.b.ts_highlight then
      vim.treesitter.stop()
    else
      vim.treesitter.start()
    end
  end}

  nmap '<C-C>' ':nohlsearch<CR>'

  -- map('n', '<Tab>'  , ':bnext<CR>', {})
  -- map('n', '<S-Tab>', ':bprev<CR>', {})
  nmap '<Tab>'   {':tabnext<CR>', silent=true}
  nmap '<S-Tab>' {':tabprev<CR>', silent=true}

  nmap '<C-o>' '<nop>'

  -- <Tab> == <C-i> in tmux so need other mappings for navigating the jump list
  vim.keymap.set('n', '<M-k>', function()
    require 'lewis6991.jump'.show_jumps()
    return '<C-o>'
  end, {expr = true, desc = 'show jumps'})

  vim.keymap.set('n', '<M-j>', function()
    require 'lewis6991.jump'.show_jumps()
    return '<C-i>'
  end, {expr = true, desc = 'show jumps'})

  nmap '|' {[[!v:count ? "<C-W>v<C-W><Right>" : '|']], expr=true, silent=true}
  nmap '_' {[[!v:count ? "<C-W>s<C-W><Down>"  : '_']], expr=true, silent=true}

  cmap '<C-P>' '<up>'
  cmap '<C-N>' '<down>'
  cmap '<C-A>' '<Home>'
  cmap '<C-D>' '<Del>'

  nmap ']d' (vim.diagnostic.goto_next)
  nmap '[d' (vim.diagnostic.goto_prev)

  autocmd 'LspAttach' {
    desc = 'lsp mappings',
    function(args)
      local bufnr = args.buf --- @type integer
      -- nmap '<C-]>'      {lsp.buf.definition, desc = 'lsp.buf.definition', buffer = bufnr  }
      nmap '<C-]>'      '<cmd>Trouble lsp_definitions<cr>'
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

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.server_capabilities.code_lens then
        autocmd {'BufEnter', 'CursorHold', 'InsertLeave'} { lsp.codelens.refresh, buffer = bufnr }
        lsp.codelens.refresh()
      end
    end
  }
end

if "Abbrev" then
  vim.cmd.cabbrev('L', 'lua=')

  vim.cmd.abbrev(':rev:', [[<c-r>=printf(&commentstring, 'REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>]])
  vim.cmd.abbrev(':todo:', [[<c-r>=printf(&commentstring, 'TODO(lewis6991):')<CR>]])
  vim.cmd.abbrev('function', 'function')
  vim.cmd.cabbrev('Q', 'q')

  vim.cmd.abbrev('-@T', '--- @type')
  vim.cmd.abbrev('-@P', '--- @param')
  vim.cmd.abbrev('-@R', '--- @return')
  vim.cmd.abbrev('-@F', '--- @field')
end

if 'Treesitter' then

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'comment',
    callback = function()
      vim.bo.commentstring = ''
    end
  })

  ---@return string?
  local function get_injection_filetype()
    local ok, parser = pcall(vim.treesitter.get_parser)
    if not ok then
      return
    end

    local cpos = api.nvim_win_get_cursor(0)
    local row, col = cpos[1] - 1, cpos[2]
    local range = { row, col, row, col + 1 }

    local ft  --- @type string?

    parser:for_each_child(function(tree, lang)
      if tree:contains(range) then
        local fts = vim.treesitter.language.get_filetypes(lang)
        for _, ft0 in ipairs(fts) do
          if vim.filetype.get_option(ft0, 'commentstring') ~= '' then
            ft = fts[1]
            break
          end
        end
      end
    end)

    return ft
  end

  local function enable_commenstrings()
    api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
      buffer = 0,
      callback = function()
        local ft = get_injection_filetype() or vim.bo.filetype
        vim.bo.commentstring = vim.filetype.get_option(ft, 'commentstring') --[[@as string]]
      end
    })
  end

  local function enable_foldexpr()
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldmethod = 'expr'
    vim.cmd.normal'zx'
  end

  api.nvim_create_autocmd('FileType', {
    callback = function()
      if not pcall(vim.treesitter.start) then
        return
      end

      enable_foldexpr()
      enable_commenstrings()
    end
  })

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
