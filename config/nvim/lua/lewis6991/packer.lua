local M = {}

local function bootstrap()
  if not pcall(require, 'packer') then
    --- @diagnostic disable-next-line
    if vim.fn.input("Download Packer? (y for yes): ") ~= "y" then
      return
    end

    print("Downloading packer.nvim...")
    print(vim.fn.system(string.format(
      'git clone %s %s --branch=main',
      'https://github.com/lewis6991/packer.nvim',
      vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    )))
  end
end

---@param spec   string|table
---@param field? integer|string
---@param fn     fun(spec: table|string): table|string
local function walk_spec(spec, field, fn)
  field = field or 1
  spec[field] = fn(spec[field])
  if type(spec[field]) == 'table' then
    for j, _ in ipairs(spec[field]) do
      walk_spec(spec[field], j, fn)
    end
    walk_spec(spec[field], 'requires', fn)
  end
end

local HOME = os.getenv('HOME')

---@param spec string|table
local function try_get_local(spec)
  if type(spec) ~= 'string' then
    return spec
  end

  local _, name = unpack(vim.split(spec, '/'))

  local loc_install = HOME..'/projects/'..name
  if name ~= '' and vim.loop.fs_stat(loc_install) then
    return loc_install
  else
    return spec
  end
end

function M.setup(init)
  bootstrap()

  -- look for local version of plugins in $HOME/projects and use them instead
  walk_spec({init}, nil, try_get_local)

  local packer = require('packer')

  packer.setup{
    git = {
      default_url_format = 'git@github.com:/%s',
    },
    max_jobs = 30,
    display = {
      prompt_border = 'rounded'
    },
    -- log = {
    --   level = 'trace'
    -- }
  }

  packer.add(init)

  vim.keymap.set('n', '<leader>u', '<cmd>PackerUpdate<CR>', {silent=true})
  P = function()
    return require('packer.plugin').plugins
  end
end

return M
