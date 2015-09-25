set nocp " VIM is better than VI

filetype off " Required in order to use pathogen and vundle.

"Install pathogen plugins
execute pathogen#infect()

filetype plugin indent on "Can enable now plugins are loaded.

"General {{{
set number
set numberwidth=1 "Width of number column
set showmatch     "Show matching parenthesis
set scrolloff=10  "Context while scrolling
set nowrap        "Turn off text wrapping
set backspace=indent,eol,start "Make backspace work
set wildmenu
set laststatus=2
set textwidth=80

if v:version == 704
    set mouse=a
endif

"}}}
"set colorcolumn=+1
"let &colorcolumn=join(range(81,999),",")

set t_kb= "Fix for backspace issue when using xterm.

set tag+=tags;/

colorscheme slate

" Crazy cool verilog macro to convert portlist into instantiation list.
let @r=':%s/\(input\|output\|inout\|ref\)\s\+\([a-z0-9_]*\s\+\|\[.*\]\s\+\)\=\([a-z][a-z0-9_]\+\)\s*\(\[.*\]\)\=\s*,\=$/\.\3(\3),\\/g'

"let &winwidth = 85 "Set focused window to around 80 columns.
"let &winwidth = &columns * 5/10

"nnoremap <silent> <Leader>+ :exe "vertical resize " . (winheight(0) * 3/2)<CR>
"nnoremap <silent> <Leader>- :exe "vertical resize " . (winheight(0) * 2/3)<CR>

"SystemVerilog Mappings {{{
augroup sv_prefs
    au Filetype systemverilog inoremap `ui `uvm_info(get_name(), "", UVM_NONE)<esc>11<left>i
    au Filetype systemverilog inoremap `ue `uvm_error(get_name(), "", UVM_NONE)<esc>11<left>i
    au Filetype systemverilog inoremap `uw `uvm_warning(get_name(), "", UVM_NONE)<esc>11<left>i
    au Filetype systemverilog inoremap `uf `uvm_fatal(get_name(), "")<left><left>
augroup END
"}}}

augroup longlines
    au BufWinEnter * let w:m2=matchadd('Search', '\%>80v.\+', -1)
augroup END

"Tabular mappings {{{
    "vmap q :Tab /(/l0<Enter>
    "nmap q :Tab /(/l0<Enter>
    "vmap Q :Tab /)/l0<Enter>
    "nmap Q :Tab /)/l0<Enter>
    "vmap c :Tab /(/l0<Enter>gv:Tab /)/l0<Enter>
    nnoremap <silent> <leader>q :Tab /=<Enter>
"}}}
"Simple Key Mappings {{{
    nmap :W :w
    nmap :Q :q
    nmap :wQ :wq
    nmap :WQ :wq
    nmap :Wq :wq
"}}}
"Buffers {{{
    set hidden    "Allows buffers to exist in background
    set autoread  "Automatically read file when it is modified outside of vim

    if v:version == 704
        set autochdir "Automatically change to directory of current buffer
    endif
"}}}
"History {{{
   set history=500                "keep a lot of history
   set viminfo+=:100              "keep lots of cmd history
   set viminfo+=/100              "keep lots of search history
"}}}
"Backups {{{
   set nowb
   set noswapfile
   set nobackup
"}}}
"Whitespace{{{
   set shiftwidth=4                "Set tab to 3 spaces
   set softtabstop=4
   set tabstop=4
   set expandtab                   "Use spaces instead of tabs

   augroup DelTrail
      autocmd!
      autocmd BufWrite * :call DeleteTrailingWS()
   augroup END

    " Delete trailing white space on save.
   func! DeleteTrailingWS()
      exe "normal mz"
      %s/\s\+$//ge
      exe "normal `z"
   endfunc
"}}}
"Searching{{{
   set hlsearch             "Highlight search results.
   set incsearch            "Move cursor to search occurance.
   set ignorecase smartcase "Case insensitive search if lowercase.
"}}}
"Indentation{{{
   set autoindent
   set smartindent
"}}}
"Syntax{{{
   syntax enable "Enable syntax highlighting
"}}}
"highlight ColorColumn ctermbg=1 "Must be placed after 'syntax enable'
"Folding{{{
if v:version == 704
    set foldmethod=marker
    set foldnestmax=10
    set foldlevel=0
    set foldenable
    set foldcolumn=0

    fu! CustomFoldText()
        "get first non-blank line
        let fs = v:foldstart
        while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
        endwhile
        if fs > v:foldend
            let line = getline(v:foldstart)
        else
            let line = substitute(getline(fs), '\t', repeat('', &tabstop), 'g')
            let line = substitute(line, '//{{{', repeat(' ', 5), 'g') "Remove marker }}}
            let line = substitute(line, '{{{', repeat(' ', 5), 'g') "Remove marker }}}
            let line = substitute(line, '//', '', 'g') "Remove comments
        endif

        let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0) + 5
        let foldSize = 1 + v:foldend - v:foldstart
        let foldSizeStr = " " . foldSize . " lines "
        let foldLevelStr = repeat("+   ", v:foldlevel)
        let lineCount = line("$")
        let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
        let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
        return foldLevelStr . line . expansionString . foldSizeStr . foldPercentage
    endf

    set foldtext=CustomFoldText()
endif
"}}}
"GUI Options {{{
if has("gui_running")
    set guioptions-=m "Remove menu bar
    set guioptions-=T "Remove toolbar
    set guifont=DejaVu\ \LGC\ Sans\ Mono\ 14
endif
"}}}
"File specific {{{
augroup file_prefs
    au Filetype verilog       setlocal sw=2 sts=2 foldmethod=indent foldlevel=10
    au Filetype systemverilog setlocal sw=2 sts=2 foldmethod=indent foldlevel=10
augroup END
"}}}
"Apply .vimrc on save {{{
augroup sourceConf
   autocmd!
   autocmd BufWritePost .vimrc so %
augroup END
"}}}
