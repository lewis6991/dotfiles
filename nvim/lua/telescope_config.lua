
require'telescope'.setup {
  defaults = {
    preview_cutoff = 20,
    selection_strategy = "reset",
    winblend = 25,
  },
}

local function git_root()
  local a = vim.split(vim.fn.system('git rev-parse --show-superproject-working-tree 2> /dev/null'), '\n')[1]
  if a ~= '' then
    return a
  end
  local b = vim.split(vim.fn.system('git rev-parse --show-toplevel 2> /dev/null'), '\n')[1]
  if b ~= '' then
    return b
  end
  return vim.fn.getcwd()
end

function My_git_files()
  local finders = require'telescope.finders'
  local pickers = require'telescope.pickers'
  local sorters = require'telescope.sorters'

  pickers.new({}, {
    prompt = 'Git Files',
    finder = finders.new_oneshot_job({
      "git", "ls-files", "-o", "--exclude-standard", "-c", git_root()
    }),
    sorter = sorters.get_fuzzy_file(),
  }):find()
end

local keymap = function(key, result)
  vim.api.nvim_set_keymap('n', key, result, {noremap = true, silent = true})
end

keymap('<C-p>'    , '<cmd>lua My_git_files()<cr>')
keymap('<C- >'    , [[<cmd>lua require('telescope.builtin').find_files()<cr>]])
keymap('<leader>r', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]])
