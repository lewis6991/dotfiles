local packer = require('lewis6991.packer')

packer.setup {
  'wbthomason/packer.nvim',

  -- 'lewis6991/moonlight.vim',
  {'lewis6991/github_dark.nvim', config = [[vim.cmd'color github_dark']]},

  'lewis6991/tcl.vim',
  -- 'lewis6991/systemverilog.vim',
  'lewis6991/impatient.nvim',
  {'lewis6991/spaceless.nvim', config = [[require('spaceless').setup()]]},
  {'lewis6991/cleanfold.nvim', config = [[require('cleanfold').setup()]]},

  'nanotee/luv-vimdocs',

  'tpope/vim-commentary',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-sleuth',

  'kyazdani42/nvim-web-devicons',
  'lewis6991/vim-dirvish',

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

  -- Highlight the current search result
  -- can be replaced with https://github.com/neovim/neovim/pull/11082
  {'PeterRincker/vim-searchlight', config = function()
    vim.api.nvim_set_hl(0, 'SearchLight', {link = 'SearchCurrent'})
  end},

  --- Filetype plugins ---
  {'tmux-plugins/vim-tmux', ft = 'tmux'  },
  {'derekwyatt/vim-scala' , ft = 'scala' },
  'cespare/vim-toml',
  'martinda/Jenkinsfile-vim-syntax',
  'teal-language/vim-teal',
  'fladson/vim-kitty',
  'raimon49/requirements.txt.vim',
  'euclidianAce/BetterLua.vim',

  {'mhinz/vim-grepper', config = function()
    vim.g.grepper = {
      dir = 'repo',
    }
    vim.keymap.set({'n', 'x'}, 'gs', '<plug>(GrepperOperator)')
  end},

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

  {'lewis6991/hover.nvim', config  = function()
    require('hover').setup{
      init = function()
        require('hover.providers.lsp')
        require('hover.providers.gh')
        require('hover.providers.dictionary')
        require('hover.providers.man')
      end
    }
    vim.keymap.set('n', 'K', require('hover').hover, {desc='hover.nvim'})
    vim.keymap.set('n', 'gK', require('hover').hover_select, {desc='hover.nvim (select)'})
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
    vim.g.lengthmatters_excluded = {'packer'}
  end},

  {'junegunn/vim-easy-align',
    keys = 'ga',
    config = function()
      vim.keymap.set({'x', 'n'}, 'ga', '<Plug>(EasyAlign)')
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

  'lewis6991/nvim-scrollview',

  {'neovim/nvim-lspconfig',
    requires = {
      'stevearc/aerial.nvim',
      'williamboman/nvim-lsp-installer',
      'scalameta/nvim-metals',
      'folke/lua-dev.nvim',
    },
    config = "require'lewis6991.lsp'"
  },

  {'jose-elias-alvarez/null-ls.nvim', config = [[require('lewis6991.null-ls')]]},

  {'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-cmdline',
      -- 'dmitmel/cmp-cmdline-history',
      'lukas-reineke/cmp-rg',
      'f3fora/cmp-spell',
      'andersevenrud/cmp-tmux',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'ray-x/cmp-treesitter',
    },
    config = [[require('lewis6991.cmp')]]
  },

  {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  {'nvim-lua/telescope.nvim',
    requires = {
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-lua/plenary.nvim'
    },
    config = "require'lewis6991.telescope'"
  },

  'nvim-lua/plenary.nvim',

  {'lewis6991/gitsigns.nvim', config = "require'lewis6991.gitsigns'" },

  {'neovim/nvimdev.nvim',
    requires = {'neomake/neomake'}
  },
  {'lewis6991/spellsitter.nvim', config = [[require('spellsitter').setup()]] },

  {'norcalli/nvim-colorizer.lua', config = [[require('colorizer').setup()]] },

  {'nvim-treesitter/nvim-treesitter',
    requires = {
      'lewis6991/nvim-treesitter-context',
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

}
