--- @diagnostic disable: missing-fields

local manager = require('lewis6991.package_manager')
manager.bootstrap()

local p = manager.add

local event = require('pckr.loader.event')

local function delayed(loader)
  vim.defer_fn(function()
    loader()
  end, 1000)
end

p('neovim/nvim-lspconfig')

--- Filetype plugins ---
p('martinda/Jenkinsfile-vim-syntax')
p('lewis6991/vc.nvim')
p('lewis6991/tree-sitter-tcl')

p('lewis6991/github_dark.nvim', {
  config = function()
    vim.cmd.color('github_dark')
  end,
})

p('lewis6991/nvim-treesitter-pairs')
p('lewis6991/spaceless.nvim')
p('lewis6991/fileline.nvim')
p('lewis6991/satellite.nvim')

p('olimorris/codecompanion.nvim', {
  cond = delayed,
  config = 'lewis6991.codecompanion',
  requires = {
    'j-hui/fidget.nvim',
    'nvim-lua/plenary.nvim',
  },
})

p('MeanderingProgrammer/render-markdown.nvim', {
  cond = delayed,
  config = function()
    require('render-markdown').setup({
      render_modes = true,
      file_types = { 'codecompanion' },
      heading = {
        backgrounds = { 'CursorLineNr' },
      },
      sign = { enabled = false },
      overrides = {
        filetype = {
          codecompanion = {
            html = {
              tag = {
                prompt = { icon = '> ' },
                buf = { icon = ' ', highlight = 'CodeCompanionChatIcon' },
                file = { icon = ' ', highlight = 'CodeCompanionChatIcon' },
                group = { icon = ' ', highlight = 'CodeCompanionChatIcon' },
                help = { icon = '󰘥 ', highlight = 'CodeCompanionChatIcon' },
                image = { icon = ' ', highlight = 'CodeCompanionChatIcon' },
                symbols = { icon = ' ', highlight = 'CodeCompanionChatIcon' },
                tool = { icon = '󰯠 ', highlight = 'CodeCompanionChatIcon' },
                url = { icon = '󰌹 ', highlight = 'CodeCompanionChatIcon' },
              },
            },
          },
        },
      },
    })
  end,
})

p('lewis6991/whatthejump.nvim', {
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
})

p('lewis6991/hover.nvim', {
  config = function()
    require('hover').config({
      providers = {
        'hover.providers.diagnostic',
        'hover.providers.dap',
        'hover.providers.lsp',
        'hover.providers.gh',
        'hover.providers.gh_user',
        'hover.providers.dictionary',
        'hover.providers.man',
      },
    })

    vim.keymap.set('n', 'K', function()
      require('hover').open()
    end, { desc = 'hover.nvim (open)' })

    vim.keymap.set('n', 'gK', function()
      require('hover').enter()
    end, { desc = 'hover.nvim (enter)' })

    vim.keymap.set('n', '<MouseMove>', function()
      require('hover').mouse()
    end, { desc = 'hover.nvim (mouse)' })

    vim.o.mousemoveevent = true
  end,
})

p('lewis6991/gitsigns.nvim', { config = 'lewis6991.gitsigns' })

p('lewis6991/nvim-colorizer.lua')

p('lewis6991/tmux.nvim', {
  config = function()
    require('tmux').setup({
      navigation = { enable_default_keybindings = true },
    })
  end,
})

p('tpope/vim-unimpaired')
p('tpope/vim-repeat')
p('tpope/vim-eunuch')
p('tpope/vim-surround')
p('tpope/vim-fugitive')
p('tpope/vim-sleuth')

p('nvim-tree/nvim-web-devicons')

p('wellle/targets.vim')
p('sindrets/diffview.nvim', { cond = event('CmdlineEnter') })
p('folke/trouble.nvim', {
  config = function()
    require('trouble').setup()
    vim.keymap.set('n', 'grr', '<cmd>Trouble lsp_references<cr>')
    vim.keymap.set('n', 'gd', '<cmd>Trouble diagnostics<cr>')
    vim.keymap.set('n', 'C-]', '<cmd>Trouble lsp_definitions<cr>')
  end,
})

p('AndrewRadev/bufferize.vim', {
  config = function()
    vim.g.bufferize_command = 'enew'
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'bufferize',
      command = 'setlocal wrap',
    })
  end,
})

-- p('rcarriga/nvim-notify', {
--   config = function()
--     --- @diagnostic disable-next-line
--     vim.notify = function(...)
--       vim.notify = require('notify')
--       return vim.notify(...)
--     end
--   end,
-- })

p('j-hui/fidget.nvim', {
  config = function()
    local done_setup = false
    local auid = vim.api.nvim_create_autocmd('LspAttach', {
      once = true,
      callback = function()
        require('fidget').setup({})
        done_setup = true
      end,
    })

    --- @diagnostic disable-next-line
    vim.notify = function(...)
      local fidget = require('fidget')
      if not done_setup then
        vim.api.nvim_del_autocmd(auid)
        fidget.setup({})
        done_setup = true
      end
      vim.notify = require('notify')
      return vim.notify(...)
    end
  end,
})

p('junegunn/vim-easy-align', {
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
})

p('scalameta/nvim-metals')

p('mfussenegger/nvim-dap', {
  requires = {
    'jbyuki/one-small-step-for-vimkind',
  },
  cond = event('LspAttach'),
  config = 'lewis6991.dap',
})

p('igorlfs/nvim-dap-view', {
  cond = event('LspAttach'),
  requires = 'mfussenegger/nvim-dap',
  config = function()
    local dap_view = require('dap-view')
    dap_view.setup({
      winbar = {
        sections = {
          'watches',
          'scopes',
          'exceptions',
          'breakpoints',
          'threads',
          'repl',
        },
        default_section = 'scopes',
        controls = {
          enabled = true,
        },
      },
      windows = {
        height = 0.4,
      },
      auto_toggle = true,
    })

    vim.keymap.set('n', '<leader>dw', function()
      dap_view.toggle()
    end)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'dap-view', 'dap-view-term' },
      callback = function()
        vim.wo.spell = false
      end,
    })
  end,
})

-- nvim-cmp sources require nvim-cmp since they depend on it in there plugin/
-- files

p('hrsh7th/cmp-nvim-lsp-signature-help', {
  cond = event('InsertEnter'),
  requires = 'hrsh7th/nvim-cmp',
})
p('hrsh7th/cmp-cmdline', { cond = event('CmdlineEnter'), requires = 'hrsh7th/nvim-cmp' })
p('hrsh7th/cmp-buffer', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('hrsh7th/cmp-emoji', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('hrsh7th/cmp-path', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('hrsh7th/cmp-nvim-lua', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('lukas-reineke/cmp-rg', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('f3fora/cmp-spell', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })
p('andersevenrud/cmp-tmux', { cond = event('InsertEnter'), requires = 'hrsh7th/nvim-cmp' })

p('zbirenbaum/copilot-cmp', {
  requires = 'zbirenbaum/copilot.lua',
  config = function()
    vim.api.nvim_create_autocmd('InsertEnter', {
      once = true,
      callback = function()
        require('copilot').setup()
        require('copilot_cmp').setup()
      end,
    })
  end,
})

p('rachartier/tiny-inline-diagnostic.nvim', {
  cond = event({ 'LspAttach', 'CursorMoved', 'BufWrite' }),
  config = function()
    require('tiny-inline-diagnostic').setup({
      options = {
        show_source = true,
        use_icons_from_diagnostic = true,
        multiple_diag_under_cursor = true,
        multilines = {
          enabled = true,
        },
        -- break_line = {
        --   enabled = true,
        --   after = 60,
        -- },
      },
    })
  end,
})

p('hrsh7th/nvim-cmp', {
  requires = {
    'zbirenbaum/copilot-cmp',
    -- TODO(lewis6991): optimize requires in cmp_nvim_lsp/init.lua
    'hrsh7th/cmp-nvim-lsp',
  },
  config = 'lewis6991.cmp',
})

p('stevearc/oil.nvim', {
  config = function()
    local done_setup = false
    vim.keymap.set('n', '-', function()
      if not done_setup then
        require('oil').setup({
          win_options = {
            number = false,
            relativenumber = false,
          },
          keymaps = {
            q = { 'actions.close', mode = 'n' },
            ['<Esc>'] = { 'actions.close', mode = 'n' },
            ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
            ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
            ['<C-t>'] = { 'actions.select', opts = { tab = true } },
          },
          float = {
            padding = 0,
            max_width = 0.3,
            win_options = {
              winblend = 20,
            },
            preview_split = 'below',
            override = function(conf)
              conf.col = 1000000
              return conf
            end,
          },
          view_options = {
            show_hidden = true,
          },
        })
      end
      done_setup = true
      require('oil').open_float()
    end)
  end,
})

p('folke/snacks.nvim', {
  config = function()
    require('snacks').setup({
      picker = { enabled = true },
    })

    vim.keymap.set('n', '<C-b>', function()
      require('snacks').picker.buffers()
    end, { desc = 'Snacks picker: buffers' })

    vim.api.nvim_set_hl(0, 'SnacksPickerDir', { link = 'LineNr' })

    vim.keymap.set('n', '<C-p>', function()
      require('snacks').picker.files({
        layout = { hidden = { 'preview' } },
      })
    end, { desc = 'Snacks picker: files' })

    vim.keymap.set('n', '<C-g>', function()
      require('snacks').picker.git_files({
        layout = { hidden = { 'preview' } },
      })
    end, { desc = 'Snacks picker: git files' })

    vim.keymap.set('n', '<C- >', function()
      require('snacks').picker.git_files({
        layout = { hidden = { 'preview' } },
        cwd = vim.env.HOME .. '/projects/dotfiles',
        untracked = true,
      })
    end, { desc = 'Snacks picker: git files' })

    vim.keymap.set('n', '<leader>g', function()
      require('snacks').picker.grep()
    end, { desc = 'Snacks picker: grep' })
  end,
})

p('neovim/nvimdev.nvim', {
  config = function()
    vim.g.nvimdev_auto_init = 0
  end,
})

p('nvim-treesitter/nvim-treesitter', {
  branch = 'main',
  config_pre = function()
    vim.g.loaded_nvim_treesitter = 1
  end,
})

p('lewis6991/ts-install.nvim', {
  requires = 'nvim-treesitter/nvim-treesitter',
  run = ':TS update',
  config = function()
    require('ts-install').setup({
      auto_install = true,
      ignore_install = {
        'verilog',
        'tcl',
        'tmux',
      },
      parsers = {
        zsh = {
          install_info = {
            url = 'https://github.com/tree-sitter-grammars/tree-sitter-zsh',
            branch = 'master',
          },
        },
      },
    })
  end,
})

p('nvim-treesitter/nvim-treesitter-context', {
  requires = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('treesitter-context').setup({
      max_lines = 5,
      trim_scope = 'outer',
      multiwindow = true,
    })
  end,
})

p('stevearc/conform.nvim', {
  config = function()
    require('conform').setup({
      default_format_opts = {
        lsp_format = 'first',
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' }, -- black
        rust = { 'rustfmt' },
        sh = { 'shfmt' },
      },
    })
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
})

manager.setup()
