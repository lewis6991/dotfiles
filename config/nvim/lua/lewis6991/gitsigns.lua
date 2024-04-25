local gitsigns = require('gitsigns')

local line = vim.fn.line

vim.keymap.set('n', 'M', '<cmd>Gitsigns debug_messages<cr>')
vim.keymap.set('n', 'mm', '<cmd>Gitsigns dump_cache<cr>')

local function on_attach(bufnr)
  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  map('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal({']c', bang = true})
    else
      gitsigns.nav_hunk('next')
    end
  end)

  map('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal({'[c', bang = true})
    else
      gitsigns.nav_hunk('prev')
    end
  end)

  map('n', '<leader>hs', gitsigns.stage_hunk)
  map('n', '<leader>hr', gitsigns.reset_hunk)

  map('v', '<leader>hs', function()
    gitsigns.stage_hunk({ line('.'), line('v') })
  end)

  map('v', '<leader>hr', function()
    gitsigns.reset_hunk({ line('.'), line('v') })
  end)

  map('n', '<leader>hS', gitsigns.stage_buffer)
  map('n', '<leader>hu', gitsigns.undo_stage_hunk)
  map('n', '<leader>hR', gitsigns.reset_buffer)
  map('n', '<leader>hp', gitsigns.preview_hunk)

  map('n', '<leader>hb', function()
    gitsigns.blame_line({full=true})
  end)

  map('n', '<leader>hi', gitsigns.preview_hunk_inline)
  map('n', '<leader>hd', gitsigns.diffthis)
  map('n', '<leader>hD', ':Gitsigns diffthis ~')

  map('n', '<leader>hld', function()
    gitsigns.diffthis(vim.b.gitsigns_blame_line_dict.sha..'~1')
  end)

  map('n', '<leader>hB', ':Gitsigns change_base ~')

  -- Toggles
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
  map('n', '<leader>td', gitsigns.toggle_deleted)
  map('n', '<leader>tw', gitsigns.toggle_word_diff)

  map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
  map('n', '<leader>hq', gitsigns.setqflist)

  map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end

gitsigns.setup({
  debug_mode = true,
  max_file_length = 100000,
  signs = {
    add = { show_count = false },
    change = { show_count = false },
    delete = { show_count = true },
    topdelete = { show_count = true },
    changedelete = { show_count = true },
  },
  on_attach = on_attach,
  preview_config = {
    border = 'rounded',
  },
  current_line_blame = true,
  current_line_blame_formatter_opts = {
    relative_time = true,
  },
  current_line_blame_opts = {
    delay = 50,
  },
  count_chars = {
    '⒈',
    '⒉',
    '⒊',
    '⒋',
    '⒌',
    '⒍',
    '⒎',
    '⒏',
    '⒐',
    '⒑',
    '⒒',
    '⒓',
    '⒔',
    '⒕',
    '⒖',
    '⒗',
    '⒘',
    '⒙',
    '⒚',
    '⒛',
  },
  attach_to_untracked = true,
  update_debounce = 50,
  _signs_staged_enable = true,
  word_diff = true,
  trouble = true,
})
