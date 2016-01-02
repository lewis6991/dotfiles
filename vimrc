set nocompatible "VIM is better than VI
"Plugins {{{

    " Install vim-plug if we don't arlready have it
    if empty(glob("~/.vim/autoload/plug.vim"))
        execute 'silent !mkdir -p ~/.vimundo'
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
    Plug 'haya14busa/incsearch-fuzzy.vim'
    Plug 'sjl/gundo.vim'
    Plug 'unblevable/quick-scope'
    Plug 'guns/xterm-color-table.vim'
    Plug 'edkolev/tmuxline.vim'
    Plug 'dag/vim-fish'
    " Unused {{{
    " Plug 'SirVer/ultisnips'
    " Plug 'Raimondi/delimitMate'
    " Plug 'easymotion/vim-easymotion'
    "}}}
    call plug#end()

    runtime macros/matchit.vim
"}}}
"General {{{
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

    if !has("gui_running")
        let base16colorspace=256
    endif

    silent! colorscheme base16-harmonic16
"}}}
"Mappings {{{
    "VIM Training {{{
        noremap  <Up>            :echo "Stop being stupid!"<cr>
        noremap  <Down>          :echo "Stop being stupid!"<cr>
        noremap  <Left>          :echo "Stop being stupid!"<cr>
        noremap  <Right>         :echo "Stop being stupid!"<cr>
        noremap  <PageUp>        :echo "Stop being stupid!"<cr>
        noremap  <PageDown>      :echo "Stop being stupid!"<cr>
        inoremap <Up>       <esc>l:echo "Stop being stupid!"<cr>
        inoremap <Down>     <esc>l:echo "Stop being stupid!"<cr>
        inoremap <Left>     <esc>l:echo "Stop being stupid!"<cr>
        inoremap <Right>    <esc>l:echo "Stop being stupid!"<cr>
        inoremap <PageUp>   <esc>l:echo "Stop being stupid!"<cr>
        inoremap <PageDown> <esc>l:echo "Stop being stupid!"<cr>
    "}}}

    noremap Q :q<enter>
    nnoremap <leader>ev :vsplit $MYVIMRC<cr>

    " Correct comman typos
    nnoremap :W  :w
    nnoremap :Q  :q
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

    " Not sure about this, ';' can be useful
    nnoremap ; :

    " Useful for selecting areas to indent/align
    nnoremap <space> :call SelectIndent()<cr>

    " Toggles line number mode.
    nnoremap <C-N> :set relativenumber!<cr>
"}}}
"Buffers {{{
    set hidden    "Allows buffers to exist in background
    set autoread  "Automatically read file when it is modified outside of vim

    if v:version == 704
        set autochdir "Automatically change to directory to current buffer
    endif
"}}}
"History & Backup {{{
    set history=1000   "keep a lot of history
    set viminfo+=:500 "keep lots of cmd history
    set viminfo+=/500 "keep lots of search history
    set nowb
    set noswapfile
    set nobackup
"}}}
"Whitespace{{{
    set shiftwidth=4  "Set tab to 3 spaces
    set softtabstop=4
    set tabstop=4
    set expandtab     "Use spaces instead of tabs

    augroup WhitespaceGroup
        autocmd!
        " Delete trailing white space on save.
        autocmd BufWrite * call DeleteTrailingWS()
        " autocmd BufEnter * call matchadd('ColorColumn', '\t')
        autocmd BufEnter * call matchadd('ColorColumn', '\s\+$')
    augroup END
"}}}
"Undo {{{
    set undofile " Preserve undo tree between sessions.
    set undodir=$HOME/.vimundo
"}}}
"Searching{{{
    set hlsearch             "Highlight search results.
    set incsearch            "Move cursor to search occurance.
    set ignorecase smartcase "Case insensitive search if lowercase.

    if executable('ag')
      " Use ag over grep
      set grepprg=ag\ --nogroup\ --nocolor
    endif
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

        if has("mac")
            set guifont=Meslo\ LG\ M\ DZ\ Regular\ for\ Powerline:h12
        else
            set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 12
        endif
    endif
"}}}
"File Init{{{
    augroup header_insert
        autocmd!
        autocmd BufNewFile *.sv*,*.c*,*.h,*.java :0r ~/headers/c_header.txt
        autocmd BufNewFile *.sv*,*.c*,*.h,*.java %s/\[date\]/\=strftime("%Y")
        autocmd BufNewFile *.sv*,*.c*,*.h,*.java %s/\[name\]     /Lewis Russell
        autocmd BufNewFile *.sv*,*.c*,*.h,*.java normal! G
    augroup END
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

    augroup systemverilog_mappings
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
    augroup END
"}}}
"SystemVerilog Settings {{{
    augroup systemverilog_settings
        au!
        " au Filetype verilog_systemverilog setlocal shiftwidth=2 tabstop=2
        au Filetype verilog_systemverilog setlocal commentstring=//%s
        au Filetype verilog_systemverilog setlocal foldmethod=syntax foldlevelstart=1
    augroup END

    let g:verilog_syntax_fold = "comment,function,class,task,clocking"
"}}}
"File Settings {{{
    augroup file_prefs
        au!
        au Filetype sh setlocal textwidth=0
        au BufEnter *.log setlocal textwidth=0 wrap cursorline
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
        let g:incsearch#auto_nohlsearch = 1

        augroup mapincsearch
            au!
            " Disable insearch for certain filetypes.
            " Log files can be very large which can cause performance issues.
            au BufEnter *.log let b:noincsearch=1
            au BufEnter * call MapIncsearch()
        augroup END

        function! MapIncsearch()
            if !exists('b:noincsearch')
                map <buffer> /  <Plug>(incsearch-forward)
                map <buffer> ?  <Plug>(incsearch-backward)
                map <buffer> g/ <Plug>(incsearch-stay)
                map <buffer> n  <Plug>(incsearch-nohl-n)
                map <buffer> N  <Plug>(incsearch-nohl-N)
                map <buffer> *  <Plug>(incsearch-nohl-*)
                map <buffer> #  <Plug>(incsearch-nohl-#)
                map <buffer> g* <Plug>(incsearch-nohl-g*)
                map <buffer> g# <Plug>(incsearch-nohl-g#)
                map <buffer> z/ <Plug>(incsearch-fuzzy-/)
                map <buffer> z? <Plug>(incsearch-fuzzy-?)
                map <buffer> zg/ <Plug>(incsearch-fuzzy-stay)
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
        let l:line = getline(v:foldstart)
        let l:line = substitute(l:line, '//{{{', '', 'g') "Remove marker }}}
        let l:line = substitute(l:line, '{{{'  , '', 'g') "Remove marker }}}
        let l:line = substitute(l:line, '//'   , '', 'g') "Remove comments
        let l:line = substitute(l:line, '^\s*' , '', 'g') "Remove leading whitespace
        let l:line = substitute(l:line, '^"'   , '', 'g') "Remove comment char (vim files)
        let l:line = substitute(l:line, '(.*);', '', 'g') "Remove function arguments
        let l:line = substitute(l:line, '/\*\s*\(.*\)', '/* \1 */', 'g') "Make block comments look nicer

        let w = winwidth(0) - len(line("$")) - 1
        let foldSize = v:foldend - v:foldstart
        let foldSizeStr = "[" . foldSize . " lines]  "
        let foldLevelStr = repeat(" ", &shiftwidth*v:foldlevel)
        let expansionString = repeat(" ", w - strwidth(foldSizeStr.l:line.foldLevelStr))
        return foldLevelStr.line.expansionString.foldSizeStr
    endfunction "}}}
"}}}

let b:verilog_indent_verbose = 1
let g:verilog_syntax_fold = "all"

function! GetSyn()
    return join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'))
endfunction

function! AppendSyn()
    let linenr = 0

    while linenr < line("$") - 1
        let linenr += 1
        let length=len(getline(linenr))
        let ws=0

        if length < 80
            let ws = 80 - length
        end

        " Goto line
        execute "normal ".linenr."G"

        " Insert whitespace upto column 80
        execute "normal ".ws."A "

        " Insert syntax groups
        execute "normal A// ".GetSyn()

        " Update screen
        redraw
    endwhile
endfunction

"Apply .vimrc on save {{{
augroup source_vimrc
    autocmd!
    autocmd BufWrite $MYVIMRC source $MYVIMRC || AirlineRefresh
    autocmd BufRead,BufWrite $MYVIMRC setlocal textwidth=0 fdm=marker foldlevel=0
augroup END
" vim: set textwidth=0 fdm=marker foldlevel=0 :
"}}}
