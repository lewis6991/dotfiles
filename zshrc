HAVE_BREW=0
REPO_DIR=~/git

if hash brew 2> /dev/null; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
fi

# Variables --------------------------------------------------------------------
export FANCY_PROMPT_DOUBLE_LINE=1
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

export ZSH_AUTOSUGGEST_USE_ASYNC=1
# Plugins ----------------------------------------------------------------------

### Added by Zplugin's installer
source '~/.zplugin/bin/zplugin.zsh'
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/history.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/grep.zsh

zplugin ice wait'0' atload'_zsh_autosuggest_start' lucid
zplugin light zsh-users/zsh-autosuggestions

zplugin light zsh-users/zsh-history-substring-search

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-completions

zplugin light mafredri/zsh-async

zplugin ice wait"0" atinit"zpcompinit; zpcdreplay" lucid
zplugin light zdharma/fast-syntax-highlighting

autoload bashcompinit && bashcompinit

# Menu completion
zstyle ':completion:*' menu yes select

setopt NO_BEEP

if ((HAVE_BREW)); then
    COREUTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec"
    if [ -d "$COREUTILS_PATH" ]; then
        export PATH="$COREUTILS_PATH/gnubin:$PATH"
        export MANPATH="$COREUTILS_PATH/gnuman:$MANPATH"
    fi
fi

alias ls='ls --color'
alias ll='ls -goAh'

if hash nvim 2>/dev/null; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

# Give command history to tclsh
if hash rlwrap 2>/dev/null; then
    alias tclsh="rlwrap -Ar -pcyan tclsh"
fi

if hash highlight 2>/dev/null; then
    alias ccat="highlight --out-format=ansi --force"
fi

alias re-csh="source ~/.zshrc"

export LESS="\
    --RAW-CONTROL-CHARS \
    --ignore-case \
    --LONG-PROMPT \
    --quit-if-one-screen \
    --chop-long-lines"

# Async prompt -----------------------------------------------------------------
source "$REPO_DIR/dotfiles/modules/fancy-prompt/prompt.zsh"

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

refresh_display() {
    if [ -n "$TMUX" ]; then
        # Refresh these variables
        eval "$(tmux showenv -s DISPLAY)"
        eval "$(tmux showenv -s SSH_CONNECTION)"
    fi
}

add-zsh-hook precmd refresh_display

[ -f ~/.aliases     ] && source ~/.aliases
[ -f ~/.fzf.zsh     ] && source ~/.fzf.zsh
[ -f ~/.zshrc_local ] && source ~/.zshrc_local
