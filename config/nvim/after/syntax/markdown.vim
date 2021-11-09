
" For doctool flavoured markdown
syntax region markdownCode matchgroup=markdownCodeDelimiter start='^\~\+\s*{.*}.*$' end='^\~\+' keepend
syntax match markdownRule "\w\+(\w\+)::"
