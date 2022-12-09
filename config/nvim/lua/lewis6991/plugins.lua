local function keys(k)
  return function(load_plugin)
    vim.keymap.set('n', k, function()
      vim.keymap.del('n', k)
      load_plugin()
      vim.api.nvim_input(k)
    end, {
        desc  = 'cond lazy_loader'
      })
  end
end

vim.opt.rtp:prepend('~/projects/packer.nvim')

require('lewis6991.packer').setup {
  -- 'lewis6991/moonlight.vim',
  {'lewis6991/github_dark.nvim', config = function()
    vim.cmd.color'github_dark'
  end},

  -- 'lewis6991/tcl.vim',
  'lewis6991/tree-sitter-tcl',
  -- 'lewis6991/systemverilog.vim',
  {'lewis6991/impatient.nvim', start = true},
  {'lewis6991/spaceless.nvim', config = [[require('spaceless').setup()]]},
  {'lewis6991/cleanfold.nvim'},
  {'lewis6991/brodir.nvim', keys = '-', cmd = 'Brodir'},
  'lewis6991/vc.nvim',

  {'lewis6991/foldsigns.nvim',
    config = function()
      require'foldsigns'.setup{
        exclude = {'GitSigns.*'}
      }
    end
  },

  {'lewis6991/hover.nvim',
    config = function()
      require('hover').setup{
        init = function()
          require('hover.providers.lsp')
          require('hover.providers.gh')
          require('hover.providers.gh_user')
          require('hover.providers.dictionary')
          require('hover.providers.man')
        end
      }
      vim.keymap.set('n', 'K', require('hover').hover, {desc='hover.nvim'})
      vim.keymap.set('n', 'gK', require('hover').hover_select, {desc='hover.nvim (select)'})
    end
  },

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

  {'folke/trouble.nvim', cmd = 'Trouble' },

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
    vim.notify = function(...)
      vim.notify = require("notify")
      return vim.notify(...)
    end
  end},

  {'dstein64/vim-startuptime', cmd = 'StartupTime'},

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

  {'whatyouhide/vim-lengthmatters', config_pre = function()
    vim.g.lengthmatters_highlight_one_column = 1
    vim.g.lengthmatters_excluded = {'packer'}
  end},

  {'junegunn/vim-easy-align',
    cond = keys('ga'),
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

  {"SmiteshP/nvim-navic", config = function()
    local autocmd = require 'lewis6991.nvim'.autocmd
    autocmd 'LspAttach' {
      desc = 'navic',
      function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        if client.server_capabilities.documentSymbolProvider then
          local navic = require("nvim-navic")
          navic.setup{ highlight = true }

          if vim.o.winbar == '' then
            vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
          end
          navic.attach(client, bufnr)
        end
      end
    }

    for k, v in pairs{
      NavicIconsModule    = '@namespace',
      NavicIconsNamespace = '@namespace',
      NavicIconsPackage   = '@namespace',
      NavicIconsClass     = '@namespace',
      NavicIconsMethod    = '@method',
      NavicIconsField     = '@field',
      NavicIconsFunction  = '@function',
      NavicIconsVariable  = '@variable',
      NavicIconsString    = '@string',
      NavicText           = 'TabLineFill',
    } do
      vim.api.nvim_set_hl(0, k, {default = true, link = v})
    end
    -- NavicIconsFile
    -- NavicIconsProperty
    -- NavicIconsConstructor
    -- NavicIconsEnum
    -- NavicIconsInterface
    -- NavicIconsConstant
    -- NavicIconsNumber
    -- NavicIconsBoolean
    -- NavicIconsArray
    -- NavicIconsObject
    -- NavicIconsKey
    -- NavicIconsNull
    -- NavicIconsEnumMember
    -- NavicIconsStruct
    -- NavicIconsEvent
    -- NavicIconsOperator
    -- NavicIconsTypeParameter
    -- NavicSeparator
  end},

  {'theHamsta/nvim-semantic-tokens', config = function()
    local autocmd = require 'lewis6991.nvim'.autocmd

    autocmd 'LspAttach' {
      desc = 'semantic_tokens setup',
      once = true,
      function()
        require("nvim-semantic-tokens").setup {
          preset = "default",
          -- highlighters is a list of modules following the interface of nvim-semantic-tokens.table-highlighter or
          -- function with the signature: highlight_token(ctx, token, highlight) where
          --        ctx (as defined in :h lsp-handler)
          --        token  (as defined in :h vim.lsp.semantic_tokens.on_full())
          --        highlight (a helper function that you can call (also multiple times) with the determined highlight group(s) as the only parameter)
          highlighters = { require 'nvim-semantic-tokens.table-highlighter'}
        }
        vim.api.nvim_create_augroup('SemanticTokens', {})
      end
    }

    autocmd 'LspAttach' {
      desc = 'semantic_tokens attach',
      function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        local caps = client.server_capabilities
        if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
          autocmd 'TextChanged' {
            group = 'SemanticTokens',
            buffer = bufnr,
            function()
              vim.lsp.buf.semantic_tokens_full()
            end,
          }
          -- fire it first time on load as well
          vim.lsp.buf.semantic_tokens_full()
        end
      end
    }
  end},

  {'ray-x/lsp_signature.nvim', config = function()
    require'lsp_signature'.setup{ hi_parameter = "Visual" }
  end},

  {'stevearc/aerial.nvim', config = function()
    require('aerial').setup()

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>', { buffer = args.buf})
      end
    })
  end},

  {'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  {'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup{}
    end,
    requires = {
      'williamboman/mason.nvim',
    }
  },

  {'scalameta/nvim-metals', config = function()
    local function setup_metals()
      local metals = require'metals'

      metals.initialize_or_attach(vim.tbl_deep_extend('force', metals.bare_config(), {
        handlers = {
          ["metals/status"] = function(_, status, ctx)
            vim.lsp.handlers["$/progress"](_, {
              token = 1,
              value = {
                kind = status.show and 'begin' or status.hide and 'end' or "report",
                message = status.text,
              }
            }, ctx)
          end
        },

        init_options = {
          statusBarProvider = 'on'
        },
        settings = {
          showImplicitArguments = true,
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      }))
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = {'scala', 'sbt'},
      callback = setup_metals
    })
  end,
    requires = {
      'hrsh7th/cmp-nvim-lsp',
    }
  },

  {'neovim/nvim-lspconfig',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
    config = function()
      local function setup(server, settings)
        require'lspconfig'[server].setup{
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          settings = settings
        }
      end

      require("neodev").setup{
        library = {
          plugins = false, -- installed opt or start plugins in packpath
        },
      }

      setup('clangd')
      setup('cmake')
      setup('sumneko_lua', {
        Lua = {
          diagnostics = {
            groupSeverity = {
              strong = 'Warning',
              strict = 'Warning',
            },
            groupFileStatus = {
              ["ambiguity"]  = "Opened",
              ["await"]      = "Opened",
              ["codestyle"]  = "None",
              ["duplicate"]  = "Opened",
              ["global"]     = "Opened",
              ["luadoc"]     = "Opened",
              ["redefined"]  = "Opened",
              ["strict"]     = "Opened",
              ["strong"]     = "Opened",
              ["type-check"] = "Opened",
              ["unbalanced"] = "Opened",
              ["unused"]     = "Opened",
            },
            unusedLocalExclude = { '_*' },
            globals = {
              'it',
              'describe',
              'before_each',
              'after_each',
              'pending'
            }
          },
        }
      })
      setup('pyright')
      setup('bashls')
      setup('teal_ls')
    end,
  },

  {'rmagatti/goto-preview',
    keys = 'gp',
    config = function()
      require('goto-preview').setup {
        opacity = 0,
        height = 30
      }
      vim.keymap.set('n', 'gp', require('goto-preview').goto_preview_definition)
    end
  },

  {'jose-elias-alvarez/null-ls.nvim', config = [[require('lewis6991.null-ls')]]},

  -- nvim-cmp sources require nvim-cmp since they depend on it in there plugin/
  -- files
  {'hrsh7th/cmp-nvim-lsp'               , requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-nvim-lsp-signature-help', requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-buffer'                 , requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-emoji'                  , requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-path'                   , requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-nvim-lua'               , requires = 'hrsh7th/nvim-cmp' },
  {'hrsh7th/cmp-cmdline'                , requires = 'hrsh7th/nvim-cmp' },
  {'lukas-reineke/cmp-rg'               , requires = 'hrsh7th/nvim-cmp' },
  {'f3fora/cmp-spell'                   , requires = 'hrsh7th/nvim-cmp' },
  {'andersevenrud/cmp-tmux'             , requires = 'hrsh7th/nvim-cmp' },
  -- {'saadparwaiz1/cmp_luasnip'           , requires = 'hrsh7th/nvim-cmp' },

  {'hrsh7th/nvim-cmp',
    -- event = {'InsertEnter', 'CmdlineEnter'},
    requires = {
      -- {'L3MON4D3/LuaSnip', event = 'InsertEnter'},
      {'L3MON4D3/LuaSnip' },
      -- 'dmitmel/cmp-cmdline-history',
      -- 'ray-x/cmp-treesitter',
      'nvim-lua/plenary.nvim'
    },
    config = [[require('lewis6991.cmp')]]
  },

  {'nvim-lua/telescope.nvim',

    -- For packer dev, not actually necessary
    cmd = 'Telescope',
    keys = {
      {'n', '<C-p>'},
      {'n', '<C- >'},
    },

    requires = {
      {'nvim-telescope/telescope-ui-select.nvim' },
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      'nvim-lua/plenary.nvim'
    },
    config = "require'lewis6991.telescope'"
  },

  {'neovim/nvimdev.nvim', config = function()
    vim.g.nvimdev_auto_init = 0
  end},

  {'nvim-treesitter/nvim-treesitter',
    start = true,
    requires = {
      'nvim-treesitter/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/playground',
    },
    run = ':TSUpdate',
    config = "require'lewis6991.treesitter'",
  },

  -- For testin packer. I don't use these
  { 'folke/noice.nvim', requires = 'MunifTanjim/nui.nvim' },
}
