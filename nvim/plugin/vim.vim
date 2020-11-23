if has('nvim')
    finish
endif

function! s:exists(var)
    if exists(a:var)
        return 1
    endif
    echoerr a:var.' is not defined'
    return 0
endfunction

if s:exists('$XDG_CONFIG_HOME') && s:exists('$XDG_DATA_HOME')
    set runtimepath=
        \$XDG_CONFIG_HOME/vim,
        \$XDG_DATA_HOME/vim/site,
        \$VIMRUNTIME,
        \$XDG_DATA_HOME/vim/site/after,
        \$XDG_CONFIG_HOME/vim/after
endif

if s:exists('$XDG_DATA_HOME')
    set directory=$XDG_DATA_HOME/vim/swap
endif

if s:exists('$XDG_CACHE_HOME')
    set backupdir=$XDG_CACHE_HOME/vim/backup
    set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
endif

" Make normal Vim behave like Neovim
set autoindent
set autoread
set backspace=indent,eol,start
set complete-=i
set display=lastline
if v:version >= 704
    set formatoptions=tcqj
endif
set history=10000
set incsearch
set showcmd
set smarttab
set tabpagemax=50
set hlsearch
set ruler
set laststatus=2
set wildmenu

" Tell vim how to use true colour.
if v:version >= 800
    let &t_8f = '[38;2;%lu;%lu;%lum'
    let &t_8b = '[48;2;%lu;%lu;%lum'
endif
