function! YamlFolds() abort "{{{
    let l:previous_level = indent(prevnonblank(v:lnum - 1)) / &shiftwidth
    let l:current_level = indent(v:lnum) / &shiftwidth
    let l:next_level = indent(nextnonblank(v:lnum + 1)) / &shiftwidth

    if getline(v:lnum + 1) =~? '^\s*$'
        return '='
    elseif l:current_level < l:next_level
        return l:next_level
    elseif l:current_level > l:next_level
        return ('s' . (l:current_level - l:next_level))
    elseif l:current_level == l:previous_level
        return '='
    endif

    return l:next_level
endfunction "}}}

setlocal foldmethod=expr
setlocal foldexpr=YamlFolds()
