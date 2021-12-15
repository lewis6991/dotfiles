require'impatient'.enable_profile()
require'lewis6991'
require'packer_compiled'

vim.cmd[[
  iabbrev :rev:
      \ <c-r>=printf(&commentstring,
      \     ' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>

  iabbrev :todo: <c-r>=printf(&commentstring, ' TODO lewis6991:')<CR>
]]
