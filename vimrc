"Plugins {{{

    " Install vim-plug if we don't already have it {{{
    if empty(glob("~/.vim/autoload/plug.vim"))
        execute 'silent !mkdir -p ~/.vim/tmp/'
        execute 'silent !mkdir -p ~/.vim/tmp/undo'
        execute 'silent !mkdir -p ~/.vim/tmp/backup'
        execute 'silent !mkdir -p ~/.vim/plugged'
        execute 'silent !mkdir -p ~/.vim/autoload'
        execute 'silent !curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
    endif "}}}

    call plug#begin('~/.vim/plugged')

    if $USER =~ 'lewrus01'
        Plug '~/asl.vim'
        Plug '~/archex.vim'
        Plug '~/git/tcl.vim'
        Plug '~/git/moonlight.vim'
        Plug '~/git/verilog_systemverilog.vim'
    else
        Plug 'lewis6991/tcl.vim'
        Plug 'lewis6991/moonlight.vim'
        Plug 'vhda/verilog_systemverilog.vim'
    endif

    " Plug '~/systemverilog.vim'

    "Plug 'chrisbra/Colorizer'
    "Config {{{
    let g:colorizer_auto_map = 1
    let g:colorizer_colornames_disable = 1
    " let g:colorizer_hex_disable = 1
    let g:colorizer_hsla_disable = 1
    let g:colorizer_rgb_disable = 1
    let g:colorizer_rgba_disable = 1
    let g:colorizer_taskwarrior_disable = 1
    let g:colorizer_term_disable = 1
    let g:colorizer_term_conceal_disable = 1
    let g:colorizer_vimcolors_disable = 1
    let g:colorizer_vimhighl_dump_disable = 1
    let g:colorizer_vimhighlight_disable = 1
    "}}}

    Plug '~/git/vim-cool-status-line'
    "Config {{{
    let g:coolstatusline_use_symbols = 1
    "}}}

    if has('timers') && has('jobs') && has('channel')
        Plug 'w0rp/ale'
    endif

    Plug 'tpope/vim-commentary', {'on': '<Plug>Commentary'}
    "Config {{{
    map  gc  <Plug>Commentary
    nmap gcc <Plug>CommentaryLine
    "}}}
    Plug 'tpope/vim-unimpaired'
    Plug 'triglav/vim-visual-increment'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'visualrepeat'
    Plug 'Super-Shell-Indent'
    Plug 'sickill/vim-pasta'
    Plug 'dietsche/vim-lastplace'
    Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign'] }
    "Config {{{
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
    let g:easy_align_delimiters['?'] = {
        \ 'pattern'     : '?',
        \ 'left_margin' : 1, 'right_margin': 1
        \ }

    nmap <leader>c mzgaip[gaipdgaip;gaip,`z
    "}}}
    Plug 'vimtaku/hl_matchit.vim'
    "Config {{{
    let g:hl_matchit_enable_on_vim_startup = 1
    "}}}
    Plug 'justinmk/vim-dirvish'
    "Config {{{
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
    Plug 'whatyouhide/vim-lengthmatters'
    "Config {{{
    let g:lengthmatters_highlight_one_column=1
    "}}}

    Plug 'ctrlpvim/ctrlp.vim', { 'on': 'CtrlP' }
    "Config {{{
    nnoremap <C-P> :CtrlP<cr>
    "}}}

    "Fold
    Plug 'lewis6991/vim-clean-fold'
    Plug 'Konfekt/FastFold'

    "Completion
    Plug 'cmdline-completion'
    Plug 'maxboisvert/vim-simple-complete'

    "Snippets
    Plug 'MarcWeber/vim-addon-mw-utils' "vim-snipmate dependency
    Plug 'tomtom/tlib_vim'              "vim-snipmate dependency
    Plug 'garbas/vim-snipmate'
    "Config {{{
    imap <tab> <Plug>snipMateNextOrTrigger
    "}}}

    "Syntax
    Plug 'tmhedberg/SimpylFold'
    Plug 'derekwyatt/vim-scala'
    Plug 'elzr/vim-json'

    "Colourschemes
    Plug 'chriskempson/base16-vim'
    Plug 'whatyouhide/vim-gotham'

    "Tmux Integration
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'tmux-plugins/vim-tmux'

    "Search
    Plug 'rking/ag.vim', { 'on': 'Ag' }
    Plug 'Chun-Yang/vim-action-ag', { 'on': '<Plug>AgActionWord' }
    "Config {{{
    nmap g* <Plug>AgActionWord
    "}}}

    if v:version >= 704
        Plug 'haya14busa/incsearch.vim',
            \ { 'on': [
            \   '<Plug>(incsearch-forward)' ,
            \   '<Plug>(incsearch-backward)',
            \   '<Plug>(incsearch-stay)'
            \ ]}
        "Config {{{
        augroup mapincsearch
            au!
            " Disable incsearch plugin for large files
            au BufEnter * if line('$') < 30000
            au BufEnter *     map <buffer> /  <Plug>(incsearch-forward)
            au BufEnter *     map <buffer> ?  <Plug>(incsearch-backward)
            au BufEnter *     map <buffer> g/ <Plug>(incsearch-stay)
            au BufEnter * endif
        augroup END
        "}}}
    endif

    "Source Control
    Plug 'tpope/vim-fugitive'
    Plug 'vim-scripts/vcscommand.vim'
    Plug 'junegunn/gv.vim', { 'on': 'GV' }
    Plug 'airblade/vim-gitgutter'
    Plug 'mhinz/vim-signify'
    "Config {{{
    let g:signify_vcs_list              = [ 'svn' ]
    let g:signify_update_on_focusgained = 1
    let g:signify_sign_delete           = '-'
    "}}}

    call plug#end()

    runtime macros/matchit.vim
"}}}
"General {{{
    set nocompatible               "VIM is better than VI
    set nostartofline              "Keep cursor in same column when moving
                                   "up/down.

    set number                     "Show line numbers.
    set numberwidth=1              "Make as small as possible
    if v:version >= 704
        set relativenumber
    endif

    set autoindent
    set showmatch                  "Show matching parenthesis
    set scrolloff=8                "Context while scrolling
    set sidescrolloff=8            "Context while side-scrolling
    set nowrap                     "Turn off text wrapping
    set backspace=indent,eol,start "Make backspace work
    set wildmenu                   "Show completions on command line
    set wildmode=longest:full,full
    set laststatus=2               "Always show the status bar
    set lazyredraw                 "Don't redraw during macros

    " Auto-completion
    set completeopt+=menuone       "Show popup menu even if there is only one match.
    set completeopt+=longest

    set diffopt+=vertical          "Show diffs in vertical splits
    set diffopt+=foldcolumn:0      "Hide foldcolumn in diffs for more room.
    set virtualedit=block          "Allow visual block mode to select over any
                                   "row/column.

    set textwidth=80
    set winwidth=40
    set winminwidth=40
    set spell                     "Enable spellchecking

    set tags=./tags;              "Search recursively up directories until a tags file is found.

    set clipboard=unnamed          "Yank and Paste from system clipboard instead
                                   "of 0 register.
    if v:version >= 704
        set mouse=nicr             "Enable mouse support
    endif

    if !has('nvim')
        set encoding=utf8
    endif

    " Enable cursorline for active pane. Using this with vim-tmux-focus-events
    " enables this to work in tmux.
    au! FocusGained,InsertLeave * setlocal cursorline
    au! FocusLost,InsertEnter   * setlocal nocursorline
"}}}
"Formatting {{{
    set formatoptions=tc "Automatic wrapping for text and comments
    set formatoptions+=r "Automatically insert comment leader after <Enter> in Insert mode.
    set formatoptions+=o "Automatically insert comment leader after 'o' or 'O' in Normal mode.
    set formatoptions+=q "Allow formatting of comments with "gq".
    set formatoptions+=l "Long lines are not broken in insert mode.
    if v:version >= 704
        set formatoptions+=j "Where it makes sense, remove a comment leader when joining lines.
        set breakindent      "Indent wrapped lines to match start
    endif
"}}}
"Colours {{{
    if has('termguicolors')
        set termguicolors
    else
        let base16colorspace=256
    endif

    if !has('nvim')
        " Tell vim how to use true colour.
        let &t_8f = "[38;2;%lu;%lu;%lum"
        let &t_8b = "[48;2;%lu;%lu;%lum"
    endif

    if v:version >= 704
        set highlight+=N:Conceal
    endif

    set background=dark

    " silent! colorscheme base16-harmonic16-dark
    silent! colorscheme moonlight
"}}}
"Mappings {{{
    nnoremap <leader>ev :call EditVimrc()<cr>

    function! EditVimrc() "{{{
        if expand('%t') == ''
            edit $MYVIMRC
        else
            split $MYVIMRC
            " vsplit $MYVIMRC
        endif
    endfunction "}}}

    " Swap visual and block selection
    nnoremap v <C-V>
    nnoremap <C-V> v
    vnoremap v <esc>

    nnoremap <bs> :nohlsearch<cr>

    nnoremap S :%s/\<<C-R><C-W>\>//g<left><left>

    nnoremap <leader>d :call RunDiff()<cr>

    function! RunDiff() "{{{
        if exists(':Gdiff')
            Gdiff
        else
            VCSVimDiff
        endif
    endfunction "}}}

    " Show syntax highlighting groups for word under cursor
    nnoremap <leader>z :call <SID>SynStack()<CR>

    function! <SID>SynStack() "{{{
      if !exists("*synstack")
        return
      endif
      echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endfunction "}}}

    " Correct common typos for commands
    command! W  w
    command! Q  q
    command! WQ wq
    command! Wq wq
    command! BD bd
    command! Bd bd
    command! Vs vs
    command! VS vs
    command! Sp sp
    command! Qa qa

    " Why is this not default?
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

    " Toggles line number mode.
    nnoremap <C-N> :set relativenumber!<cr>
"}}}
"Buffers {{{
    set hidden    "Allows buffers to exist in background
    set autoread  "Automatically read file when it is modified outside of vim
"}}}
"History, Backup and Undo {{{
    set history=5000   "keep a lot of history
    set noswapfile

    if exists('$SUDO_USER')
        " Don't create root-owned files.
        set nobackup
        set nowritebackup
        set viminfo=
    else
        set backupdir=~/.vim/tmp/backup  " keep backup files out of the way
        if !has('nvim')
            set viminfo+=n~/.vim/tmp/viminfo " override ~/.viminfo default
        else
            set viminfo+=n~/.vim/tmp/nviminfo " override ~/.viminfo default
        endif
    endif

    if has('persistent_undo')
        if exists('$SUDO_USER')
            set noundofile
        else
            set undolevels=5000
            set undodir=~/.vim/tmp/undo
            set undofile " Preserve undo tree between sessions.
        endif
    endif
"}}}
"Whitespace {{{
    set shiftwidth=4           "Set tab to 4 spaces
    set softtabstop=4
    set tabstop=4
    set expandtab              "Convert tabs to spaces when typing
    set list
    set listchars=tab:›\       "Show tabs as '›   ›   '

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
"Searching {{{
    set hlsearch   "Highlight search results.
    set incsearch  "Move cursor to search occurrence.
    set ignorecase "Case insensitive search if lowercase.
    set smartcase
"}}}
"Folding{{{
    if has('folding')
        set foldnestmax=10
        set foldlevel=0
        set foldcolumn=3
        set foldcolumn=0
        set foldenable
        set foldmethod=syntax

        let g:sh_fold_enabled=1

        augroup folding
            autocmd!

            " Use SimpylFold for python
            autocmd FileType python setlocal foldmethod=expr
        augroup END
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
    let g:verilog_syntax_fold_lst = "all"

    augroup systemverilog_settings
        au!
        au Filetype verilog_systemverilog setlocal shiftwidth=2
        au Filetype verilog_systemverilog setlocal tabstop=2
        au Filetype verilog_systemverilog setlocal softtabstop=2
        au Filetype verilog_systemverilog setlocal commentstring=//%s
    augroup END
"}}}
"File Settings {{{
    "XML
    let g:xml_syntax_folding=1

    "VimL
    let g:vimsyn_embed    = 0    "Don't highlight any embedded languages.
    let g:vimsyn_folding  = 'af' "Fold augroups and functions
    let g:vim_indent_cont = &sw

    "Perl
    let perl_fold=1
    let perl_extended_vars = 1

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
    autocmd BufWritePost $MYVIMRC set foldmethod=marker foldlevel=0
augroup END
"}}}
" vim: set textwidth=0 foldmethod=marker foldlevel=0:
