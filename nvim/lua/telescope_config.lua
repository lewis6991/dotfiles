local actions = require'telescope.actions'
local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local sorters = require'telescope.sorters'

require'telescope'.setup {
  defaults = {
    preview_cutoff = 20,
    selection_strategy = "reset",
    -- default_mappings = {
    --   i = {
    --     ["<C-n>"] = actions.move_selection_next,
    --     ["<C-p>"] = actions.move_selection_previous,
    --     ["<esc>"] = actions.close,
    --   },
    --   n = { ["<esc>"] = actions.close },
    -- },
    winblend = 25,
  },
}

my_git_files = function()
  local git_root = (function()
    -- local a = vim.split(vim.fn.system('git rev-parse --show-superproject-working-tree 2> /dev/null'), '\n')[1]
    -- if a ~= '' then
    --   return a
    -- end
    local b = vim.split(vim.fn.system('git rev-parse --show-toplevel 2> /dev/null'), '\n')[1]
    if b ~= '' then
      return b
    end
    return vim.fn.getcwd()
  end)()

  pickers.new({}, {
    prompt = 'Git Files',
    finder = finders.new_oneshot_job({
      "git", "ls-files", "-o", "--exclude-standard", "-c", git_root
    }),
    sorter = sorters.get_fuzzy_file(),
  }):find()
end

vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>lua my_git_files()<cr>', {})


