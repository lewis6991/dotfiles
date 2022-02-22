augroup terminal_cfg
    autocmd!
    autocmd TermOpen * setlocal
        \ nonumber
        \ norelativenumber
        \ nospell
    autocmd TermOpen * startinsert
augroup END

tnoremap <Esc> <c-\><c-n>
