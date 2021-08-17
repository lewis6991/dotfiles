
" Add syntax for grouped explicit targets
" Adapted from $VIMRUNTIME/syntax/make.vim
syn region makeTarget transparent matchgroup=makeTarget
	\ start="^[~A-Za-z0-9_./$()%-][A-Za-z0-9_./\t $()%-]*&:\{1,2}[^:=]"rs=e-1
	\ end=";"re=e-1,me=e-1 end="[^\\]$"
	\ keepend contains=makeIdent,makeSpecTarget,makeNextLine,makeComment,makeDString
	\ skipnl nextGroup=makeCommands
