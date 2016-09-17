"Plugins {{{

    " Install vim-plug if we don't already have it {{{
    if empty(glob("~/.vim/autoload/plug.vim"))
        execute 'silent !mkdir -p ~/.vimundo'
        execute 'silent !mkdir -p ~/.vim/plugged'
        execute 'silent !mkdir -p ~/.vim/autoload'
        execute 'silent !curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
    endif "}}}
    call plug#begin('~/.vim/plugged')

     Plug '~/git/vim-cool-status-line'
     Plug 'Super-Shell-Indent'

    if $HOST =~ 'arm'
        Plug '~/asl.vim'
        Plug '~/archex.vim'
    endif

    Plug 'vhda/verilog_systemverilog.vim'

    "Should be built in
    Plug 'tpope/vim-commentary', {'on': '<Plug>Commentary'}
    map  gc  <Plug>Commentary
    nmap gcc <Plug>CommentaryLine

    Plug 'tpope/vim-unimpaired'
    Plug 'triglav/vim-visual-increment'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'visualrepeat'

    Plug 'whatyouhide/vim-lengthmatters'
    Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign'] }
    Plug 'vimtaku/hl_matchit.vim'
    Plug 'sickill/vim-pasta'
    Plug 'dietsche/vim-lastplace'
    Plug 'Konfekt/FastFold'
    Plug 'ervandew/supertab'
    Plug 'cmdline-completion'
    Plug 'justinmk/vim-dirvish', { 'on': '<Plug>(dirvish_up)' }
    nmap - <Plug>(dirvish_up)

    "Snippets
    Plug 'MarcWeber/vim-addon-mw-utils' "vim-snipmate dependency
    Plug 'tomtom/tlib_vim'              "vim-snipmate dependency
    Plug 'garbas/vim-snipmate'

    "Syntax
    Plug 'tmhedberg/SimpylFold'
    Plug 'derekwyatt/vim-scala'

    "Colourschemes
    Plug 'chriskempson/base16-vim'
    Plug 'whatyouhide/vim-gotham'
    Plug 'tomasr/molokai'

    "Tmux Integration
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'tmux-plugins/vim-tmux'

    "Search
    Plug 'rking/ag.vim', { 'on': 'Ag'    }
    Plug 'ctrlpvim/ctrlp.vim', { 'on': 'CtrlP' }
    nnoremap <C-P> :CtrlP<cr>

    Plug 'Chun-Yang/vim-action-ag', { 'on': '<Plug>AgActionWord' }
    if v:version == 704
        Plug 'haya14busa/incsearch.vim', { 'on': [
            \   '<Plug>(incsearch-forward)' ,
            \   '<Plug>(incsearch-backward)',
            \   '<Plug>(incsearch-stay)'
            \ ]}
    endif

    "Source Control
    Plug 'tpope/vim-fugitive'
    Plug 'vim-scripts/vcscommand.vim', { 'on': 'VCSVimDiff' }
    Plug 'junegunn/gv.vim', { 'on': 'GV' }
    Plug 'airblade/vim-gitgutter'
    Plug 'mhinz/vim-signify' "For SVN

    call plug#end()

    runtime macros/matchit.vim
"}}}
"General {{{
    set nocompatible              "VIM is better than VI
    set nostartofline             "Keep cursor in same column when moving
                                  "up/down.
    set number
    if v:version == 704
        set relativenumber
    endif

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
    set lazyredraw                 "Don't redraw during macros
    set completeopt+=menuone
    set diffopt+=vertical          "Show diffs in vertical splits
    set virtualedit=block          "Allow visual block mode to select over any
                                   "row/column.
    set list listchars=tab:._      "Show tabs as '.___.___'
    set winwidth=40
    set winminwidth=40
    set spell

    set clipboard=unnamed          "Yank and Paste from system clipboard instead
                                   "of 0 register. Very useful.
    if v:version == 704
        set mouse=nicr             "Enable mouse support
    endif

    if !has('nvim')
        set encoding=utf8
    endif

    set background=dark

    " Enable cursorline for active pane. Using this with vim-tmux-focus-events
    " enables this to work in tmux.
    au! FocusGained,InsertLeave * setlocal cursorline
    au! FocusLost,InsertEnter   * setlocal nocursorline
"}}}
"Colours {{{
    if $TERM =~ '256'
        let base16colorspace=256
    endif

    if has('termguicolors')
        set termguicolors
    endif

    silent! colorscheme base16-harmonic16-dark
"}}}
"Mappings {{{
    nnoremap <leader>ev :call EditVimrc()<cr>

    function! EditVimrc() "{{{
        if expand('%t') == ''
            edit $MYVIMRC
        else
            vsplit $MYVIMRC
        endif
    endfunction "}}}

    " Swap visual and block selection
    nnoremap v <C-V>
    nnoremap <C-V> v
    vnoremap v <esc>

    nnoremap <bs> :nohlsearch<cr>

    nnoremap S :%s/<C-R><C-W>//g<left><left>

    nnoremap <leader>d :call RunDiff()<cr>

    function! RunDiff() "{{{
        if exists(':Gdiff')
            Gdiff
        else
            VCSVimDiff
        endif
    endfunction "}}}

    " Correct common typos
    cnoremap W  w
    cnoremap Q  q
    cnoremap WQ wq
    cnoremap Wq wq
    cnoremap BD bd
    cnoremap Bd bd
    cnoremap Vs vs
    cnoremap VS vs
    cnoremap Sp sp

    " Should this not be default?
    nnoremap Y y$

    " Disable
    nnoremap Q <nop>
    vnoremap Q <nop>
    nnoremap K <nop>
    vnoremap K <nop>

    " Swap these
    noremap 0 ^
    noremap ^ 0

    vnoremap > >gv
    vnoremap < <gv

    " Escape is inefficient
    inoremap jk <esc>l

    " Toggles line number mode. Very useful.
    nnoremap <C-N> :set relativenumber!<cr>
"}}}
"Buffers {{{
    set hidden    "Allows buffers to exist in background
    set autoread  "Automatically read file when it is modified outside of vim
"}}}
"History & Backup {{{
    set history=5000   "keep a lot of history
    set viminfo+=:1000 "keep lots of cmd history
    set viminfo+=/1000 "keep lots of search history
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

    function! DeleteTrailingWS() "{{{
        if expand('%:t') =~ 'indent.sv'
            return
        endif

        normal mz"
        %s/\s\+$//ge
        normal `z"
    endfunction "}}}
"}}}
"Undo {{{
    if has('persistent_undo')
        set undolevels=5000
        set undodir=$HOME/.vimundo
        set undofile " Preserve undo tree between sessions.
    endif
"}}}
"Searching{{{
    set hlsearch             "Highlight search results.
    set incsearch            "Move cursor to search occurance.
    set ignorecase smartcase "Case insensitive search if lowercase.

    if executable('ag')
      "Use ag over grep
      set grepprg=ag\ --vimgrep
    endif
"}}}
"Folding{{{
    if v:version == 704
        set foldnestmax=10
        set foldlevel=0
        set foldcolumn=3
        set foldenable
        set foldtext=CustomFoldText()
        set foldmethod=syntax

        au! BufRead *vimrc* set foldmethod=marker foldlevel=0

        augroup folding
            autocmd!
            autocmd FileType json,sh setlocal foldmethod=marker
            autocmd FileType json,sh setlocal foldmarker={,}

            " Use SimpylFold for python
            autocmd FileType python setlocal foldmethod=expr
        augroup END

        function! CustomFoldText() "{{{
            let l:line = getline(v:foldstart)
            let l:line = substitute(l:line, '//{{{', '', 'g') "Remove marker }}}
            let l:line = substitute(l:line, '"{{{', '', 'g') "Remove marker }}}
            let l:line = substitute(l:line, '{{{'  , '', 'g') "Remove marker }}}
            let l:line = substitute(l:line, '//'   , '', 'g') "Remove comments
            let l:line = substitute(l:line, '^\s*' , '', 'g') "Remove leading whitespace
            let l:line = substitute(l:line, '^"'   , '', 'g') "Remove comment char (vim files)
            let l:line = substitute(l:line, '(.\{-})', '', 'g') "Remove function arguments
            let l:line = substitute(l:line, ';'     , '', 'g') "Remove function semi-colon
            let l:line = substitute(l:line, '/\*\s*\(.*\)', '/* \1 */', 'g') "Make block comments look nicer

            let right_margin = 1
            let fold_size    = v:foldend - v:foldstart + 1
            let fold_level   = &shiftwidth * v:foldlevel
            let num_col_size = wincol() - virtcol('.')

            let padding =
                \ winwidth(0) -
                \ num_col_size -
                \ len(l:line) -
                \ len(fold_size) -
                \ fold_level -
                \ right_margin

            return
                \ repeat(' ', fold_level).
                \ l:line.
                \ repeat(' ', padding).
                \ fold_size.
                \ repeat(' ', right_margin)

        endfunction "}}}
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
            set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10
        endif
    endif
"}}}
"SystemVerilog Settings {{{
    let g:verilog_syntax_fold_lst = "function,task,clocking"

    augroup systemverilog_settings
        au!
        au Filetype verilog_systemverilog setlocal shiftwidth=2
        au Filetype verilog_systemverilog setlocal tabstop=2
        au Filetype verilog_systemverilog setlocal softtabstop=2
        au Filetype verilog_systemverilog setlocal commentstring=//%s
    augroup END
"}}}
"File Settings {{{
    let g:xml_syntax_folding=1
    let g:vim_indent_cont = &sw
    augroup file_prefs
        autocmd!
        autocmd Filetype map    setlocal textwidth=0
        autocmd BufEnter *.log  setlocal textwidth=0
        autocmd BufEnter *.sig  setlocal filetype=xml
        autocmd Filetype tcl    setlocal shiftwidth=2
        autocmd Filetype yaml   setlocal shiftwidth=2

        " Set filetype to asl for txt files in asset-protection
        autocmd BufRead *.txt if expand('%:p') =~ 'asset-protection'
        autocmd BufRead *.txt     set filetype=asl
        autocmd BufRead *.txt endif
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
    iabbrev previouse   previous
    iabbrev seperate    separate
"}}}
"Plugin Settings {{{
    "Ag {{{
        let g:ag_prg='ag --vimgrep'
        "Start searching from project root rather than CWD.
        let g:ag_working_path_mode="r"
    "}}}
    "Cool-Status-Line {{{
        let g:coolstatusline_use_symbols = 1
    "}}}
    "CtrlP {{{
        let g:ctrlp_root_markers=['.ctrlp']

        let g:ctrlp_custom_ignore = {
            \ 'dir': '\v[\/](teal_autogen|eventdb|hal|lint)$',
            \ }
    "}}}
    "Dirvish {{{
    augroup dirvish_group
        autocmd!

        " Put directories at top.
        autocmd FileType dirvish sort r /[^\/]$/

        " Put cursor on current file.
        autocmd FileType dirvish call Attempt_select_last_file()

        " Disable spell checker
        autocmd FileType dirvish setlocal nospell

        " Colour certain file types.
        autocmd FileType dirvish call matchadd('Special'  , ".*\.tcl$")
        autocmd FileType dirvish call matchadd('Type'     , ".*\.yml$")
        autocmd FileType dirvish call matchadd('Statement', ".*\.v$"  )
        autocmd FileType dirvish call matchadd('Statement', ".*\.sv$" )
        autocmd FileType dirvish call matchadd('Statement', ".*\.hv$" )
        autocmd FileType dirvish call matchadd('Statement', ".*\.vh$" )
        autocmd FileType dirvish call matchadd('Statement', ".*\.svh$")
    augroup END

    function! Attempt_select_last_file() abort "{{{
        let l:previous=expand('#:t')
        if l:previous != ''
            call search('\v<' . l:previous . '>')
        endif
    endfunction "}}}
    "}}}
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
            \ 'left_margin' : 1, 'right_margin': 0
            \ }
        let g:easy_align_delimiters['['] = {
            \ 'pattern'     : '\s\zs\[',
            \ 'left_margin' : 1, 'right_margin': 0
            \ }
        let g:easy_align_delimiters[']'] = {
            \ 'pattern'     : ']',
            \ 'left_margin' : 0, 'right_margin': 1
            \ }
        let g:easy_align_delimiters[','] = {
            \ 'pattern'     : ',',
            \ 'left_margin' : 0, 'right_margin': 1
            \ }
        let g:easy_align_delimiters[')'] = {
            \ 'pattern'     : ')',
            \ 'left_margin' : 0, 'right_margin': 0
            \ }
        let g:easy_align_delimiters['('] = {
            \ 'pattern'     : '(',
            \ 'left_margin' : 0, 'right_margin': 0
            \ }
        let g:easy_align_delimiters['='] = {
            \ 'pattern'     : '<\?=',
            \ 'left_margin' : 1, 'right_margin': 1
            \ }
        let g:easy_align_delimiters['|'] = {
            \ 'pattern'     : '|\?|',
            \ 'left_margin' : 1, 'right_margin': 1
            \ }
        let g:easy_align_delimiters['&'] = {
            \ 'pattern'     : '&\?&',
            \ 'left_margin' : 1, 'right_margin': 1
            \ }
        let g:easy_align_delimiters[':'] = {
            \ 'pattern'     : ':',
            \ 'left_margin' : 1, 'right_margin': 1
            \ }
        nmap <leader>c mzgaip[gaipdgaip;gaip,`z
    "}}}
    "HL Matchit {{{
        let g:hl_matchit_enable_on_vim_startup = 1
    "}}}
    "Incsearch {{{
        augroup mapincsearch
            au!
            " Disable incsearch plugin for large files
            au BufEnter * if line('$') < 30000 && v:version >= 704
            au BufEnter *     map <buffer> /  <Plug>(incsearch-forward)
            au BufEnter *     map <buffer> ?  <Plug>(incsearch-backward)
            au BufEnter *     map <buffer> g/ <Plug>(incsearch-stay)
            au BufEnter * endif
        augroup END
    "}}}
    "Lengthmatters {{{
        let g:lengthmatters_highlight_one_column=1
    "}}}
    "Vim Action Ag {{{
        nmap g* <Plug>AgActionWord
    "}}}
    "Signify {{{
        let g:signify_vcs_list              = [ 'svn' ]
        let g:signify_update_on_focusgained = 1
        let g:signify_sign_delete           = '-'
    "}}}
"}}}
"Bug Fixes {{{
augroup bug_fixes
    " When using vim-tmux-navigator and vim-tmux-focus-events, ^[[O gets
    " inserted when switching panes. This is a workaround to prevent that.
    au FocusLost * silent redraw!
augroup END
"}}}
"Apply .vimrc on save {{{
augroup apply_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
    autocmd BufWritePost $MYVIMRC call coolstatusline#Refresh()
augroup END
"}}}

" vim: set textwidth=0 foldmethod=marker foldlevel=0:
