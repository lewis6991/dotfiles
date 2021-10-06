lua require'impatient'.enable_profile()
lua require'lewis6991'
lua require'packer_compiled'

augroup vimrc
    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype gitconfig     setlocal noexpandtab
    autocmd Filetype log           setlocal textwidth=1000
    autocmd FileType xml           setlocal foldnestmax=20
    autocmd Filetype fugitiveblame setlocal cursorline
augroup END

iabbrev :rev:
    \ <c-r>=printf(&commentstring,
    \     ' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>
