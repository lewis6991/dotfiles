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
    local loc_install = HOME .. '/projects/' .. name
    if name ~= '' and vim.fn.isdirectory(loc_install) == 1 then
      return loc_install
    end
  end
end

local function try_get_local(spec)
  if type(spec) == 'string' then
    return resolve(spec) or spec
  end

  if not spec or type(spec) == 'string' or type(spec[1]) ~= 'string' then
    return spec
  end

  local loc_install = resolve(spec[1])
  if loc_install then
    spec[1] = loc_install
  end
  return spec
end

local function setup_pckr(init)
  local pckr_path = vim.fn.expand('~/projects/pckr.nvim')
  -- local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  vim.opt.rtp:prepend(pckr_path)

  if not vim.loop.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      -- "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path,
    })
  end

  local pckr = require('pckr')

  pckr.setup({
    git = {
      default_url_format = 'git@github.com:/%s',
    },
    max_jobs = 30,
    display = {
      prompt_border = 'rounded',
    },
    -- log = {
    --   level = 'trace'
    -- }
  })

  pckr.add(init)

  vim.keymap.set('n', '<leader>u', '<cmd>Pckr update<CR>', { silent = true })
end

function M.setup(init)
  -- look for local version of plugins in $HOME/projects and use them instead
  walk_spec({ init }, nil, try_get_local)
  setup_pckr(init)
end

return M
