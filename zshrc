DOTFILES="$HOME/$(dirname $(readlink $(print -P %N)))"

function have_cmd {
    if ! hash $1 2>/dev/null; then
        echo "zshrc: Command '$1' is not installed"
        return 1
    fi
}

if have_cmd brew; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
else
    HAVE_BREW=0
fi

if ((HAVE_BREW)); then
    COREUTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec"
    if [ -d "$COREUTILS_PATH" ]; then
        PATH="$COREUTILS_PATH/gnubin:$PATH"
        MANPATH="$COREUTILS_PATH/gnuman:$MANPATH"
    fi
fi

if [[ -d $DOTFILES/bin ]]; then
    PATH="$DOTFILES/bin:$PATH"
else
    echo "Error: Directory \"$DOTFILES/bin\" does not exist"
fi

# Variables --------------------------------------------------------------------
export FANCY_PROMPT_DOUBLE_LINE=1
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

export ZSH_AUTOSUGGEST_USE_ASYNC=1

# History ----------------------------------------------------------------------
if (( ${+XDG_DATA_HOME} )); then
    HISTFILE="$XDG_DATA_HOME/zsh_history"
fi
HISTSIZE=50000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# Completion -------------------------------------------------------------------
# enable menu completion and highlighting current option
zstyle ':completion:*' menu yes select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $XDG_CACHE_HOME

# Set up ls colors
eval "$(dircolors -b)"  # Needed to set up completion colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# export LS_COLORS="$(ls_colors_generator)"
zmodload zsh/complist

# Pager ------------------------------------------------------------------------
export PAGER="less"

export LESS="\
    --RAW-CONTROL-CHARS \
    --ignore-case \
    --LONG-PROMPT \
    --quit-if-one-screen \
    --chop-long-lines"

export MANPAGER='nvim +Man!'

# Plugins ----------------------------------------------------------------------

### Added by Zinit's installer
if ! [ -f "$HOME/.zinit/bin/zinit.zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zinit]=_zplugin
### End of Zinit's installer chunk

zinit lucid light-mode for \
    mafredri/zsh-async \
    wait hlissner/zsh-autopair \
    wait zsh-users/zsh-history-substring-search \
    wait blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    wait atload'_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
        zdharma/fast-syntax-highlighting \

if [[ -f $DOTFILES/mouse.zsh ]]; then
    . $DOTFILES/mouse.zsh
fi

# marlonrichert/zsh-autocomplete

zstyle ':autocomplete:list-choices:*' min-input 3
zstyle ':autocomplete:list-choices:*' max-lines 4
zstyle ':autocomplete:tab:*' completion select
zstyle ':autocomplete:tab:*' completion cycle


# Other ----------------------------------------------------------------------

fpath=($HOME/zsh_completions $fpath)
autoload -U +X bashcompinit && bashcompinit

setopt NO_BEEP

# Stop ctrl-d from closing the shell
setopt IGNORE_EOF

# Aliases ----------------------------------------------------------------------

alias ls='ls --color'
alias ll='ls -goAh'

if have_cmd nvim; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

# Give command history to tclsh
if have_cmd rlwrap; then
    if have_cmd tclsh; then
        alias tclsh="rlwrap -Ar -pcyan tclsh"
    fi
    if have_cmd lua; then
        alias lua="rlwrap -Ar -pcyan lua"
    fi
fi

if have_cmd rg; then
    rg() {
        if [[ -t 1 ]]; then
            command rg --pretty --smart-case "$@" | less
        else
            command rg "$@"
        fi
    }

    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" 2> /dev/null'
fi

# --RAW-CONTROL-CHARS cause --quit-if-one-screen to not work
export LESS="\
    --raw-control-chars \
    --ignore-case \
    --LONG-PROMPT \
    --quit-if-one-screen \
    --chop-long-lines"

# Async prompt -----------------------------------------------------------------
source "$DOTFILES/modules/fancy-prompt/prompt.zsh"

# Use default emacs bindings
bindkey -e
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
# Enable shift-tab to cycle back completions
bindkey -M menuselect '^[[Z' reverse-menu-complete

extract(){
   if [[ -z "$1" ]]; then
       print -P "usage: \e[1;36mextract\e[1;0m < filename >"
       print -P "       Extract the file specified based on the extension"
   elif [[ -f $1 ]]; then
       case ${(L)1} in
           *.tar.xz)   tar -Jxf   $1 ;;
           *.tar.bz2)  tar -jxvf  $1 ;;
           *.tar.gz)   tar -zxvf  $1 ;;
           *.bz2)      bunzip2    $1 ;;
           *.gz)       gunzip     $1 ;;
           *.jar)      unzip      $1 ;;
           *.rar)      unrar x    $1 ;;
           *.tar)      tar -xvf   $1 ;;
           *.tbz2)     tar -jxvf  $1 ;;
           *.tgz)      tar -zxvf  $1 ;;
           *.zip)      unzip      $1 ;;
           *.Z)        uncompress $1 ;;
           *.7z)       7za e      $1 ;;
           *)          echo "Unable to extract '$1' :: Unknown extension"
       esac
   else
       echo "File ('$1') does not exist!"
   fi
}

refresh_tmux() {
    if [[ -n "$TMUX" ]]; then
        # Update environment variables when we attach to an existing tmux
        # session from a new connection
        tmux show-environment | grep -v '^-' | sed 's/=\(.*\)/="\1"/' | while read foo; do
            eval "export $foo"
        done
    fi
}

add-zsh-hook precmd refresh_tmux

ring_bell() {
    echo -n -e '\a'
}

add-zsh-hook precmd ring_bell

! [ -f ~/.aliases       ] || source ~/.aliases
! [ -f ~/.aliases_local ] || source ~/.aliases_local
! [ -f ~/.fzf.zsh       ] || source ~/.fzf.zsh
! [ -f ~/.zshrc_local   ] || source ~/.zshrc_local
