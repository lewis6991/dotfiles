local ok, impatient = pcall(require, 'impatient')
if ok then
  impatient.enable_profile()
end

-- Do all init in lewis6991/init.lua so imnpatient can cache it
require'lewis6991'

-- Same for packer
require'packer_compiled'
