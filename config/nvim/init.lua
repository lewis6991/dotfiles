_G.__luacache_config = {
  -- This obscures bugs in packer.nvim and plugin loading order
  modpaths = {
    enable = false,
  }
}

local ok, impatient = pcall(require, 'impatient')
if ok then
  impatient.enable_profile()
else
  vim.notify(impatient)
end

-- Do all init in lewis6991/init.lua so impatient can cache it
require'lewis6991'
