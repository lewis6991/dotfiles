function! JsonFolds() abort
    let l:line = getline(v:lnum)
    " let l:lline = split(l:line, '\zs')
    let l:inc = count(l:line, '{')
    let l:dec = count(l:line, '}')
    let l:level = inc - dec
    if l:level == 0
        return '='
    elseif l:level > 0
        return 'a'.l:level
    elseif l:level < 0
        return 's'.-l:level
    endif
endfunction

setlocal conceallevel=0
setlocal foldnestmax=5
setlocal foldmethod=marker
setlocal foldmarker={,}

setlocal foldmethod=expr
setlocal foldexpr=JsonFolds()
setlocal nofoldenable
