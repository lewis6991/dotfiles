autocmd BufNewFile,BufRead *.conf                setfiletype toml
autocmd BufNewFile,BufRead gerrit_hooks          setfiletype toml
autocmd BufNewFile,BufRead setup.cfg             setfiletype toml
autocmd BufNewFile,BufRead lit.cfg,lit.local.cfg setfiletype python
autocmd BufNewFile,BufRead dotshrc,dotsh         setfiletype sh
autocmd BufNewFile,BufRead dotcshrc              setfiletype csh
autocmd BufNewFile,BufRead gitconfig             setfiletype gitconfig
autocmd BufNewFile,BufRead *
    \   if getline(1) =~ '^#%Module.*'
    \ |     setfiletype tcl
    \ | endif
