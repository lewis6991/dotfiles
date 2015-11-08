function! SVFold(line) "{{{
    let str = getline(a:line)
    let fold_open  = [
                \'^\s*(virtual\s+)?class\s+',
                \'^\s*(virtual\s+)?function\s+',
                \'^\s*(virtual\s+)?task\s+',
                \'^\s*(default\s+)?clocking\s+',
                \'^\s*module\s+',
                \'^\s*\(\s*$',
                \'\s*/\*\s*$'
                \]
    let fold_close = [
                \'^\s*endclass',
                \'^\s*endfunction',
                \'^\s*endtask',
                \'^\s*endclocking',
                \'^\s*endmodule',
                \'^\s*\)\s*;\s*$',
                \'\s*\*/\s*$'
                \]
    if str =~ '\v'.join(fold_open, '|')
        return 'a1'
    elseif str =~ '\v'.join(fold_close, '|')
        return 's1'
    else
        return '='
    endif
endfunction

function! UpdateTags()
    let file = expand("%:p")
    let cmd = 'ctags -a ' . file
    let resp = system(cmd)
endfunction
