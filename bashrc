#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Prompt                                                                       #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#

export PROMPT_COMMAND=__prompt_command  # Func to gen PS1 after CMDs

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

function __prompt_command() {
    local EXIT=$?             # This needs to be first

    local Col='\[\e[0m\]'

    local Red='\[\e[0;31m\]'
    local Gre='\[\e[0;32m\]'
    local Yel='\[\e[1;33m\]'
    local Blu='\[\e[1;34m\]'
    local Pur='\[\e[0;35m\]'

    if [ $EXIT -ne 0 ]; then
        PS1="${Red}\u:${Col}"      # Add red if exit code non 0
    else
        PS1="${Gre}\u:${Col}"
    fi

    PS1+="${Col}${Pur}\W${Yel}> ${Col}"
}

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Variables                                                                    #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#

# Mmodify path if coretuils is installed (Mac)
if [ -d "/usr/local/opt/coreutils/libexec" ]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

# Colourise man pages
if which most >/dev/null; then
    export PAGER="most -s"
fi

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Bindings                                                                     #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Aliases                                                                      #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
if [ "$(uname)" == "Darwin" ]; then
    alias ls='ls --color'
    alias ll='ls -oAh --group-directories-first'
else
    alias ll='ls -oAh'
fi

if which nvim >/dev/null; then
    alias v='nvim'
else
    alias v='nvim'
fi

alias vim='echo "Use 'v' instead"'
alias re-bashrc='source ~/.bashrc'
alias edit-bashrc='v ~/.bashrc'
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'


#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Utilities                                                                    #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#

# Handy Extract Program
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# vim: set foldmarker={,} foldmethod=marker foldlevel=0:
