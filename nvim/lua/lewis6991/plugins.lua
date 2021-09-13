local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if not vim.loop.fs_stat(install_path) then
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

local init = {
  'wbthomason/packer.nvim',

  'nanotee/luv-vimdocs',
  'wsdjeg/luarefvim',

  'lewis6991/github_dark.nvim',

  {'justinmk/vim-dirvish', config = "require'lewis6991.dirvish'"},

  'tpope/vim-commentary',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'tpope/vim-eunuch',
  'tpope/vim-surround',
  'tpope/vim-fugitive',

  {'AndrewRadev/bufferize.vim',
    cmd = 'Bufferize',
    config = function()
      vim.g.bufferize_command = 'enew'
      vim.cmd('autocmd vimrc FileType bufferize setlocal wrap')
    end
  },

  'vim-scripts/visualrepeat',

  -- Highlight the current search result
  -- 'timakro/vim-searchant',
  {'PeterRincker/vim-searchlight', config = function()
    vim.cmd[[highlight default link Searchlight SearchCurrent]]
  end},

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

  'simrat39/symbols-outline.nvim',

  {'neovim/nvim-lspconfig',
    requires = {
      'kabouzeid/nvim-lspinstall',
      'scalameta/nvim-metals',
    },
    config = "require'lewis6991.lsp'"
  },

  {'jose-elias-alvarez/null-ls.nvim',
    config = [[require('lewis6991.null-ls')]]
  },

  {'hrsh7th/nvim-cmp',
    event = "InsertEnter *",
    requires = {
      'onsails/lspkind-nvim',
      { 'hrsh7th/cmp-nvim-lsp'    , after = "nvim-cmp" },
      { 'hrsh7th/cmp-buffer'      , after = "nvim-cmp" },
      { 'hrsh7th/cmp-path'        , after = "nvim-cmp" },
      { 'hrsh7th/cmp-nvim-lua'    , after = "nvim-cmp" },
      { 'andersevenrud/compe-tmux', after = "nvim-cmp", branch = 'cmp'},
      { "L3MON4D3/LuaSnip"        , after = "nvim-cmp", module_pattern = "^luasnip%.*" },
      { 'saadparwaiz1/cmp_luasnip', after = "nvim-cmp" },
    },
    config = [[require('lewis6991.cmp')]]
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

  {'pwntester/octo.nvim', config=function()
    require"octo".setup()
  end, keys = ':'},

  -- 'mhinz/vim-signify',
  -- 'airblade/vim-gitgutter',
  {'~/projects/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.cmd[[cabbrev g Gitsigns]]
      require('gitsigns').setup{
        debug_mode = true,
        signs = {
          add       = {text = '┃' },
          change    = {text = '┃' },
          delete    = {linehl = 'NormalNC'},
          topdelete = {linehl = 'NormalNC'},
        },
        keymaps = {
          -- Default keymap options
          noremap = true,

          ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
          ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

          ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
          ['v <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
          ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',
          ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
          ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
          ['v <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
          ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',
          ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
          ['n <leader>hb'] = '<cmd>Gitsigns blame_line true <CR>',
          ['n <leader>hB'] = '<cmd>Gitsigns toggle_current_line_blame<CR>',
          ['n <leader>hd'] = '<cmd>Gitsigns diffthis<CR>',
          ['n <leader>hD'] = '<cmd>Gitsigns diffthis ~<CR>',

          ['n m'] = '<cmd>Gitsigns dump_cache<CR>',
          ['n M'] = '<cmd>Gitsigns debug_messages<CR>',

          ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
          ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
        },
        preview_config = {
          border = 'rounded',
        },
        current_line_blame_formatter_opts = {
          relative_time = true
        },
        current_line_blame_opts = {
          delay = 200
        },
        count_chars = {'₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉', ['+']='₊'},
        _refresh_staged_on_update = false,
        word_diff = true,
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

  {'ojroques/vim-oscyank',
    event = 'TextYankPost',
    config = function()
      vim.g.oscyank_silent = true
      vim.cmd[[autocmd vimrc TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif]]
    end
  },

  {'folke/persistence.nvim',
    config = function()
      require('persistence').setup()

      -- restore the session for the current directory
      vim.api.nvim_set_keymap("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], {})

      -- restore the last session
      vim.api.nvim_set_keymap("n", "<leader>ql", [[<cmd>lua require("persistence").load({last=true})<cr>]], {})
    end,
  },

  {'romgrk/barbar.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      vim.g.bufferline = vim.tbl_extend('force', vim.g.bufferline or {}, {
        closable = false
      })
      vim.api.nvim_set_keymap('n', '<Tab>'  , ':BufferNext<CR>'    , {noremap=true,silent=true})
      vim.api.nvim_set_keymap('n', '<S-Tab>', ':BufferPrevious<CR>', {noremap=true,silent=true})
    end
  }

}

-- Hacky way of auto clean/install/compile
vim.cmd[[
  augroup plugins
  " Reload plugins.lua
  autocmd!
  autocmd BufWritePost plugins.lua lua package.loaded["lewis6991.plugins"] = nil; require("lewis6991.plugins")
  autocmd BufWritePost plugins.lua PackerClean
  augroup END
]]

local packer = require('packer')

local state = 1
local orig_complete = packer.on_complete
packer.on_complete = vim.schedule_wrap(function()
  if state == 1 then
    packer.install()
    state = state + 1
    return
  elseif state == 2 then
    packer.compile()
    state = state + 1
    return
  end
  packer.on_complete = orig_complete
end)

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

vim.api.nvim_set_keymap('n', '<leader>u', ':PackerUpdate<CR>', {noremap=true, silent=true})

return packer
