" Init {{{
scriptencoding utf-8

augroup vimrc
    autocmd!
augroup END
" }}}
" Plugins {{{

    " Install vim-plug if we don't already have it {{{
    if empty(glob('~/.vim/autoload/plug.vim'))
        execute 'silent !mkdir -p ~/.vim/tmp/'
        execute 'silent !mkdir -p ~/.vim/tmp/undo'
        execute 'silent !mkdir -p ~/.vim/tmp/backup'
        execute 'silent !mkdir -p ~/.vim/plugged'
        execute 'silent !mkdir -p ~/.vim/autoload'
        silent !git clone https://github.com/junegunn/vim-plug.git $HOME/.vim/bundle/vim-plug
        silent !ln -s $HOME/.vim/bundle/vim-plug/plug.vim $HOME/.vim/autoload/plug.vim
        autocmd! vimrc VimEnter * PlugInstall --sync | source $MYVIMRC
    endif "}}}

    " Install vim-pathogen if we don't already have it {{{
    if empty(glob('~/.vim/autoload/pathogen.vim'))
        execute 'silent !curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim'
    endif
    "}}}

let g:loaded_netrwPlugin = 1  " Stop netrw loading

" Load any plugins which are work sensitive.
execute pathogen#infect('~/gerrit/{}')

call plug#begin('~/.vim/plugged')
    Plug 'junegunn/vim-plug'

    Plug 'lewis6991/moonlight.vim'

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-eunuch'

    Plug 'sheerun/vim-polyglot'
    Plug 'tmhedberg/SimpylFold'       , { 'for': 'python'        }
    Plug 'lewis6991/tcl.vim'          , { 'for': 'tcl'           }
    Plug 'lewis6991/systemverilog.vim', { 'for': 'systemverilog' }
    Plug 'tmux-plugins/vim-tmux'      , { 'for': 'tmux'          }
    Plug 'dzeban/vim-log-syntax'

    Plug 'rhysd/conflict-marker.vim'

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'whatyouhide/vim-lengthmatters'
    Plug 'gaving/vim-textobj-argument'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'justinmk/vim-dirvish'

    if v:version >= 704
        Plug 'lewis6991/vim-clean-fold'
    endif
    Plug 'airblade/vim-gitgutter'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'dietsche/vim-lastplace'
    Plug 'Yggdroot/indentLine'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'ryanoasis/vim-devicons'
    " Plug 'powerman/vim-plugin-AnsiEsc'

    if has('nvim')
        " Workaround for: https://github.com/neovim/neovim/issues/1822
        Plug 'bfredl/nvim-miniyank'

        if has('nvim')
            map p <Plug>(miniyank-autoput)
            map P <Plug>(miniyank-autoPut)
        endif

        Plug 'Shougo/deoplete.nvim'

        " Deoplete sources
        Plug 'Shougo/neco-vim'
        Plug 'Shougo/neco-syntax'
        Plug 'zchee/deoplete-jedi'
        Plug 'zchee/deoplete-zsh'
        Plug 'ujihisa/neco-look'
        Plug 'wellle/tmux-complete.vim'

        Plug 'w0rp/ale'
    endif

call plug#end()
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

nmap <leader>an <Plug>(ale_next)
nmap <leader>ap <Plug>(ale_previous)
" }}}
" Dirvish {{{
let g:dirvish_mode = ':sort ,^.*[\/],'

nmap - :<C-U>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort "{{{
    " Close any existing dirvish buffers
    for l:i in range(1, bufnr('$'))
        if bufexists(l:i) && bufloaded(l:i) && getbufvar(l:i, '&filetype') ==? 'dirvish'
            execute ':'.l:i.'bd!'
        endif
    endfor

    30vsp

    if expand('%') ==# ''
        Dirvish
    else
        Dirvish %
    endif
endfunction "}}}

function! s:dirvish_open(cmd) abort "{{{
    let l:line = getline('.')
    if l:line =~? '/$'
        call dirvish#open(a:cmd, 0)
    else
        execute 'bd'
        execute a:cmd.' '.l:line
    endif
endfunction "}}}

augroup dirvish_commands
    autocmd!
    autocmd FileType dirvish nnoremap <silent> <buffer> <CR>  :<C-U> call <SID>dirvish_open('edit')<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> -     <Plug>(dirvish_up)
    autocmd FileType dirvish nmap     <silent> <buffer> <ESC> :bd<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> q     :bd<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> v     :<C-U> call <SID>dirvish_open('vsplit')<CR>
    autocmd FileType dirvish nmap     <silent> <buffer> s     :<C-U> call <SID>dirvish_open('split')<CR>

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
" Indentline {{{
let g:indentLine_char = '│'
let g:indentLine_setColors = 0
let g:indentLine_fileTypeExclude = ['fzf', 'dirvish']
" }}}
" FZF {{{
function! s:find_git_root() abort
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! ProjectFiles execute 'Files' s:find_git_root()

nnoremap <c-p> :ProjectFiles<cr>
nnoremap <c-space> :GFiles<cr>
nnoremap <c-s> :Ag<cr>
let g:fzf_layout = { 'window': '12split enew' }
let g:fzf_buffers_jump = 1
" }}}
" Polyglot {{{
let g:polyglot_disabled = ['yaml']
let g:vim_json_syntax_conceal = 0
" }}}
" Scala {{{
augroup vim-scala-override
    autocmd!
    autocmd Filetype scala setlocal errorformat=
        \%E\ %#[error]\ %f:%l:%c:\ %m,%C\ %#[error]\ %p^,%-C%.%#,%Z,
        \%W\ %#[warn]\ %f:%l:%c:\ %m,%C\ %#[warn]\ %p^,%-C%.%#,%Z,
        \%-G%.%#
augroup END
" }}}
if has('nvim')
    " Deoplete {{{
    let g:deoplete#enable_at_startup = 1

    call deoplete#custom#option('refresh_always', v:true)

    inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
    inoremap <expr> <TAB>   pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"
    "}}}
endif
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

if has('mouse')
    set mouse=a
endif

set diffopt+=vertical  "Show diffs in vertical splits

if has('persistent_undo')
    set undolevels=10000
    set undodir=~/.vim/tmp/undo
    set undofile " Preserve undo tree between sessions.
endif

if has('nvim')
    set viminfo+=n~/.vim/tmp/nviminfo " override ~/.viminfo default
else
    set viminfo+=n~/.vim/tmp/viminfo " override ~/.viminfo default
endif

set splitright
set splitbelow
set spell
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
    " set tags=./tags;,tags
    set hlsearch
    set ttyfast
    set ruler
    set laststatus=2
    set wildmenu

    " Tell vim how to use true colour.
    if v:version >= 704
        let &t_8f = '[38;2;%lu;%lu;%lum'
        let &t_8b = '[48;2;%lu;%lu;%lum'
    endif
endif
" }}}
" Nvim {{{
if has('nvim')
    let g:loaded_python_provider = 1 " Disable python2
    let g:loaded_ruby_provider   = 1 " Disable ruby
    let g:loaded_node_provider   = 1 " Disable ruby

    set inccommand=split
    set previewheight=20

    if has('nvim-0.2.3')
        highlight EndOfBuffer ctermfg=bg guifg=bg
    endif
endif
" }}}
" Mappings {{{
nnoremap <leader>ev :tabnew $MYVIMRC<CR>
nnoremap <leader>rv :source $MYVIMRC<bar>edit!<CR>
nnoremap <bs> :nohlsearch<cr>
nnoremap <leader>s :%s/\<<C-R><C-W>\>//g<left><left>
nnoremap <leader>c 1z=
nnoremap <leader>w :execute "resize ".line('$')<cr>

nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gs :Gstatus<CR>

nnoremap j gj
nnoremap k gk

nnoremap Y y$

nnoremap Q :w<cr>
vnoremap Q <nop>

" Show syntax highlighting groups for word under cursor
nnoremap <leader>z :call <SID>SynStack()<CR>

nnoremap <Tab> gt
nnoremap <S-Tab> gT

nnoremap <expr><silent> \| !v:count ? "<C-W>v<C-W><Right>" : '\|'
nnoremap <expr><silent> _  !v:count ? "<C-W>s<C-W><Down>"  : '_'
" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '

"Delete trailing white space on save.
autocmd! vimrc BufWrite * call DeleteTrailingWS()

if v:version >= 704
    "Highlight trailing whitespace
    autocmd! vimrc BufEnter * call matchadd('ColorColumn', '\s\+$')
endif
" }}}
" Folding {{{
if has('folding')
    let g:vimsyn_folding = 'af' "Fold augroups and functions
    let g:sh_fold_enabled = 1
    set foldmethod=syntax
    set foldcolumn=3
    set foldnestmax=2
endif
" }}}
" Comments {{{
set commentstring=#%s " This is the most common
augroup commentstring_group
    autocmd!
    autocmd Filetype scala     setlocal commentstring=//%s
    autocmd Filetype sbt.scala setlocal commentstring=//%s
    autocmd Filetype vim       setlocal commentstring=\"%s
    autocmd Filetype dosini    setlocal commentstring=#%s
augroup END
" }}}
" Functions {{{
function! DeleteTrailingWS() abort "{{{
    " Save cursor position
    let l:save = winsaveview()

    " vint: -ProhibitCommandWithUnintendedSideEffect
    " vint: -ProhibitCommandRelyOnUser
    " Remove trailing whitespace
    %s/\s\+$//e
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

function! SCTags() abort "{{{
    if executable('sctags')
        let g:tagbar_ctags_bin = 'sctags'
        let g:tagbar_type_scala = {
            \ 'ctagstype' : 'scala',
            \ 'sro'       : '.',
            \ 'kinds'     : [
                \ 'p:packages',
                \ 'V:values',
                \ 'v:variables',
                \ 'T:types',
                \ 't:traits',
                \ 'o:objects',
                \ 'O:case objects',
                \ 'c:classes',
                \ 'C:case classes',
                \ 'm:methods:1'
            \ ],
            \ 'kind2scope'  : {
                \ 'p' : 'package',
                \ 'T' : 'type',
                \ 't' : 'trait',
                \ 'o' : 'object',
                \ 'O' : 'case_object',
                \ 'c' : 'class',
                \ 'C' : 'case_class',
                \ 'm' : 'method'
            \ },
            \ 'scope2kind'  : {
                \ 'package'     : 'p',
                \ 'type'        : 'T',
                \ 'trait'       : 't',
                \ 'object'      : 'o',
                \ 'case_object' : 'O',
                \ 'class'       : 'c',
                \ 'case_class'  : 'C',
                \ 'method'      : 'm'
            \ }
        \ }
    endif
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
"}}}
" File Settings {{{
"VimL
let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &shiftwidth

let g:xml_syntax_folding=1

augroup vimrc
    autocmd!

    " Filetype detections
    autocmd BufRead dotshrc,dotsh         setlocal filetype=sh
    autocmd BufRead dotcshrc              setlocal filetype=csh
    autocmd BufRead *.tmux                setlocal filetype=tmux
    autocmd BufRead *.jelly               setlocal filetype=xml
    autocmd BufRead setup.cfg             setlocal filetype=dosini
    autocmd BufRead *.hv                  setlocal filetype=systemverilog
    autocmd BufRead lit.cfg,lit.local.cfg setlocal filetype=python

    autocmd BufRead * if getline(1) == '#%Module1.0'
                  \ |     setlocal ft=tcl
                  \ | endif

    " Scala
    autocmd Filetype scala setlocal
        \ shiftwidth=4
        \ foldlevelstart=1

    autocmd FileType scala call SCTags()


    autocmd Filetype systemverilog setlocal shiftwidth=2
        \                                   tabstop=2
        \                                   softtabstop=2
    autocmd Filetype tags          setlocal tabstop=30
    autocmd Filetype make          setlocal noexpandtab
    autocmd Filetype gitconfig     setlocal noexpandtab
    autocmd Filetype log           setlocal textwidth=0
    autocmd FileType yaml          setlocal foldmethod=expr
        \                          setlocal foldexpr=YamlFolds()
    autocmd FileType xml           setlocal foldnestmax=20
        \                                   foldcolumn=5

    autocmd BufRead .vimrc,vimrc,init.vim setlocal foldmethod=marker

augroup END
" }}}
" Formatting {{{
set formatoptions+=r "Automatically insert comment leader after <Enter> in Insert mode.
set formatoptions+=o "Automatically insert comment leader after 'o' or 'O' in Normal mode.
set formatoptions+=l "Long lines are not broken in insert mode.
set formatoptions-=t "Do not auto wrap text
set formatoptions+=n "Recognise lists
if v:version >= 704
    set breakindent      "Indent wrapped lines to match start
endif
"}}}
" Snippets {{{
iabbrev rev
    \ <c-r>=substitute(&commentstring, '%s', '', '').
    \' REVISIT: '.$USER.' '.strftime("%m/%d/%y").':'<CR>
" }}}
" Statusline {{{
function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! Hunks() abort
    let l:hunks = GitGutterGetHunkSummary()

    let l:modified = l:hunks[0]
    let l:added    = l:hunks[1]
    let l:deleted  = l:hunks[2]

    let l:modified_s = ''
    if l:modified !=# '0'
        let l:modified_s .= '~'
        let l:modified_s .= l:modified
    endif

    let l:added_s = ''
    if l:added !=# '0'
        let l:added_s .= '+'
        let l:added_s .= l:added
    endif

    let l:deleted_s = ''
    if l:deleted !=# '0'
        let l:deleted_s .= '-'
        let l:deleted_s .= l:deleted
    endif

    return Strip(join([l:modified_s, l:added_s, l:deleted_s]))
endfunction

function! EncodingAndFormat() abort
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
endfunction

function! s:GetAle(active) abort
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
endfunction

function! Statusbar(active)
    if a:active
        let l:s = '%#PmenuSel#'
    else
        let l:s = '%#StatusLineNC#'
    endif

    " let l:s .= '%(  %{fugitive#head()}  %)'

    if a:active
        let l:s .= '%#Visual#'
    endif

    let l:s .= '%(  %{Hunks()}  %)'

    if a:active
        let l:s .= '%#CursorLine#'
    endif

    let l:s .= '  %.40f'
    let l:s .= '%m%r' " [+][RO]

    let l:s .= '%='

    let l:s .= s:GetAle(a:active)

    let l:s .= '  '

    if a:active
        let l:s .= '%#Visual#'
    endif

    let l:s .= '%(  %{&filetype} %{WebDevIconsGetFileTypeSymbol()}  %)'

    if a:active
        let l:s .= '%#PmenuSel#'
    endif

    let l:s .= '%(  %{EncodingAndFormat()}%{WebDevIconsGetFileFormatSymbol()}%)'
    let l:s .= ' %p%%' " Percent through file
    let l:s .= ' %l/%L %c  ' " lnum:cnum

    return l:s
endfunction

augroup status
  autocmd!
  autocmd WinEnter * setlocal statusline=%!Statusbar(1)
  autocmd WinLeave * setlocal statusline=%!Statusbar(0)
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
        let l:s .= '%{WebDevIconsGetFileTypeSymbol(MyTabLabel(' . l:t . '))}'
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
