" Init {{{
function! s:exists(var)
    if exists(a:var)
        return 1
    endif
    echoerr a:var.' is not defined'
    return 0
endfunction

if !has('nvim')
    if s:exists('$XDG_CONFIG_HOME') && s:exists('$XDG_DATA_HOME')
        set runtimepath=
            \$XDG_CONFIG_HOME/vim,
            \$XDG_DATA_HOME/vim/site,
            \$VIMRUNTIME,
            \$XDG_DATA_HOME/vim/site/after,
            \$XDG_CONFIG_HOME/vim/after
    endif
    if s:exists('$XDG_DATA_HOME')
        set directory=$XDG_DATA_HOME/vim/swap
    endif
    if s:exists('$XDG_CACHE_HOME')
        set backupdir=$XDG_CACHE_HOME/vim/backup
        set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
    endif
endif

" }}}
" Bootstrap {{{
if has('nvim')
    let s:tool = 'nvim'
else
    let s:tool = 'vim'
endif

let s:audir = expand('$XDG_DATA_HOME/'.s:tool.'/site/autoload')
let s:pldir = expand('$XDG_DATA_HOME/'.s:tool.'/site/plugged')

" Install vim-plug if we don't already have it
if empty(glob(s:audir.'/plug.vim'))
    call mkdir(s:audir, 'p')
    call mkdir(s:pldir, 'p')
    execute '!wget -nc -q github.com/junegunn/vim-plug/raw/master/plug.vim -P '.s:audir
    autocmd vimrc VimEnter * PlugInstall --sync | bd | source $MYVIMRC
endif

" Install vim-pathogen if we don't already have it
if empty(glob(s:audir.'/pathogen.vim'))
    call mkdir(s:audir, 'p')
    execute '!curl -LSso '.s:audir.'/pathogen.vim https://tpo.pe/pathogen.vim'
endif

" }}}
" Plugins {{{

" Load any plugins which are work sensitive.
silent execute pathogen#infect('~/gerrit/{}')

let g:loaded_netrwPlugin = 1  " Stop netrw loading

augroup vimrc
    autocmd!
augroup END

" let ppath = 'lewis6991'
let ppath = '~/projects'

call plug#begin(s:pldir)
    Plug ppath.'/dotfiles/modules/moonlight.vim'
    Plug 'junegunn/vim-plug'
    Plug ppath.'/systemverilog.vim'     , { 'for': 'systemverilog' }
    Plug ppath.'/tcl.vim'               , { 'for': 'tcl'           }
    Plug 'raimon49/requirements.txt.vim', { 'for': 'requirements'  }
call plug#end()
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
" Avoid showing message extra message when using completion
set shortmess+=c
if v:version >= 800
    set completeopt=noinsert,menuone,noselect
endif

let &showbreak='↳ '

if has('mouse')
    set mouse=a
endif

silent! set signcolumn=auto:3
silent! set pumblend=10
silent! set winblend=10

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
" set spell
if s:exists('$XDG_CONFIG_HOME')
    set spellfile=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
endif

" }}}
" Colours {{{
silent! set termguicolors
silent! colorscheme moonlight
" }}}
" Nvim {{{
if has('nvim')
    let g:loaded_python_provider = 1 " Disable python2
    let g:loaded_ruby_provider   = 1 " Disable ruby

    if glob('/devtools/linuxbrew/bin/python3') != ''
        let g:python3_host_prog = '/devtools/linuxbrew/bin/python3'
    else
        let g:python3_host_prog = systemlist('which python3')[0]
    endif

    set inccommand=split
    set previewheight=30

    " Remove tilda from signcolumn
    let &fillchars='eob: '
endif
" }}}
" Mappings {{{
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>rv :source $MYVIMRC<bar>edit!<CR>
nnoremap <leader>s :%s/\<<C-R><C-W>\>\C//g<left><left>
nnoremap <leader>c 1z=
nnoremap <leader>w :execute "resize ".line('$')<cr>

nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>

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

nmap <Tab>   :bnext<CR>
nmap <S-Tab> :bprev<CR>

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <C-A> <Home>
cnoremap <C-D> <Del>

imap <tab>   <Plug>(completion_smart_tab)
imap <s-tab> <Plug>(completion_smart_s_tab)

" nnoremap & /\<<C-R><C-w>\>\C<CR>

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
" Folding {{{
if has('folding')
    let g:vimsyn_folding = 'af' "Fold augroups and functions
    let g:sh_fold_enabled = 1
    set foldmethod=syntax
    set foldcolumn=0
    set foldnestmax=3
    set foldopen+=jump
    " set foldminlines=10
endif

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
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal textwidth=10000
augroup END

" Commentstring
augroup vimrc
    autocmd Filetype sbt.scala   setlocal commentstring=//%s
augroup END

" Filetype settings

augroup vimrc
    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype gitconfig     setlocal noexpandtab
    autocmd Filetype log           setlocal textwidth=1000
    autocmd FileType xml           setlocal foldnestmax=20
    autocmd Filetype fugitiveblame  set cursorline
augroup END
" }}}
" Formatting {{{
set formatoptions+=r "Automatically insert comment leader after <Enter> in Insert mode.
set formatoptions+=o "Automatically insert comment leader after 'o' or 'O' in Normal mode.
set formatoptions+=l "Long lines are not broken in insert mode.
set formatoptions-=t "Do not auto wrap text
set formatoptions+=n "Recognise lists
if v:version >= 800
    set breakindent      "Indent wrapped lines to match start
endif
" }}}
" Snippets {{{
iabbrev :rev:
    \ <c-r>=substitute(&commentstring, '%s', '', '').
    \' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):'<CR>
" }}}
"Commands {{{

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

set keywordprg=:FloatingMan

function! CreateCenteredFloatingWindow() "{{{
    let width  = float2nr(&columns * 0.8)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = { 'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
endfunction "}}}

function! CreatePadding(opts) abort "{{{
    let a:opts.row    += 1
    let a:opts.height -= 2
    let a:opts.col    += 2
    let a:opts.width  -= 4
    return a:opts
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

let bufferline = {}
let bufferline.closable = v:false
let bufferline.shadow = v:false
" let bufferline.maximum_padding = 2

nnoremap <silent> <Tab>   :BufferNext<CR>
nnoremap <silent> <S-Tab> :BufferPrevious<CR>

" hi def link BufferCurrent         Title
" hi def link BufferCurrentMod      Title
" hi def link BufferCurrentSign     Title
" hi def link BufferCurrentTarget   Title
" hi def link BufferVisible         Title
" hi def link BufferVisibleMod      Title
" hi def link BufferVisibleSign     Error
" hi def link BufferVisibleTarget   Error
" hi def link BufferInactive        Title
" hi def link BufferInactiveMod     Title
" hi def link BufferInactiveSign    Title
" hi def link BufferInactiveTarget  Title
" hi def link BufferShadow          Error


" vim: foldmethod=marker foldminlines=0:
