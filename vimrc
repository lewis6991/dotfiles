set nocompatible               "VIM is better than VI
"Plugins {{{

" Install vim-plug if we don't arlready have it
if empty(glob("~/.vim/autoload/plug.vim"))
    execute 'silent !mkdir -p ~/.vim/plugged'
    execute 'silent !mkdir -p ~/.vim/autoload'
    execute 'silent !curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
Plug 'lewis6991/verilog_systemverilog.vim', { 'for': 'verilog_systemverilog' }
Plug 'chriskempson/base16-vim'
Plug 'ervandew/supertab'
Plug 'bling/vim-airline'
Plug 'vimtaku/hl_matchit.vim'
Plug 'bkad/CamelCaseMotion'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'airblade/vim-gitgutter'
Plug 'rking/ag.vim'
Plug 'sickill/vim-pasta'
Plug 'haya14busa/incsearch.vim'
Plug 'sjl/gundo.vim'
Plug 'unblevable/quick-scope'
Plug 'guns/xterm-color-table.vim'
" Plug 'edkolev/tmuxline.vim'
" Plug 'nachumk/systemverilog.vim'
" Plug 'Raimondi/delimitMate'
" Plug 'easymotion/vim-easymotion'
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
call plug#end()

runtime macros/matchit.vim
"}}}
"General {{{
filetype plugin indent on
syntax enable                  "Enable syntax highlighting
set nostartofline
set number
set autoindent
set numberwidth=1              "Make as small as possible
set showmatch                  "Show matching parenthesis
set scrolloff=10               "Context while scrolling
set sidescrolloff=10           "Context while side-scrolling
set nowrap                     "Turn off text wrapping
set backspace=indent,eol,start "Make backspace work
set wildmenu
" set wildmode=list:longest,full
set laststatus=2
set textwidth=80
set t_kb=                    "Fix for backspace issue when using xterm.
" set tag+=tags;/
set lazyredraw                 "Don't redraw during macros
set relativenumber
" set completeopt=menu,preview,longest
set diffopt=filler,vertical,context:4
set encoding=utf8

if v:version == 704
    set mouse=a                "Enable mouse support
endif

set background=dark

if has("gui_running")
    colorscheme base16-harmonic16
else
    let base16colorspace=256
    colorscheme base16-harmonic16
    " colorscheme slate
endif

"}}}
"Mappings {{{
    "VIM Training {{{
    noremap  <Up>            :echo "Stop being stupid!"<cr>
    noremap  <Down>          :echo "Stop being stupid!"<cr>
    noremap  <Left>          :echo "Stop being stupid!"<cr>
    noremap  <Right>         :echo "Stop being stupid!"<cr>
    noremap  <PageUp>        :echo "Stop being stupid!"<cr>
    noremap  <PageDown>      :echo "Stop being stupid!"<cr>
    inoremap <Up>       <esc>:echo "Stop being stupid!"<cr>
    inoremap <Down>     <esc>:echo "Stop being stupid!"<cr>
    inoremap <Left>     <esc>:echo "Stop being stupid!"<cr>
    inoremap <Right>    <esc>:echo "Stop being stupid!"<cr>
    inoremap <PageUp>   <esc>:echo "Stop being stupid!"<cr>
    inoremap <PageDown> <esc>:echo "Stop being stupid!"<cr>
    "}}}
noremap Q :q<enter>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>

" Correct comman typos
nnoremap :W :w
nnoremap :Q :q
nnoremap :WQ :wq
nnoremap :Wq :wq
nnoremap :wQ :wq
nnoremap :BD :bd
nnoremap :Bd :bd
nnoremap :bD :bd

" Should this not be default?
nnoremap Y y$

nnoremap gb :bn<cr>
nnoremap gp :bp<cr>

" Swap these
noremap 0 ^
noremap ^ 0

" Easier pane navigation
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Escape is very inefficient
inoremap jk <esc>
inoremap jj <esc>j

nnoremap ; :

" Useful for selecting areas to indent/align
nnoremap <space> :call SelectIndent()<cr>

" Toggles line number mode.
nnoremap <C-N> :call ToggleNuMode()<cr>
"}}}
"Buffers {{{
set hidden    "Allows buffers to exist in background
set autoread  "Automatically read file when it is modified outside of vim

if v:version == 704
    set autochdir "Automatically change to directory to current buffer
endif
"}}}
"History & Backup {{{
set history=500   "keep a lot of history
set viminfo+=:100 "keep lots of cmd history
set viminfo+=/100 "keep lots of search history
set nowb
set noswapfile
set nobackup
"}}}
"Whitespace{{{
set shiftwidth=4  "Set tab to 3 spaces
set softtabstop=4
set tabstop=4
set expandtab     "Use spaces instead of tabs

augroup DelTrail
    autocmd!
    " Delete trailing white space on save.
    autocmd BufWrite * :call DeleteTrailingWS()
augroup END

"}}}
"Undo {{{
set undofile
set undodir=$HOME/.vim/undo
"}}}
"Searching{{{
set hlsearch             "Highlight search results.
set incsearch            "Move cursor to search occurance.
set ignorecase smartcase "Case insensitive search if lowercase.

if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Re-enable hlsearch when we want it.
nnoremap n :set hlsearch<cr>n
nnoremap N :set hlsearch<cr>N
nnoremap / :set hlsearch<cr>/
nnoremap ? :set hlsearch<cr>?
nnoremap * :set hlsearch<cr>*
nnoremap # :set hlsearch<cr>#

augroup disable_hl
    " This is acts like calling nohl when entering insert mode.
    autocmd! InsertEnter * :set nohlsearch
augroup END
"}}}
"Folding{{{
if v:version == 704
    set foldmethod=syntax
    set foldnestmax=10
    set foldlevel=1
    set foldenable
    set foldcolumn=0
    set foldtext=CustomFoldText()
endif
"}}}
"GUI Options {{{
if has("gui_running")
    set guioptions-=m "Remove menu bar
    set guioptions-=M "Remove menu bar
    set guioptions-=L "Remove left scroll bar
    set guioptions-=R "Remove right scroll bar
    set guioptions-=r "Remove right scroll bar
    set guioptions-=T "Remove toolbar
    set guioptions-=e "Always use terminal tab line
    set guioptions+=b "Include horizontal scroll bar
    set encoding=utf8
    if has("mac")
        set guifont=Meslo\ LG\ M\ DZ\ Regular\ for\ Powerline:h12
        " set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h12
    else
        " set guifont=Hack\ 13
        " set guifont=Meslo\ LG\ M\ for\ Powerline\ 13
        set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 12
    endif
endif
"}}}
"SystemVerilog Mappings {{{

function! InsertSVFunction(type, virtual, doc) "{{{
    let s:line=line(".")
    let s:name = substitute(getline('.'), '\s*' , '', 'g')
    let s:indent = repeat(' ', indent('.'))
    if a:type == "function"
        if a:virtual != 0
            call setline(s:line, s:indent."virtual function void ".s:name."();")
        else
            call setline(s:line, s:indent."function void ".s:name."();")
        endif
        call append(s:line, s:indent."endfunction : ".s:name)
    else
        if a:virtual != 0
            call setline(s:line, s:indent."virtual task ".s:name."();")
        else
            call setline(s:line, s:indent."task ".s:name."();")
        endif
        call append(s:line, s:indent."endtask : ".s:name)
    endif
    call append(s:line+1, "")
    if a:doc != 0
        if a:type == "function"
            call append(s:line-1, s:indent."/* Function: ".s:name)
        else
            call append(s:line-1, s:indent."/* Task: ".s:name)
        endif
        call append(s:line  , s:indent."*"             )
        call append(s:line+1, s:indent."*  Parameters:")
        call append(s:line+2, s:indent."*"             )
        call append(s:line+3, s:indent."*  Returns:"   )
        call append(s:line+4, s:indent."*/"            )
    endif
    unlet s:line
endfunction "}}}

function! InsertSVClass(uvm, doc) "{{{
    let s:line=line(".")
    let s:name = substitute(getline('.'), '\s*' , '', 'g')
    if a:uvm != 0
        call setline(s:line , "class ".s:name." extends uvm_object;")
        call append(s:line  , "`uvm_object_utils(".s:name.")")
        call append(s:line+1, "")
        call append(s:line+2, "function new(string name = \"".s:name."\");")
        call append(s:line+3, "super.new(name);")
        call append(s:line+4, "endfunction  : new")
        call append(s:line+5, "")
        call append(s:line+6, "endclass : ".s:name)
    else
        call setline(s:line , "class ".s:name.";")
        call append(s:line  , "")
        call append(s:line+1, "function new();")
        call append(s:line+2, "endfunction  : new")
        call append(s:line+3, "")
        call append(s:line+4, "endclass : ".s:name)
    endif
    if a:doc != 0
        call append(s:line-1, "")
        call append(s:line  , "/* Class: ".s:name)
        call append(s:line+1, "*/"            )
    endif
    unlet s:line
endfunction "}}}

function! InsertARMHeader() "{{{
    let s:line=line(".")
    call append(s:line-1 , "//------------------------------------------------------------------------------")
    call append(s:line   , "// The confidential and proprietary information contained in this file may      ")
    call append(s:line+1 , "// only be used by a person authorised under and to the extent permitted        ")
    call append(s:line+2 , "// by a subsisting licensing agreement from ARM Limited.                        ")
    call append(s:line+3 , "//                                                                              ")
    call append(s:line+4 , "//            (C) COPYRIGHT 2015 ARM Limited.                                   ")
    call append(s:line+5 , "//                ALL RIGHTS RESERVED                                           ")
    call append(s:line+6 , "//                                                                              ")
    call append(s:line+7 , "// This entire notice must be reproduced on all copies of this file             ")
    call append(s:line+8 , "// and copies of this file may only be made by a person if such person is       ")
    call append(s:line+9 , "// permitted to do so under the terms of a subsisting license agreement         ")
    call append(s:line+10, "// from ARM Limited.                                                            ")
    call append(s:line+11, "//------------------------------------------------------------------------------")
endfunction "}}}

augroup sv_prefs
    au!
    "UVM Report Macros {{{
    au FileType verilog_systemverilog inoremap `ui `uvm_info(BIU_TAG, "", UVM_NONE)<esc>11<left>i
    au FileType verilog_systemverilog inoremap `us `uvm_info(BIU_TAG, $sformatf(""), UVM_NONE)<esc>12<left>i
    au FileType verilog_systemverilog inoremap `ue `uvm_error(BIU_TAG, "")<left><left>
    au FileType verilog_systemverilog inoremap `uw `uvm_warning(BIU_TAG, "")<left><left>
    au FileType verilog_systemverilog inoremap `uf `uvm_fatal(BIU_TAG, "")<left><left>
    "}}}
    "UVM Class Macros {{{
    au FileType verilog_systemverilog inoremap `newc function new(string name, uvm_component parent);<enter>super.new(name, parent);<enter> endfunction : new<esc>2<up>3==i
    au FileType verilog_systemverilog inoremap `newo function new(string name = "");<enter>super.new(name);<enter> endfunction : new<esc>2<up>3==i
    "}}}
    "UVM Phase Macros {{{
    au FileType verilog_systemverilog inoremap `cphase function void connect_phase(uvm_phase phase);<enter>endfunction : connect_phase<esc>1<up>2==i<esc>o
    au FileType verilog_systemverilog inoremap `bphase function void build_phase(uvm_phase phase);<enter>endfunction : build_phase<esc>1<up>2==i<esc>o
    "}}}
    "SystemVerilog Macros {{{
    au FileType verilog_systemverilog inoremap <leader>f   <esc>:call InsertSVFunction("function", 0, 0)<cr>
    au FileType verilog_systemverilog inoremap <leader>t   <esc>:call InsertSVFunction("task"    , 0, 0)<cr>
    au FileType verilog_systemverilog inoremap <leader>df  <esc>:call InsertSVFunction("function", 0, 1)<cr>
    au FileType verilog_systemverilog inoremap <leader>dt  <esc>:call InsertSVFunction("task"    , 0, 1)<cr>
    au FileType verilog_systemverilog inoremap <leader>vf  <esc>:call InsertSVFunction("function", 1, 0)<cr>
    au FileType verilog_systemverilog inoremap <leader>vt  <esc>:call InsertSVFunction("task"    , 1, 0)<cr>
    au FileType verilog_systemverilog inoremap <leader>dvf <esc>:call InsertSVFunction("function", 1, 1)<cr>
    au FileType verilog_systemverilog inoremap <leader>dvt <esc>:call InsertSVFunction("task"    , 1, 1)<cr>
    au FileType verilog_systemverilog noremap  <leader>s <esc>kA begin<esc>joend<esc>kO
    au FileType verilog_systemverilog noremap  <leader>f <esc>F"i$sformatf(<esc>2f"a)<esc>hi
    "}}}

    "verilog macro to convert portlist into instantiation list.
    " au FileType verilog_systemverilog let @r=':%s/\v(input|output|inout|ref)\s+((\w+|\[.*\])\s+)?([a-z]\w+)\s*(\[.*\]\s*)?=?.*,$/\.\3\(\3\),\\/g'
    au BufNewFile *.sv call InsertARMHeader()
augroup END
"}}}
"SystemVerilog Settings {{{

function! RenameFunction() "{{{
    let str = getline('.')
    let lifetime        = '((automatic|static)\s+)?'
    let virtual         = '(virtual\s+)?'
    let static          = '(static\s+)?'
    let name            = '[a-zA-Z_]\w+\s*'
    let arguments       = '\(.*\)'
    let function_syntax = '\v^\s*'.static.virtual.'function\s+'.lifetime.'.*\s+'.name.arguments.';'
    let task_syntax     = '\v^\s*'.static.virtual.'task\s+'.lifetime.name.arguments.';'
    let class_syntax    = '\v^\s*'.virtual.'(interface\s+)?class\s+'.name.'(\s+extends\s+.+)?(\s+implements\s+.+)?\s*;'
    let class_syntax2   = '\v^class\s+'.name.'(\s+extends\s+.+)?(\s+implements\s+.+)?\s*;'
    if str =~ function_syntax || str =~ task_syntax || str =~ class_syntax
        "Save starting position
        execute "normal! mz"
        let line_type = ''
        if str =~ function_syntax
            let line_type = 'function'
            "Goto name and yank it
            execute "normal! t(yiw"
        elseif str =~ task_syntax
            let line_type = 'task'
            "Goto name and yank it
            execute "normal! t(yiw"
        elseif str =~ class_syntax
            let line_type = 'class'
            "Goto name and yank it
            execute "normal! 0/\\<class\<cr>wyiw"
        elseif str =~ class_syntax2
            let line_type = 'class'
            "Goto name and yank it
            execute "normal! 0wyiw"
        endif
        "Goto closing line
        execute "normal! /end".line_type."\<cr>"
        "Navigate to name
        execute "normal! ww"
        "Store old name in register a
        execute "normal! \"ayiw"
        "Substitute throughout file
        execute "normal! :%s/\\<\<C-r>a\\>/\<C-r>0/g\<cr>"
        "Move back to starting position
        execute "normal! `z"
    endif
endfunction "}}}

augroup sv_file_prefs
    au!
    au Filetype verilog_systemverilog setlocal shiftwidth=2 tabstop=2
    au Filetype verilog_systemverilog setlocal commentstring=//%s
    au Filetype verilog_systemverilog setlocal foldmethod=syntax foldlevelstart=1
    au BufEnter *.log setlocal wrap cursorline
augroup END
let g:verilog_syntax_fold = "comment,function,class,task,clocking"
com! -buffer RenameFunction call RenameFunction()
"}}}
"File Settings {{{

augroup file_prefs
    au!
    au Filetype sh setlocal textwidth=0
    au BufEnter *.log setlocal textwidth=0
    au BufEnter * call EnableColorColumn()
augroup END
"}}}
"Abbreviations {{{
iabbrev funciton    function
iabbrev functiton   function
iabbrev fucntion    function
iabbrev funtion     function
iabbrev erturn      return
iabbrev retunr      return
iabbrev reutrn      return
iabbrev reutn       return
iabbrev htis        this
iabbrev foreahc     foreach
iabbrev forech      foreach
iabbrev wrtie       write
iabbrev recieve     receive
iabbrev recieved    received
iabbrev recieving   receiving
iabbrev sucessful   successful
iabbrev successfull successful
iabbrev contiguouse contiguous
iabbrev fori for (int i = 0; i <; ++i)<esc>5hi
iabbrev forj for (int j = 0; j <; ++j)<esc>5hi
iabbrev forn for (int n = 0; n <; ++n)<esc>5hi
"}}}
"Plugin Settings {{{
    "Easy Align {{{
    nmap ga <Plug>(EasyAlign)
    xmap ga <Plug>(EasyAlign)
    if !exists('g:easy_align_delimiters')
      let g:easy_align_delimiters = {}
    endif
    let g:easy_align_delimiters[';'] = {
                \ 'pattern'     : '\(.*function.*\)\@<!\zs;',
                \ 'left_margin' : 0
                \ }
    let g:easy_align_delimiters['d'] = {
                \ 'pattern'     : '\ze\S\+\s*[,;=]',
                \ 'left_margin' : 1,
                \ 'right_margin': 0
                \ }
    let g:easy_align_delimiters['['] = {
                \ 'pattern'     : '\s\zs\[',
                \ 'left_margin' : 1,
                \ 'right_margin': 0
                \ }
    let g:easy_align_delimiters[','] = {
                \ 'pattern'     : ',',
                \ 'left_margin' : 0,
                \ 'right_margin': 1
                \ }
    let g:easy_align_delimiters[')'] = {
                \ 'pattern'     : ')',
                \ 'left_margin' : 0,
                \ 'right_margin': 0
                \ }
    let g:easy_align_delimiters['='] = {
                \ 'pattern'     : '[^!>]<\?=',
                \ 'left_margin' : 1,
                \ 'right_margin': 1
                \ }
    nmap <leader>c mzgaip[gaipdgaip;gaip,`z
    "}}}
    "CtrlP {{{
    let g:ctrlp_root_markers=['.ctrlp']
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)$',
      \ 'file': '\v((\.(exe|so|dll|pm))|tags)$',
      \ 'link': 'some_bad_symbolic_links',
      \ }
    if executable('ag')
        " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
        let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    endif
    "}}}
    "CamelCaseMotion {{{
    map <S-W> <Plug>CamelCaseMotion_w
    map <S-B> <Plug>CamelCaseMotion_b
    map <S-E> <Plug>CamelCaseMotion_e
    "}}}
    "Indent Guides {{{
    if has("gui_running")
        let g:indent_guides_color_change_percent = 2
        let g:indent_guides_enable_on_vim_startup = 1
        let g:indent_guides_start_level = 2
        " let g:indent_guides_guide_size = 1
    endif
    "}}}
    "HL Matchit {{{
    let g:hl_matchit_enable_on_vim_startup = 1
    "}}}
    "Supertab {{{
    " let g:SuperTabDefaultCompletionType = 'context'
    "}}}
    "Airline {{{
    let g:airline_powerline_fonts=1
    if has("gui_running") || has("mac")
        let g:airline_powerline_fonts=1
    endif
    let g:airline_mode_map = {
        \ '__' : '-',
        \ 'n'  : 'N',
        \ 'i'  : 'I',
        \ 'R'  : 'R',
        \ 'c'  : 'C',
        \ 'v'  : 'V',
        \ 'V'  : 'V',
        \ '' : 'V',
        \ 's'  : 'S',
        \ 'S'  : 'S',
        \ '' : 'S',
        \ }
    let g:airline#extensions#default#layout = [
        \ [ 'a', 'b', 'c' ],
        \ [ 'z', 'warning' ] ]
    let g:airline#extensions#tabline#enabled = 1
    "}}}
    "Gitgutter {{{
    if !has("mac")
        let g:gitgutter_enabled = 0
    endif
    " let g:gitgutter_diff_args = '-w'
    "}}}
    "Ag {{{
    let g:ag_prg='ag --vimgrep'
    " let g:ag_working_path_mode="r"
    "}}}
    "Incsearch {{{
    augroup mapincsearch
        au!
        au BufEnter *.log let b:noincsearch=1
        au BufEnter * call MapIncsearch()
    augroup END

    function! MapIncsearch()
        if !exists('b:noincsearch')
            nmap <buffer> /  :set hlsearch<cr><Plug>(incsearch-forward)
            nmap <buffer> ?  :set hlsearch<cr><Plug>(incsearch-backward)
            nmap <buffer> g/ :set hlsearch<cr><Plug>(incsearch-stay)
        endif
    endfunction
    "}}}
    "Gundo {{{
    nnoremap <F5> :GundoToggle<CR>
    "}}}
    "Quick-Scope {{{
    let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
    "}}}
"}}}
"Functions {{{
function! EnableColorColumn() "{{{
    if &tw != 0
        let hl_column = &tw + 2
        call matchadd('ColorColumn', '\%'.hl_column.'v', 100)
    endif
endfunction "}}}

function! ToggleNuMode() "{{{
    if(&rnu == 1)
        set nornu
    else
        set rnu
    endif
endfunc "}}}

function! SelectIndent() "{{{
    let cur_line = line(".")
    let cur_ind = indent(cur_line)
    let line = cur_line
    while indent(line - 1) >= cur_ind
        let line = line - 1
    endwhile
    execute "normal " . line . "G"
    execute "normal V"
    let line = cur_line
    while indent(line + 1) >= cur_ind
        let line = line + 1
    endwhile
    execute "normal " . line . "G"
endfunction "}}}

function! DeleteTrailingWS() "{{{
    normal mz"
    %s/\s\+$//ge
    normal `z"
endfunction "}}}

function! CustomFoldText() "{{{
    "get first non-blank line
    let line = getline(v:foldstart)
    if v:foldstart < v:foldend
        let line = substitute(line, '//{{{', '', 'g') "Remove marker }}}
        let line = substitute(line, '{{{'  , '', 'g') "Remove marker }}}
        let line = substitute(line, '//'   , '', 'g') "Remove comments
        let line = substitute(line, '^\s*' , '', 'g') "Remove leading whitespace
        let line = substitute(line, '(.*);', '', 'g') "Remove function arguments
        let line = substitute(line, '/\*\s*\(.*\)', '/* \1 */', 'g') "Make block comments look nicer
    endif

    let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0) + 5
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = repeat(" ", &shiftwidth*v:foldlevel-1)
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
    return foldLevelStr.line.expansionString.foldSizeStr.foldPercentage
endfunction "}}}
"}}}

"Apply .vimrc on save {{{
augroup sourceConf
    autocmd!
    autocmd BufWritePre $MYVIMRC source $MYVIMRC
    autocmd BufWritePost $MYVIMRC setlocal textwidth=0 fdm=marker foldlevel=0
augroup END
" vim: set textwidth=0 fdm=marker foldlevel=0:
"}}}
