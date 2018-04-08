# Variables --------------------------------------------------------------------
export FANCY_PROMPT_DOUBLE_LINE=1
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

# Plugins (antigen) ------------------------------------------------------------
source "$(brew --prefix)/share/antigen/antigen.zsh"

antigen use oh-my-zsh

antigen bundle pip
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle mafredri/zsh-async
antigen bundle zsh-users/zsh-history-substring-search

antigen apply

# Async prompt -----------------------------------------------------------------
source ~/git/dotfiles/modules/fancy-prompt/prompt.zsh

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# vim : set nofoldenable
