local manager = require('lewis6991.package_manager')
manager.bootstrap()

local event = require('pckr.loader.event')

manager.setup({

  --- Filetype plugins ---
  'martinda/Jenkinsfile-vim-syntax',
  'lewis6991/vc.nvim',
  'lewis6991/tree-sitter-tcl',

  { 'lewis6991/github_dark.nvim',
    config = function()
      vim.cmd.color('github_dark')
    end,
  },

  'lewis6991/nvim-treesitter-pairs',
  'lewis6991/spaceless.nvim',
  'lewis6991/brodir.nvim',
  'lewis6991/fileline.nvim',
  'lewis6991/satellite.nvim',

  { 'yetone/avante.nvim',
    run = 'make',
    config = function()
      require('avante_lib').load()
      require('avante').setup({
        provider = 'copilot',
      })
    end,
    requires = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- optional,
      "zbirenbaum/copilot.lua", -- for providers='copilot'
    },
  },

  { 'MeanderingProgrammer/render-markdown.nvim',
    config = function()
      require('render-markdown').setup({
        file_types = { 'markdown', 'Avante' },
      })
    end,
  },

  { 'lewis6991/whatthejump.nvim',
    config = function()
      -- <Tab> == <C-i> in tmux so need other mappings for navigating the jump list
      vim.keymap.set('n', '<M-k>', function()
        require('whatthejump').show_jumps(false)
        return '<C-o>'
      end, { expr = true })

      vim.keymap.set('n', '<M-j>', function()
        require('whatthejump').show_jumps(true)
        return '<C-i>'
      end, { expr = true })
    end,
  },

  { 'lewis6991/hover.nvim',
    config = function()
      local did_setup = false
      local function hover_action(action)
        return function()
          if not did_setup then
            require('hover').setup({
              init = function()
                require('hover.providers.lsp')
                require('hover.providers.gh')
                require('hover.providers.gh_user')
                require('hover.providers.dictionary')
                require('hover.providers.man')
                -- require('hover.providers.diagnostic')
              end,
            })
            did_setup = true
          end
          require('hover')[action]()
        end
      end

      vim.keymap.set('n', 'K',
        hover_action('hover'), { desc = 'hover.nvim' })

      vim.keymap.set('n', 'gK',
        hover_action('hover_select'), { desc = 'hover.nvim (select)' })

      vim.keymap.set( 'n', '<MouseMove>',
        hover_action('hover_mouse'), { desc = 'hover.nvim (mouse)' })

      vim.o.mousemoveevent = true
    end,
  },

  { 'lewis6991/gitsigns.nvim', config = 'lewis6991.gitsigns' },

  'lewis6991/nvim-colorizer.lua',

  { 'lewis6991/tmux.nvim',
    config = function()
      require('tmux').setup({
        navigation = { enable_default_keybindings = true },
      })
    end,
  },

  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-fugitive',
  'tpope/vim-sleuth',

  'nvim-tree/nvim-web-devicons',

  'wellle/targets.vim',
  'sindrets/diffview.nvim',
  {'folke/trouble.nvim', config = function()
    require('trouble').setup()
  end},

  { 'AndrewRadev/bufferize.vim',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'bufferize',
        command = 'setlocal wrap',
      })
    end,
  },

  { 'rcarriga/nvim-notify',
    config = function()
      --- @diagnostic disable-next-line
      vim.notify = function(...)
        vim.notify = require('notify')
        return vim.notify(...)
      end
    end,
  },

  { 'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end,
  },

  { 'junegunn/vim-easy-align',
    config = function()
      vim.keymap.set({ 'x', 'n' }, 'ga', '<Plug>(EasyAlign)')
      vim.g.easy_align_delimiters = {
        [';'] = { pattern = ';', left_margin = 0 },
        ['['] = { pattern = '[', left_margin = 1, right_margin = 0 },
        [']'] = { pattern = ']', left_margin = 0, right_margin = 1 },
        [','] = { pattern = ',', left_margin = 0, right_margin = 1 },
        [')'] = { pattern = ')', left_margin = 0, right_margin = 0 },
        ['('] = { pattern = '(', left_margin = 0, right_margin = 0 },
        ['='] = { pattern = [[<\?=>\?]], left_margin = 1, right_margin = 1 },
        ['|'] = { pattern = [[|\?|]], left_margin = 1, right_margin = 1 },
        ['&'] = { pattern = [[&\?&]], left_margin = 1, right_margin = 1 },
        [':'] = { pattern = ':', left_margin = 1, right_margin = 1 },
        ['?'] = { pattern = '?', left_margin = 1, right_margin = 1 },
        ['<'] = { pattern = '<', left_margin = 1, right_margin = 0 },
        ['>'] = { pattern = '>', left_margin = 1, right_margin = 0 },
        ['\\'] = { pattern = '\\', left_margin = 1, right_margin = 0 },
        ['+'] = { pattern = '+', left_margin = 1, right_margin = 1 },
      }
    end,
  },

  'inkarkat/vim-visualrepeat',

  'scalameta/nvim-metals',

  { 'mfussenegger/nvim-dap',
    cond = event('LspAttach'),
    config = 'lewis6991.dap'
  },

  { 'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio'
    },
  },

  { 'mfussenegger/nvim-lint', config = 'lewis6991.nvim-lint' },

  -- nvim-cmp sources require nvim-cmp since they depend on it in there plugin/
  -- files

  { 'hrsh7th/cmp-nvim-lsp-signature-help', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-buffer'    , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-emoji'     , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-path'      , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lua'  , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'lukas-reineke/cmp-rg'  , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'f3fora/cmp-spell'      , cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },
  { 'andersevenrud/cmp-tmux', cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' },

  { 'zbirenbaum/copilot-cmp',
    requires = 'zbirenbaum/copilot.lua',
    config = function ()
      vim.api.nvim_create_autocmd('InsertEnter', {
        once = true,
        callback = function()
          require('copilot').setup()
          require('copilot_cmp').setup()
        end})
    end,
  },

  { 'hrsh7th/nvim-cmp',
    requires = {
      'zbirenbaum/copilot-cmp',
      -- TODO(lewis6991): optimize requires in cmp_nvim_lsp/init.lua
      'hrsh7th/cmp-nvim-lsp',
    },
    config = 'lewis6991.cmp',
  },

  { 'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup({
        input = {
          mappings = {
            i = {
              ['<C-a>'] = '<HOME>',
              ['<C-e>'] = '<END>',
              ['<C-d>'] = '<DEL>',
            },
          },
        },
      })
    end,
  },

  { 'nvim-lua/telescope.nvim',
    requires = {
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      'nvim-lua/plenary.nvim',
    },
    config = 'lewis6991.telescope',
  },

  { 'neovim/nvimdev.nvim',
    config = function()
      vim.g.nvimdev_auto_init = 0
    end,
  },

  { 'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    config_pre = function()
      vim.g.loaded_nvim_treesitter = 1
    end
  },

  { 'lewis6991/ts-install.nvim',
    requires = 'nvim-treesitter/nvim-treesitter',
    run = ':TS update',
    config = function()
      require('ts-install').setup({
        auto_install = true,
        ignore_install = {
          'verilog',
          'tcl',
        },
      })
    end,
  },

  -- TODO(lewis6991): optimize this plugin
  { 'uga-rosa/translate.nvim', cond = event('CmdlineEnter') },

  { 'nvim-treesitter/nvim-treesitter-context',
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('treesitter-context').setup({
        max_lines = 5,
        trim_scope = 'outer',
      })
    end,
  },

})
