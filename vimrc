" Plugins {{{

    " Install vim-plug if we don't already have it {{{
    if empty(glob("~/.vim/autoload/plug.vim"))
        execute 'silent !mkdir -p ~/.vim/tmp/'
        execute 'silent !mkdir -p ~/.vim/tmp/undo'
        execute 'silent !mkdir -p ~/.vim/tmp/backup'
        execute 'silent !mkdir -p ~/.vim/plugged'
        execute 'silent !mkdir -p ~/.vim/autoload'
        silent !git clone https://github.com/junegunn/vim-plug.git $HOME/.vim/bundle/vim-plug
        silent !ln -s $HOME/.vim/bundle/vim-plug/plug.vim $HOME/.vim/autoload/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif "}}}

    " Install vim-pathogen if we don't already have it {{{
    if empty(glob("~/.vim/autoload/pathogen.vim"))
        execute 'silent !curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim'
    endif
    "}}}

let loaded_netrwPlugin = 1

" Load any plugins which are work sensitive.
execute pathogen#infect('~/gerrit/{}')

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-plug'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug '~/git/tcl.vim'
" Plug 'lewis6991/tcl.vim'
Plug '~/git/systemverilog.vim'
Plug 'whatyouhide/vim-lengthmatters'
Plug 'wellle/targets.vim'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeFind', 'NERDTreeToggle'] }
Plug 'sickill/vim-pasta'

if version >= 704
    Plug 'lewis6991/vim-clean-fold'
endif

" Python
Plug 'tmhedberg/SimpylFold'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'davidhalter/jedi-vim'

Plug 'airblade/vim-gitgutter'
Plug 'chriskempson/base16-vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dietsche/vim-lastplace'
Plug 'Yggdroot/indentLine'
Plug 'tmux-plugins/vim-tmux'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'w0rp/ale'
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/neosnippet'
    Plug 'zchee/deoplete-jedi'
    Plug 'Shougo/neco-vim' "Deoplete completion for vim
endif
call plug#end()

" }}}
" Plugin Settings {{{
" Airline {{{
let g:airline_detect_spell=0
let g:airline_powerline_fonts = 1
let g:airline#extensions#hunks#non_zero_only = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_mode_map = {
            \ '__' : '-',
            \ 'n'  : 'N',
            \ 'i'  : 'I',
            \ 'R'  : 'R',
            \ 'c'  : 'C',
            \ 'v'  : 'V',
            \ 'V'  : '-V',
            \ '' : '[V]',
            \ 's'  : 'S',
            \ 'S'  : 'S',
            \ '' : 'S',
            \ }

" let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_tab_nr = 0

" }}}
" Easy-align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:easy_aln_delimiters = {
    \ ';': { 'pattern': ';'   , 'left_margin': 0 },
    \ '[': { 'pattern': '['   , 'left_margin': 1, 'right_margin': 0 },
    \ ']': { 'pattern': ']'   , 'left_margin': 0, 'right_margin': 1 },
    \ ',': { 'pattern': ','   , 'left_margin': 0, 'right_margin': 1 },
    \ ')': { 'pattern': ')'   , 'left_margin': 0, 'right_margin': 0 },
    \ '(': { 'pattern': '('   , 'left_margin': 0, 'right_margin': 0 },
    \ '=': { 'pattern': '<\?=', 'left_margin': 1, 'right_margin': 1 },
    \ '|': { 'pattern': '|\?|', 'left_margin': 1, 'right_margin': 1 },
    \ '&': { 'pattern': '&\?&', 'left_margin': 1, 'right_margin': 1 },
    \ ':': { 'pattern': ':'   , 'left_margin': 1, 'right_margin': 1 },
    \ '?': { 'pattern': '?'   , 'left_margin': 1, 'right_margin': 1 },
    \ '<': { 'pattern': '<'   , 'left_margin': 1, 'right_margin': 0 },
    \ '\': { 'pattern': '\\'  , 'left_margin': 1, 'right_margin': 0 }
    \ }
"}}}
" Vim-lengthmatters {{{
let g:lengthmatters_highlight_one_column = 1
" }}}
" NERDTree {{{
augroup NerdTreeGroup
    autocmd!
    autocmd StdinReadPre * let s:std_in=1
    " Open NERDTree when No files are specified
    " autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
    " Close vim if only window open is NERDTree
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

function MyNerdToggle() abort
    if &filetype == 'nerdtree'
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction

nnoremap - :call MyNerdToggle()<cr>
let g:NERDTreeQuitOnOpen = 1
" }}}
" Indentline {{{
let g:indentLine_char = '│'
let g:indentLine_color_gui = '#1b2c3c'
" }}}
" FZF {{{
let g:fzf_colors = {
    \ 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment']
    \ }

nnoremap <c-p> :GitFiles<cr>
let g:fzf_layout = { 'down': '~30%' }
let g:fzf_buffers_jump = 1
" }}}
if has('nvim')
    " Deoplete {{{
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#auto_complete_delay = 50
    " let g:deoplete#sources = ['buffer', 'tag', 'file', 'omni', 'jedi' ]
    " let g:deoplete#sources = ['buffer', 'tag', 'file', 'omni', 'jedi' ]
    " set completeopt-=preview
    "}}}
    "Neosnippet {{{
    let g:neosnippet#snippets_directory='~/snippets'
    let g:neosnippet#disable_runtime_snippets = { '_' : 1 }

    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)" :
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ deoplete#mappings#manual_complete()
    function! s:check_back_space() abort "{{{
        let col = col('.') - 1
        return !col || getline ('.')[col - 1] =~ '\s'
    endfunction "}}}
    "}}}
endif
"Ale {{{
let g:ale_sh_shellcheck_options = '-x'
let g:ale_python_pylint_options = '--disable=C0326,C0103,E0401'
let g:ale_set_highlights = 1
let g:ale_sign_info = '->'
let g:ale_echo_msg_error_str = '%linter%:%severity% %s'
let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_insert_leave = 1

let g:ale_python_flake8_options = '--ignore E202,E203,E221,E251'
let g:ale_type_map = {'flake8': {'ES': 'WS', 'E': 'E'}}

let g:ale_python_mypy_options = '--strict'

let g:ale_lint_on_enter = 0

" highlight ALEError guibg=yellow guifg=red
" }}}
" }}}
" General {{{
set number
set nowrap
if version >= 704
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
set clipboard=unnamed
set scrolloff=6

if has('mouse')
    set mouse=a
endif

set diffopt+=vertical          "Show diffs in vertical splits

if has('persistent_undo')
    set undolevels=5000
    set undodir=~/.vim/tmp/undo
    set undofile " Preserve undo tree between sessions.
endif

if !has('nvim')
    set viminfo+=n~/.vim/tmp/viminfo " override ~/.viminfo default
else
    set viminfo+=n~/.vim/tmp/nviminfo " override ~/.viminfo default
endif

set splitright
set splitbelow
set spell

" }}}
" Vim {{{
" Make normal Vim behave like Neovim
" Comment settings we set elsewhere in this file
if !has('nvim')
    " 'listchars' defaults to "tab:> ,trail:-,nbsp:+"
    " 'directory' defaults to ~/.local/share/nvim/swap// (|xdg|), auto-created
    " 'backupdir' defaults to .,~/.local/share/nvim/backup (|xdg|)
    " 'sessionoptions' doesn't include "options"
    " 'undodir' defaults to ~/.local/share/nvim/undo (|xdg|), auto-created
    " 'viminfo' includes "!"
    set autoindent
    set autoread
    set backspace=indent,eol,start
    if v:version >= 704
        set belloff=all
    endif
    set complete-=i
    set display=lastline
    if v:version >= 704
        set formatoptions=tcqj
    endif
    set history=10000
    set incsearch
    if v:version >= 704
        set nolangremap
        set nrformats=bin,hex
    endif
    set showcmd
    set smarttab
    set tabpagemax=50
    set tags=./tags;,tags
    set nocompatible
    set hlsearch
    set ttyfast
    set ruler
    set laststatus=2
    set wildmenu

    " Tell vim how to use true colour.
    if v:version >= 704
        let &t_8f = "[38;2;%lu;%lu;%lum"
        let &t_8b = "[48;2;%lu;%lu;%lum"
    endif
endif
" }}}
" Nvim {{{
if has("nvim")
    let g:loaded_python_provider = 1 " Disable python2
    let g:loaded_ruby_provider   = 1 " Disable ruby

    let alt_python3_bin = '/home/lewrus01/tools/python/bin/python3.6'
    if filereadable(alt_python3_bin)
        let g:python3_host_prog = alt_python3_bin
    endif

    set inccommand=split
    set previewheight=20
endif
" }}}
" Mappings {{{
nnoremap <leader>ev :tabnew $MYVIMRC<CR>
nnoremap <leader>rv :source $MYVIMRC <bar> set fdm=marker<cr>
nnoremap <bs> :nohlsearch<cr>
nnoremap <leader>s :%s/\<<C-R><C-W>\>//g<left><left>
nnoremap <leader>w :call DeleteTrailingWS()<cr>
nnoremap <leader>d :Gdiff<CR>

nnoremap Y y$

nnoremap Q :w<cr>
vnoremap Q <nop>

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>SynStack()<CR>

" nnoremap <Tab> <C-W>w
" nnoremap <S-Tab> <C-W>W
nnoremap <Tab> gt
nnoremap <S-Tab> gT

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _ !v:count ? "<C-W>s<C-W><Down>"  : '_'

nmap <leader>an <Plug>(ale_next)
nmap <leader>ap <Plug>(ale_previous)

nmap <leader>hn <Plug>GitGutterNextHunk
nmap <leader>hp <Plug>GitGutterPrevHunk

" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '
"set list listchars=tab:›\  "Show tabs as '›   ›   '

augroup WhitespaceGroup
    autocmd!
    "Delete trailing white space on save.
    autocmd BufWrite * call DeleteTrailingWS()
augroup END

if v:version >= 704
    "Highlight trailing whitespace
    autocmd! BufEnter * call matchadd('ColorColumn', '\s\+$')
endif
" }}}
" Folding {{{
if has('folding')
    let g:vimsyn_folding = 'af' "Fold augroups and functions
    let g:sh_fold_enabled = 1
    set foldmethod=syntax

    set commentstring=#%s " This is the most common
    augroup commentstring_group
         autocmd!
         autocmd Filetype scala         setlocal commentstring=//%s
         autocmd Filetype vim           setlocal commentstring=\"%s
    augroup END
endif
" }}}
" GUI Options {{{
if has("gui_running")
    set guioptions-=m "Remove menu bar
    set guioptions-=M "Remove menu bar
    set guioptions-=L "Remove left scroll bar
    set guioptions-=R "Remove right scroll bar
    set guioptions-=r "Remove right scroll bar
    set guioptions-=T "Remove toolbar
    set guioptions-=e "Always use terminal tab line
    set guioptions-=b "Remove horizontal scroll bar
endif
"}}}
" Functions {{{

function! DeleteTrailingWS() abort "{{{
    normal mz"
    %s/\s\+$//ge
    normal `z"
endfunction "}}}

function! <SID>SynStack() abort "{{{
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction "}}}

"}}}
" Colours {{{
if has('termguicolors')
    set termguicolors
else
    let base16colorspace=256
endif

silent! colorscheme base16-harmonic16-dark
" }}}
" File Settings {{{
"VimL
let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &sw

augroup file_settings_group
    autocmd!
    autocmd Filetype scala         setlocal shiftwidth=4
    autocmd Filetype systemverilog setlocal shiftwidth=2
    autocmd Filetype systemverilog setlocal tabstop=2
    autocmd Filetype systemverilog setlocal softtabstop=2
    autocmd Filetype make          setlocal noexpandtab
    autocmd Filetype gitconfig     setlocal noexpandtab
    autocmd Filetype dirvish       setlocal nospell
    autocmd BufEnter *.log         setlocal textwidth=0
    autocmd BufEnter dotshrc       setlocal filetype=sh
    autocmd BufEnter dotcshrc      setlocal filetype=csh

    autocmd BufNewFile,BufRead *   if getline(1) == '#%Module1.0'
    autocmd BufNewFile,BufRead *       setlocal ft=tcl
    autocmd BufNewFile,BufRead *   endif
augroup END
" }}}
" Formatting {{{
set formatoptions+=r "Automatically insert comment leader after <Enter> in Insert mode.
set formatoptions+=o "Automatically insert comment leader after 'o' or 'O' in Normal mode.
set formatoptions+=l "Long lines are not broken in insert mode.
if v:version >= 704
    set breakindent      "Indent wrapped lines to match start
endif
"}}}

" vim: foldmethod=marker foldlevel=0:
