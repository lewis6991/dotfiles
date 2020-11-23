
vim.g.loaded_python_provider = 1 -- Disable python2
-- vim.g.loaded_ruby_provider   = 1 -- Disable ruby

-- if vim.fn.glob('/devtools/linuxbrew/bin/python3') ~= '' then
--     vim.g.python3_host_prog = '/devtools/linuxbrew/bin/python3'
-- else
--     vim.g.python3_host_prog = vim.fn.systemlist('which python3')[0]
-- end

vim.o.inccommand = 'split'
vim.o.previewheight = 30

-- Remove tilda from signcolumn
vim.o.fillchars = 'eob: '

vim.o.signcolumn='auto:3'
vim.o.pumblend=10
vim.o.winblend=10
