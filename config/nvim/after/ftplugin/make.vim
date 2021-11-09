
function! MakeFolds() abort
    let l:line1 = getline(v:lnum)
    let l:line2 = getline(v:lnum+1)
    if l:line1 =~# '^# \w\+' && l:line2 =~# '^#-\+$'
        return '>1'
    else
        return '='
    endif
endfunction

setlocal noexpandtab
setlocal foldmethod=expr
setlocal foldexpr=MakeFolds()
