autocmd FileType groovy
    \   if search('^pipeline\s*{', 'n', 10) > 0
    \ |     setlocal filetype=Jenkinsfile
    \ | endif
