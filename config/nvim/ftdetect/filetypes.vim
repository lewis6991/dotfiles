autocmd BufNewFile,BufRead *.conf                set filetype=toml
autocmd BufNewFile,BufRead gerrit_hooks          set filetype=toml
autocmd BufNewFile,BufRead setup.cfg             set filetype=toml
autocmd BufNewFile,BufRead lit.cfg,lit.local.cfg set filetype=python
autocmd BufNewFile,BufRead dotshrc,dotsh         set filetype=sh
autocmd BufNewFile,BufRead dotcshrc              set filetype=csh
autocmd BufNewFile,BufRead gitconfig             set filetype=gitconfig
autocmd BufNewFile,BufRead *
    \   if getline(1) =~ '^#%Module.*'
    \ |     set filetype=tcl
    \ | endif
