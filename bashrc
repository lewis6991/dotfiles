#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┃ Lewis's .bashrc                                                             ┃
#┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Skip remaining setup if not an interactive shell
[[ $- != *i* ]] && return

# shellcheck  source=/dev/null
source ~/.bash_functions

HAVE_BREW=0

if hash brew 2> /dev/null; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
fi

IS_WSL=0
IS_MAC=0
IS_LINUX=0

if [ "$(uname)" == "Darwin" ]; then
    IS_MAC=1
elif [ "$(uname)" == "Linux" ]; then
    if grep Microsoft /proc/version > /dev/null; then
        IS_WSL=1
    else
        IS_LINUX=1
    fi
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ FZF                                                                         ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
source_if_exists ~/.fzf.bash

export FZF_DEFAULT_OPTS='--height 30% --reverse'

if hash rg 2>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
elif hash ag 2>/dev/null; then
    export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Completion                                                                  ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

source_if_exists "$HOME/.bash_completion"

if ((HAVE_BREW)); then
    source_if_exists "$BREW_PREFIX/etc/bash_completion"
elif [[ $PS1 ]]; then
    source_if_exists ~/.local/share/bash-completion/bash_completion
elif ! shopt -oq posix; then
    source_if_exists /etc/bash_completion
fi

if hash gerrit 2> /dev/null; then
    source <(gerrit completion)
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Prompt                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
prompt_command() {
    PS1=$(~/.prompt bash $?)

    if [ -n "$TMUX" ]; then
        # Refresh these variables
        eval "$(tmux showenv -s DISPLAY)"
        eval "$(tmux showenv -s SSH_CONNECTION)"
    fi

    # Update history after every command
    history -a
}

PROMPT_COMMAND=prompt_command

export FANCY_PROMPT_RHS_ENABLE=0
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Variables                                                                   ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# Modify path if coretuils is installed (Mac)
if ((HAVE_BREW)); then
    COREUTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec"
    if [ -d "$COREUTILS_PATH" ]; then
        export PATH="$COREUTILS_PATH/gnubin:$PATH"
        export MANPATH="$COREUTILS_PATH/gnuman:$MANPATH"
    fi
fi

# Colourise man pages
export MANPAGER="\
    nvim \
    -R \
    -c 'set ft=man nomod nolist nonu nornu' \
    -c 'map q :q<CR>' \
    -c 'map <SPACE> <C-D>' \
    -c 'map K :Man<CR>' \
    -c 'map b <C-U>' \
    -c 'map d <C-d>' \
    -c 'map u <C-u>' -"

export PAGER="less"
export LESS="\
    --no-init \
    --RAW-CONTROL-CHARS \
    --ignore-case \
    --LONG-PROMPT \
    --quit-if-one-screen \
    --chop-long-lines"

export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

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
alias ls='ls --color'
alias ll='ls -goAh'

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
alias re-csh="source ~/.bashrc"

alias python=python3
alias pip=pip3

alias lssize="ls --color=none | xargs du -sh"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Other                                                                       ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
# Disable software flow control so <Ctrl-S> doesn't hang the terminal.
stty -ixon

if [ "${BASH_VERSINFO:-0}" -ge 4 ]; then
    shopt -s autocd
fi

shopt -s histappend

export HISTCONTROL=erasedups

if ((IS_MAC)); then
    xhost + > /dev/null
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Load other setups                                                           ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
source_if_exists "$HOME/.bashrc_local"

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/tools/python/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┃ Locale                                                                      ┃
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
if ! ((IS_MAC)); then
    LC_ALL="en_US.utf8"
    LANG="en_US.utf8"
fi

#┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
#┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
