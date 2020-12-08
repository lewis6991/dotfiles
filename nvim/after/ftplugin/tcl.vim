
setlocal keywordprg=:FloatingTclMan

command! -nargs=* FloatingTclMan call ToggleCommand('execute ":r !man -D n '.<q-args>. '" | Man!')
