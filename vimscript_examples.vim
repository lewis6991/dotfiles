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
endfunction "}}}

function! UpdateTags()
    let file = expand("%:p")
    let cmd = 'ctags -a ' . file
    let resp = system(cmd)
endfunction

function! RenameFunction() "{{{
    let str = getline('.')
    let lifetime        = '((automatic|static)\s+)?'
    let virtual         = '(virtual\s+)?'
    let static          = '(static\s+)?'
    let name            = '[a-zA-Z_]\w+\s*'
    let arguments       = '\(.*\)'
    let function_syntax = '\v^\s*'.static.virtual.'function\s+'.lifetime.'.*\s+'.name.arguments.';'
    let task_syntax     = '\v^\s*'.static.virtual.'task\s+'.lifetime.name.arguments.';'
    let class_syntax    = '\v^\s*'.virtual.'(interface\s+)?class\s+'.name.'(\s+extends\s+.+)?(\s+implements\s+.+)?\s*;'
    let class_syntax2   = '\v^class\s+'.name.'(\s+extends\s+.+)?(\s+implements\s+.+)?\s*;'
    if str =~ function_syntax || str =~ task_syntax || str =~ class_syntax
        "Save starting position
        execute "normal! mz"
        let line_type = ''
        if str =~ function_syntax
            let line_type = 'function'
            "Goto name and yank it
            execute "normal! t(yiw"
        elseif str =~ task_syntax
            let line_type = 'task'
            "Goto name and yank it
            execute "normal! t(yiw"
        elseif str =~ class_syntax
            let line_type = 'class'
            "Goto name and yank it
            execute "normal! 0/\\<class\<cr>wyiw"
        elseif str =~ class_syntax2
            let line_type = 'class'
            "Goto name and yank it
            execute "normal! 0wyiw"
        endif
        "Goto closing line
        execute "normal! /end".line_type."\<cr>"
        "Navigate to name
        execute "normal! ww"
        "Store old name in register a
        execute "normal! \"ayiw"
        "Substitute throughout file
        execute "normal! :%s/\\<\<C-r>a\\>/\<C-r>0/g\<cr>"
        "Move back to starting position
        execute "normal! `z"
    endif
endfunction "}}}

com! -buffer RenameFunction call RenameFunction()

" vim: set fdm=marker :
