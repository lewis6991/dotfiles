local packer = require('lewis6991.packer')

packer.setup {
  'wbthomason/packer.nvim',

  -- 'lewis6991/moonlight.vim',
  {'lewis6991/github_dark.nvim', config = function()
    vim.cmd.color'github_dark'
  end},

  'lewis6991/tcl.vim',
  'lewis6991/tree-sitter-tcl',
  -- 'lewis6991/systemverilog.vim',
  'lewis6991/impatient.nvim',
  {'lewis6991/spaceless.nvim', config = [[require('spaceless').setup()]]},
  {'lewis6991/cleanfold.nvim'},
  'lewis6991/brodir.nvim',
  'lewis6991/vc.nvim',

  {'lewis6991/foldsigns.nvim',
    config = function()
      require'foldsigns'.setup{
        exclude = {'GitSigns.*'}
      }
    end
  },

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

  {'lewis6991/satellite.nvim', config = function()
    require('satellite').setup()
  end},

  {'lewis6991/gitsigns.nvim', config = "require'lewis6991.gitsigns'" },

  {'lewis6991/nvim-colorizer.lua', config = [[require('colorizer').setup()]] },

  {'lewis6991/tmux.nvim', config = function()
    require("tmux").setup{
      navigation = { enable_default_keybindings = true }
    }
  end},

  {'tpope/vim-commentary', keys = 'gc'}, -- plugin/commentary.vim - ~120LOC
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-sleuth',

  'nvim-tree/nvim-web-devicons',

  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',
  'dietsche/vim-lastplace',
  {'sindrets/diffview.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  },
  'folke/trouble.nvim', --  EXITFREE lag
  'bogado/file-line', -- Open file:line

  {'AndrewRadev/bufferize.vim', config = function()
    vim.g.bufferize_command = 'enew'
    vim.cmd('autocmd vimrc FileType bufferize setlocal wrap')
  end},

  --- Filetype plugins ---
  'tmux-plugins/vim-tmux',
  {'derekwyatt/vim-scala', ft = 'scala' },  -- plugin/scala.vim - ~150LOC
  'martinda/Jenkinsfile-vim-syntax',
  'teal-language/vim-teal',
  'fladson/vim-kitty',
  'raimon49/requirements.txt.vim',

  {'rcarriga/nvim-notify', config = function()
    vim.notify = require("notify")
  end},

  {'j-hui/fidget.nvim', config = function()
    require'fidget'.setup{
      text = {
        spinner = "dots",
      },
      fmt = {
        stack_upwards = false,
        task = function(task_name, message, percentage)
          local pct = percentage and string.format(" (%s%%)", percentage) or ""
          if task_name then
            return string.format("%s%s [%s]", message, pct, task_name)
          else
            return string.format("%s%s", message, pct)
          end
        end,
      },
      sources = {
        ['null-ls'] = {
          ignore = true
        }
      }
    }
  end},

  {'mhinz/vim-grepper', config = function()
    vim.g.grepper = {
      dir = 'repo',
    }
    vim.keymap.set({'n', 'x'}, 'gs', '<plug>(GrepperOperator)')
  end},

  'ryanoasis/vim-devicons',

  {'neapel/vim-bnfc-syntax', config = function()
    -- Argh, why don't syntax plugins ever set commentstring!
    vim.cmd[[autocmd vimrc FileType bnfc setlocal commentstring=--%s]]
    -- This syntax works pretty well for regular BNF too
    vim.cmd[[autocmd vimrc BufNewFile,BufRead *.bnf setlocal filetype=bnfc]]
  end},

  {'whatyouhide/vim-lengthmatters', config = function()
    vim.g.lengthmatters_highlight_one_column = 1
    vim.g.lengthmatters_excluded = {'packer'}
  end},

  {'junegunn/vim-easy-align',
    keys = 'ga', -- plugin/easy_align.vim - ~ 140LOC
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

  {'neovim/nvim-lspconfig',
    requires = {
      'stevearc/aerial.nvim',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'scalameta/nvim-metals',
      'folke/lua-dev.nvim',
      'ray-x/lsp_signature.nvim',
      'theHamsta/nvim-semantic-tokens',
    },
    config = "require'lewis6991.lsp'"
  },

  {'rmagatti/goto-preview', config = function()
    require('goto-preview').setup {
      opacity = 0,
      height = 30
    }
    vim.keymap.set('n', 'gp', require('goto-preview').goto_preview_definition)
  end},

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
      -- 'ray-x/cmp-treesitter',
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

  'neovim/nvimdev.nvim',

  {'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/playground',
    },
    run = ':TSUpdate',
    config = "require'lewis6991.treesitter'",
  }
}
