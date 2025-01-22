vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4
vim.opt_local.foldlevelstart = 1
vim.opt_local.foldnestmax = 3

vim.api.nvim_set_hl(0, '@type.scala', { default = true, link = '@class' })
vim.api.nvim_set_hl(0, '@lsp.mod.readOnly.scala', { default = true, link = '@lsp' })
