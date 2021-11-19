
require'telescope'.setup {
  defaults = {
    layout_config = {
      preview_cutoff = 20,
    },
    selection_strategy = "reset",
    winblend = 25,
  },
  extensions = {
    fzf = {
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case"        -- or "ignore_case" or "respect_case"
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
      }
    }
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('ui-select')

local keymap = function(key, result)
  vim.api.nvim_set_keymap('n', key, result, {noremap = true, silent = true})
end

keymap('<C-p>'    , '<cmd>Telescope git_files<cr>')
keymap('<C- >'    , [[<cmd>lua require('telescope.builtin').find_files()<cr>]])
keymap('<leader>r', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]])
