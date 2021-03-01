" Plugins {{{

" Load any plugins which are work sensitive.
for f in split(globpath('~/gerrit/', '*'), '\n') + [
    \ '~/projects/dotfiles/modules/moonlight.vim',
    \ '~/projects/tcl.vim'
    \ ]
    let &rtp=f.','.&rtp
endfor

let g:loaded_netrwPlugin = 1  " Stop netrw loading

augroup vimrc
    autocmd!
augroup END

" }}}
" General {{{
set number
set nowrap
if v:version >= 704
    set relativenumber
endif
set textwidth=80
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set noswapfile
set ignorecase
set smartcase
set clipboard+=unnamedplus
set scrolloff=6
set sidescroll=6
set sidescrolloff=6
set nostartofline
set virtualedit=block " allow cursor to exist where there is no character
set updatetime=200
set hidden
set backup
set backupdir-=.
set lazyredraw
set redrawtime=4000
set shortmess+=I

if v:version >= 800
    " Avoid showing message extra message when using completion
    set shortmess+=c
    set completeopt=noinsert,menuone,noselect
endif

let &showbreak='    ↳ '

if has('mouse')
    set mouse=a
endif

" if has('nvim-0.3.2') || has('patch-8.1.0360')
"     set diffopt=filler,algorithm:histogram,indent-heuristic
" endif

set diffopt+=vertical  "Show diffs in vertical splits

if !empty($SSH_TTY)
    let g:clipboard = {
          \   'name': 'pb-remote',
          \   'copy':  {'+': 'pbcopy-remote' , '*': 'pbcopy-remote' },
          \   'paste': {'+': 'pbpaste-remote', '*': 'pbpaste-remote'},
          \   'cache_enabled': 0,
          \ }
endif

if has('persistent_undo')
    set undolevels=10000
    set undofile " Preserve undo tree between sessions.
endif

set splitright
set splitbelow
set spell

if exists('$XDG_CONFIG_HOME')
    set spellfile=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
endif

silent! set termguicolors
silent! colorscheme moonlight

if has('folding')
    let g:vimsyn_folding = 'af' "Fold augroups and functions
    let g:sh_fold_enabled = 1
    set foldmethod=syntax
    set foldcolumn=0
    set foldnestmax=3
    set foldopen+=jump
    " set foldminlines=10
endif

set formatoptions+=r "Automatically insert comment leader after <Enter> in Insert mode.
set formatoptions+=o "Automatically insert comment leader after 'o' or 'O' in Normal mode.
set formatoptions+=l "Long lines are not broken in insert mode.
set formatoptions-=t "Do not auto wrap text
set formatoptions+=n "Recognise lists
if v:version >= 800
    set breakindent      "Indent wrapped lines to match start
endif

" }}}
" Mappings {{{
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>el :edit $XDG_CONFIG_HOME/nvim/lua/plugins.lua<CR>
nnoremap <leader>s :%s/\<<C-R><C-W>\>\C//g<left><left>
nnoremap <leader>c 1z=
nnoremap <leader>w :execute "resize ".line('$')<cr>

nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>

nnoremap T :sp<space><bar><space>term<space>

nnoremap j gj
nnoremap k gk

nnoremap Y y$

nnoremap Q :w<cr>
vnoremap Q <nop>
nnoremap gQ <nop>
vnoremap gQ <nop>

" I never use macros and more often mis-hit this key
nnoremap q <nop>

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>syn_stack()<CR>

nnoremap <leader>: :lua<space>

nmap   <Tab> :bnext<CR>
nmap <S-Tab> :bprev<CR>

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <C-A> <Home>
cnoremap <C-D> <Del>

" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '

if v:version >= 800
    "Delete trailing white space on save.
    autocmd vimrc BufWrite * call <SID>delete_trailing_ws()

    "Highlight trailing whitespace
    autocmd vimrc BufEnter * call matchadd('ColorColumn', '\s\+$')
endif

function! s:delete_trailing_ws() abort
    " Save cursor position
    let l:save = winsaveview()

    " Remove trailing whitespace
    %s/\s\+$//ge

    " Move cursor to original position
    call winrestview(l:save)
endfunction
" }}}
" Functions {{{

function! s:syn_stack() abort "{{{
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, ''name'')')
endfunction "}}}

"}}}
" File Settings {{{
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
    autocmd BufRead SConstruct            setlocal filetype=scons
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
    autocmd FileType markdown      setlocal wrap
    autocmd FileType markdown      setlocal textwidth=10000
augroup END
" }}}
" Snippets {{{
iabbrev :rev:
    \ <c-r>=printf(&commentstring,
    \     ' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):')<CR>
" }}}
" Commands {{{

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

"}}}

" Brighten lsp floating windows
highlight link NormalFloat StatusLine

set nospell

" vim: foldmethod=marker foldminlines=0:
