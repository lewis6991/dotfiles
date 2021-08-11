local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
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

vim.cmd[[augroup plugins | autocmd! | augroup END]]

-- Reload plugins.lua
vim.cmd[[autocmd plugins BufWritePost plugins.lua lua package.loaded["lewis6991.plugins"] = nil; require("lewis6991.plugins")]]

-- Recompile lazy loaders
vim.cmd[[autocmd plugins BufWritePost plugins.lua PackerCompile]]

-- -- Reload lazy loaders
-- vim.cmd[[autocmd BufWritePost plugins.lua runtime plugin/packer_compiled.vim]]


local init = {
  'wbthomason/packer.nvim',

  'lewis6991/github_dark.nvim',

  {'justinmk/vim-dirvish', config = "require'lewis6991.dirvish'"},

  'tpope/vim-commentary',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',

  {'tpope/vim-fugitive', cmd = {'Git', 'Gblame'} },

  {'AndrewRadev/bufferize.vim',
    cmd = 'Bufferize',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.cmd('autocmd vimrc FileType bufferize setlocal wrap')
    end
  },

  'vim-scripts/visualrepeat',
  'timakro/vim-searchant', -- Highlight the current search result
  {'folke/trouble.nvim', config = [[require('trouble').setup()]]},

  --- Filetype plugins ---
  {'tmux-plugins/vim-tmux', ft = 'tmux'  },
  {'derekwyatt/vim-scala' , ft = 'scala' },
  {'cespare/vim-toml'     },
  {'zinit-zsh/zinit-vim-syntax', ft = 'zsh'},
  'martinda/Jenkinsfile-vim-syntax',
  'teal-language/vim-teal',

  'tmhedberg/SimpylFold',

  {'lewis6991/foldsigns.nvim',
    config = function()
      require'foldsigns'.setup{
        exclude = {'GitSigns.*'}
      }
    end
  },

  'dietsche/vim-lastplace',

  'christoomey/vim-tmux-navigator',

  'ryanoasis/vim-devicons',
  'powerman/vim-plugin-AnsiEsc',

  {'neapel/vim-bnfc-syntax',
    config = function()
      -- Argh, why don't syntax plugins ever set commentstring!
      vim.cmd[[autocmd vimrc FileType bnfc setlocal commentstring=--%s]]
      -- This syntax works pretty well for regular BNF too
      vim.cmd[[autocmd vimrc BufNewFile,BufRead *.bnf setlocal filetype=bnfc]]
    end
  },

  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',

  {'whatyouhide/vim-lengthmatters', config = function()
    vim.g.lengthmatters_highlight_one_column = 1
  end},

  'rhysd/conflict-marker.vim',

  {'lewis6991/spaceless.nvim', config = [[require('spaceless').setup()]]},

  'bogado/file-line', -- Open file:line

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

  {'scalameta/nvim-metals',
    config = function()
      _G.setup_metals = function()
        require("metals").initialize_or_attach {
          init_options = {
            statusBarProvider = 'on'
          },
          settings = {
            showImplicitArguments = true,
          },
          on_attach = function()
            local function keymap(key, result)
              vim.api.nvim_buf_set_keymap(0, 'n', key, result, {noremap = true, silent = true})
            end
            keymap('<C-]>'     , '<cmd>lua vim.lsp.buf.definition()<CR>')
            keymap('K'         , '<cmd>lua vim.lsp.buf.hover()<CR>')
            keymap('gK'        , '<cmd>lua vim.lsp.buf.signature_help()<CR>')
            keymap('gr'        , '<cmd>lua vim.lsp.buf.references()<CR>')
            keymap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
            keymap(']d'        , '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
            keymap('[d'        , '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
            keymap('go'        , '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')

            vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
          end
        }
      end

      vim.cmd('augroup metals_lsp')
      vim.cmd('au!')
      vim.cmd('au FileType scala,sbt lua setup_metals()')
      vim.cmd('augroup end')
    end
  },

  'simrat39/symbols-outline.nvim',

  {'neovim/nvim-lspconfig',
    requires = {'tjdevries/nlua.nvim'},
    config = "require'lewis6991.lsp'"
  },

  {'jose-elias-alvarez/null-ls.nvim',
    config = [[require('lewis6991.null-ls')]]
  },

  {'hrsh7th/nvim-compe',
    requires = {'andersevenrud/compe-tmux'},
    config = [[require('lewis6991.compe')]]
  },

  {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  {'nvim-lua/telescope.nvim',
    requires = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim'
    },
    config = "require'lewis6991.telescope'"
  },

  {'lewis6991/cleanfold.nvim', config = "require('cleanfold').setup()" },

  'whiteinge/diffconflicts',

  {'dstein64/nvim-scrollview', config = function()
    vim.g.scrollview_current_only = 1
    vim.g.scrollview_column = 1
  end},

  {'pwntester/octo.nvim', config=function()
    require"octo".setup()
  end},

  -- 'mhinz/vim-signify',
  -- 'airblade/vim-gitgutter',
  {'~/projects/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.cmd[[cabbrev G Gitsigns]]
      vim.api.nvim_set_keymap('n', 'm', ':Gitsigns dump_cache<cr>'    , {silent=true})
      vim.api.nvim_set_keymap('n', 'M', ':Gitsigns debug_messages<cr>', {silent=true})
      require('gitsigns').setup{
        -- debug_mode = true,
        signs = {
          add          = {text= '┃', hl = 'GitGutterAdd'   },
          change       = {text= '┃', hl = 'GitGutterChange'},
          delete       = {text= '_', hl = 'GitGutterDelete'},
          topdelete    = {text= '‾', hl = 'GitGutterDelete'},
          changedelete = {text= '≃', hl = 'GitGutterChange'},
        }
      }
    end
  },

  {'~/projects/spellsitter.nvim', config = [[require('spellsitter').setup()]] },

  {'norcalli/nvim-colorizer.lua', config = [[require('colorizer').setup()]] },

  {'nvim-treesitter/nvim-treesitter',
    requires = {
      'romgrk/nvim-treesitter-context',
      'nvim-treesitter/playground',
    },
    run = ':TSUpdate',
    config = "require'lewis6991.treesitter'",
  },

  'euclidianAce/BetterLua.vim',

  {'romgrk/barbar.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      vim.g.bufferline = vim.tbl_extend('force', vim.g.bufferline or {}, {
        closable = false
      })
      vim.api.nvim_set_keymap('n', '<Tab>'  , ':BufferNext<CR>'    , {silent=true})
      vim.api.nvim_set_keymap('n', '<S-Tab>', ':BufferPrevious<CR>', {silent=true})
    end
  }

}

local packer = require('packer')

packer.startup{init,
  config = {
    -- profile = {
    --   enable = false,
    --   threshold = 1
    -- },
    display = {
      open_cmd = 'vnew \\[packer\\]',
      prompt_border = 'rounded'
    }
  }
}

return packer
