" Init {{{

function! s:CheckVar(var)
    if eval(printf('empty($%s)', a:var))
        echoerr a:var.' is not defined'
        return 0
    endif
    return 1
endfunction

if !has('nvim')
    if s:CheckVar("XDG_CONFIG_HOME") && s:CheckVar("XDG_DATA_HOME")
        set runtimepath=
            \$XDG_CONFIG_HOME/vim,
            \$XDG_DATA_HOME/vim/site,
            \$VIMRUNTIME,
            \$XDG_DATA_HOME/vim/site/after,
            \$XDG_CONFIG_HOME/vim/after
    endif
    if s:CheckVar("XDG_DATA_HOME")
        set directory=$XDG_DATA_HOME/vim/swap
    endif
    if s:CheckVar("XDG_CACHE_HOME")
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

function! PlugLazy(...) "{{{
    let l:name = a:1
    if v:version >= 800
        Plug l:name, {'on' : []}
        let l:au_prefix = 'autocmd lazy_plugin User LazyPlugin'

        let l:base = split(l:name, '/')[1]
        execute printf('%s call plug#load("%s")', l:au_prefix, l:base)

        if a:0 > 1
            let l:post_cmds = a:000[2:]
            for cmd in l:post_cmds
                execute printf('%s %s', l:au_prefix, cmd)
            endfor
        endif
    else
        Plug l:name
    endif
endfunction "}}}

command! -nargs=* PlugLazy call PlugLazy(<args>)

call plug#begin(s:pldir)
    PlugLazy 'junegunn/vim-plug'

    Plug     '~/projects/dotfiles/modules/moonlight.vim'
    " Plug 'lewis6991/systemverilog.vim', { 'for': 'systemverilog' }
    Plug     '~/projects/systemverilog.vim', { 'for': 'systemverilog' }

    Plug     'tpope/vim-fugitive'
    PlugLazy 'tpope/vim-commentary'
    PlugLazy 'tpope/vim-unimpaired'
    Plug     'tpope/vim-surround'
    PlugLazy 'tpope/vim-repeat'
    PlugLazy 'tpope/vim-eunuch'
    Plug     'vim-scripts/visualrepeat'
    Plug     'timakro/vim-searchant'
    Plug     'martinda/Jenkinsfile-vim-syntax'
    Plug     'tmhedberg/SimpylFold' , { 'for': 'python' }
    Plug     'lewis6991/tcl.vim'    , { 'for': 'tcl'    }
    Plug     'tmux-plugins/vim-tmux', { 'for': 'tmux'   }
    Plug     'dzeban/vim-log-syntax'
    Plug     'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    PlugLazy 'junegunn/fzf.vim'
    Plug     'junegunn/vim-easy-align', { 'on' : '<Plug>(EasyAlign)' }
    Plug     'whatyouhide/vim-lengthmatters'
    PlugLazy 'gaving/vim-textobj-argument'
    PlugLazy 'michaeljsmith/vim-indent-object'
    Plug     'justinmk/vim-dirvish'
    Plug     'christoomey/vim-tmux-navigator'
    Plug     'dietsche/vim-lastplace'
    Plug     'tmux-plugins/vim-tmux-focus-events'
    Plug     'ryanoasis/vim-devicons'
    Plug     'derekwyatt/vim-scala', {'for': 'scala'}
    Plug     'raimon49/requirements.txt.vim', {'for': 'requirements'}
    PlugLazy 'dense-analysis/ale'

    if v:version >= 800
        Plug 'lewis6991/vim-clean-fold'
        " Plug 'airblade/vim-gitgutter'
    endif

    Plug 'Shougo/neco-vim'
    Plug 'neoclide/coc-neco'

    " coc-dictionary
    " coc-git
    " coc-json
    " coc-python
    " coc-tag
    " coc-word

    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    if has('nvim')
        " Workaround for: https://github.com/neovim/neovim/issues/1822
        Plug 'bfredl/nvim-miniyank'
        map p <Plug>(miniyank-autoput)
        map P <Plug>(miniyank-autoPut)

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
set sidescroll=1
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

if has('mouse')
    set mouse=a
endif

silent! set pumblend=20

if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=filler,algorithm:histogram,indent-heuristic
endif

set diffopt+=vertical  "Show diffs in vertical splits

if !empty($SSH_TTY)
    let g:clipboard = {
          \   'name': 'pb-remote',
          \   'copy':  {'+': 'pbcopy-remote' , '*': 'pbcopy-remote' },
          \   'paste': {'+': 'pbpaste-remote', '*': 'pbpaste-remote'},
          \   'cache_enabled': 1,
          \ }
endif

if has('persistent_undo')
    set undolevels=10000
    set undofile " Preserve undo tree between sessions.
endif

set splitright
set splitbelow
set spell
if s:CheckVar("XDG_CONFIG_HOME")
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
let g:ale_python_mypy_options = '--config-file setup.cfg'
let g:ale_set_highlights = 1
let g:ale_sh_shellcheck_options = '-x'
let g:ale_sign_info = '>'
let g:ale_tcl_nagelfar_options = '-s ~/syntaxdbjg.tcl'
let g:ale_type_map = {'flake8': {'ES': 'WS', 'E': 'E'}}
let g:ale_echo_msg_format = '%severity%->%linter%->%code: %%s'

let g:ale_linters = {}
" let g:ale_linters.python = ['vulture', 'mypy', 'pylint']
" let g:ale_linters.python = ['pyls', 'pylint']
let g:ale_linters.python = ['mypy', 'pylint', 'flake8']
" let g:ale_linters.scala = ['fsc', 'sbtserver', 'scalastyle']
" let g:ale_linters.scala = ['fsc', 'scalastyle']
let g:ale_linters.scala = []

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
" let g:ale_python_pylint_options = '--disable=bad-whitespace,missing-docstring,line-too-long,invalid-name'
" }}}
" Dirvish {{{
let g:dirvish_mode = ':sort ,^.*[\/],'

nmap <silent> - :<C-U>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort "{{{
    " Close any existing dirvish buffers
    for l:i in range(1, bufnr('$'))
        if bufexists(l:i) && bufloaded(l:i) && getbufvar(l:i, '&filetype') ==? 'dirvish'
            execute ':'.l:i.'bd!'
        endif
    endfor

    if expand('%') ==# ''
        Dirvish
    else
        30vsp
        Dirvish %
    endif
endfunction "}}}

function! s:dirvish_open(cmd) abort "{{{
    let l:path = getline('.')
    if !isdirectory(l:path)
        if bufname(bufnr('#')) !=? ''
            execute 'bd'
        endif
    endif
    execute a:cmd.' '.l:path
endfunction "}}}

augroup vimrc "{{{
    autocmd FileType dirvish nnoremap <silent> <buffer> <CR>  :<C-U>.call <SID>dirvish_open('edit')<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> -     <Plug>(dirvish_up)
    autocmd FileType dirvish nmap     <silent> <buffer> <ESC> :bd<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> q     :bd<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> v     :<C-U>call <SID>dirvish_open('vsplit')<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> s     :<C-U>call <SID>dirvish_open('split')<CR>

    autocmd Filetype dirvish setlocal nospell
    autocmd Filetype dirvish setlocal statusline=%f
    autocmd Filetype dirvish setlocal nonumber
    autocmd Filetype dirvish setlocal norelativenumber
augroup END "}}}
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
augroup END
"}}}
" Vim-lengthmatters {{{
let g:lengthmatters_highlight_one_column = 1
" }}}
" Gitgutter {{{
let g:gitgutter_max_signs=3000
let g:gitgutter_sign_added              = '│'  " '+'
let g:gitgutter_sign_modified           = '│'  " '~'
let g:gitgutter_sign_removed            = '_'  " '_'
let g:gitgutter_sign_removed_first_line = '‾'  " '‾'
let g:gitgutter_sign_modified_removed   = '│'  " '~_'
" }}}
" FZF {{{
function! s:find_git_root() abort
    let a = system('git rev-parse --show-superproject-working-tree')[:-2]
    if a != ''
        return a
    endif
    return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! FZFMix call fzf#run(fzf#wrap('my_cmd', {
    \ 'dir' : s:find_git_root(),
    \ }))

command! GFiles2 call fzf#run(fzf#wrap('my_cmd', {
    \ 'source': 'git ls-files --recurse-submodules && git ls-files --others --exclude-standard',
    \ 'dir' : s:find_git_root(),
    \ }))

" nnoremap <c-p> :FZFMix<cr>
nnoremap <c-p> :GFiles2<cr>
nnoremap <c-space> :FZFMix<cr>
nnoremap <c-s> :Ag<cr>

let g:fzf_layout = { 'window': '12split enew' }
let g:fzf_buffers_jump = 1

let g:fzf_colors = {
    \ 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Question'],
    \ 'fg+':     ['fg', 'Visual'],
    \ 'bg+':     ['bg', 'Visual'],
    \ 'hl+':     ['fg', 'Question'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'MoreMsg'],
    \ 'marker':  ['fg', 'MoreMsg'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment'] }

let g:fzf_action = {
  \     'enter'  : 'drop',
  \     'ctrl-t' : 'tab drop',
  \     'ctrl-x' : 'split',
  \     'ctrl-v' : 'vsplit'
  \ }

augroup vimrc
    autocmd FileType fzf        set laststatus=0 noshowmode noruler
        \ | autocmd BufLeave <buffer> set laststatus=2   showmode   ruler
    autocmd FileType fzf tunmap <Esc>
augroup END

" }}}
" LanguageClient {{{
" let g:LanguageClient_diagnosticsEnable = 0

" let g:LanguageClient_settingsPath = '~/.lsp_settings.json'
" let g:LanguageClient_serverCommands = {
"     \     'scala': ['metals-vim'],
"     \     'python': ['setup.cfg']
"     \ }

" let g:LanguageClient_loggingFile = expand('~/LanguageClient.log')
" let g:LanguageClient_useFloatingHover = 1
" let g:LanguageClient_windowLogMessageLevel = 'Log'

" " " Having LogMessageLevel set to Log interferes with non-preview
" " " displaying of Hover
" " let g:LanguageClient_hoverPreview = 'Never'
" nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
" nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
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
    let g:loaded_node_provider   = 1 " Disable node

    let hostname = substitute(system('hostname'), '\n', '', '')
    if hostname ==# 'cem-dev'
        let g:python3_host_prog = '/devtools/linuxbrew/bin/python3'
    endif

    set inccommand=split
    set previewheight=30

    silent highlight EndOfBuffer ctermfg=bg guifg=bg
endif
" }}}
" Mappings {{{
nnoremap <leader>ev :tabnew $MYVIMRC<CR>
nnoremap <leader>rv :source $MYVIMRC<bar>edit!<CR>
nnoremap <leader>s :%s/\<<C-R><C-W>\>\C//g<left><left>
nnoremap <leader>c 1z=
nnoremap <leader>w :execute "resize ".line('$')<cr>

nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>

nnoremap <M-]> <C-w><c-]><C-w>T

nnoremap j gj
nnoremap k gk

nnoremap Y y$

nnoremap Q :w<cr>
vnoremap Q <nop>

" I never use macros and more often mishit this key
nnoremap q <nop>

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>syn_stack()<CR>

nnoremap <Tab>   gt
nnoremap <S-Tab> gT

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <C-A> <Home>
cnoremap <C-D> <Del>

" inoremap <silent><expr> <TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nnoremap & /\<<C-R><C-w>\>\C<CR>

nmap [c <Plug>(coc-git-prevchunk)
nmap ]c <Plug>(coc-git-nextchunk)

nmap <leader>hs :CocCommand git.chunkStage<cr>
nmap <leader>hu :CocCommand git.chunkUndo<cr>
nmap <leader>hv <Plug>(coc-git-chunkinfo)

if has('nvim')
    autocmd vimrc TermOpen * tnoremap <Esc> <c-\><c-n>
endif

cnoreabbrev <expr> h    getcmdtype() == ":" && getcmdline() == 'h'    ? 'tab h'    : 'h'
cnoreabbrev <expr> help getcmdtype() == ":" && getcmdline() == 'help' ? 'tab help' : 'help'
" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '

if v:version >= 800
    "Delete trailing white space on save.
    autocmd vimrc BufWrite * call <SID>delete_trailing_ws()

    "Highlight trailing whitespace
    autocmd vimrc BufEnter * call matchadd('ColorColumn', '\s\+$')
endif
" }}}
" Folding {{{
if has('folding')
    let g:vimsyn_folding = 'af' "Fold augroups and functions
    let g:sh_fold_enabled = 1
    set foldmethod=syntax
    set foldcolumn=0
    set foldnestmax=2
    set foldopen+=jump
endif

" }}}
" Functions {{{
function! s:delete_trailing_ws() abort "{{{
    " Save cursor position
    let l:save = winsaveview()

    " vint: -ProhibitCommandWithUnintendedSideEffect
    " vint: -ProhibitCommandRelyOnUser
    " Remove trailing whitespace
    %s/\s\+$//ge
    " vint: +ProhibitCommandWithUnintendedSideEffect
    " vint: +ProhibitCommandRelyOnUser

    " Move cursor to original position
    call winrestview(l:save)
endfunction "}}}

function! s:syn_stack() abort "{{{
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, ''name'')')
endfunction "}}}

function! s:qualified_tag_jump() abort "{{{
    let l:plain_tag = expand('<cword>')
    let l:orig_keyword = &iskeyword
    set iskeyword+=\.
    let l:word = expand('<cword>')
    let &iskeyword = l:orig_keyword

    let l:splitted = split(l:word, '\.')
    let l:acc = []
    for wo in l:splitted
        let l:acc = add(l:acc, wo)
        if wo ==# l:plain_tag
            break
        endif
    endfor

    let l:combined = join(l:acc, '.')
    try
        execute 'ta ' . l:combined
    catch /.*E426.*/ " Tag not found
        execute 'ta ' . l:plain_tag
    endtry
endfunction "}}}

nnoremap <silent> <C-]> :<C-u>call <SID>qualified_tag_jump()<CR>

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
let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
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
    autocmd BufRead coc-settings.json syntax match Comment +\/\/.\+$+
    autocmd BufRead coc-settings.json setlocal commentstring=//%s

    autocmd BufRead * if getline(1) =~ '^#%Module.*'
                  \ |     setlocal ft=tcl
                  \ | endif
    autocmd BufRead modulefile            setlocal filetype=tcl
augroup END

" Commentstring
augroup vimrc
    autocmd Filetype sbt.scala setlocal commentstring=//%s
augroup END

" Filetype settings

function! s:man_settings() abort "{{{
    setlocal laststatus=0
    setlocal nomodified
    map <nowait> q :q<CR>
    map <nowait> d <C-d>
    map <nowait> u <C-u>
endfunction "}}}

function! s:enable_coc_mappings() abort "{{{
    nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
    nmap <buffer> <silent> <C-q> <Plug>(coc-diagnostic-info)
    nmap <buffer> <silent> [d    <Plug>(coc-diagnostic-prev)
    nmap <buffer> <silent> ]d    <Plug>(coc-diagnostic-next)
    nmap <buffer> <silent> gr    <Plug>(coc-references)

    function! s:show_documentation() abort
        if &filetype == 'vim'
            execute 'h '.expand('<cword>')
        else
            call CocAction('doHover')
        endif
    endfunction
    nnoremap <silent> K :call <SID>show_documentation()<CR>
endfunction "}}}

function! s:python_settings() abort "{{{
    call s:enable_coc_mappings()

    highlight semshiSelected ctermbg=8 guibg=#444A54
endfunction "}}}

function! s:scala_settings() abort "{{{
    setlocal shiftwidth=4
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
endfunction "}}}

augroup vimrc "{{{
    autocmd Filetype systemverilog setlocal shiftwidth=4
        \                                   tabstop=4
        \                                   softtabstop=4

    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype gitconfig     setlocal noexpandtab

    autocmd Filetype make          setlocal noexpandtab
        \                                   foldmethod=expr
        \                                   foldexpr=MakeFolds()

    autocmd FileType yaml          setlocal foldmethod=expr
        \                                   foldexpr=YamlFolds()

    autocmd Filetype log           setlocal textwidth=1000
    autocmd FileType xml           setlocal foldnestmax=20
        \                                   foldcolumn=5

    autocmd Filetype groovy setlocal errorformat+=
        \%PErrors\ encountered\ validating\ %f:,
        \%EWorkflowScript:\ %l:\ %m\ column\ %c.,%-C%.%#,%Z
    autocmd Filetype groovy setlocal makeprg=java\ -jar\ ~/jenkins-cli.jar\ -s\ http://cem-jenkins.euhpc.arm.com\ declarative-linter\ <\ Jenkinsfile

    autocmd FileType man    call s:man_settings()
    autocmd FileType python call s:python_settings()
    autocmd Filetype scala  call s:scala_settings()
    autocmd Filetype json   call s:json_settings()

    autocmd Filetype fugitiveblame  set cursorline
augroup END "}}}
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
iabbrev rev
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
    if !(v:version >= 704 && exists('*GitGutterGetHunkSummary'))
        return ''
    endif

    let l:hunks = copy(GitGutterGetHunkSummary())
    let l:map = {1: '~', 0: '+', 2: '-'}

    for l:key in keys(l:map)
        let l:s = ''
        let l:t = l:hunks[l:key]
        if l:t !=# '0'
            let l:s = l:map[l:key] . l:t
        endif
        let l:hunks[l:key] = l:s
    endfor

    return s:strip(join(l:hunks))
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
        else           | return '%#VertSplit#'  " Hidden
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
    if exists('*WebDevIconsGetFileTypeSymbol')
        let l:s .= '%( %{WebDevIconsGetFileTypeSymbol()} %)'
    endif
    let l:s .= ' %= '
    let l:s .= s:status_highlight(2, a:active) . '%(  %{&filetype}  %)'
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
set tabline=%!MyTabLine()

function! MyTabLine() abort "{{{
    let l:s = ''
    for l:i in range(tabpagenr('$'))
        let l:t = l:i + 1
        " select the highlighting
        if l:t == tabpagenr()
            let l:s .= '%#TabLineSel#'
        else
            let l:s .= '%#TabLine#'
        endif

        let l:s .= ' '
        if exists('*WebDevIconsGetFileTypeSymbol')
            let l:s .= '%{WebDevIconsGetFileTypeSymbol(MyTabLabel(' . l:t . '))}'
        endif
        let l:s .= ' %{MyTabLabel(' . l:t . ')}'
        let l:s .= ' '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let l:s .= '%#TabLineFill#%T'

    return l:s
endfunction "}}}

function! MyTabLabel(n) abort "{{{
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:path = bufname(l:buflist[l:winnr - 1])
    let l:label = fnamemodify(l:path, ':t')

    if l:label ==# ''
        let l:label = '[NONE]'
    endif

    return l:label
endfunction "}}}
" }}}
" Terminal {{{
if has('nvim')
    augroup vimrc
        autocmd TermOpen * setlocal nonumber
        autocmd TermOpen * setlocal norelativenumber
        autocmd TermOpen * setlocal nospell
    augroup END
endif
"}}}
" vim: foldmethod=marker
