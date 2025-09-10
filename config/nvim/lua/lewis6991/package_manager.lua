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

--- @generic T
--- @param x T
--- @return T
local function try_get_local(x)
  if type(x) == 'string' and x:sub(1, 1) ~= '/' then
    local name = x:match('/(.*)')
    local loc_install = vim.fs.joinpath(HOME, 'projects', name)
    if name ~= '' and vim.fn.isdirectory(loc_install) == 1 then
      return loc_install
    end
  end
  return x
end

function M.bootstrap()
  local pckr_path = vim.fn.expand('~/projects/pckr.nvim')
  -- local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"
  vim.opt.rtp:prepend(pckr_path)

  if not vim.uv.fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      -- "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path,
    })
  end
end

local init = {}

function M.setup()
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
  }, init)

  init = {}

  vim.keymap.set('n', '<leader>u', '<cmd>Pckr update<CR>', { silent = true })
  vim.keymap.set('n', '<leader>p', '<cmd>Pckr status<CR>', { silent = true })
end

--- @param name string
--- @param spec? Pckr.UserSpec
function M.add(name, spec)
  spec = spec or {}
  spec[1] = name
  walk_spec({ spec }, nil, try_get_local)
  init[#init + 1] = spec
end

return M
