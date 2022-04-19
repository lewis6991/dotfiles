
local telescope = require 'telescope'

telescope.setup {
  defaults = {
    preview = false,
    layout_config = {
      preview_cutoff = 20,
    },
    selection_strategy = "reset",
    winblend = 15,
    mappings = {
      i = {
        ["<CR>"] =  require('telescope.actions').select_tab,
        ["<esc>"] = require('telescope.actions').close,
      }
    }
  },
  extensions = {
    fzf = {
      override_generic_sorter = false, -- Causes crashes
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown{}
    }
  }
}
telescope.load_extension('fzf')
telescope.load_extension('ui-select')

local keymap = function(key, fun, opts)
  vim.api.nvim_set_keymap('n', key, '', {
    desc = 'Telescope '..fun..vim.inspect(opts or '', {newline='', indent=''}),
    callback = function()
      require('telescope.builtin')[fun](opts)
    end,
    noremap = true,
    silent = true,
  })
end

-- default: CTRL-B   scroll N screens Backwards
keymap('<C-b>'    , 'buffers')

-- default:  CTRL-P same as "k"
keymap('<C-p>'    , 'git_files', {use_git_root=true})

-- default: none
keymap('<C- >'    , 'git_files', {preview=true, cwd="$HOME/projects/dotfiles", hidden=true})

keymap('<leader>f', 'find_files')
keymap('<leader>g', 'live_grep', {preview=true})
