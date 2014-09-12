
set nocp

set number
set numberwidth=1 "Width of number column
set cursorline    "Highlight cursor line
set showmatch     "Show matching parenthesis
set scrolloff=8   "Context while scrolling

set autoread "Automatically read file when it is modified outside of vim
set hidden   "Allows buffers to exist in background

set nowrap     "Turn off text wrapping

set autochdir "Automatically change to directory of current buffer

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
   set shiftwidth=3                "Set tab to 3 spaces
   set softtabstop=3
   set tabstop=3
   set expandtab                   "Use spaces instead of tabs

   augroup DelTrail
      autocmd!
      autocmd BufWrite * :call DeleteTrailingWS()
   augroup END
   
    " Delete trailing white space on save, useful for Python and CoffeeScript ;)
   func! DeleteTrailingWS()
      exe "normal mz"
      %s/\s\+$//ge
      exe "normal `z"
   endfunc
"}}}

"Searching{{{
   set hlsearch                   "Highlight search results.
   set incsearch                  "Move cursor to search occurance.
   set ignorecase smartcase       "Case insensitive search if lowercase.
"}}}

"Indentation{{{
   set autoindent
   set smartindent
"}}}

"Syntax{{{
   syntax enable                         "Enable syntax highlighting
   set omnifunc=syntaxcomplete#Complete  "Enable omnicomplete
"}}}

"Folding{{{
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
         let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
         let line = substitute(line, '//{{{', repeat(' ', 5), 'g') "}}}
         let line = substitute(line, '{{{', repeat(' ', 5), 'g') "}}}
         let line = substitute(line, '//', '', 'g')
      endif

      let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0) + 5
      let foldSize = 1 + v:foldend - v:foldstart
      let foldSizeStr = " " . foldSize . " lines "
      let foldLevelStr = repeat("   ", v:foldlevel)
      let lineCount = line("$")
      let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
      let expansionString = repeat(" ", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
      return foldLevelStr . line . expansionString . foldSizeStr . foldPercentage
   endf
   set foldtext=CustomFoldText()
"}}}


set guioptions-=m "Remove menu bar
set guioptions-=T "Remove toolbar
set guifont=DejaVu\ Sans\ Mono\ 12

"Apply .vimrc on save {{{
augroup sourceConf
   autocmd!
   autocmd BufRead .vimrc set foldmethod=marker
   autocmd BufWritePost .vimrc so %
augroup END
"}}}

