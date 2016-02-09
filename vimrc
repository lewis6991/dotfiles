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
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-vinegar'
    Plug 'tpope/vim-unimpaired'
    Plug 'lewis6991/verilog_systemverilog.vim', { 'for': 'verilog_systemverilog' }
    Plug 'junegunn/vim-easy-align'
    Plug 'chriskempson/base16-vim'
    Plug 'ervandew/supertab'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'vimtaku/hl_matchit.vim'
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'sickill/vim-pasta'
    Plug 'sjl/gundo.vim'
    Plug 'dietsche/vim-lastplace'

    "Tmux Integration
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tmux-plugins/vim-tmux'
    Plug 'edkolev/tmuxline.vim'

    "Search
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'rking/ag.vim'
    Plug 'haya14busa/incsearch.vim'
    Plug 'haya14busa/incsearch-fuzzy.vim'

    "Source Control
    Plug 'tpope/vim-fugitive'
    Plug 'vim-scripts/vcscommand.vim'
    Plug 'juneedahamed/vc.vim'
    if has("mac")
        Plug 'airblade/vim-gitgutter'
    else
        Plug 'mhinz/vim-signify' "For SVN at work.
    endif

    " Unused {{{
    " Plug 'unblevable/quick-scope'
    " Plug 'wellle/tmux-complete.vim'
    " Plug 'tomasr/molokai'
    " Plug 'bkad/CamelCaseMotion'
    " Plug 'dag/vim-fish'
    " Plug 'guns/xterm-color-table.vim'
    " Plug 'SirVer/ultisnips'
    "}}}
    call plug#end()

    runtime macros/matchit.vim
"}}}
"General {{{
    set nostartofline
    set number relativenumber
    set autoindent
    set numberwidth=1              "Make as small as possible
    set showmatch                  "Show matching parenthesis
    set scrolloff=8                "Context while scrolling
    set sidescrolloff=8            "Context while side-scrolling
    set nowrap                     "Turn off text wrapping
    set backspace=indent,eol,start "Make backspace work
    set wildmenu                   "Show completions on command line
    set laststatus=2               "Always show the status bar
    set textwidth=80
    set t_kb=                    "Fix for backspace issue when using xterm.
    " set tag+=tags;/
    set lazyredraw                 "Don't redraw during macros
    set completeopt+=menuone
    set diffopt+=vertical
    set encoding=utf8
    set virtualedit=block          "Allow visual block mode to select over any row/column
    set cursorline
    set list listchars=tab:>–      "Show tabs as '>–––'

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
    noremap Q :q<enter>
    nnoremap <leader>ev :call EditVimrc()<cr>

    " Yank and Paste from systeam clipboard. Very useful.
    nnoremap <leader>y "+y
    nnoremap <leader>p "+p

    nnoremap <leader>d :call RunDiff()<cr>

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

    " Disable
    nnoremap K <nop>

    nnoremap gb :bn<cr>
    nnoremap gp :bp<cr>

    " Swap these
    noremap 0 ^
    noremap ^ 0

    vnoremap > >gv
    vnoremap < <gv

    " Escape is inefficient
    inoremap jk <esc>l

    " Useful for selecting areas to indent/align
    " 26/01/16: Disable for a while
    " nnoremap <space> :call SelectIndent()<cr>

    " Toggles line number mode. Very useful.
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
    set nowritebackup
    set noswapfile
    set nobackup
"}}}
"Whitespace{{{
    set shiftwidth=4  "Set tab to 4 spaces
    set softtabstop=4
    set tabstop=4
    set expandtab     "Convert tabs to spaces when typing

    augroup WhitespaceGroup
        autocmd!
        "Delete trailing white space on save.
        autocmd BufWrite * call DeleteTrailingWS()
        "Highlight trailing whitespace
        autocmd BufEnter * call matchadd('ColorColumn', '\s\+$')
    augroup END
"}}}
"Undo {{{
    if v:version == 704
        set undofile " Preserve undo tree between sessions.
        set undodir=$HOME/.vimundo
    endif
"}}}
"Searching{{{
    set hlsearch             "Highlight search results.
    set incsearch            "Move cursor to search occurance.
    set ignorecase smartcase "Case insensitive search if lowercase.

    if executable('ag')
      "Use ag over grep
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
        set guioptions-=b "Remove horizontal scroll bar

        if has("mac")
            set guifont=Meslo\ LG\ M\ DZ\ Regular\ for\ Powerline:h12
        else
            " set guifont=DejaVu\ Sans\ Mono\ 11
            set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 11
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
            au FileType verilog_systemverilog inoremap `newc function new(string name, uvm_component parent);<enter>super.new(name, parent);<enter>endfunction : new<esc>2<up>3==i
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
            au FileType verilog_systemverilog noremap  <leader>r <esc>A // REVISIT (lewrus01 <C-r>=strftime('%d/%m/%y')<cr>):
        "}}}
    augroup END
"}}}
"SystemVerilog Settings {{{
    augroup systemverilog_settings
        au!
        au Filetype verilog_systemverilog setlocal shiftwidth=2 tabstop=2
        au Filetype verilog_systemverilog setlocal commentstring=//%s

        " Enable folding for normal size files. Folding is really slow for large files.
        au Filetype verilog_systemverilog if line('$') < 2000
        au Filetype verilog_systemverilog     setlocal foldmethod=syntax foldlevelstart=1
        au Filetype verilog_systemverilog     let g:verilog_syntax_fold = "comment,function,class,task,clocking"
        au Filetype verilog_systemverilog     syntax enable "Trigger fold calculation
        au Filetype verilog_systemverilog endif
    augroup END

    let b:verilog_indent_verbose = 1
    let b:verilog_indent_modules = 1
    let b:verilog_indent_preproc = 1
    " let b:verilog_dont_deindent_eos = 1
    " let g:verilog_syntax_fold = "all"

"}}}
"File Settings {{{
    augroup file_prefs
        au!
        au Filetype sh,map setlocal textwidth=0
        au BufEnter *.log  setlocal textwidth=0 wrap cursorline
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
    iabbrev reutnr      return
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
        let g:easy_align_delimiters = {}
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
        let g:easy_align_delimiters[']'] = {
                    \ 'pattern'     : ']',
                    \ 'left_margin' : 0,
                    \ 'right_margin': 1
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
        let g:easy_align_delimiters['('] = {
                    \ 'pattern'     : '(',
                    \ 'left_margin' : 0,
                    \ 'right_margin': 0
                    \ }
        let g:easy_align_delimiters['='] = {
                    \ 'pattern'     : '<\?=',
                    \ 'left_margin' : 1,
                    \ 'right_margin': 1
                    \ }
        let g:easy_align_delimiters[':'] = {
                    \ 'pattern'     : ':',
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
            " Use ag in CtrlP for listing files. Fast and respects .gitignore
            let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
        endif
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
            \ [ 'x', 'z', 'warning' ] ]
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#show_buffers = 0
        let g:airline#extensions#tabline#show_tab_nr = 0
        let g:airline#extensions#tabline#formatter = 'unique_tail'
        let g:airline#extensions#tabline#show_tab_type = 0
        let g:airline#extensions#tabline#show_close_button = 0
        " let g:airline_section_c = '%t'
    "}}}
    "Gitgutter {{{
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
    "Tmuxline {{{
    let g:tmuxline_preset='full'
    "}}}
"}}}
"Functions {{{

    function! EditVimrc() "{{{
        if expand('%t') == ''
            edit $MYVIMRC
        else
            vsplit $MYVIMRC
        endif
    endfunction "}}}

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
        if expand('%:t') =~ 'indent.sv'
            return
        endif

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
        let foldSizeStr = "|".repeat(" ", 4-len(foldSize)).foldSize . "   "
        let foldLevelStr = repeat(" ", &shiftwidth*v:foldlevel)
        let expansionString = repeat(" ", w - strwidth(foldSizeStr.l:line.foldLevelStr))
        return foldLevelStr.line.expansionString.foldSizeStr
    endfunction "}}}

    function! RunDiff() "{{{
        if exists(':Gdiff')
            Gdiff
        else
            VCSVimDiff
        endif
    endfunction "}}}

"}}}

"Plugin Development {{{
function! GetSyn()
    return join(map(synstack(line('.'), col('$')), 'synIDattr(v:val, "name")'))
endfunction
function! GetSyn3()
    return map(synstack(line('.'), col('$')), 'synIDattr(v:val, "name")')
endfunction
function! GetSyn2()
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
"}}}

"Apply .vimrc on save {{{
augroup source_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC || AirlineRefresh
    autocmd BufRead,BufWritePost $MYVIMRC setlocal textwidth=0 fdm=marker foldlevel=0
augroup END
" vim: set textwidth=0 fdm=marker foldlevel=0 :
"}}}
