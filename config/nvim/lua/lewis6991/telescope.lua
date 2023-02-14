local telescope = require 'telescope'

local done_setup  = false

local function setup()
  -- local actions = require('telescope.actions')

  -- local file_picker_opts = {
  --   mappings = {
  --     i = {
  --       ["<CR>"]  = actions.select_tab,
  --       ["<C-e>"] = actions.select_default,
  --       ["<esc>"] = actions.close,
  --     }
  --   }
  -- }

  telescope.setup {
    defaults = {
      selection_strategy = "reset",
      winblend = 15,
    },
    -- pickers = {
    --   git_files = file_picker_opts,
    --   live_grep = file_picker_opts,
    --   find_files = file_picker_opts,
    -- },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown{}
      }
    }
  }
  telescope.load_extension('fzf')
end

telescope.load_extension('ui-select')

local function nmap(key)
  return function(spec)
    local fun, opts
    if type(spec) == 'string' then
      fun = spec
    else
      fun = spec[1]
      spec[1] = nil
      opts = spec
    end
    opts = opts or {}
    opts.preview = false
    vim.keymap.set('n', key, function()
      if not done_setup then
        setup()
        done_setup = true
      end
      require('telescope.builtin')[fun](opts)
    end, {})
  end
end

-- default: CTRL-B   scroll N screens Backwards
nmap '<C-b>' 'buffers'

nmap '<C-p>' {'git_files', use_git_root=true}
nmap '<C- >' {'git_files', cwd="$HOME/projects/dotfiles", hidden=true}

nmap '<leader>f' 'find_files'
nmap '<leader>g' 'live_grep'
