local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  if vim.fn.input("Download Packer? (y for yes): ") ~= "y" then
    return
  end

  local directory = string.format(
    '%s/site/pack/packer/opt/',
    vim.fn.stdpath('data')
  )

  local out = vim.fn.system(string.format(
    'git clone %s %s',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  ))

  print(out)
  print("Downloading packer.nvim...")
end

execute 'packadd packer.nvim'

local init = {
  {'wbthomason/packer.nvim', opt = true},

  {'tpope/vim-commentary', keys = {'gc'}},
  'tpope/vim-fugitive',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',

  {'AndrewRadev/bufferize.vim',
    cmd = 'Bufferize',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.cmd('autocmd vimrc FileType bufferize setlocal wrap')
    end
  },

  'vim-scripts/visualrepeat',
  'timakro/vim-searchant', -- Highlight the current search result

  {'tmhedberg/SimpylFold' , disable=true, ft = 'python'},
  {'tmux-plugins/vim-tmux', ft = 'tmux'  },
  {'derekwyatt/vim-scala' , ft = 'scala' },

  'martinda/Jenkinsfile-vim-syntax',

  {'ap/vim-buftabline', disable=true},

  'dietsche/vim-lastplace',
  'christoomey/vim-tmux-navigator',
  'tmux-plugins/vim-tmux-focus-events',
  'ryanoasis/vim-devicons',
  'powerman/vim-plugin-AnsiEsc',

  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',

  {'whatyouhide/vim-lengthmatters',
    config = function()
      vim.g.lengthmatters_highlight_one_column = 1
    end
  },

  'justinmk/vim-dirvish',

  'lewis6991/vim-clean-fold',

  'rhysd/conflict-marker.vim',

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
        ['\\'] = { pattern = '\\'       , left_margin = 1, right_margin = 0 },
        ['+']  = { pattern = '+'        , left_margin = 1, right_margin = 1 }
      }
    end
  },

  {'bfredl/nvim-miniyank',
    config = function()
      vim.api.nvim_set_keymap('n', 'p', '<Plug>(miniyank-autoput)', {})
      vim.api.nvim_set_keymap('n', 'P', '<Plug>(miniyank-autoPut)', {})
    end
  },

  'tjdevries/nlua.nvim',

  {'neovim/nvim-lspconfig',
    config = "require('lsp')"
  },

  'nvim-lua/completion-nvim',

  {'nvim-lua/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = "require('telescope_config')"
  },

  'scalameta/nvim-metals',

  'nvim-lua/popup.nvim',
  'kyazdani42/nvim-web-devicons',

  {'~/projects/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup{
          -- debug_mode = true,
          signs = {
            add          = {hl = 'GitGutterAdd'   },
            change       = {hl = 'GitGutterChange'},
            delete       = {hl = 'GitGutterDelete'},
            topdelete    = {hl = 'GitGutterDelete'},
            changedelete = {hl = 'GitGutterChange'},
          },
        }
    end
  },

  {'nvim-treesitter/nvim-treesitter',
    config = "require('treesitter')",
  },

  'romgrk/nvim-treesitter-context',

  {'romgrk/barbar.nvim',
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

packer.startup{init}

return packer
