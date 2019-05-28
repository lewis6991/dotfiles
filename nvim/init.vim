" Init {{{
if empty($XDG_CONFIG_HOME)
    echoerr 'XDG_CONFIG_HOME is not defined'
    quitall
endif

scriptencoding utf-8

if v:version >= 800
    augroup vimrc | autocmd! | augroup END

    augroup lazy_plugin
        autocmd!
        autocmd CursorHold *
            \   doautocmd User LazyPlugin
            \ | autocmd! lazy_plugin
    augroup END
endif

" }}}
" Plugins {{{

    " Install vim-plug if we don't already have it {{{
    if empty(glob(expand('$XDG_CONFIG_HOME/nvim/autoload/plug.vim')))
        !mkdir -p $XDG_CONFIG_HOME/nvim/tmp/
        !mkdir -p $XDG_CONFIG_HOME/nvim/tmp/undo
        !mkdir -p $XDG_CONFIG_HOME/nvim/tmp/backup
        !mkdir -p $XDG_CONFIG_HOME/nvim/plugged
        !mkdir -p $XDG_CONFIG_HOME/nvim/autoload
        !wget -nc -q github.com/junegunn/vim-plug/raw/master/plug.vim -P $XDG_CONFIG_HOME/nvim/autoload/
        autocmd! vimrc VimEnter * PlugInstall --sync | bd | source $MYVIMRC
    endif

    " Install vim-pathogen if we don't already have it
    if empty(glob(expand('$XDG_CONFIG_HOME/nvim/autoload/pathogen.vim')))
        !mkdir -p $XDG_CONFIG_HOME/nvim/autoload
        !curl -LSso $XDG_CONFIG_HOME/nvim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    endif
    "}}}

let g:loaded_netrwPlugin = 1  " Stop netrw loading

" Load any plugins which are work sensitive.
silent execute pathogen#infect('~/gerrit/{}')

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

call plug#begin(expand('$XDG_CONFIG_HOME/nvim/plugged'))
    Plug 'junegunn/vim-plug'

    Plug 'lewis6991/moonlight.vim'

    Plug 'powerman/vim-plugin-AnsiEsc'

    Plug 'tpope/vim-fugitive'

    PlugLazy 'tpope/vim-commentary'
    PlugLazy 'tpope/vim-unimpaired'

    Plug 'vim-scripts/visualrepeat'
    Plug 'timakro/vim-searchant'

    Plug 'martinda/Jenkinsfile-vim-syntax'

    PlugLazy 'tpope/vim-surround'
    PlugLazy 'tpope/vim-repeat'
    PlugLazy 'tpope/vim-eunuch'

    " Plug 'sheerun/vim-polyglot'
    Plug 'tmhedberg/SimpylFold'       , { 'for': 'python'        }
    Plug 'lewis6991/tcl.vim'          , { 'for': 'tcl'           }
    Plug 'lewis6991/systemverilog.vim', { 'for': 'systemverilog' }
    Plug 'tmux-plugins/vim-tmux'      , { 'for': 'tmux'          }
    Plug 'dzeban/vim-log-syntax'

    " Plug 'rhysd/conflict-marker.vim'

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    PlugLazy 'junegunn/vim-easy-align'
    Plug 'whatyouhide/vim-lengthmatters'
    Plug 'gaving/vim-textobj-argument'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'justinmk/vim-dirvish'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'dietsche/vim-lastplace'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'ryanoasis/vim-devicons'
    Plug 'derekwyatt/vim-scala'
    Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}


    " Plug 'pangloss/vim-javascript'
    " Plug 'mxw/vim-jsx'
    " Plug 'neoclide/vim-jsx-improve'
    " Plug 'othree/yajs.vim'
    " Plug 'davidhalter/jedi-vim'

    if v:version >= 800
        Plug 'lewis6991/vim-clean-fold'
        " Plug 'airblade/vim-gitgutter'
    endif

    if has('nvim')
        Plug 'Shougo/neco-vim'
        Plug 'neoclide/coc-neco'

        function UpdateCoc()
            call coc#util#install()

            CocInstall coc-git
            CocInstall coc-python
            CocInstall coc-json
            CocInstall coc-tag
            CocInstall coc-word
            CocInstall coc-dictionary
        endfunction

        Plug 'neoclide/coc.nvim', { 'do': function('UpdateCoc') }

        " Workaround for: https://github.com/neovim/neovim/issues/1822
        Plug 'bfredl/nvim-miniyank'
        map p <Plug>(miniyank-autoput)
        map P <Plug>(miniyank-autoPut)

        Plug 'w0rp/ale'
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
set virtualedit=block " allow cursor to exist where there is no character
set updatetime=100
set hidden
set backup
set backupdir-=.
set lazyredraw
if v:version >= 800
    set completeopt=noinsert,menuone,noselect
endif

if has('mouse')
    set mouse=a
endif

silent! set pumblend=20

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

" }}}
" Plugin Settings {{{
"Ale {{{
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
let g:ale_linters.python = ['mypy', 'pylint', 'flake8']
" let g:ale_linters.python = ['pyls', 'pylint']
let g:ale_linters.scala = ['fsc', 'sbtserver', 'scalastyle']

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

" let g:ale_virtualtext_cursor = v:true
" highlight link ALEVirtualTextError ErrorMsg
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

augroup dirvish_commands
    autocmd!
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
"}}}
" Vim-lengthmatters {{{
let g:lengthmatters_highlight_one_column = 1
" }}}
" Gitgutter {{{
let g:gitgutter_max_signs=4000
let g:gitgutter_sign_added              = '│'  " '+'
let g:gitgutter_sign_modified           = '│'  " '~'
let g:gitgutter_sign_removed            = '_'  " '_'
let g:gitgutter_sign_removed_first_line = '‾'  " '‾'
let g:gitgutter_sign_modified_removed   = '│'  " '~_'
" }}}
" FZF {{{
function! s:find_git_root() abort
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

autocmd vimrc FileType fzf        set laststatus=0 noshowmode noruler
    \ | autocmd BufLeave <buffer> set laststatus=2   showmode   ruler
autocmd vimrc FileType fzf tunmap <Esc>

" }}}
" LanguageClient {{{
let g:LanguageClient_serverCommands = {
    \ 'python': ['pyls'],
    \ }
let g:LanguageClient_diagnosticsEnable = 0

let g:LanguageClient_rootMarkers = {
    \ 'python': ['setup.cfg']
    \ }

let g:LanguageClient_settingsPath = '~/.lsp_settings.json'
" }}}
" Plug {{{
let g:plug_window = 'tabnew'
" }}}
" Polyglot {{{
let g:polyglot_disabled = ['yaml']
" }}}
" }}}
" Colours {{{
if has('termguicolors')
    set termguicolors
endif

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
    set previewheight=20

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

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>SynStack()<CR>

nnoremap <Tab>   gt
nnoremap <S-Tab> gT

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'

cnoremap <C-P> <up>
cnoremap <C-N> <down>

cnoremap <C-A> <Home>
cnoremap <C-D> <Del>

" inoremap <expr> <TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
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

" navigate chunks of current buffer
nmap [c <Plug>(coc-git-prevchunk)
nmap ]c <Plug>(coc-git-nextchunk)
nmap <leader>hi <Plug>(coc-git-chunkinfo)
nmap <leader>hs :CocCommand git.chunkStage<cr>

if has('nvim')
    autocmd vimrc TermOpen * tnoremap <Esc> <c-\><c-n>
endif

cabbrev help tab help
cabbrev h    tab h
" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '

if v:version >= 800
    "Delete trailing white space on save.
    autocmd vimrc BufWrite * call DeleteTrailingWS()

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
endif

" }}}
" Comments {{{
augroup commentstring_group
    autocmd!
    autocmd Filetype sbt setlocal commentstring=//%s
augroup END
" }}}
" Functions {{{
function! DeleteTrailingWS() abort "{{{
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

function! <SID>SynStack() abort "{{{
    if !exists('*synstack')
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, ''name'')')
endfunction "}}}

function! QualifiedTagJump() abort "{{{
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

nnoremap <silent> <C-]> :<C-u>call QualifiedTagJump()<CR>

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
    let l:lline = split(l:line, '\zs')
    let l:inc = count(l:lline, '{')
    let l:dec = count(l:lline, '}')
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
"}}}
" File Settings {{{
"VimL
let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &shiftwidth

let g:xml_syntax_folding=1

augroup vimrc
    " Filetype detections
    autocmd BufRead dotshrc,dotsh         setlocal filetype=sh
    autocmd BufRead dotcshrc              setlocal filetype=csh
    autocmd BufRead *.tmux                setlocal filetype=tmux
    autocmd BufRead *.jelly               setlocal filetype=xml
    autocmd BufRead setup.cfg             setlocal filetype=dosini
    autocmd BufRead gerrit_hooks          setlocal filetype=dosini
    autocmd BufRead requirements*.txt     setlocal filetype=requirements
    " autocmd BufRead Jenkinsfile*          setlocal filetype=groovy
    autocmd BufRead lit.cfg,lit.local.cfg setlocal filetype=python
    autocmd BufRead gitconfig             setlocal filetype=gitconfig

    autocmd BufRead * if getline(1) == '#%Module1.0'
                  \ |     setlocal ft=tcl
                  \ | endif

    " Scala
    autocmd Filetype scala         setlocal shiftwidth=4
        \                                   foldlevelstart=1
        \                                   foldnestmax=3
    " autocmd FileType scala         call SCTags()

    autocmd Filetype systemverilog setlocal shiftwidth=4
        \                                   tabstop=4
        \                                   softtabstop=4
    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype make          setlocal noexpandtab
    autocmd Filetype gitconfig     setlocal noexpandtab
    autocmd FileType json          setlocal conceallevel=0
        \                                   foldnestmax=5
        \                                   foldmethod=marker
        \                                   foldmarker={,}

    " autocmd FileType json          setlocal foldmethod=expr foldexpr=JsonFolds()

    autocmd FileType make          setlocal foldmethod=expr foldexpr=MakeFolds()
    autocmd Filetype log           setlocal textwidth=1000
    autocmd FileType yaml          setlocal foldmethod=expr
        \                                   foldexpr=YamlFolds()
    autocmd FileType xml           setlocal foldnestmax=20
        \                                   foldcolumn=5

    autocmd FileType python nmap <silent> <C-]> <Plug>(coc-definition)
    autocmd FileType python nmap <silent> <C-q> <Plug>(coc-diagnostic-info)
    autocmd FileType python highlight semshiSelected ctermbg=8 guibg=#444A54

    autocmd Filetype groovy setlocal errorformat+=
        \%PErrors\ encountered\ validating\ %f:,
        \%EWorkflowScript:\ %l:\ %m\ column\ %c.,%-C%.%#,%Z
    autocmd Filetype groovy setlocal makeprg=java\ -jar\ ~/jenkins-cli.jar\ -s\ http://cem-jenkins.euhpc.arm.com\ declarative-linter\ <\ Jenkinsfile

augroup END
" highlight semshiSelected ctermbg=8 guibg=#444A54
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
function! Strip(input_string) "{{{
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction "}}}

function! Hunks() abort "{{{
    if v:version >= 704
        try
            let l:hunks = GitGutterGetHunkSummary()
        catch
            let l:hunks = [0,0,0]
        endtry
    else
        let l:hunks = ''
    endif

    let l:added    = l:hunks[0]
    let l:modified = l:hunks[1]
    let l:deleted  = l:hunks[2]

    let l:modified_s = ''
    if l:modified !=# '0'
        let l:modified_s = '~' . l:modified
    endif

    let l:added_s = ''
    if l:added !=# '0'
        let l:added_s .= '+' . l:added
    endif

    let l:deleted_s = ''
    if l:deleted !=# '0'
        let l:deleted_s .= '-' . l:deleted
    endif

    return Strip(join([l:modified_s, l:added_s, l:deleted_s]))
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

    return Strip(join([l:e, l:f]))
endfunction "}}}

function! s:GetAle(active) abort "{{{
    try
        let l:aleinfo = ale#statusline#Count(bufnr('%'))
    catch
        return ''
    endtry

    if l:aleinfo['total'] == 0
        return ''
    endif

    let l:keydisp = {
        \     'error'         : {'display' : 'E' , 'highlight' : 'DiffRemoved'},
        \     'warning'       : {'display' : 'W' , 'highlight' : 'DiffLine'   },
        \     'style_error'   : {'display' : 'SE', 'highlight' : 'DiffRemoved'},
        \     'style_warning' : {'display' : 'SW', 'highlight' : 'DiffLine'   },
        \     'info'          : {'display' : 'I' , 'highlight' : 'DiffAdded'  }
        \ }

    let l:alestatus = []
    for l:key in keys(l:keydisp)
        if l:aleinfo[l:key] > 0
            let l:entry = ''
            if a:active
                let l:entry .= '%#' . l:keydisp[l:key]['highlight'] . '#'
            endif
            let l:entry .= l:keydisp[l:key]['display'] . ':' . l:aleinfo[l:key]
            let l:alestatus += [l:entry]
        endif
    endfor

    return Strip(join(l:alestatus))
endfunction "}}}

let s:diagnostics = {}

function! s:record_diagnostics(state)
  let result = json_decode(a:state.result)
  let s:diagnostics = result.diagnostics
endfunction

function! s:diagnostics_for_buffer() "{{{

    " let d = getqflist()
    let d = getloclist(0)

    let message = []

    for [p, s, h] in [
        \     ['E', 1, 'DiffRemoved'],
        \     ['W', 2, 'DiffLine'],
        \     ['I', 3, 'DiffAdded'],
        \     ['H', 4, 'DiffRemoved']
        \ ]
        let l:count = 0
        for i in d
            if i.type == p
                let l:count += 1
            endif
        endfor
        if l:count > 0
            let message += ['%#'.h.'#'.p.':'.l:count]
        endif
    endfor
    return join(message, ' ')
endfunction "}}}

function! StatusHighlight(no, active) abort "{{{
    if a:active
        if     a:no == 1 | return '%#PmenuSel#'
        elseif a:no == 2 | return '%#Visual#'
        elseif a:no == 3 | return '%#CursorLine#'
        endif
    endif
    return ''
endfunction "}}}

function! Statusbar(active) abort "{{{
    let l:s = '%#StatusLine#'
    " let l:s = StatusHighlight(1, a:active)

    " let l:s .= '%(  %{fugitive#head()}  %)'
    " if expand('%t') !~# '/.git/'
    "     let l:s .= '%(  %{fugitive#statusline()}  %)'
    " endif
    let l:s .= StatusHighlight(1, a:active)
    let l:s .= '%{get(b:, "coc_git_status", "")}'
    let l:s .= '%( %{Hunks()}  %)'
    let l:s .= StatusHighlight(2, a:active)
    let l:s .= '  ' . s:GetAle(a:active)
    " let l:s .= '  ' . s:diagnostics_for_buffer()
    " Reset Ale Highlight
    let l:s .= StatusHighlight(2, a:active)
    let l:s .= ' %= '
    let l:s .= '%<%0.60f%m%r'  " file.txt[+][RO]
    let l:s .= ' %= '
    if exists('*WebDevIconsGetFileTypeSymbol')
        let l:s .= StatusHighlight(2, a:active)
        let l:s .= '%(  %{&filetype} %{WebDevIconsGetFileTypeSymbol()}  %)'
    endif
    let l:s .= StatusHighlight(1, a:active)
    if exists('*WebDevIconsGetFileFormatSymbol')
        let l:s .= '%(  %{EncodingAndFormat()}%{WebDevIconsGetFileFormatSymbol()}%)'
    endif
    " let l:s .= ' %p%% %l/%L %c ' " 80% 65/120 12
    let l:s .= ' %3p%% %3l(%02c)/%-3L ' " 80% 65[12]/120
    return l:s
endfunction "}}}

augroup status
    autocmd!
    " Only set up WinEnter autocmd when the WinLeave autocmd runs
    autocmd WinLeave,FocusLost *
        \ setlocal statusline=%!Statusbar(0) |
        \ autocmd status WinEnter,FocusGained *
            \ setlocal statusline=%!Statusbar(1)
augroup END

set statusline=%!Statusbar(1)

"}}}
" Tabline {{{
set tabline=%!MyTabLine()
" set showtabline=2

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
    augroup terminal_settings
        au!
        au TermOpen * setlocal nonumber
        au TermOpen * setlocal norelativenumber
        au TermOpen * setlocal nospell
    augroup END
    " let g:terminal_color_0  = "#051018"
    " let g:terminal_color_18 = "#0F1A22"
    " let g:terminal_color_19 = "#253038"
    " let g:terminal_color_8  = "#556068"
    " let g:terminal_color_20 = "#657078"
    " let g:terminal_color_7  = "#C5D0D8"
    " let g:terminal_color_21 = "#D5E0E8"
    " let g:terminal_color_15 = "#FFFFFF"
    " let g:terminal_color_1  = "#d5996d"
    " let g:terminal_color_9  = "#d5996d"
    " let g:terminal_color_16 = "#d5d56d"
    " let g:terminal_color_11 = "#99d56d"
    " let g:terminal_color_3  = "#99d56d"
    " let g:terminal_color_10 = "#6dd599"
    " let g:terminal_color_02 = "#6dd599"
    " let g:terminal_color_14 = "#6d99d5"
    " let g:terminal_color_6  = "#6d99d5"
    " let g:terminal_color_12 = "#996dd5"
    " let g:terminal_color_4  = "#996dd5"
    " let g:terminal_color_13 = "#d56d99"
    " let g:terminal_color_5  = "#d56d99"
    " let g:terminal_color_17 = "#d56d6d"
endif
"}}}
" vim: foldmethod=marker
