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
      'https://github.com/wbthomason/packer.nvim',
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
    if vim.loop.fs_stat(loc_install) then
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

-- Hacky way of auto clean/install/compile
local function automize(packer)
  vim.api.nvim_create_augroup('plugins', {})
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'plugins',
    pattern = '*/lua/lewis6991/plugins.lua',
    callback = function()
      package.loaded["lewis6991.plugins"] = nil
      require("lewis6991.plugins")
      require('packer').clean()
    end
  })

  local state = 'cleaned'
  local orig_complete = packer.on_complete
  packer.on_complete = vim.schedule_wrap(function()
    if state == 'cleaned' then
      packer.install()
      state = 'installed'
    elseif state == 'installed' then
      packer.compile()
      -- packer.compile('profile=true')
      state = 'compiled'
    elseif state == 'compiled' then
      packer.on_complete = orig_complete
      state = 'done'
    end
  end)
end

function M.setup(init)
  bootstap()

  use_local(init)

  local packer = require('packer')

  automize(packer)

  packer.startup{init,
    config = {
      git = {
        default_url_format = 'git@github.com:/%s',
      },
      max_jobs = 30,
      display = {
        open_cmd = 'edit \\[packer\\]',
        prompt_border = 'rounded'
      },
      autoremove = true
    }
  }

  vim.keymap.set('n', '<leader>u', '<cmd>PackerUpdate<CR>', {silent=true})
end

return M
