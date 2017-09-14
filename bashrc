#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┃ Lewis's .bashrc                                                             ┃
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Skip remaining setup if not an interactive shell
[[ $- != *i* ]] && return

export PATH="$HOME/bin:$PATH"
# export PATH="$HOME/.local/bin:$PATH"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Completion                                                                  ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
if hash brew 2>/dev/null; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
else
    HAVE_BREW=0
fi

# shellcheck source=/dev/null
if ((HAVE_BREW)); then
    if [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
        . "$BREW_PREFIX/etc/bash_completion"
    fi
elif [[ $PS1 && -f ~/.local/share/bash-completion/bash_completion ]]; then
    . ~/.local/share/bash-completion/bash_completion
fi

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
set completion-ignore-case on

# Show auto-completion list automatically, without double tab
set show-all-if-ambiguous on

_pip_completion() {
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
        COMP_CWORD=$COMP_CWORD \
        PIP_AUTO_COMPLETE=1 $1 ) )
}

complete -o default -F _pip_completion pip

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Prompt                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
prompt_command() {
    PS1=$(~/.prompt bash $?)

    if [ -n "$TMUX" ]; then
        if [ -f "~/.display" ]; then
            export DISPLAY
            DISPLAY=$(cat ~/.display)
        fi
    fi
}

export PROMPT_COMMAND=prompt_command

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Variables                                                                   ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Modify path if coretuils is installed (Mac)
if ((HAVE_BREW)); then
    if [ -d "$BREW_PREFIX/opt/coreutils" ]; then
        export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
        export MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
    fi
fi

# Colourise man pages
if hash most 2>/dev/null; then
    export PAGER="most -s"
fi

export FZF_DEFAULT_OPTS='--height 30%'

export LS_COLORS=""
# export LS_COLORS="*.sv=00;35:*.v=00;35:*.tcl=00;36:*.yml=00;94"

export MYPYPATH=$PYTHONPATH:$HOME/.local/lib/python3.6/site-packages

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Bindings                                                                    ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind 'TAB: menu-complete'

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Aliases                                                                     ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

if ((HAVE_BREW)); then
    if brew --prefix coreutils >/dev/null ; then
        alias ls='ls --color'
        alias ll='ls -goAh --group-directories-first'
    else
        alias ll='ls -goAh'
    fi
fi

if hash nvim 2>/dev/null; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

# Give command history to tclsh
if hash rlwrap 2>/dev/null; then
    alias tclsh="rlwrap -A tclsh"
fi

alias install-nvim='make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME"'

alias tree="tree -A"

alias ta="tmux attach"
alias bashrc="vim ~/.bashrc"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Other                                                                       ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Disable software flow control so <Ctrl-S> doesn't hang the terminal.
stty -ixon

# Load fzf
# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

BASE16_SHELL=$HOME/git/base16-shell/
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && eval "$("$BASE16_SHELL/profile_helper.sh")"

[ "${BASH_VERSINFO:-0}" -ge 4 ] && shopt -s autocd

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Utilities                                                                   ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Handy Extract Program
function extract() {
    if [ -f "$1" ] ; then
        case $1 in
            *.tar.bz2) tar xvjf   "$1" ;;
            *.tar.gz ) tar xvzf   "$1" ;;
            *.bz2    ) bunzip2    "$1" ;;
            *.gz     ) gunzip     "$1" ;;
            *.tar    ) tar xvf    "$1" ;;
            *.tbz2   ) tar xvjf   "$1" ;;
            *.tgz    ) tar xvzf   "$1" ;;
            *.zip    ) unzip      "$1" ;;
            *.Z      ) uncompress "$1" ;;
            *        ) echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

bjobs_mem_internal() {
    local IFS=$'\n'
    bjobs_info=($(command bjobs))

    if [ ${#bjobs_info[@]} -ne 0 ]; then
        echo "${bjobs_info[0]} MAX_MEM AVG_MEM"

        bjobs_info=("${bjobs_info[@]:1}")

        for i in "${bjobs_info[@]}"; do
            # shellcheck disable=SC2001
            i2=$(echo "$i" | sed 's/\(.*\s\)\(\w\+\)\s\+\(\w\+\)\s\+\(\w\+.*\)/\1\2-\3-\4/g')
            bjob_id=$(echo "$i" | awk '{print $1}')
            MAX_MEM=$(command bjobs -l "$bjob_id" | grep "MAX MEM")
            if [ "$MAX_MEM" == "" ]; then
                MAX_MEM="PENDING"
            else
                MAX_MEM=$(echo "$MAX_MEM" | awk '{print $3 "\t" $7}')
            fi
            echo -e "$i2\t$MAX_MEM"
        done
    fi
}

bjobs2() {
    bjobs_mem_internal | column -t
}

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Load other setups                                                           ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# shellcheck source=/dev/null
if [ -f "$HOME/.bashrc_arm" ]; then
    source "$HOME/.bashrc_arm"
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Locale                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
LC_ALL="en_US.utf8"
LANG="en_US.utf8"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
