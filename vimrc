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

let loaded_netrwPlugin = 1  " Stop netrw loading

" Load any plugins which are work sensitive.
execute pathogen#infect('~/gerrit/{}')

call plug#begin('~/.vim/plugged')
    Plug 'lewis6991/tcl.vim', { 'for': 'tcl' }
    Plug 'lewis6991/systemverilog.vim', { 'for': 'systemverilog' }
    Plug '~/projects/dotfiles/modules/moonlight.vim'
    if version >= 704
        Plug 'lewis6991/vim-clean-fold'
    endif

    Plug 'junegunn/vim-plug'

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-eunuch'

    Plug 'majutsushi/tagbar'

    Plug 'rhysd/conflict-marker.vim'

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'whatyouhide/vim-lengthmatters'
    Plug 'gaving/vim-textobj-argument'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'justinmk/vim-dirvish'
    Plug 'derekwyatt/vim-scala'

    " Python
    Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
    Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
    Plug 'airblade/vim-gitgutter'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'dietsche/vim-lastplace'
    Plug 'Yggdroot/indentLine'
    Plug 'tmux-plugins/vim-tmux', { 'for': 'tmux' }
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'ryanoasis/vim-devicons'
    Plug 'powerman/vim-plugin-AnsiEsc'
    Plug 'rhysd/clever-f.vim'

    if has('nvim')
        Plug 'Shougo/neosnippet', { 'on': [] }

        Plug 'Shougo/deoplete.nvim'

        " Deoplete sources
        Plug 'Shougo/neco-vim'
        Plug 'Shougo/neco-syntax'
        Plug 'zchee/deoplete-jedi'
        Plug 'zchee/deoplete-zsh'
        Plug 'ujihisa/neco-look'
        Plug 'wellle/tmux-complete.vim'

        Plug 'w0rp/ale', { 'on': [] }
    endif
call plug#end()

if has('nvim')
    augroup LazyLoadPluginsInsertEnter
        autocmd!
        autocmd CursorHold,InsertEnter * call plug#load('neosnippet')
    augroup END

    " Only run LazyLoadPlugins once
    autocmd! CursorHold,InsertEnter *
        \ autocmd! LazyLoadPluginsInsertEnter

    augroup LazyLoadPluginsBufWritePre
        autocmd!
        autocmd CursorHold,BufWritePre * call plug#load('ale')
    augroup END

    autocmd! CursorHold,BufWritePre *
        \ autocmd! LazyLoadPluginsBufWritePre
endif

" }}}
" Plugin Settings {{{
"Ale {{{
" let g:ale_echo_msg_error_str = '%linter%:%severity% %s'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_python_mypy_options = '--config-file setup.cfg'
let g:ale_set_highlights = 1
let g:ale_sh_shellcheck_options = '-x'
let g:ale_sign_info = '->'
let g:ale_tcl_nagelfar_options = "-s ~/syntaxdbjg.tcl"
let g:ale_type_map = {'flake8': {'ES': 'WS', 'E': 'E'}}
let g:ale_echo_msg_format = '%severity%->%linter%->%code: %%s'
" }}}
" Dirvish {{{
let g:dirvish_mode = ':sort ,^.*[\/],'

nmap - :<C-U>call <SID>dirvish_toggle()<CR>

function! s:dirvish_toggle() abort "{{{
    " Close any existing dirvish buffers
    for i in range(1, bufnr('$'))
        if bufexists(l:i) && bufloaded(l:i) && getbufvar(l:i, '&filetype') ==? 'dirvish'
            execute ':'.l:i.'bd!'
        endif
    endfor

    30vsp

    if expand('%') == ""
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
" Clever F {{{
let g:clever_f_across_no_line = 1
let g:clever_f_mark_char_color = "DiffChange"
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
let g:gitgutter_max_signs=2000
autocmd! BufWritePre * GitGutter
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
nnoremap <c-s> :Ag<cr>
let g:fzf_layout = { 'window': '12split enew' }
let g:fzf_buffers_jump = 1
" }}}
" Scala {{{
augroup vim-scala-override
    autocmd!
    autocmd Filetype scala setlocal errorformat=
        \%E\ %#[error]\ %f:%l:%c:\ %m,%C\ %#[error]\ %p^,%-C%.%#,%Z,
        \%W\ %#[warn]\ %f:%l:%c:\ %m,%C\ %#[warn]\ %p^,%-C%.%#,%Z,
        \%-G%.%#
augroup END
"}}}
if has('nvim')
    " Deoplete {{{
    let g:deoplete#enable_at_startup = 1

    call deoplete#custom#option('refresh_always', v:true)
    " }}}
    "Neosnippet {{{
    let g:neosnippet#snippets_directory='~/.vim/snippets'
    let g:neosnippet#disable_runtime_snippets = { '_' : 1 }

    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    imap <expr><TAB>
        \ neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" :
        \ pumvisible()                        ? "\<C-n>" :
        \                                       "\<TAB>"
    "}}}
endif
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
set clipboard^=unnamed,unnamedplus
set scrolloff=6
set sidescroll=1
set sidescrolloff=6
set virtualedit=block " allow cursor to exist where there is no character

if has('mouse')
    set mouse=a
endif

set diffopt+=vertical          "Show diffs in vertical splits

if has('persistent_undo')
    set undolevels=5000
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

nmap <leader>an <Plug>(ale_next)
nmap <leader>ap <Plug>(ale_previous)

nmap <leader>hn <Plug>GitGutterNextHunk
nmap <leader>hp <Plug>GitGutterPrevHunk

nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hr <Plug>GitGutterUndoHunk
" }}}
" Whitespace {{{
set list listchars=tab:▸\  "Show tabs as '▸   ▸   '

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
augroup END
" }}}
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

function! SCTags() abort "{{{
    if executable("sctags")
        let g:tagbar_ctags_bin = "sctags"
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

"}}}
" File Settings {{{
"VimL
let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
let g:vimsyn_folding  = 'af' "Fold augroups and functions
let g:vim_indent_cont = &sw

augroup file_settings_group
    autocmd!
    autocmd Filetype         scala         setlocal shiftwidth=4
    autocmd Filetype         scala         setlocal foldlevelstart=1
    autocmd FileType         scala         call SCTags()

    autocmd Filetype         systemverilog setlocal shiftwidth=2
    autocmd Filetype         systemverilog setlocal tabstop=2
    autocmd Filetype         systemverilog setlocal softtabstop=2

    autocmd Filetype         tags          setlocal tabstop=30

    autocmd Filetype         make          setlocal noexpandtab
    autocmd Filetype         gitconfig     setlocal noexpandtab
    autocmd BufEnter,BufRead *.log         setlocal textwidth=0
    autocmd BufEnter,BufRead dotshrc,dotsh setlocal filetype=sh
    autocmd BufEnter,BufRead dotcshrc      setlocal filetype=csh
    autocmd BufEnter,BufRead *.tmux        setlocal filetype=tmux
    autocmd BufEnter,BufRead setup.cfg     setlocal filetype=dosini

    autocmd BufNewFile,BufRead *   if getline(1) == '#%Module1.0'
    autocmd BufNewFile,BufRead *       setlocal ft=tcl
    autocmd BufNewFile,BufRead *   endif

    autocmd BufRead .vimrc,vimrc,init.vim setlocal foldmethod=marker

    autocmd BufRead lit.cfg,lit.local.cfg setlocal filetype=python
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
" Statusline {{{
function! Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! Hunks() abort
    let hunks = GitGutterGetHunkSummary()

    let modified = hunks[0]
    let added    = hunks[1]
    let deleted  = hunks[2]

    let modified_s = ''
    if modified != '0'
        let modified_s .= '~'
        let modified_s .= modified
    endif

    let added_s = ''
    if added != '0'
        let added_s .= '+'
        let added_s .= added
    endif

    let deleted_s = ''
    if deleted != '0'
        let deleted_s .= '-'
        let deleted_s .= deleted
    endif

    return Strip(join([modified_s,added_s,deleted_s]))
endfunction

function! EncodingAndFormat() abort
    let e = &fileencoding ? &fileencoding : &encoding
    let f = &fileformat

    if e == 'utf-8'
        let e = ''
    endif

    if f == 'unix'
        let f = ''
    else
        let f = '['.f.']'
    endif

    return Strip(join([e,f]))
endfunction

function! s:GetAle(active) abort
    try
        let aleinfo = ale#statusline#Count(bufnr('%'))
    catch
        return ""
    endtry

    if aleinfo['total'] == 0
        return ""
    endif

    let keydisp = {
        \     'error'         : {'display' : 'E' , 'highlight' : 'DiffRemoved'},
        \     'warning'       : {'display' : 'W' , 'highlight' : 'DiffLine'   },
        \     'style_error'   : {'display' : 'SE', 'highlight' : 'DiffRemoved'},
        \     'style_warning' : {'display' : 'SW', 'highlight' : 'DiffLine'   },
        \     'info'          : {'display' : 'I' , 'highlight' : 'DiffAdded'  }
        \ }

    let alestatus = []
    for key in keys(keydisp)
        if aleinfo[key] > 0
            let entry = ''
            if a:active
                let entry .= "%#".keydisp[key]['highlight']."#"
            endif
            let entry .= keydisp[key]['display'].':'.aleinfo[key]
            let alestatus += [entry]
        endif
    endfor

    return Strip(join(alestatus))
endfunction

function! Statusbar(active)
    if a:active
        let s="%#PmenuSel#"
    else
        let s="%#StatusLineNC#"
    endif

    " let s.="%(  %{fugitive#head()}  %)"

    if a:active
        let s.="%#Visual#"
    endif

    let s .= "%(  %{Hunks()}  %)"

    if a:active
        let s.="%#CursorLine#"
    endif

    let s.="  %.40f"
    let s.="%m%r" " [+][RO]"

    let s.="%="

    let s.=s:GetAle(a:active)

    let s.="  "

    if a:active
        let s.="%#Visual#"
    endif

    let s.="%(  %{&filetype} %{WebDevIconsGetFileTypeSymbol()}  %)"

    if a:active
        let s.="%#PmenuSel#"
    endif

    let s.="%(  %{EncodingAndFormat()}%{WebDevIconsGetFileFormatSymbol()}%)"
    let s.=" %p%%" " Percent through file
    let s.=" %l/%L %c  " " lnum:cnum
    return s
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
    let s = ''
    for i in range(tabpagenr('$'))
        let t = i + 1
        " select the highlighting
        if t == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        let s .= ' '
        let s .= '%{WebDevIconsGetFileTypeSymbol(MyTabLabel(' . t . '))}'
        let s .= ' %{MyTabLabel(' . t . ')}'
        let s .= ' '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    return s
endfunction "}}}

function! MyTabLabel(n) abort "{{{
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let path = bufname(buflist[winnr - 1])
    let label = fnamemodify(path, ':t')

    if label == ""
        let label = "[NONE]"
    endif

    return label
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

" autocmd! FileType scala call SCTags()
