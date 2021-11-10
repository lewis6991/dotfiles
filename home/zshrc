# Prompt for spelling correction of commands.
setopt CORRECT

# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it does not exist or it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey -e

DOTFILES="$HOME/$(dirname $(readlink $(print -P %N)))"

export EDTIOR=nvim

function have_cmd {
    if ! hash $1 2>/dev/null; then
        # echo "zshrc: Command '$1' is not installed"
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
zmodload zsh/complist

# Enable shift-tab to cycle back completions
bindkey -M menuselect '^[[Z' reverse-menu-complete
setopt menu_complete

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

# zinit lucid light-mode for \
#     mafredri/zsh-async \
#     wait hlissner/zsh-autopair \
#     wait zsh-users/zsh-history-substring-search \
#     wait blockf atpull'zinit creinstall -q .' \
#         zsh-users/zsh-completions \
#     wait atload'_zsh_autosuggest_start' \
#         zsh-users/zsh-autosuggestions \
#     atload"FAST_HIGHLIGHT[chroma-ssh]=''" \
#     atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
#         zdharma/fast-syntax-highlighting \

# atload"FAST_HIGHLIGHT[chroma-ssh]=''" Disables ssh highlighting which has bad
# performance issues: https://github.com/zdharma/fast-syntax-highlighting/issues/139

# Other ----------------------------------------------------------------------

fpath=($HOME/zsh_completions $fpath)
autoload -U +X bashcompinit && bashcompinit

setopt NO_BEEP

# Stop ctrl-d from closing the shell
setopt IGNORE_EOF

# Aliases ----------------------------------------------------------------------

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
        alias lua="rlwrap -Ar -pcyan --always-readline lua"
    fi
fi

# MacOS Built in less is too old.
if [[ "$(which less)" != "/usr/bin/less" ]]; then
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
else
    echo "'less' is too old"
fi

extract() {
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

if [[ -n "$TMUX" ]]; then
    if [[ -n "$TERM_BACK" ]]; then
        export TERM=$TERM_BACK
    fi
else
    export TERM_BACK=$TERM
fi

if {true} {
    if [[ -n "$TMUX" ]]; then
        local is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        local files=(
            "~/.profile"
            "~/.zprofile"
            "~/.zshrc"
            "~/.zshrc_local"
            "~/.aliases"
            "~/.aliases_local"
            "~/.tmux.conf"
            "\$XDG_CONFIG_HOME/nvim/init.vim"
            "\$XDG_CONFIG_HOME/nvim/lua/lewis6991/plugins.lua"
        )
        local menu_spec=""
        local key=0
        for i in $files; {
            # menu_spec+=" '$i' $key \"if-shell $(printf '%q' $is_vim) \
            #     \\\"send-keys ':e   $i' Enter\\\" \
            #     \\\"send-keys 'nvim $i' Enter\\\" \""
            menu_spec+=" '$i' $key $(printf '%q' "if-shell $(printf '%q' $is_vim) \
                $(printf '%q' "send-keys ':e   $i' Enter") \
                $(printf '%q' "send-keys 'nvim $i' Enter")")"
            key=$((key+1))
        }
        eval "tmux bind-key -n M-c display-menu -x W -y S -T '#[fg=colour4]Configuration Files' $menu_spec"
    fi
}

ring_bell() {
    echo -n -e '\a'
}

add-zsh-hook precmd ring_bell

! [ -f ~/.aliases       ] || source ~/.aliases
! [ -f ~/.aliases_local ] || source ~/.aliases_local
! [ -f ~/.zshrc_local   ] || source ~/.zshrc_local
