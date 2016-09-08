#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Completion
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
if hash brew 2>/dev/null; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
set completion-ignore-case on

# Show auto-completion list automatically, without double tab
set show-all-if-ambiguous on

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Prompt
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

function __prompt_command() {
    EXIT=$?
    PS1=`~/git/fancy-prompt/.prompt bash ${EXIT}`
}

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Variables
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

# Modify path if coretuils is installed (Mac)
if hash brew 2>/dev/null; then
    if brew --prefix coreutils >/dev/null ; then
        export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
        export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    fi
fi

# Colourise man pages
if hash most 2>/dev/null; then
    export PAGER="most -s"
fi

export GREP_OPTIONS='--color=auto'

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Bindings
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Aliases
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
if hash brew 2>/dev/null; then
    if brew --prefix coreutils >/dev/null ; then
        alias ls='ls --color'
        alias ll='ls -goAh --group-directories-first'
    else
        alias ll='ls -goAh'
    fi
fi

# if hash nvim 2>/dev/null; then
#     alias vim=nvim
# fi

alias re-bashrc='source ~/.bashrc'
alias edit-bashrc='v ~/.bashrc'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

~/git/base16-shell/base16-harmonic16.dark.sh

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# Utilities
#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

# Handy Extract Program
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf   $1 ;;
            *.tar.gz ) tar xvzf   $1 ;;
            *.bz2    ) bunzip2    $1 ;;
            *.gz     ) gunzip     $1 ;;
            *.tar    ) tar xvf    $1 ;;
            *.tbz2   ) tar xvjf   $1 ;;
            *.tgz    ) tar xvzf   $1 ;;
            *.zip    ) unzip      $1 ;;
            *.Z      ) uncompress $1 ;;
            *        ) echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

#–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

# vim: set foldmarker={,} foldmethod=marker foldlevel=0:
