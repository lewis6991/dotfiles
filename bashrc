#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┃ Lewis's .bashrc                                                             ┃
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Skip remaining setup if not an interactive shell
[[ $- != *i* ]] && return

source_if_exists() {
    # shellcheck source=/dev/null
    [[ -f "$1" ]] && source "$1"
}

HAVE_BREW=0
IS_WSL=0
if hash brew 2> /dev/null; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
elif grep Microsoft /proc/version > /dev/null; then
    IS_WSL=1
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Completion                                                                  ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

source_if_exists "$HOME/.bash_completion"

if ((HAVE_BREW)); then
    source_if_exists "$(brew --prefix)/etc/bash_completion"
elif [[ $PS1 ]]; then
    source_if_exists ~/.local/share/bash-completion/bash_completion
elif ! shopt -oq posix; then
    source_if_exists /etc/bash_completion
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Prompt                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
prompt_command() {
    if [ -n "$TMUX" ]; then
        # Refresh these variables
        eval "$(tmux showenv -s DISPLAY)"
        eval "$(tmux showenv -s SSH_CONNECTION)"
    fi

    # Update history after every command
    history -a

    PS1=$(~/.prompt bash $?)
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

export FZF_DEFAULT_OPTS='--height 30% --reverse --preview "head -80 {}"'
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'


export LS_COLORS=""

if ((IS_WSL)); then
    # WSL sets all permissions outside of the unix filesystem to 777. This ruins
    # all ls colors since they are all files executable. Tweak this to make the
    # colors less offensive.
    export LS_COLORS="$LS_COLORS:tw=30:ow=34:ex=00:"
fi

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

alias ll='ls -Al'
if hash nvim 2>/dev/null; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

alias fim='vim $(fzf-tmux)'

# Give command history to tclsh
if hash rlwrap 2>/dev/null; then
    alias tclsh="rlwrap -A tclsh"
fi

alias install-nvim='make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME"'

alias tree="tree -A"

alias ta="tmux attach"
alias bashrc="vim ~/.bashrc"
alias re-csh="source ~/.bashrc"

alias python=python3
alias pip=pip3

alias lssize="ls --color=none | xargs du -sh"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Other                                                                       ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Disable software flow control so <Ctrl-S> doesn't hang the terminal.
stty -ixon

# Load fzf
source_if_exists ~/.fzf.bash

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

source_if_exists "$HOME/.bashrc_local"

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
