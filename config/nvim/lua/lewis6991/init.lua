local o, api = vim.opt, vim.api

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
    --- @diagnostic disable-next-line: no-unknown
    local ok, r = xpcall(require, debug.traceback, mod)
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
  safe_require('lewis6991.treesitter')
  safe_require('lewis6991.lsp')
  safe_require('lewis6991.linters')

  -- safe_require 'gizmos.ts_matchparen'
  -- safe_require('gizmos.lsp_cmds')
  safe_require('gizmos.lastplace')
  safe_require('gizmos.marksigns')
  safe_require('gizmos.hashbang')
  safe_require('gizmos.lastplace')
  safe_require('gizmos.http_file_viewer')
  safe_require('gizmos.gh_issue_hl')
  safe_require('gizmos.conflict')
  safe_require('gizmos.restart')

  vim.cmd.packadd('cfilter')
end

--- @diagnostic disable-next-line: duplicate-set-field
vim.ui.input = function(...)
  require('gizmos.input')(...)
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
  o.laststatus = 3 -- For avante.nvim
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
  -- Terminal
  map('n', [[<C-\>]], '<cmd>vsplit | term<cr>')
  map('n', [[<C-->]], '<cmd>split | term<cr>')

  map('n', '<leader>ev', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/init.lua<CR>')
  map('n', '<leader>eV', ':edit $XDG_CONFIG_HOME/nvim/init.lua<CR>')
  map('n', '<leader>el', ':edit $XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua<CR>')
  map('n', '<leader>s', ':%s/\\<<C-R><C-W>\\>\\C//g<left><left>')
  map('n', '<leader>R', ':Restart<CR>')

  map('n', 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })
  map('n', 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })

  map('n', 'Q', ':w<cr>')
  map('v', 'Q', '<nop>')
  map({ 'n', 'v' }, 'gQ', '<nop>')

  -- delete the current buffer without deleting the window
  map('n', '<leader>b', ':b#|bd#<CR>')

  -- I never use macros and more often mis-hit this key
  map({ 'n', 'v' }, 'q', '<nop>')

  map('n', '<leader>z', '<cmd>Inspect<cr>')

  map('n', '<C-C>', ':nohlsearch<CR>')
  api.nvim_create_autocmd('InsertEnter', {
    callback = vim.schedule_wrap(function()
      vim.cmd.nohlsearch()
    end),
  })

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
end

if 'Abbrev' then
  map(
    '!a',
    'rev::',
    [[<c-r>=printf(&commentstring, 'REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>]]
  )
  map('!a', 'todo::', [[<c-r>=printf(&commentstring, 'TODO(lewis6991):')<CR>]])
  map('ca', 'Q', 'q')

  autocmd('FileType', {
    pattern = 'lua',
    callback = function()
      map('!a', '--T', '--- @type', { buffer = true })
      map('!a', '--P', '--- @param', { buffer = true })
      map('!a', '--R', '--- @return', { buffer = true })
      map('!a', '--F', '--- @field', { buffer = true })
      map('!a', '--A', '--' .. '[[@as]]<c-r>=execute("normal! hh")<CR>', { buffer = true })
    end,
  })

  -- auto spell
  map('!a', 'funciton', 'function')
  map('!a', 'functino', 'function')
end

autocmd('VimResized', {
  group = 'vimrc',
  command = 'wincmd =',
})

autocmd('BufReadPost', {
  group = 'vimrc',
  callback = function()
    if vim.bo.buftype ~= 'nofile' then
      vim.fn.matchadd('ColorColumn', '^.\\{' .. vim.bo.textwidth .. '}\\zs.')
    end
  end,
})

if vim.g.neovide then
  vim.o.guifont = 'Monaco,DejaVuSansM Nerd Font Mono:h12'
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
end

-- api.nvim_create_user_command('Term', function()
--   -- local buf = api.nvim_get_current_buf()
--   -- local b = api.nvim_create_buf(false, true)
--   -- local chan = api.nvim_open_term(b, {})
--   -- api.nvim_chan_send(chan, table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), '\n'))
--   -- api.nvim_win_set_buf(0, b)
--
--   api.nvim_open_term(0, {})
--
--   vim.cmd.stopinsert()
-- end, {})

api.nvim_create_autocmd('User', {
  pattern = 'RestartPre',
  callback = function()
    pcall(function()
      require('dap-view').close(true)
    end)
  end,
})

local function auto_create_dirs()
  local dir_path = vim.fn.expand('%:p:h')

  if vim.fn.isdirectory(dir_path) == 1 then
    return
  end

  local choice =
    vim.fn.confirm("Directory '" .. dir_path .. "' does not exist. Create it?", '&Yes\n&No', 1)

  if choice == 0 then
    vim.notify(
      'Directory creation cancelled. File not saved.',
      vim.log.levels.WARN,
      { title = 'Neovim' }
    )
    return
  end

  vim.fn.mkdir(dir_path, 'p')
end

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = auto_create_dirs,
})
