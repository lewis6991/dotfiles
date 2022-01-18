local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if not vim.loop.fs_stat(install_path) then
  if vim.fn.input("Download Packer? (y for yes): ") ~= "y" then
    return
  end

  print("Downloading packer.nvim...")
  print(vim.fn.system(string.format(
    'git clone %s %s',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  )))
end

local init = {
  'wbthomason/packer.nvim',

  'lewis6991/moonlight.vim',
  {'lewis6991/github_dark.nvim', config = [[vim.cmd'color github_dark']]},

  'lewis6991/tcl.vim',
  -- 'lewis6991/systemverilog.vim',
  'lewis6991/impatient.nvim',
  {'lewis6991/spaceless.nvim', config = [[require('spaceless').setup()]]},
  {'lewis6991/cleanfold.nvim', config = [[require('cleanfold').setup()]]},

  'nanotee/luv-vimdocs',
  'wsdjeg/luarefvim',

  {'lewis6991/vim-dirvish', config = function()
    vim.g.dirvish_mode = ':sort ,^.*[\\/],'
  end},

  'tpope/vim-commentary',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-sleuth',

  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',
  'dietsche/vim-lastplace',
  'sindrets/diffview.nvim',
  'folke/trouble.nvim',
  'rhysd/conflict-marker.vim',
  'bogado/file-line', -- Open file:line

  {'AndrewRadev/bufferize.vim',
    cmd = 'Bufferize',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.cmd('autocmd vimrc FileType bufferize setlocal wrap')
    end
  },

  {'vim-scripts/visualrepeat', requires = 'inkarkat/vim-ingo-library' },

  -- Highlight the current search result
  -- 'timakro/vim-searchant',
  {'PeterRincker/vim-searchlight', config = function()
    vim.cmd[[highlight default link Searchlight SearchCurrent]]
  end},

  --- Filetype plugins ---
  {'tmux-plugins/vim-tmux', ft = 'tmux'  },
  {'derekwyatt/vim-scala' , ft = 'scala' },
  'cespare/vim-toml',
  'martinda/Jenkinsfile-vim-syntax',
  'teal-language/vim-teal',
  'raimon49/requirements.txt.vim',
  'euclidianAce/BetterLua.vim',
  'tmhedberg/SimpylFold',

  {'lewis6991/foldsigns.nvim',
    config = function()
      require'foldsigns'.setup{
        exclude = {'GitSigns.*'}
      }
    end
  },

  {'aserowy/tmux.nvim', config = function()
    require("tmux").setup{
      navigation = { enable_default_keybindings = true }
    }
  end},

  'ryanoasis/vim-devicons',

  {'neapel/vim-bnfc-syntax',
    config = function()
      -- Argh, why don't syntax plugins ever set commentstring!
      vim.cmd[[autocmd vimrc FileType bnfc setlocal commentstring=--%s]]
      -- This syntax works pretty well for regular BNF too
      vim.cmd[[autocmd vimrc BufNewFile,BufRead *.bnf setlocal filetype=bnfc]]
    end
  },

  {'whatyouhide/vim-lengthmatters', config = function()
    vim.g.lengthmatters_highlight_one_column = 1
  end},

  {'junegunn/vim-easy-align',
    keys = 'ga',
    config = function()
      vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
      vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {})
      vim.g.easy_align_delimiters = {
        [';']  = { pattern = ';'        , left_margin = 0 },
        ['[']  = { pattern = '['        , left_margin = 1, right_margin = 0 },
        [']']  = { pattern = ']'        , left_margin = 0, right_margin = 1 },
        [',']  = { pattern = ','        , left_margin = 0, right_margin = 1 },
        [')']  = { pattern = ')'        , left_margin = 0, right_margin = 0 },
        ['(']  = { pattern = '('        , left_margin = 0, right_margin = 0 },
        ['=']  = { pattern = [[<\?=>\?]], left_margin = 1, right_margin = 1 },
        ['|']  = { pattern = [[|\?|]]   , left_margin = 1, right_margin = 1 },
        ['&']  = { pattern = [[&\?&]]   , left_margin = 1, right_margin = 1 },
        [':']  = { pattern = ':'        , left_margin = 1, right_margin = 1 },
        ['?']  = { pattern = '?'        , left_margin = 1, right_margin = 1 },
        ['<']  = { pattern = '<'        , left_margin = 1, right_margin = 0 },
        ['>']  = { pattern = '>'        , left_margin = 1, right_margin = 0 },
        ['\\'] = { pattern = '\\'       , left_margin = 1, right_margin = 0 },
        ['+']  = { pattern = '+'        , left_margin = 1, right_margin = 1 }
      }
    end
  },

  {'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer',
      'scalameta/nvim-metals',
      'folke/lua-dev.nvim',
    },
    config = "require'lewis6991.lsp'"
  },

  {'jose-elias-alvarez/null-ls.nvim', config = [[require('lewis6991.null-ls')]]},

  {'hrsh7th/nvim-cmp',
    event = "InsertEnter,CmdlineEnter *",
    requires = {
      'onsails/lspkind-nvim',
      { 'hrsh7th/cmp-nvim-lsp'    , after = "nvim-cmp" },
      { 'hrsh7th/cmp-buffer'      , after = "nvim-cmp" },
      { 'hrsh7th/cmp-path'        , after = "nvim-cmp" },
      { 'hrsh7th/cmp-nvim-lua'    , after = "nvim-cmp" },
      { 'hrsh7th/cmp-cmdline'     , after = "nvim-cmp" },
      { 'lukas-reineke/cmp-rg'    , after = "nvim-cmp" },
      { 'f3fora/cmp-spell'        , after = "nvim-cmp" },
      { 'andersevenrud/cmp-tmux'  , after = "nvim-cmp" },
      { "L3MON4D3/LuaSnip"        },
      { 'saadparwaiz1/cmp_luasnip', after = "nvim-cmp" },
    },
    config = [[require('lewis6991.cmp')]]
  },

  {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  {'nvim-lua/telescope.nvim',
    requires = {
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim'
    },
    config = "require'lewis6991.telescope'"
  },

  {'pwntester/octo.nvim',
    event = 'CmdlineEnter *',
    config=function()
      require"octo".setup()
    end
  },

  -- 'mhinz/vim-signify',
  -- 'airblade/vim-gitgutter',
  -- 'rhysd/git-messenger.vim',
  {'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.api.nvim_set_keymap('n', 'm', '<cmd>Gitsigns dump_cache<CR>'    , {noremap=true})
      vim.api.nvim_set_keymap('n', 'M', '<cmd>Gitsigns debug_messages<CR>', {noremap=true})
      require('gitsigns').setup{
        debug_mode = true,
        max_file_length = 1000000000,
        signs = {
          add          = {show_count = false, text = '┃' },
          change       = {show_count = false, text = '┃' },
          delete       = {show_count = true },
          topdelete    = {show_count = true },
          changedelete = {show_count = true},
        },
        keymaps = {
          -- Default keymap options
          noremap = true,

          ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
          ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},

          ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
          ['v <leader>hs'] = ':Gitsigns stage_hunk<CR>',
          ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',
          ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
          ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
          ['v <leader>hr'] = ':Gitsigns reset_hunk<CR>',
          ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',
          ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
          ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
          ['n <leader>tb'] = '<cmd>Gitsigns toggle_current_line_blame<CR>',
          ['n <leader>hd'] = '<cmd>Gitsigns diffthis<CR>',
          ['n <leader>hD'] = '<cmd>Gitsigns diffthis ~<CR>',
          ['n <leader>td'] = '<cmd>Gitsigns toggle_deleted<CR>',

          ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
          ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
        },
        preview_config = {
          border = 'rounded',
        },
        current_line_blame = true,
        current_line_blame_formatter_opts = {
          relative_time = true
        },
        current_line_blame_opts = {
          delay = 0
        },
        count_chars = {
          '⒈', '⒉', '⒊', '⒋', '⒌', '⒍', '⒎', '⒏', '⒐',
          '⒑', '⒒', '⒓', '⒔', '⒕', '⒖', '⒗', '⒘', '⒙', '⒚', '⒛',
        },
        _refresh_staged_on_update = false,
        _blame_cache = true,
        word_diff = true,
      }
    end
  },

  {'lewis6991/spellsitter.nvim', config = [[require('spellsitter').setup()]] },

  {'norcalli/nvim-colorizer.lua', config = [[require('colorizer').setup()]] },

  {'nvim-treesitter/nvim-treesitter',
    requires = {
      'romgrk/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/playground',
    },
    run = ':TSUpdate',
    config = "require'lewis6991.treesitter'",
  },

  {'ojroques/vim-oscyank',
    event = 'TextYankPost',
    config = function()
      vim.g.oscyank_silent = true
      vim.cmd[[
        augroup oscyank
          autocmd!
          autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is ''
          autocmd TextYankPost *     execute 'OSCYankReg "'
          autocmd TextYankPost * endif
        augroup END
      ]]
    end
  },

  {'folke/persistence.nvim',
    config = function()
      require('persistence').setup()

      -- restore the session for the current directory
      vim.api.nvim_set_keymap("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], {})

      -- restore the last session
      vim.api.nvim_set_keymap("n", "<leader>ql", [[<cmd>lua require("persistence").load({last=true})<cr>]], {})
    end,
  },

  -- {'romgrk/barbar.nvim',
  --   requires = { 'kyazdani42/nvim-web-devicons' },
  --   config = function()
  --     vim.g.bufferline = vim.tbl_extend('force', vim.g.bufferline or {}, {
  --       closable = false
  --     })
  --     vim.api.nvim_set_keymap('n', '<Tab>'  , ':BufferNext<CR>'    , {noremap=true,silent=true})
  --     vim.api.nvim_set_keymap('n', '<S-Tab>', ':BufferPrevious<CR>', {noremap=true,silent=true})
  --   end
  -- },

  {"jose-elias-alvarez/buftabline.nvim",
    requires = {"kyazdani42/nvim-web-devicons"}, -- optional!
    config = function()
      require("buftabline").setup{
        tab_format = " #{i} #{b}#{f} ",
        go_to_maps = false,
      }
      vim.api.nvim_set_keymap('n', '<Tab>'  , ':BufNext<CR>', {noremap=true,silent=true})
      vim.api.nvim_set_keymap('n', '<S-Tab>', ':BufPrev<CR>', {noremap=true,silent=true})
    end
  },

}

do -- look for local version of plugins in $HOME/projects and use them instead
  local home = os.getenv('HOME')

  local function try_get_local(plugin)
    local _, name = unpack(vim.split(plugin, '/'))
    local loc_install = home..'/projects/'..name
    if vim.loop.fs_stat(loc_install) then
      return loc_install
    else
      return plugin
    end
  end

  local function try_local(spec, i)
    i = i or 1
    if type(spec[i]) == 'string' then
      spec[i] = try_get_local(spec[i])
    elseif type(spec[i]) == 'table' then
      for j, _ in ipairs(spec[i]) do
        try_local(spec[i], j)
      end
      try_local(spec[i], 'requires')
    end
  end

  try_local{init}
end

local packer = require('packer')

do -- Hacky way of auto clean/install/compile
  vim.cmd[[
    augroup plugins
    " Reload plugins.lua
    autocmd!
    autocmd BufWritePost plugins.lua lua package.loaded["lewis6991.plugins"] = nil; require("lewis6991.plugins")
    autocmd BufWritePost plugins.lua PackerClean
    augroup END
  ]]

  local state = 'cleaned'
  local orig_complete = packer.on_complete
  packer.on_complete = vim.schedule_wrap(function()
    if state == 'cleaned' then
      packer.install()
      state = 'installed'
    elseif state == 'installed' then
      packer.compile()
      -- packer.compile('profile=true')
      state = 'compiled'
    elseif state == 'compiled' then
      packer.on_complete = orig_complete
      state = 'done'
    end
  end)

end

packer.startup{init,
  config = {
    display = {
      open_cmd = 'edit \\[packer\\]',
      prompt_border = 'rounded'
    },
    -- Move to lua dir so impatient.nvim can cache it
    compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua'
  }
}

vim.api.nvim_set_keymap('n', '<leader>u', ':PackerUpdate<CR>', {noremap=true, silent=true})

return packer
