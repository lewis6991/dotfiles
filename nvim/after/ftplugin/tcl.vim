
setlocal keywordprg=:FloatingTclMan

command! -nargs=* FloatingTclMan call ToggleCommand('execute ":r !man -D n '.<q-args>. '" | Man!')

" requires lewis6991/tcl.vim
syntax keyword tclProc fts_proc     nextgroup=tclProcName skipwhite skipempty
syntax keyword tclProc fts_proc_dec nextgroup=tclProcName skipwhite skipempty
syntax keyword tclProc fts_proc_imp nextgroup=tclProcName skipwhite skipempty
