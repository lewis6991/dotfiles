set nocp " VIM is better than VI
"Pathogen plugins {{{
filetype off " Required in order to use pathogen and vundle.
execute pathogen#infect()
filetype plugin indent on "Can enable now plugins are loaded.
"}}}
"General {{{
set nostartofline
set number
set numberwidth=1              "Width of number column
set showmatch                  "Show matching parenthesis
set scrolloff=10               "Context while scrolling
set nowrap                     "Turn off text wrapping
set backspace=indent,eol,start "Make backspace work
set wildmenu
set laststatus=2
set textwidth=80
set t_kb=                    "Fix for backspace issue when using xterm.
set tag+=tags;/
set lazyredraw                 "Don't redraw during macros

if v:version == 704
    set mouse=a                "Enable mouse support
endif

colorscheme slate
"}}}
"Mappings {{{
    "VIM Training {{{
    noremap <Up>       :echo "Stop being stupid!"<enter>
    noremap <Down>     :echo "Stop being stupid!"<enter>
    noremap <Left>     :echo "Stop being stupid!"<enter>
    noremap <Right>    :echo "Stop being stupid!"<enter>
    noremap <PageUp>   :echo "Stop being stupid!"<enter>
    noremap <PageDown> :echo "Stop being stupid!"<enter>
    inoremap <Up>       <esc>:echo "Stop being stupid!"<enter>
    inoremap <Down>     <esc>:echo "Stop being stupid!"<enter>
    inoremap <Left>     <esc>:echo "Stop being stupid!"<enter>
    inoremap <Right>    <esc>:echo "Stop being stupid!"<enter>
    inoremap <PageUp>   <esc>:echo "Stop being stupid!"<enter>
    inoremap <PageDown> <esc>:echo "Stop being stupid!"<enter>
    "}}}
    noremap Q :q<enter>
    nnoremap <leader>ev :vsplit $MYVIMRC<cr>
    nnoremap :W :w
    nnoremap :Q :q
    nnoremap :wQ :wq
    nnoremap :WQ :wq
    nnoremap :Wq :wq
    nnoremap :BD :bd
    nnoremap :Bd :bd
    nnoremap :bD :bd
    inoremap jk <esc>
    nnoremap ; :
    nnoremap <space> za
    " Toggles line number mode.
    function! g:ToggleNuMode() "{{{
        if(&rnu == 1)
            set nornu
        else
            set rnu
        endif
    endfunc "}}}
    nnoremap <C-N> :call g:ToggleNuMode()<cr>
"}}}
"Tabular mappings {{{
    nnoremap <silent> <leader>q :Tab /=<Enter>
"}}}
"Buffers {{{
    set hidden    "Allows buffers to exist in background
    set autoread  "Automatically read file when it is modified outside of vim

    if v:version == 704
        set autochdir "Automatically change to directory to current buffer
    endif
"}}}
"History {{{
   set history=500   "keep a lot of history
   set viminfo+=:100 "keep lots of cmd history
   set viminfo+=/100 "keep lots of search history
"}}}
"Backups {{{
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
   " set smartindent
"}}}
"Syntax{{{
   syntax enable "Enable syntax highlighting
"}}}
"Folding{{{
if v:version == 704
    set foldmethod=marker
    set foldnestmax=10
    set foldlevel=0
    set foldenable
    set foldcolumn=0

    function! CustomFoldText() "{{{
        "get first non-blank line
        let line = getline(v:foldstart)
        if v:foldstart < v:foldend
            let line = substitute(line, '//{{{', '', 'g') "Remove marker }}}
            let line = substitute(line, '{{{'  , '', 'g') "Remove marker }}}
            let line = substitute(line, '//'   , '', 'g') "Remove comments
            let line = substitute(line, '^\s*' , '', 'g') "Remove leading whitespace
            let line = substitute(line, '(.*);', '', 'g') "Remove function arguments
            let line = substitute(line, '/\*', '/*...*/', 'g') "Make block comments look nicer
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

    set foldtext=CustomFoldText()
endif
"}}}
"GUI Options {{{
if has("gui_running")
    set guioptions-=m "Remove menu bar
    set guioptions-=T "Remove toolbar
    set guifont=DejaVu\ \LGC\ Sans\ Mono\ 14
endif
if has("mac")
    let g:airline_powerline_fonts=1
endif
"}}}
"SystemVerilog Mappings {{{
function! UpdateTags() "{{{
    let file = expand("%:p")
    let cmd = 'ctags -a ' . file
    let resp = system(cmd)
endfunction "}}}
augroup sv_prefs
    au!
    "UVM Report Macros {{{
    au FileType verilog_systemverilog inoremap `ui `uvm_info(BIU_TAG, "", UVM_NONE)<esc>11<left>i
    au FileType verilog_systemverilog inoremap `us `uvm_info(BIU_TAG, $sformatf(""), UVM_NONE)<esc>12<left>i
    au FileType verilog_systemverilog inoremap `ue `uvm_error(BIU_TAG, "", UVM_NONE)<esc>11<left>i
    au FileType verilog_systemverilog inoremap `uw `uvm_warning(BIU_TAG, "", UVM_NONE)<esc>11<left>i
    au FileType verilog_systemverilog inoremap `uf `uvm_fatal(BIU_TAG, "")<left><left>
    "}}}
    "UVM Class Macros {{{
    au FileType verilog_systemverilog inoremap `newc function new(string name, uvm_component parent);<enter>super.new(name, parent);<enter> endfunction : new<esc>2<up>3==i
    au FileType verilog_sVystemverilog inoremap `newo function new(string name = "");<enter>super.new(name);<enter> endfunction : new<esc>2<up>3==i
    "}}}
    "UVM Phase Macros {{{
    au FileType verilog_systemverilog inoremap `cphase function void connect_phase(uvm_phase phase);<enter>endfunction : connect_phase<esc>1<up>2==i<esc>o
    au FileType verilog_systemverilog inoremap `bphase function void build_phase(uvm_phase phase);<enter>endfunction : build_phase<esc>1<up>2==i<esc>o
    "}}}
    "SystemVerilog Macros {{{
    au FileType verilog_systemverilog inoremap <leader>f <esc>diwifunction void <esc>pa();<enter>endfunction : <esc>p<up>2==o
    au FileType verilog_systemverilog inoremap <leader>t <esc>diwitask <esc>pa();<enter>endtask : <esc>p<up>2==o
    au FileType verilog_systemverilog inoremap <leader>df <esc>diwifunction void <esc>pa();<enter>endfunction : <esc>p<up>O/*<enter>Function: <esc>pa<enter><enter><enter>Parameters:<enter><enter>Returns:<enter><bs>/<esc>jo
    au FileType verilog_systemverilog inoremap <leader>dt <esc>diwitask <esc>pa();<enter>endtask : <esc>p<up>O/*<enter>Task: <esc>pa<enter><enter><enter>Parameters:<enter><bs>/<esc>j2==
    au FileType verilog_systemverilog inoremap <leader>vf <esc>diwivirtual function void <esc>pa();<enter>endfunction : <esc>p<up>2==o
    au FileType verilog_systemverilog inoremap <leader>vt <esc>diwivirtual task <esc>pa();<enter>endtask : <esc>p<up>2==o
    au FileType verilog_systemverilog noremap  <leader>s <esc>kA begin<esc>jjIend <esc>==ko
    "}}}
    au BufEnter *.log setlocal wrap cursorline

    "verilog macro to convert portlist into instantiation list.
    au FileType verilog_systemverilog let @r=':%s/\v(input|output|inout|ref)\s+((\w+|\[.*\])\s+)?([a-z]\w+)\s*(\[.*\]\s*)?=?.*,$/\.\3\(\3\),\\/g'
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

    augroup file_prefs
        au!
        au Filetype verilog_systemverilog setlocal sw=2 sts=2
        au Filetype verilog_systemverilog setlocal commentstring=//%s
        au Filetype verilog_systemverilog setlocal foldmethod=syntax foldlevel=1

        "Tabular macro to allign class fields and variable assignments
        au Filetype verilog_systemverilog nnoremap <silent> <leader>c :Tab /\s[/l0<enter>:Tab /\s[a-z]/l0<enter>:Tab /;/l0<enter>:Tab /=<enter>
    augroup END
    let g:verilog_syntax_fold = "all"
    com! -buffer RenameFunction call RenameFunction()
"}}}
"Example vimscript {{{
function! SVFold(line) "{{{
   let str = getline(a:line)
   let fold_open  = [
               \'^\s*(virtual\s+)?class\s+',
               \'^\s*(virtual\s+)?function\s+',
               \'^\s*(virtual\s+)?task\s+',
               \'^\s*(default\s+)?clocking\s+',
               \'^\s*module\s+',
               \'^\s*\(\s*$',
               \'\s*/\*\s*$'
               \]
   let fold_close = [
               \'^\s*endclass',
               \'^\s*endfunction',
               \'^\s*endtask',
               \'^\s*endclocking',
               \'^\s*endmodule',
               \'^\s*\)\s*;\s*$',
               \'\s*\*/\s*$'
               \]
   if str =~ '\v'.join(fold_open, '|')
      return 'a1'
   elseif str =~ '\v'.join(fold_close, '|')
      return 's1'
   else
       return '='
   endif
endfunction "}}}
" au Filetype systemverilog :au InsertLeave * :call RenameFunction()
    "au BufWritePost *.sv,*.svh,*.v call UpdateTags()
"}}}
"Abbreviations {{{
    iabbrev funciton  function
    iabbrev functiton function
    iabbrev fucntion  function
    iabbrev funtion   function
    iabbrev erturn    return
    iabbrev retunr    return
    iabbrev reutrn    return
    iabbrev reutn     return
    iabbrev htis      this
    iabbrev foreahc   foreach
    iabbrev forech    foreach
"}}}
"Apply .vimrc on save {{{
augroup sourceConf
   autocmd!
   autocmd BufWritePost .vimrc so %
   autocmd FileType vim :au BufEnter setlocal textwidth=0
augroup END
"}}}
