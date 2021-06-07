lua require'lewis6991'

"VimL
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &shiftwidth
let g:xml_syntax_folding=1
let g:man_hardwrap=1

" Filetype detections
augroup vimrc
    autocmd BufRead dotshrc,dotsh         setlocal filetype=sh
    autocmd BufRead dotcshrc              setlocal filetype=csh
    autocmd BufRead *.tmux                setlocal filetype=tmux
    autocmd BufRead *.jelly               setlocal filetype=xml
    autocmd BufRead setup.cfg             setlocal filetype=dosini
    autocmd BufRead gerrit_hooks          setlocal filetype=dosini
    autocmd BufRead requirements*.txt     setlocal filetype=requirements
    autocmd BufRead lit.cfg,lit.local.cfg setlocal filetype=python
    autocmd BufRead gitconfig             setlocal filetype=gitconfig
    autocmd BufRead * if getline(1) =~ '^#%Module.*'
                  \ |     setlocal ft=tcl
                  \ | endif
    autocmd BufRead modulefile            setlocal filetype=tcl
augroup END

" Filetype settings

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

function! Hashbang() abort "{{{
    let shells = {
        \     'sh': 'bash',
        \     'py': 'python3',
        \  'scala': 'scala',
        \    'tcl': 'tclsh'
        \ }

    let extension = expand('%:e')

    if has_key(shells, extension)
        0put = '#! /usr/bin/env ' . shells[extension]
        2put = ''
        autocmd vimrc BufWritePost <buffer> silent !chmod u+x %
    endif
endfunction "}}}

command! Hashbang call Hashbang()

command! -nargs=* FloatingMan call ToggleCommand('execute ":r !man -D '.<q-args>. '" | Man!')

command! LspDisable lua vim.lsp.stop_client(vim.lsp.get_active_clients())

set keywordprg=:FloatingMan

function! CreateCenteredFloatingWindow() "{{{
    let width  = float2nr(&columns * 0.8)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = { 'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
endfunction "}}}

function! ToggleCommand(cmd) abort "{{{
    call CreateCenteredFloatingWindow()
    execute a:cmd
    nmap <buffer><silent> q     :bwipeout!<cr>
    nmap <buffer><silent> <esc> :bwipeout!<cr>

    " Disable window movement
    nmap <buffer> <C-w> <nop>
    nmap <buffer> <C-h> <nop>
    nmap <buffer> <C-j> <nop>
    nmap <buffer> <C-k> <nop>
    nmap <buffer> <C-l> <nop>
endfunction "}}}

" vim: foldmethod=marker foldminlines=0:
