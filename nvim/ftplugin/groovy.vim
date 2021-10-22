if search('^pipeline\s*{', 'n', 10) > 0
    setlocal filetype=Jenkinsfile
    syntax on
endif
