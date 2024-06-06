local o, api, lsp = vim.opt, vim.api, vim.lsp

local autocmd = api.nvim_create_autocmd
local map = vim.keymap.set

if 'Plugins' then
  local dir = vim.fn.expand('~/gerrit') --[[@as string]]
  if vim.fn.isdirectory(dir) == 1 then
    for path, t in vim.fs.dir(dir) do
      if t == 'directory' then
        o.rtp:prepend('~/gerrit/' .. path)
      end
    end
  end

  -- Stop loading built in plugins
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  -- vim.g.loaded_2html_plugin = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_gzip = 1

  api.nvim_create_augroup('vimrc', {})
end

if 'Modules' then
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

  safe_require('lewis6991.plugins')
  safe_require('lewis6991.status')
  safe_require('lewis6991.tabline')
  safe_require('lewis6991.diagnostic')
  -- safe_require 'lewis6991.ts_matchparen'
  safe_require('lewis6991.treesitter')
  safe_require('lewis6991.lsp')
  safe_require('lewis6991.lsp_cmds')
end

if 'Options' then
  o.backup = true
  o.backupdir:remove('.')
  -- o.showbreak   = '    ↳ '
  o.breakindent = true -- Indent wrapped lines to match start
  o.clipboard = 'unnamedplus'
  o.expandtab = true
  o.fillchars = { eob = ' ', diff = ' ', fold = ' ' }
  o.hidden = true
  o.ignorecase = true
  o.inccommand = 'split'
  o.list = true
  o.listchars = 'tab:▸ ' -- Show tabs as '▸   ▸   '
  o.mouse = 'a'
  o.mousemoveevent = true
  o.number = true
  o.pumblend = 10
  o.relativenumber = true
  o.scrolloff = 6
  o.shiftwidth = 4
  o.showbreak = '↳ '
  o.showmode = false
  o.sidescroll = 6
  o.sidescrolloff = 6
  o.signcolumn = 'auto:3'
  o.smartcase = true
  o.softtabstop = 4
  o.spell = true
  o.splitbelow = true
  o.splitright = true
  o.startofline = false
  o.swapfile = false
  o.tabstop = 4
  o.textwidth = 80
  o.undofile = true
  o.undolevels = 10000
  o.virtualedit = 'block' -- allow cursor to exist where there is no character
  o.winblend = 10
  o.wrap = false

  -- Avoid showing message extra message when using completion
  o.shortmess:append('c')
  o.completeopt:append({
    'noinsert',
    'menuone',
    'noselect',
    'preview',
  })

  o.diffopt:append({
    'linematch:30',
    'vertical',
    'foldcolumn:0',
    'indent-heuristic',
  })

  o.foldcolumn = '0'
  o.foldnestmax = 3
  o.foldopen:append('jump')
  o.foldtext = ''
  o.fillchars:append({ fold = ' ' })

  local xdg_cfg = os.getenv('XDG_CONFIG_HOME')
  if xdg_cfg then
    o.spellfile = xdg_cfg .. '/nvim/spell/en.utf-8.add'
  end

  o.formatoptions:append({
    r = true, -- Automatically insert comment leader after <Enter> in Insert mode.
    o = true, -- Automatically insert comment leader after 'o' or 'O' in Normal mode.
    l = true, -- Long lines are not broken in insert mode.
    t = true, -- Do not auto wrap text
    n = true, -- Recognise lists
  })
end

if 'Whitespace' then
  -- Highlight trailing whitespace
  -- setup in VimEnter to stop the intro screen being cleared
  autocmd('VimEnter', {
    group = 'vimrc',
    callback = function()
      autocmd('BufEnter', {
        group = 'vimrc',
        callback = vim.schedule_wrap(function()
          if vim.bo.buftype == '' then
            vim.fn.matchadd('ColorColumn', '\\s\\+$')
          end
        end),
      })
    end,
  })
end

if 'Mappings' then
  map('n', '<leader>ev', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/init.lua<CR>')
  map('n', '<leader>eV', ':edit $XDG_CONFIG_HOME/nvim/init.lua<CR>')
  map('n', '<leader>el', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua<CR>')
  map('n', '<leader>s', ':%s/\\<<C-R><C-W>\\>\\C//g<left><left>')

  map('n', 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })
  map('n', 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })

  map('n', 'Y', 'y$')

  map('n', 'Q', ':w<cr>')
  map('v', 'Q', '<nop>')
  map('n', 'gQ', '<nop>')
  map('v', 'gQ', '<nop>')

  -- delete the current buffer without deleting the window
  map('n', '<leader>b', ':b#|bd#<CR>')

  -- I never use macros and more often mis-hit this key
  map('n', 'q', '<nop>')

  map('n', '<leader>z', '<cmd>Inspect<cr>')

  map('n', '<C-C>', ':nohlsearch<CR>')

  map('n', '<Tab>', function()
    if #api.nvim_list_tabpages() > 1 then
      vim.cmd.tabnext()
    else
      vim.cmd.bnext()
    end
  end, { silent = true })

  map('n', '<S-Tab>', function()
    if #api.nvim_list_tabpages() > 1 then
      vim.cmd.tabprev()
    else
      vim.cmd.bprev()
    end
  end, { silent = true })

  map('n', '<C-o>', '<nop>')

  map('n', '|', [[!v:count ? "<C-W>v<C-W><Right>" : '|']], { expr = true, silent = true })
  map('n', '_', [[!v:count ? "<C-W>s<C-W><Down>"  : '_']], { expr = true, silent = true })

  map('c', '<C-P>', '<up>')
  map('c', '<C-N>', '<down>')
  map('c', '<C-A>', '<Home>')
  map('c', '<C-D>', '<Del>')

  autocmd('LspAttach', {
    desc = 'lsp mappings',
    callback = function(args)
      local bufnr = args.buf --- @type integer
      map(
        'n',
        '<M-]>',
        lsp.buf.type_definition,
        { desc = 'lsp.buf.type_definition', buffer = bufnr }
      )

      map('n', '<M-i>', function()
        lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled({bufnr = bufnr}), {bufnr = bufnr})
      end, { desc = 'lsp.buf.inlay_hint', buffer = bufnr })

      map('n', '<leader>cl', lsp.codelens.run, { desc = 'lsp.codelens.run', buffer = bufnr })
      -- map(bufnr, 'K'         , lsp.buf.hover         , 'lsp.buf.hover'         )
      -- map(bufnr, 'gK'        , lsp.buf.signature_help, 'lsp.buf.signature_help')
      map('n', '<C-s>', lsp.buf.signature_help, { desc = 'lsp.buf.signature_help', buffer = bufnr })
      map('n', '<leader>rn', lsp.buf.rename, { desc = 'lsp.buf.rename', buffer = bufnr })
      map('n', '<leader>ca', lsp.buf.code_action, { desc = 'lsp.buf.code_action', buffer = bufnr })

      -- keymap('n', 'gr' { lsp.buf.references }
      map('n', 'gr', '<cmd>Trouble lsp toggle<cr>')
      map('n', 'gd', '<cmd>Trouble diagnostics toggle<cr>')
      map('n', 'gi', lsp.buf.implementation, { desc = 'lsp.buf.implementation', buffer = bufnr })
    end,
  })
end

if 'Abbrev' then
  map(
    '!a',
    ':rev:',
    [[<c-r>=printf(&commentstring, 'REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>]]
  )
  map('!a', ':todo:', [[<c-r>=printf(&commentstring, 'TODO(lewis6991):')<CR>]])
  map('ca', 'Q', 'q')

  autocmd('FileType', {
    pattern = 'lua',
    callback = function()
      map('!a', '--T', '--- @type', { buffer = true })
      map('!a', '--P', '--- @param', { buffer = true })
      map('!a', '--R', '--- @return', { buffer = true })
      map('!a', '--F', '--- @field', { buffer = true })
      map('!a', '--A', '--[[@as', { buffer = true })
    end,
  })

  -- auto spell
  map('!a', 'funciton', 'function')
end

autocmd('VimResized', {
  group = 'vimrc',
  command = 'wincmd =',
})

local ns = api.nvim_create_namespace('overlength')
api.nvim_set_decoration_provider(ns, {
  on_line = function(_, _winid, bufnr, row)
    local line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
    local tw = vim.bo[bufnr].textwidth
    if line and #line > tw then
      api.nvim_buf_set_extmark(bufnr, ns, row, tw, {
        end_row = row,
        end_col = tw + 1,
        hl_group = 'ColorColumn',
        ephemeral = true
      })
    end
  end
})
