HAVE_BREW=0
REPO_DIR=~/projects/

if hash brew 2> /dev/null; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
fi

# Variables --------------------------------------------------------------------
export FANCY_PROMPT_DOUBLE_LINE=1
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

# Plugins (antigen) ------------------------------------------------------------
source "$(brew --prefix)/share/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle pip
antigen bundle colored-man-pages
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle mafredri/zsh-async
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-completions

antigen apply

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

alias re-csh="source ~/.zshrc"

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

# vim : set nofoldenable
