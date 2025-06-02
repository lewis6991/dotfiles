--- @diagnostic disable: missing-fields

local manager = require('lewis6991.package_manager')
manager.bootstrap()

local p = manager.add

local event = require('pckr.loader.event')

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
-- p('lewis6991/brodir.nvim')
p('lewis6991/fileline.nvim')
p('lewis6991/satellite.nvim')

-- p('yetone/avante.nvim', {
--   run = 'make',
--   cond = event('CursorMoved'),
--   config = function()
--     require('avante_lib').load()
--     require('avante').setup({
--       provider = 'copilot',
--       hints = {
--         enabled = false,
--       },
--       windows = {
--         ask = {
--           floating = true, -- Open the 'AvanteAsk' prompt in a floating window
--         },
--       },
--     })
--   end,
--   requires = {
--     'nvim-lua/plenary.nvim',
--     'MunifTanjim/nui.nvim',
--     --- optional,
--     'zbirenbaum/copilot.lua', -- for providers='copilot'
--   },
-- })

p('olimorris/codecompanion.nvim', {
  cond = event('CmdlineEnter'),
  config = function()
    require('codecompanion').setup({
      strategies = {
        chat = {
          adapter = 'copilot',
        },
        inline = {
          adapter = 'copilot',
        },
      },
    })

    local Spinner = { handles = {} }

    local function llm_role_title(adapter)
      local parts = {}
      table.insert(parts, adapter.formatted_name)
      if adapter.model and adapter.model ~= '' then
        table.insert(parts, '(' .. adapter.model .. ')')
      end
      return table.concat(parts, ' ')
    end

    local group = vim.api.nvim_create_augroup('CodeCompanionFidgetHooks', {})

    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = 'CodeCompanionRequestStarted',
      group = group,
      callback = function(request)
        local id = request.data.id
        local handle = require('fidget.progress').handle.create({
          title = (' Requesting assistance (%s)'):format(request.data.strategy),
          message = 'In progress...',
          lsp_client = {
            name = llm_role_title(request.data.adapter),
          },
        })
        Spinner.handles[id] = handle
      end,
    })

    vim.api.nvim_create_autocmd({ 'User' }, {
      pattern = 'CodeCompanionRequestFinished',
      group = group,
      callback = function(request)
        local id = request.data.id
        local handle = Spinner.handles[id]
        Spinner.handles[id] = nil
        if not handle then
          if request.data.status == 'success' then
            handle.message = 'Completed'
          elseif request.data.status == 'error' then
            handle.message = ' Error'
          else
            handle.message = '󰜺 Cancelled'
          end
          handle:finish()
        end
      end,
    })

    vim.keymap.set('n', '<leader>ae', function()
      vim.cmd.CodeCompanion()
    end, { desc = 'Code Companion' })
  end,
  requires = {
    'j-hui/fidget.nvim',
    'nvim-lua/plenary.nvim',
  },
})

p('MeanderingProgrammer/render-markdown.nvim', {
  cond = event('Filetype', 'Avante'),
  config = function()
    require('render-markdown').setup({
      file_types = { 'Avante' },
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

    vim.keymap.set('n', 'K', hover_action('hover'), { desc = 'hover.nvim' })

    vim.keymap.set('n', 'gK', hover_action('hover_select'), { desc = 'hover.nvim (select)' })

    vim.keymap.set('n', '<MouseMove>', hover_action('hover_mouse'), { desc = 'hover.nvim (mouse)' })

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
    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'trouble mappings',
      callback = function(args)
        vim.keymap.set('n', 'grr', '<cmd>Trouble lsp_references<cr>', { buffer = args.buf })
        vim.keymap.set('n', 'gd', '<cmd>Trouble diagnostics<cr>', { buffer = args.buf })
      end,
    })
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

p('rcarriga/nvim-notify', {
  config = function()
    --- @diagnostic disable-next-line
    vim.notify = function(...)
      vim.notify = require('notify')
      return vim.notify(...)
    end
  end,
})

p('j-hui/fidget.nvim', {
  cond = event('LspAttach'),
  config = function()
    require('fidget').setup({})
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
    'rcarriga/nvim-dap-ui',
  },
  cond = event('LspAttach'),
  config = 'lewis6991.dap',
})

p('rcarriga/nvim-dap-ui', { requires = { 'nvim-neotest/nvim-nio' } })

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
        break_line = {
          enabled = true,
        },
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

p('nvim-lua/telescope.nvim', {
  requires = {
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
  },
  config = 'lewis6991.telescope',
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

-- TODO(lewis6991): optimize this plugin
-- { 'uga-rosa/translate.nvim', cond = event('CmdlineEnter') },

p('nvim-treesitter/nvim-treesitter-context', {
  requires = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('treesitter-context').setup({
      max_lines = 5,
      trim_scope = 'outer',
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
      },
    })
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
})

manager.setup()
