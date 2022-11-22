local M = {}

local function bootstap()
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

  if not vim.loop.fs_stat(install_path) then
    if vim.fn.input("Download Packer? (y for yes): ") ~= "y" then
      return
    end

    print("Downloading packer.nvim...")
    print(vim.fn.system(string.format(
      'git clone %s %s',
      'https://github.com/lewis6991/packer.nvim',
      install_path
    )))
  end
end

-- look for local version of plugins in $HOME/projects and use them instead
local function use_local(init)
  local home = os.getenv('HOME')

  local function try_get_local(plugin)
    local _, name = unpack(vim.split(plugin, '/'))
    local loc_install = home..'/projects/'..name
    if name ~= '' and vim.loop.fs_stat(loc_install) then
      return loc_install
    else
      return plugin
    end
  end

  local function try_local(spec, i)
    i = i or 1
    if type(spec[i]) == 'string' then
      spec[i] = try_get_local(spec[i])
    elseif type(spec[i]) == 'table' then
      for j, _ in ipairs(spec[i]) do
        try_local(spec[i], j)
      end
      try_local(spec[i], 'requires')
    end
  end

  try_local{init}
end

function M.setup(init)
  bootstap()

  use_local(init)

  local packer = require('packer')

  packer.startup{init,
    config = {
      git = {
        default_url_format = 'git@github.com:/%s',
        subcommands = {
          update  = 'pull --progress',
          install = 'clone --progress',
        },
      },
      max_jobs = 30,
      display = {
        -- open_cmd = '65vnew \\[packer\\]',
        -- open_cmd = 'edit \\[packer\\]',
        prompt_border = 'rounded'
      },
      -- autoremove = true
    }
  }

  vim.keymap.set('n', '<leader>u', '<cmd>PackerUpdate<CR>', {silent=true})
end

return M
