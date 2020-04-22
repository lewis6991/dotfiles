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
    autocmd! vimrc VimEnter * PlugInstall --sync | bd | source $MYVIMRC
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

augroup lazy_plugin
    autocmd!
    autocmd CursorHold *
        \   doautocmd User LazyPlugin
        \ | autocmd! lazy_plugin
augroup END

function! PlugLazy(name) "{{{
    if v:version >= 800
        Plug a:name, {'on' : []}
        let l:base = split(a:name, '/')[1]
        execute printf('autocmd lazy_plugin User LazyPlugin call plug#load("%s")', l:base)
    else
        Plug a:name
    endif
endfunction "}}}

command! -nargs=* PlugLazy call PlugLazy(<args>)

call plug#begin(s:pldir)
    PlugLazy 'junegunn/vim-plug'
    PlugLazy 'triglav/vim-visual-increment'
    PlugLazy 'tpope/vim-commentary'
    PlugLazy 'tpope/vim-surround'
    PlugLazy 'wellle/targets.vim'
    PlugLazy 'michaeljsmith/vim-indent-object'
    Plug     'dstein64/vim-startuptime'
    Plug     'lewis6991/moonlight.vim'
    Plug     'lewis6991/systemverilog.vim', { 'for': 'systemverilog' }
    Plug     'tpope/vim-fugitive'
    PlugLazy 'tpope/vim-unimpaired'
    PlugLazy 'tpope/vim-repeat'
    PlugLazy 'tpope/vim-eunuch'
    Plug     'vim-scripts/visualrepeat'
    Plug     'timakro/vim-searchant' " Highlight the current search result
    Plug     'AndrewRadev/bufferize.vim' " Dump ex command output to a buffer. e.g: ':Bufferize messages'
    Plug     'zefei/vim-wintabs'
    Plug     'tmhedberg/SimpylFold'         , { 'for': 'python'       }
    Plug     'lewis6991/tcl.vim'            , { 'for': 'tcl'          }
    Plug     'tmux-plugins/vim-tmux'        , { 'for': 'tmux'         }
    Plug     'derekwyatt/vim-scala'         , { 'for': 'scala'        }
    Plug     'raimon49/requirements.txt.vim', { 'for': 'requirements' }
    Plug     'martinda/Jenkinsfile-vim-syntax'
    Plug     'dzeban/vim-log-syntax'
    Plug     'vim-scripts/scons.vim'
    Plug     'Vimjas/vim-python-pep8-indent'
    Plug     'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug     'junegunn/fzf.vim'
    Plug     'junegunn/vim-easy-align', { 'on' : '<Plug>(EasyAlign)' }
    Plug     'whatyouhide/vim-lengthmatters'
    Plug     'justinmk/vim-dirvish'
    Plug     'dietsche/vim-lastplace'
    Plug     'christoomey/vim-tmux-navigator'
    Plug     'tmux-plugins/vim-tmux-focus-events'
    Plug     'ryanoasis/vim-devicons'
    Plug     'dense-analysis/ale'
    Plug     'powerman/vim-plugin-AnsiEsc'
    Plug     'chrisbra/Colorizer'
    Plug     'neoclide/coc.nvim', {'branch': 'release'}

    if v:version >= 800
        Plug 'lewis6991/vim-clean-fold'
    endif

    if has('nvim')
        " " Workaround for: https://github.com/neovim/neovim/issues/1822
        " Plug 'bfredl/nvim-miniyank'
        " map p <Plug>(miniyank-autoput)
        " map P <Plug>(miniyank-autoPut)

        Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
    endif

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
if v:version >= 800
    set completeopt=noinsert,menuone,noselect
endif

let &showbreak='↳ '

if has('mouse')
    set mouse=a
endif

silent! set pumblend=15

if has('nvim-0.3.2') || has('patch-8.1.0360')
    set diffopt=filler,algorithm:histogram,indent-heuristic
endif

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
if s:exists('$XDG_CONFIG_HOME')
    set spellfile=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
endif

" }}}
" Plugin Settings {{{
"Ale {{{
let g:ale_pattern_options = {
    \     '\.scala$': {'ale_enabled': 0}
    \ }

" let g:ale_echo_msg_error_str = '%linter%:%severity% %s'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
" let g:ale_python_mypy_options = '--config-file setup.cfg --follow-imports silent'
let g:ale_python_mypy_options = '--follow-imports silent'
let g:ale_set_highlights = 1
let g:ale_sh_shellcheck_options = '-x'
let g:ale_sign_info = '>'
let g:ale_tcl_nagelfar_options = '-s ~/syntaxdbjg.tcl'
let g:ale_type_map = {'flake8': {'ES': 'WS', 'E': 'E'}}
let g:ale_echo_msg_format = '%severity%->%linter%->%code: %%s'

let g:ale_linters = {}
let g:ale_linters.python = ['mypy', 'pylint', 'flake8']

if has('nvim')
    let g:ale_python_pyls_config = {
        \   'pyls': {
        \     'plugins': {
        \       'pycodestyle': {
        \         'enabled': v:false
        \       }
        \     }
        \   },
        \ }
endif

let g:ale_virtualenv_dir_names = ['venv_7', '.venv_7']

let g:ale_python_pylint_options = '--disable=bad-whitespace,invalid-name'
" }}}
" Coc {{{
call coc#add_extension(
    \    'coc-dictionary',
    \    'coc-git',
    \    'coc-json',
    \    'coc-python',
    \    'coc-tag',
    \    'coc-word',
    \    'coc-vimlsp',
    \    'coc-metals'
    \)
" }}}
" Dirvish {{{
let g:dirvish_mode = ':sort ,^.*[\/],'

nmap <silent> - :<C-U>call <SID>dirvish_toggle()<CR>

function! s:dirvish_open(cmd, bg) abort "{{{
    let path = getline('.')
    if isdirectory(path)
        if a:cmd ==# 'edit' && a:bg ==# '0'
            call dirvish#open(a:cmd, 0)
        endif
    else
        if a:bg
            call dirvish#open(a:cmd, 1)
        else
            bwipeout
            execute a:cmd ' ' path
        endif
    endif
endfunction "}}}

" call dirvish#add_icon_fn({p -> WebDevIconsGetFileTypeSymbol(p)})

function! s:dirvish_toggle() abort "{{{
    let width  = float2nr(&columns * 0.5)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    let fdir = expand('%:h')
    let path = expand('%:p')
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    if fdir ==# ''
        let fdir = '.'
    endif

    call dirvish#open(fdir)

    if !empty(path)
        call search('\V\^'.escape(path, '\').'\$', 'cw')
    endif
endfunction "}}}

augroup vimrc
    autocmd FileType dirvish nmap <silent> <buffer> <CR>  :<C-U>call <SID>dirvish_open('edit'   , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> v     :<C-U>call <SID>dirvish_open('vsplit' , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> V     :<C-U>call <SID>dirvish_open('vsplit' , 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> s     :<C-U>call <SID>dirvish_open('split'  , 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> S     :<C-U>call <SID>dirvish_open('split'  , 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> t     :<C-U>call <SID>dirvish_open('tabedit', 0)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> T     :<C-U>call <SID>dirvish_open('tabedit', 1)<CR>
    autocmd FileType dirvish nmap <silent> <buffer> -     <Plug>(dirvish_up)
    autocmd FileType dirvish nmap <silent> <buffer> <ESC> :bd<CR>
    autocmd FileType dirvish nmap <silent> <buffer> q     :bd<CR>

    autocmd FileType dirvish nmap <buffer> <C-w> <nop>
    autocmd FileType dirvish nmap <buffer> <C-h> <nop>
    autocmd FileType dirvish nmap <buffer> <C-j> <nop>
    autocmd FileType dirvish nmap <buffer> <C-k> <nop>
    autocmd FileType dirvish nmap <buffer> <C-l> <nop>

    autocmd FileType dirvish setlocal winhl=Normal:Floating
    autocmd FileType dirvish setlocal nocursorline
augroup END
" }}}
" Easy-align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
let g:easy_align_delimiters = {
    \ ';': { 'pattern': ';'      , 'left_margin': 0 },
    \ '[': { 'pattern': '['      , 'left_margin': 1, 'right_margin': 0 },
    \ ']': { 'pattern': ']'      , 'left_margin': 0, 'right_margin': 1 },
    \ ',': { 'pattern': ','      , 'left_margin': 0, 'right_margin': 1 },
    \ ')': { 'pattern': ')'      , 'left_margin': 0, 'right_margin': 0 },
    \ '(': { 'pattern': '('      , 'left_margin': 0, 'right_margin': 0 },
    \ '=': { 'pattern': '<\?=>\?', 'left_margin': 1, 'right_margin': 1 },
    \ '|': { 'pattern': '|\?|'   , 'left_margin': 1, 'right_margin': 1 },
    \ '&': { 'pattern': '&\?&'   , 'left_margin': 1, 'right_margin': 1 },
    \ ':': { 'pattern': ':'      , 'left_margin': 1, 'right_margin': 1 },
    \ '?': { 'pattern': '?'      , 'left_margin': 1, 'right_margin': 1 },
    \ '<': { 'pattern': '<'      , 'left_margin': 1, 'right_margin': 0 },
    \ '\': { 'pattern': '\\'     , 'left_margin': 1, 'right_margin': 0 },
    \ '+': { 'pattern': '+'      , 'left_margin': 1, 'right_margin': 1 }
    \ }

augroup vimrc
    autocmd FileType make let g:easy_align_delimiters['='] = {
        \     'pattern': '[:?]\?=', 'left_margin': 1, 'right_margin': 1
        \ }
    autocmd FileType scala let g:easy_align_delimiters['='] = {
        \     'pattern': '=>\?', 'left_margin': 1, 'right_margin': 1
        \ }
augroup END
"}}}
" Vim-lengthmatters {{{
let g:lengthmatters_highlight_one_column = 1
" }}}
" Wintabs {{{
let g:wintabs_ui_sep_leftmost = ' '
let g:wintabs_ui_sep_inbetween = ' '
let g:wintabs_ui_sep_rightmost = ' '
" let g:wintabs_ui_vimtab_name_format = ' %t '
" }}}
" FZF {{{
function! s:find_git_root() abort
    let a = system('git rev-parse --show-superproject-working-tree 2> /dev/null')[:-2]
    if a !=? ''
        return a
    endif
    let a = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
    if a !=? ''
        return a
    endif
    return getcwd()
endfunction

" 'source' : 'git ls-files --recurse-submodules --cached --exclude-standard || rg --no-ignore --files',
command! -bang -nargs=? -complete=dir GFiles2
    \ call fzf#vim#files(
    \     <q-args>,
    \     {
    \         'source' : 'rg --no-ignore --files',
    \         'dir'    : s:find_git_root(),
    \         'options': [
    \             '--layout=reverse',
    \             '--info=inline',
    \             '--preview',
    \             'highlight --out-format=ansi --style=base16/harmonic-dark --force {}'
    \         ]
    \     },
    \     <bang>0
    \ )

nnoremap <c-p> :<C-u>GFiles2<cr>
nnoremap <c-s> :<C-u>Ag<cr>
nnoremap <m-p> :<C-u>CocList -I symbols<cr>

" let g:fzf_layout = { 'window': '12split enew' }
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.6 } }
let g:fzf_buffers_jump = 1

let g:fzf_colors = {
    \     'fg':      ['fg', 'Normal'],
    \     'bg':      ['bg', 'Normal'],
    \     'hl':      ['fg', 'Question'],
    \     'fg+':     ['fg', 'Visual'],
    \     'bg+':     ['bg', 'Visual'],
    \     'hl+':     ['fg', 'Question'],
    \     'info':    ['fg', 'PreProc'],
    \     'border':  ['fg', 'Ignore'],
    \     'prompt':  ['fg', 'Conditional'],
    \     'pointer': ['fg', 'MoreMsg'],
    \     'marker':  ['fg', 'MoreMsg'],
    \     'spinner': ['fg', 'Label'],
    \     'header':  ['fg', 'Comment']
    \ }

let g:fzf_action = {
    \     'enter'  : 'drop',
    \     'ctrl-t' : 'tab drop',
    \     'ctrl-s' : 'split',
    \     'ctrl-v' : 'vsplit'
    \ }

augroup vimrc
    autocmd FileType fzf setlocal laststatus=0 noshowmode noruler
    autocmd FileType fzf tunmap <Esc>
augroup END

" }}}
" Plug {{{
let g:plug_window = 'tabnew'
" }}}
" }}}
" Colours {{{
silent! set termguicolors
silent! colorscheme moonlight
" }}}
" Vim {{{
" Make normal Vim behave like Neovim
" Comment settings we set elsewhere in this file
if !has('nvim')
    set autoindent
    set autoread
    set backspace=indent,eol,start
    set complete-=i
    set display=lastline
    if v:version >= 704
        set formatoptions=tcqj
    endif
    set history=10000
    set incsearch
    set showcmd
    set smarttab
    set tabpagemax=50
    set hlsearch
    set ruler
    set laststatus=2
    set wildmenu

    " Tell vim how to use true colour.
    if v:version >= 800
        let &t_8f = '[38;2;%lu;%lu;%lum'
        let &t_8b = '[48;2;%lu;%lu;%lum'
    endif
endif
" }}}
" Nvim {{{
if has('nvim')
    let g:loaded_python_provider = 1 " Disable python2
    let g:loaded_ruby_provider   = 1 " Disable ruby

    let hostname = substitute(system('hostname'), '\n', '', '')
    if hostname ==# 'cem-dev'
        let g:python3_host_prog = '/devtools/linuxbrew/bin/python3'
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

" I never use macros and more often mis-hit this key
nnoremap q <nop>

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>syn_stack()<CR>

" nnoremap <Tab>   gt
" nnoremap <S-Tab> gT

nmap <Tab>   <Plug>(wintabs_next)
nmap <S-Tab> <Plug>(wintabs_previous)
" nmap <Tab>   :bnext<CR>
" nmap <S-Tab> :bprev<CR>

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <C-A> <Home>
cnoremap <C-D> <Del>

inoremap <silent><expr> <TAB>
      \ pumvisible()            ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

" Notify coc.nvim that <enter> has been pressed.
" Currently used for the formatOnType feature.
inoremap <silent><expr> <CR>
    \ pumvisible() ? coc#_select_confirm() :
    \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" nnoremap & /\<<C-R><C-w>\>\C<CR>

nmap [c <Plug>(coc-git-prevchunk)
nmap ]c <Plug>(coc-git-nextchunk)

nmap <leader>hs :CocCommand git.chunkStage<cr>
nmap <leader>hu :CocCommand git.chunkUndo<cr>
nmap <leader>hv <Plug>(coc-git-chunkinfo)

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
    set foldminlines=10
endif

" }}}
" Functions {{{

function! s:syn_stack() abort "{{{
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, ''name'')')
endfunction "}}}

function! YamlFolds() abort "{{{
    let l:previous_level = indent(prevnonblank(v:lnum - 1)) / &shiftwidth
    let l:current_level = indent(v:lnum) / &shiftwidth
    let l:next_level = indent(nextnonblank(v:lnum + 1)) / &shiftwidth

    if getline(v:lnum + 1) =~? '^\s*$'
        return '='
    elseif l:current_level < l:next_level
        return l:next_level
    elseif l:current_level > l:next_level
        return ('s' . (l:current_level - l:next_level))
    elseif l:current_level == l:previous_level
        return '='
    endif

    return l:next_level
endfunction "}}}

function! JsonFolds() abort "{{{
    let l:line = getline(v:lnum)
    " let l:lline = split(l:line, '\zs')
    let l:inc = count(l:line, '{')
    let l:dec = count(l:line, '}')
    let l:level = inc - dec
    if l:level == 0
        return '='
    elseif l:level > 0
        return 'a'.l:level
    elseif l:level < 0
        return 's'.-l:level
    endif
endfunction "}}}

function! MakeFolds() abort "{{{
    let l:line1 = getline(v:lnum)
    let l:line2 = getline(v:lnum+1)
    if l:line1 =~# '^# \w\+' && l:line2 =~# '^#-\+$'
        return '>1'
    else
        return '='
    endif
endfunction "}}}

"}}}
" File Settings {{{
"VimL
" let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &shiftwidth

let g:xml_syntax_folding=1

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
    autocmd BufRead coc-settings.json syntax match Comment +\/\/.\+$+
    autocmd BufRead coc-settings.json setlocal commentstring=//%s

    autocmd BufRead * if getline(1) =~ '^#%Module.*'
                  \ |     setlocal ft=tcl
                  \ | endif
    autocmd BufRead modulefile            setlocal filetype=tcl
augroup END

" Commentstring
augroup vimrc
    autocmd Filetype sbt.scala   setlocal commentstring=//%s
    autocmd Filetype Jenkinsfile setlocal commentstring=//%s
augroup END

" Filetype settings

function! s:enable_coc_mappings() abort "{{{
    nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
    nmap <buffer> <silent> <C-q> <Plug>(coc-diagnostic-info)
    nmap <buffer> <silent> [d    <Plug>(coc-diagnostic-prev)
    nmap <buffer> <silent> ]d    <Plug>(coc-diagnostic-next)
    nmap <buffer> <silent> gr    <Plug>(coc-references)

    function! s:show_documentation() abort
        if &filetype ==# 'vim'
            execute 'h '.expand('<cword>')
        else
            call CocActionAsync('doHover')
        endif
    endfunction
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    autocmd! CursorHold * silent call CocActionAsync('highlight')
    highlight CocHighlightText ctermbg=8 guibg=#444650
endfunction "}}}

function! s:man_settings() abort "{{{
    setlocal laststatus=0
    setlocal nomodified
    setlocal showbreak=
    map <buffer><nowait> d <C-d>
    map <buffer><nowait> u <C-u>
endfunction "}}}

function! s:python_settings() abort "{{{
    call s:enable_coc_mappings()

    let g:ale_enabled = v:false

    setlocal foldminlines=0

    highlight semshiSelected ctermbg=8 guibg=#444A54
endfunction "}}}

function! s:scala_settings() abort "{{{
    setlocal shiftwidth=4
    setlocal softtabstop=4
    setlocal tabstop=4
    setlocal foldlevelstart=1
    setlocal foldnestmax=3

    call s:enable_coc_mappings()
endfunction "}}}

function! s:json_settings() abort "{{{
    setlocal conceallevel=0
    setlocal foldnestmax=5
    setlocal foldmethod=marker
    setlocal foldmarker={,}

    setlocal foldmethod=expr
    setlocal foldexpr=JsonFolds()
    setlocal nofoldenable
endfunction "}}}

function! s:make_settings() abort "{{{
    setlocal noexpandtab
    setlocal foldmethod=expr
    setlocal foldexpr=MakeFolds()
endfunction "}}}

function! s:tcl_settings() abort "{{{
    setlocal keywordprg=:FloatingTclMan
endfunction "}}}

function! s:systemverilog_settings() abort "{{{
    setlocal shiftwidth=4
    setlocal tabstop=4
    setlocal softtabstop=4
endfunction "}}}

augroup vimrc "{{{
    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype gitconfig     setlocal noexpandtab

    autocmd FileType yaml          setlocal foldmethod=expr
        \                                   foldexpr=YamlFolds()

    autocmd Filetype log           setlocal textwidth=1000
    autocmd FileType xml           setlocal foldnestmax=20
        \                                   foldcolumn=5

    autocmd Filetype groovy setlocal errorformat+=
        \%PErrors\ encountered\ validating\ %f:,
        \%EWorkflowScript:\ %l:\ %m\ column\ %c.,%-C%.%#,%Z
    autocmd Filetype groovy setlocal makeprg=java\ -jar\ ~/jenkins-cli.jar\ -s\ http://cem-jenkins.euhpc.arm.com\ declarative-linter\ <\ Jenkinsfile

    autocmd Filetype fugitiveblame  set cursorline
augroup END "}}}

for ft in [
    \     'systemverilog',
    \     'make',
    \     'man',
    \     'python',
    \     'scala',
    \     'json',
    \     'tcl'
    \ ]
    execute 'autocmd vimrc Filetype '.ft.' call s:'.ft.'_settings()'
endfor

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
"}}}
" Snippets {{{
iabbrev :rev:
    \ <c-r>=substitute(&commentstring, '%s', '', '').
    \' REVISIT '.$USER.' ('.strftime("%d/%m/%y").'):'<CR>
" }}}
" Statusline {{{
function! s:strip(input_string) "{{{
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction "}}}

function! Hunks() abort "{{{
    if exists('b:coc_git_status')
        return trim(b:coc_git_status)
    endif
endfunction "}}}

function! EncodingAndFormat() abort "{{{
    let l:e = &fileencoding ? &fileencoding : &encoding
    let l:f = &fileformat

    if l:e ==# 'utf-8'
        let l:e = ''
    endif

    if l:f ==# 'unix'
        let l:f = ''
    else
        let l:f = '['.l:f.']'
    endif

    return s:strip(join([l:e, l:f]))
endfunction "}}}

function! s:aleStatusLine(active) abort "{{{
    let l:keydisp = {
        \     'error'         : 'DiffRemoved',
        \     'warning'       : 'DiffLine'   ,
        \     'style_error'   : 'DiffRemoved',
        \     'style_warning' : 'DiffLine'   ,
        \     'info'          : 'DiffAdded'
        \ }

    let l:alestatus = []
    for l:key in keys(l:keydisp)
        let l:entry = ''
        if a:active
            let l:entry .= '%#' . l:keydisp[l:key] . '#'
        endif
        let l:entry .= '%( %{AleMsg("'.l:key.'")} %)'
        let l:alestatus += [l:entry]
    endfor

    return join(l:alestatus, '')
endfunction "}}}

function! AleMsg(msgtype) abort "{{{
    try
        let l:aleinfo = ale#statusline#Count(bufnr('%'))
    catch
        return ''
    endtry

    if l:aleinfo['total'] == 0
        return ''
    endif

    let l:keydisp = {
        \     'error'         : 'E' ,
        \     'warning'       : 'W' ,
        \     'style_error'   : 'SE',
        \     'style_warning' : 'SW',
        \     'info'          : 'I'
        \ }

    if l:aleinfo[a:msgtype] > 0
        return l:keydisp[a:msgtype] . ':' . l:aleinfo[a:msgtype]
    endif

    return ''
endfunction "}}}

function! s:status_highlight(no, active) abort "{{{
    if a:active
        if   a:no == 1 | return '%#PmenuSel#'
        else           | return '%#Visual#'
        endif
    else
        if   a:no == 3 | return '%#StatusLine#'
        else           | return '%#StatusLine#'
        endif
    endif
endfunction "}}}

function! s:recording() abort "{{{
    if !exists('*reg_recording')
        return ''
    endif

    let reg = reg_recording()
    if reg !=# ''
        return '%#ModeMsg#  RECORDING['.reg.']  '
    else
        return ''
    endif
endfunction "}}}

function! StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info)
        return ''
    endif
    let msgs = []
    if get(info, 'error', 0)
        call add(msgs, 'E:' . info['error'])
    endif
    if get(info, 'warning', 0)
        call add(msgs, 'W:' . info['warning'])
    endif
    if get(info, 'information', 0)
        call add(msgs, 'I:' . info['warning'])
    endif
    if get(info, 'hint', 0)
        call add(msgs, 'H:' . info['warning'])
    endif
    return join(msgs, ' ') . ' ' . get(g:, 'coc_status', '')
endfunction

function! Statusline_expr(active) abort "{{{
    let l:s = '%#StatusLine#'
    let l:s .= s:status_highlight(1, a:active) . s:recording()
    let l:s .= s:status_highlight(1, a:active) . '%( %{Hunks()}  %)'
    let l:s .= s:status_highlight(2, a:active) . s:aleStatusLine(a:active)
    let l:s .= s:status_highlight(2, a:active) . '%( %{StatusDiagnostic()}  %)'
    let l:s .= s:status_highlight(3, a:active) . '%='
    let l:s .= s:status_highlight(3, a:active) . '%<%0.60f%m%r'  " file.txt[+][RO]
    let l:s .= ' %= '
    let l:s .= s:status_highlight(2, a:active) . '%(  %{&filetype} %)'
    if exists('*WebDevIconsGetFileTypeSymbol')
        let l:s .= '%( %{WebDevIconsGetFileTypeSymbol()}  %)'
    endif
    if exists('*WebDevIconsGetFileFormatSymbol')
        let l:s .= s:status_highlight(1, a:active) . '%(  %{EncodingAndFormat()}%{WebDevIconsGetFileFormatSymbol()}%)'
    endif
    let l:s .= s:status_highlight(1, a:active) . ' %3p%% %3l(%02c)/%-3L ' " 80% 65[12]/120
    return l:s
endfunction "}}}

augroup vimrc
    " Only set up WinEnter autocmd when the WinLeave autocmd runs
    autocmd WinLeave,FocusLost *
        \ setlocal statusline=%!Statusline_expr(0) |
        \ autocmd vimrc WinEnter,FocusGained *
            \ setlocal statusline=%!Statusline_expr(1)
augroup END

set statusline=%!Statusline_expr(1)

"}}}
" Tabline {{{
" set tabline=%!MyTabLine()

" function! MyTabLine() abort "{{{
"     let l:s = ''
"     for l:i in range(tabpagenr('$'))
"         let l:t = l:i + 1
"         " select the highlighting
"         if l:t == tabpagenr()
"             let l:s .= '%#TabLineSel#'
"         else
"             let l:s .= '%#TabLine#'
"         endif

"         let l:s .= ' '
"         if exists('*WebDevIconsGetFileTypeSymbol')
"             let l:s .= '%{WebDevIconsGetFileTypeSymbol(MyTabLabel(' . l:t . '))}'
"         endif
"         let l:s .= ' %{MyTabLabel(' . l:t . ')}'
"         let l:s .= ' '
"     endfor

"     " after the last tab fill with TabLineFill and reset tab page nr
"     let l:s .= '%#TabLineFill#%T'

"     return l:s
" endfunction "}}}

" function! MyTabLabel(n) abort "{{{
"     let l:buflist = tabpagebuflist(a:n)
"     let l:winnr = tabpagewinnr(a:n)
"     let l:path = bufname(l:buflist[l:winnr - 1])
"     let l:label = fnamemodify(l:path, ':t')

"     if l:label ==# ''
"         let l:label = '[NONE]'
"     endif

"     return l:label
" endfunction "}}}
" }}}
" Terminal {{{
if has('nvim')
    augroup vimrc
        autocmd TermOpen * setlocal
            \ nonumber
            \ norelativenumber
            \ nospell
        autocmd TermOpen * startinsert
    augroup END

    tnoremap <Esc> <c-\><c-n>
endif
"}}}
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
        autocmd vimrc BufWritePost <buffer> * silent !chmod u+x %
    endif
endfunction "}}}

command! Hashbang call Hashbang()

command! -nargs=* FloatingMan call ToggleCommand('execute ":r !man -D '.<q-args>. '" | Man!')

set keywordprg=:FloatingMan

function! MyLazy()
    call ToggleTerm('lazygit')
endfunction

command! -nargs=* FloatingTclMan call ToggleCommand('execute ":r !man -D n '.<q-args>. '" | Man!')

function! CreateCenteredFloatingWindow() "{{{
    let width  = float2nr(&columns * 0.8)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = { 'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
endfunction "}}}

" Floating window with a border
function! CreateCenteredFloatingWindow2() "{{{
    let width  = float2nr(&columns * 0.8)
    let height = float2nr(&lines * 0.8)
    let top    = ((&lines - height) / 2) - 1
    let left   = (&columns - width) / 2
    let opts   = { 'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal' }
    let top    = "╭" . repeat("─", width - 2) . "╮"
    let mid    = "│" . repeat(" ", width - 2) . "│"
    let bot    = "╰" . repeat("─", width - 2) . "╯"
    let lines  = [top] + repeat([mid], height - 2) + [bot]
    let s:buf  = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    setlocal winhl=Normal:Normal
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, CreatePadding(opts))
    setlocal winhl=Normal:Normal
    autocmd BufWipeout <buffer> exe 'bwipeout '.s:buf
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

function! ToggleTerm(cmd) abort "{{{
    if empty(bufname(a:cmd))
        call CreateCenteredFloatingWindow()
        call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
    else
        bwipeout!
    endif
endfunction "}}}

function! OnTermExit(job_id, code, event) dict "{{{
    if a:code == 0
        bwipeout!
    endif
endfunction "}}}
"}}}
"
let g:bufferize_command = 'enew'
augroup vimrc
    autocmd FileType bufferize setlocal wrap
augroup END

" Brighten coc floating windows
highlight link NormalFloat StatusLine

let g:man_hardwrap=1

"" vim: foldmethod=marker foldminlines=0
