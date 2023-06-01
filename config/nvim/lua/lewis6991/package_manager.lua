local M = {}

---@param spec   table
---@param field? integer|string
---@param fn     fun(spec: table|string): table|string
local function walk_spec(spec, field, fn)
  field = field or 1
  if type(spec[field]) == 'table' then
    for j in ipairs(spec[field]) do
      walk_spec(spec[field], j, fn)
    end
    walk_spec(spec[field], 'requires', fn)
  end
  spec[field] = fn(spec[field])
end

local HOME = os.getenv('HOME')

local function resolve(x)
  if type(x) == 'string' and x:sub(1, 1) ~= '/' then
    local name = vim.split(x, '/')[2]
    local loc_install = HOME..'/projects/'..name
    if name ~= '' and vim.fn.isdirectory(loc_install) == 1 then
      return loc_install
    end
  end
end

local function try_get_local(lazy)
  return function(spec)
    if type(spec) == 'string' and not lazy then
      return resolve(spec) or spec
    end

    if not spec or type(spec) == 'string' or type(spec[1]) ~= 'string' then
      return spec
    end

    local loc_install = resolve(spec[1])
    if loc_install then
      if lazy then
        spec.dir = loc_install
      else
        spec[1] = loc_install
      end
    end
    return spec
  end
end

local function setup_pckr(init)
  -- local pckr_path = vim.fn.expand('~/projects/pckr.nvim')
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  vim.opt.rtp:prepend(pckr_path)

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  local pckr = require('pckr')

  pckr.setup{
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

  pckr.add(init)

  vim.keymap.set('n', '<leader>u', '<cmd>Pckr update<CR>', {silent=true})
end

local function setup_lazy(init)
  walk_spec({init}, nil, function(spec)
    if not spec or type(spec) == 'string' then
      return spec
    end

    if spec.requires then
      spec.dependencies = spec.requires
      spec.requires = nil
    end

    if spec.run then
      spec.build = spec.run
      spec.run = nil
    end

    if spec.config_pre then
      spec.init = spec.config_pre
      spec.config_pre = nil
    end

    spec.start = nil

    return spec
  end)

  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
  end

  vim.opt.runtimepath:prepend(lazypath)

  require("lazy").setup(init)
end

function M.setup(init)
  -- look for local version of plugins in $HOME/projects and use them instead
  walk_spec({init}, nil, try_get_local(vim.env.LAZY))

  if vim.env.LAZY then
    setup_lazy(init)
  else
    setup_pckr(init)
  end
end

return M
