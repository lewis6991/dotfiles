
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

local async = require('plenary.async')

local M = {}

M.git_files = async.void(function()
  local opts = {}
  async.util.scheduler()

  local finders = require "telescope.finders"
  local pickers = require "telescope.pickers"
  local conf = require("telescope.config").values
  local make_entry = require "telescope.make_entry"

  opts.cwd = vim.trim(vim.fn.system('git rev-parse --show-toplevel'))
  opts.entry_maker = make_entry.gen_from_file(opts)

  pickers.new(opts, {
    prompt_title = "Git Files",
    finder = finders.new_oneshot_job(
      {"git", "ls-files", "--exclude-standard", "--cached", "--others" },
      opts
    ),
    sorter = conf.file_sorter(opts),
  }):find()
end)

M.find_files = function(opts)
  opts = opts or {}
  local finders = require "telescope.finders"
  local pickers = require "telescope.pickers"
  local conf = require("telescope.config").values
  local make_entry = require "telescope.make_entry"

  local search_dirs = opts.search_dirs
  if type(search_dirs) == 'string' then
    opts.cwd = vim.fn.expand(search_dirs)
    search_dirs = {search_dirs}
  end

  if search_dirs then
    for i, v in ipairs(search_dirs) do
      search_dirs[i] = vim.fn.expand(v)
    end
  end

  local find_command
  if vim.fn.executable "fd" == 1 then
    find_command = { "fd", "--type", "f" }
    table.insert(find_command, "-L")
    if search_dirs then
      table.insert(find_command, ".")
      for _, v in ipairs(search_dirs) do
        table.insert(find_command, v)
      end
    end
  elseif vim.fn.executable "rg" == 1 then
    find_command = { "rg", "--files" }
    table.insert(find_command, "-L")
    if search_dirs then
      for _, v in ipairs(search_dirs) do
        table.insert(find_command, v)
      end
    end
  end

  opts.entry_maker = make_entry.gen_from_file(opts)

  pickers.new(opts, {
    prompt_title = "Find Files",
    finder = finders.new_oneshot_job(find_command, opts),
    sorter = conf.file_sorter(opts),
  }):find()
end


local keymap = function(key, result)
  vim.api.nvim_set_keymap('n', key, result, {noremap = true, silent = true})
end

-- keymap('<C-p>'    , '<cmd>Telescope git_files<cr>')
keymap('<C-p>'    , [[<cmd>lua require('lewis6991.telescope').git_files()<cr>]])
keymap('<leader>f', [[<cmd>lua require('lewis6991.telescope').find_files()<cr>]])
keymap('<C- >'    , [[<cmd>lua require('lewis6991.telescope').find_files{search_dirs='$HOME/projects/dotfiles'}<cr>]])
keymap('<leader>g', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]])

return M
