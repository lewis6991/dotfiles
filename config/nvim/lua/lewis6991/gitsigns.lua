local gitsigns = require('gitsigns')

local line = vim.fn.line

local function wrap(fn, ...)
  local args = {...}
  local nargs = select('#', ...)
  return function()
    fn(unpack(args, nargs))
  end
end

--  TODO(lewis6991): doesn't work properly
vim.keymap.set('n', 'M', '<cmd>Gitsigns debug_messages<cr>')
vim.keymap.set('n', 'm', '<cmd>Gitsigns dump_cache<cr>')

local function on_attach(bufnr)
  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  map('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(gitsigns.next_hunk)
    return '<Ignore>'
  end, {expr=true})

  map('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(gitsigns.prev_hunk)
    return '<Ignore>'
  end, {expr=true})

  map('n', '<leader>hs', gitsigns.stage_hunk)
  map('n', '<leader>hr', gitsigns.reset_hunk)
  map('v', '<leader>hs', wrap(gitsigns.stage_hunk, {line("."), line("v")}))
  map('v', '<leader>hr', wrap(gitsigns.reset_hunk, {line("."), line("v")}))
  map('n', '<leader>hS', gitsigns.stage_buffer)
  map('n', '<leader>hu', gitsigns.undo_stage_hunk)
  map('n', '<leader>hR', gitsigns.reset_buffer)
  map('n', '<leader>hp', gitsigns.preview_hunk)
  map('n', '<leader>hb', wrap(gitsigns.blame_line, {full=true}))
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
  map('n', '<leader>hd', gitsigns.diffthis)
  map('n', '<leader>hD', wrap(gitsigns.diffthis, '~'))
  map('n', '<leader>td', gitsigns.toggle_deleted)

  map('n', '<leader>hQ', wrap(gitsigns.setqflist, 'all'))
  map('n', '<leader>hq', wrap(gitsigns.setqflist))

  map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

gitsigns.setup{
  debug_mode = true,
  max_file_length = 1000000000,
  signs = {
    add          = {show_count = false},
    change       = {show_count = false},
    delete       = {show_count = true },
    topdelete    = {show_count = true },
    changedelete = {show_count = true },
  },
  on_attach = on_attach,
  preview_config = {
    border = 'rounded',
  },
  current_line_blame = true,
  current_line_blame_formatter_opts = {
    relative_time = true
  },
  current_line_blame_opts = {
    delay = 0
  },
  count_chars = {
    '⒈', '⒉', '⒊', '⒋', '⒌', '⒍', '⒎', '⒏', '⒐',
    '⒑', '⒒', '⒓', '⒔', '⒕', '⒖', '⒗', '⒘', '⒙', '⒚', '⒛',
  },
  update_debounce = 0,
  word_diff = true,
}
