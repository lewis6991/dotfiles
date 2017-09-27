#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┃ Lewis's .bashrc                                                             ┃
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Skip remaining setup if not an interactive shell
[[ $- != *i* ]] && return

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

    # Update history after every command
    history -a

    if [ -n "$TMUX" ]; then
        if [ -f "$HOME/.display" ]; then
            export DISPLAY
            DISPLAY=$(cat ~/.display)
        fi
    fi
}

PROMPT_COMMAND=prompt_command

export FANCY_PROMPT_RHS_ENABLE=0
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

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
else
    export PAGER="less -isMR"
fi

export FZF_DEFAULT_OPTS='--height 30%'

export LS_COLORS=""
# export LS_COLORS="*.sv=00;35:*.v=00;35:*.tcl=00;36:*.yml=00;94"

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
else
    alias ls='ls --color'
fi

alias ll='ls --Al'

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

alias python=python3
alias pip=pip3

alias lssize="ls --color=none | xargs du -sh"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Other                                                                       ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Disable software flow control so <Ctrl-S> doesn't hang the terminal.
stty -ixon

# Load fzf
# shellcheck source=/dev/null
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi

if [ "${BASH_VERSINFO:-0}" -ge 4 ]; then
    shopt -s autocd
fi

shopt -s histappend

export HISTCONTROL=erasedups

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Utilities                                                                   ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Handy Extract Program
function extract() {
    if [ -f "$1" ] ; then
        case $1 in
            *.tar.bz2) tar xvjf   "$1" ;;
            *.tar.gz ) tar xvzf   "$1" ;;
            *.tar.xz ) tar xvf    "$1" ;;
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

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Load other setups                                                           ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# shellcheck source=/dev/null
if [ -f "$HOME/.bashrc_local" ]; then
    source "$HOME/.bashrc_local"
fi

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/tools/python/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Locale                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
if [ "$(uname)" != "Darwin" ]; then
    LC_ALL="en_US.utf8"
    LANG="en_US.utf8"
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
