local did_setup = false

local function setup()
  if did_setup then
    return
  end
  did_setup = true

  local telescope = require('telescope')

  telescope.setup({
    defaults = {
      selection_strategy = 'reset',
      winblend = 15,
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown({}),
      },
    },
  })

  telescope.load_extension('fzf')
end

local function nmap(key, fun, opts)
  vim.keymap.set('n', key, function()
    setup()
    require('telescope.builtin')[fun](opts)
  end, {})
end

-- default: CTRL-B   scroll N screens Backwards
nmap('<C-b>', 'buffers', { previewer = false })

nmap('<C-p>', 'git_files', { use_git_root = true, previewer = false, show_untracked = true })
nmap('<C- >', 'git_files', { cwd = '$HOME/projects/dotfiles', hidden = true })

nmap('<leader>f', 'find_files')
nmap('<leader>g', 'live_grep')
