-- vim.env.LAZY=1
if not vim.env.LAZY then
  if vim.env.IMP then
    local ok, impatient = pcall(require, 'impatient')
    if ok then
      impatient.enable_profile()
      require("lazy.core.cache").profile_loaders()
    else
      vim.notify(impatient)
    end
  else
    local ok, cachemod = pcall(require, 'lazy.core.cache')
    if ok then
      cachemod.enable()
    else
      vim.notify(cachemod)
    end
  end
end

-- Do all init in lewis6991/init.lua so impatient can cache it
require'lewis6991'
