local actions = require'telescope.actions'
local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local sorters = require'telescope.sorters'
local make_entry = require'telescope.make_entry'

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
    -- finder = finders.new_oneshot_job({ "git", "ls-tree", "--full-tree", "-r", "--name-only", "HEAD"}),
    finder = finders.new_oneshot_job({
      "git", "ls-files", "-o", "--exclude-standard", "-c", git_root
    }),
    sorter = sorters.get_fuzzy_file(),
  }):find()
end

buffers = function()
  local opts = {}
  local buffers = vim.tbl_filter(function(b)
    return (opts.show_all_buffers or vim.api.nvim_buf_is_loaded(b)) and 1 == vim.fn.buflisted(b)
  end, vim.api.nvim_list_bufs())

  local max_bufnr = math.max(unpack(buffers))
  opts.bufnr_width = #tostring(max_bufnr)

  pickers.new({}, {
    prompt = 'Buffers',
    finder    = finders.new_table {
      results = buffers,
      entry_maker = make_entry.gen_from_buffer(opts)
    },
    sorter = sorters.get_fuzzy_file(),
  }):find()
end

vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>lua my_git_files()<cr>', {})
vim.api.nvim_set_keymap('n', '<C-b>', '<cmd>lua buffers()<cr>'     , {})


