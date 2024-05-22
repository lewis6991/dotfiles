require('lewis6991.package_manager').setup({

  --- Filetype plugins ---
  'martinda/Jenkinsfile-vim-syntax',
  'lewis6991/vc.nvim',
  'lewis6991/tree-sitter-tcl',

  {
    'lewis6991/github_dark.nvim',
    config = function()
      vim.cmd.color('github_dark')
    end,
  },

  'lewis6991/nvim-treesitter-pairs',
  'lewis6991/spaceless.nvim',
  'lewis6991/brodir.nvim',
  'lewis6991/fileline.nvim',
  'lewis6991/satellite.nvim',

  {
    'lewis6991/whatthejump.nvim',
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

  {
    'lewis6991/hover.nvim',
    config = function()
      require('hover').setup({
        init = function()
          require('hover.providers.lsp')
          require('hover.providers.gh')
          require('hover.providers.gh_user')
          require('hover.providers.dictionary')
          require('hover.providers.man')
        end,
      })
      vim.keymap.set('n', 'K', require('hover').hover, { desc = 'hover.nvim' })
      vim.keymap.set('n', 'gK', require('hover').hover_select, { desc = 'hover.nvim (select)' })

      vim.keymap.set(
        'n',
        '<MouseMove>',
        require('hover').hover_mouse,
        { desc = 'hover.nvim (mouse)' }
      )
      vim.o.mousemoveevent = true
    end,
  },

  { 'lewis6991/gitsigns.nvim', config = 'lewis6991.gitsigns' },

  'lewis6991/nvim-colorizer.lua',

  {
    'lewis6991/tmux.nvim',
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
  'michaeljsmith/vim-indent-object',
  { 'sindrets/diffview.nvim', requires = { 'nvim-lua/plenary.nvim' } },
  'folke/trouble.nvim',
  'dstein64/vim-startuptime',

  {
    'AndrewRadev/bufferize.vim',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'bufferize',
        command = 'setlocal wrap',
      })
    end,
  },

  -- { "vigoux/notifier.nvim", config = function()
  --   require'notifier'.setup()
  -- end },

  {
    'rcarriga/nvim-notify',
    config = function()
      --- @diagnostic disable-next-line
      vim.notify = function(...)
        vim.notify = require('notify')
        return vim.notify(...)
      end
    end,
  },

  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    config = function()
      require('fidget').setup({
        text = {
          spinner = 'dots',
        },
        fmt = {
          stack_upwards = false,
          task = function(task_name, message, percentage)
            local pct = percentage and string.format(' (%s%%)', percentage) or ''
            if task_name then
              return string.format('%s%s [%s]', message, pct, task_name)
            else
              return string.format('%s%s', message, pct)
            end
          end,
        },
      })
    end,
  },

  {
    'neapel/vim-bnfc-syntax',
    config = function()
      -- Argh, why don't syntax plugins ever set commentstring!
      vim.cmd([[autocmd FileType bnfc setlocal commentstring=--%s]])
      -- This syntax works pretty well for regular BNF too
      vim.cmd([[autocmd BufNewFile,BufRead *.bnf setlocal filetype=bnfc]])
    end,
  },

  {
    'junegunn/vim-easy-align',
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

  -- {'ray-x/lsp_signature.nvim', config = function()
  --   require'lsp_signature'.setup{ hi_parameter = "Visual" }
  -- end},

  'inkarkat/vim-visualrepeat',

  {
    'scalameta/nvim-metals',
    config = 'lewis6991.metals',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
    },
  },

  { 'mfussenegger/nvim-lint', config = 'lewis6991.nvim-lint' },

  -- nvim-cmp sources require nvim-cmp since they depend on it in there plugin/
  -- files
  { 'hrsh7th/cmp-nvim-lsp', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp-signature-help', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-buffer', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-emoji', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-path', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lua', requires = 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-cmdline', requires = 'hrsh7th/nvim-cmp' },
  { 'lukas-reineke/cmp-rg', requires = 'hrsh7th/nvim-cmp' },
  { 'f3fora/cmp-spell', requires = 'hrsh7th/nvim-cmp' },
  { 'andersevenrud/cmp-tmux', requires = 'hrsh7th/nvim-cmp' },

  { 'hrsh7th/nvim-cmp', config = 'lewis6991.cmp' },

  {
    'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup({
        input = {
          mappings = {
            i = {
              ['<C-a>'] = '<HOME>',
              ['<C-e>'] = '<END>',
            },
          },
        },
      })
    end,
  },

  {
    'nvim-lua/telescope.nvim',
    requires = {
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      'nvim-lua/plenary.nvim',
    },
    config = 'lewis6991.telescope',
  },

  {
    'neovim/nvimdev.nvim',
    config = function()
      vim.g.nvimdev_auto_init = 0
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    run = ':TSUpdate',
    config = function()
      require('lewis6991.nvim-treesitter')
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    requires = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('treesitter-context').setup({
        max_lines = 5,
        trim_scope = 'outer',
      })
    end,
  },
})
