-- On ly required if you have packer in your `opt` pack
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
  if vim.fn.input("Download Packer? (y for yes)") ~= "y" then
    return
  end

  local directory = string.format(
    '%s/site/pack/packer/opt/',
    vim.fn.stdpath('data')
  )

  vim.fn.mkdir(directory, 'p')

  local out = vim.fn.system(string.format(
    'git clone %s %s',
    'https://github.com/wbthomason/packer.nvim',
    directory .. '/packer.nvim'
  ))

  print(out)
  print("Downloading packer.nvim...")

  return
end

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-commentary'

  use 'tpope/vim-fugitive'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-repeat'
  use 'tpope/vim-eunuch'
  use 'tpope/vim-surround'

  use 'AndrewRadev/bufferize.vim'

  use 'vim-scripts/visualrepeat'
  use 'timakro/vim-searchant' -- Highlight the current search result

  use  {'tmhedberg/SimpylFold' , ft = 'python'}
  use  {'tmux-plugins/vim-tmux', ft = 'tmux'  }
  use  {'derekwyatt/vim-scala' , ft = 'scala' }

  use 'martinda/Jenkinsfile-vim-syntax'

  use 'ap/vim-buftabline'

  use 'dietsche/vim-lastplace'
  use 'christoomey/vim-tmux-navigator'
  use 'tmux-plugins/vim-tmux-focus-events'
  use 'ryanoasis/vim-devicons'
  use 'powerman/vim-plugin-AnsiEsc'

  use 'wellle/targets.vim'
  use 'michaeljsmith/vim-indent-object'

  use 'whatyouhide/vim-lengthmatters'
  vim.g.lengthmatters_highlight_one_column = 1

  use 'justinmk/vim-dirvish'

  use 'lewis6991/vim-clean-fold'

  use 'rhysd/conflict-marker.vim'

  use {'junegunn/vim-easy-align',
    keys = '<Plug>(EasyAlign)',
    config = {
      vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {});
      vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {});
     }
  }
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
  };

  use {'bfredl/nvim-miniyank',
    config = {
      vim.api.nvim_set_keymap('n', 'p', '<Plug>(miniyank-autoput)', {});
      vim.api.nvim_set_keymap('n', 'P', '<Plug>(miniyank-autoPut)', {});
    }
  }

  use 'tjdevries/nlua.nvim'
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/completion-nvim'
  use 'nvim-lua/diagnostic-nvim'
  use 'nvim-lua/telescope.nvim'
  use 'scalameta/nvim-metals'

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'kyazdani42/nvim-web-devicons'

  use 'nvim-treesitter/nvim-treesitter'
end)