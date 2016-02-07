#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Completion                                                                   #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
if which brew 2>&1 > /dev/null; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
set completion-ignore-case on

# Show auto-completion list automatically, without double tab
set show-all-if-ambiguous on

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Prompt                                                                       #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#

export PROMPT_COMMAND=__prompt_command  # Func to gen PS1 after CMDs

if which brew 2>&1 > /dev/null; then
    if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
        GIT_PROMPT_ONLY_IN_REPO=1
        GIT_PROMPT_THEME=Default
        source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
    fi
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

# Modify path if coretuils is installed (Mac)
if which brew 2>&1 > /dev/null; then
    if brew --prefix coreutils >/dev/null ; then
        export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
        export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    fi
fi

# Colourise man pages
if which most 2>&1 > /dev/null; then
    export PAGER="most -s"
fi

export GREP_OPTIONS='--color=auto'

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Bindings                                                                     #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Aliases                                                                      #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
if which brew 2>&1 > /dev/null; then
    if brew --prefix coreutils >/dev/null ; then
        alias ls='ls --color'
        alias ll='ls -goAh --group-directories-first'
    else
        alias ll='ls -goAh'
    fi
fi

# if which nvim >/dev/null; then
#     alias vim='nvim'
# fi

alias re-bashrc='source ~/.bashrc'
alias edit-bashrc='v ~/.bashrc'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

~/git/base16-shell/base16-harmonic16.dark.sh

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
