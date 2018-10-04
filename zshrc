HAVE_BREW=0
REPO_DIR=~/projects

have_cmd() {
    if ! hash $1 2>/dev/null; then
        echo "zshrc: Command '$1' is not installed"
        return 1
    fi
}

if have_cmd brew; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
fi

# Variables --------------------------------------------------------------------
export FANCY_PROMPT_DOUBLE_LINE=1
export FANCY_PROMPT_USE_NERD_SYMBOLS=1

export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Plugins ----------------------------------------------------------------------

### Added by Zplugin's installer
source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

zplugin ice wait"0" lucid
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/history.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/termsupport.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/completion.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/grep.zsh

zplugin ice wait"0" lucid
zplugin snippet OMZ::lib/theme-and-appearance.zsh

# zplugin ice wait"0" lucid
# zplugin snippet OMZ::lib/key-bindings.zsh

zplugin ice wait'0' atload'_zsh_autosuggest_start' lucid
zplugin light zsh-users/zsh-autosuggestions

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-history-substring-search

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-completions

zplugin light mafredri/zsh-async

zplugin ice wait"0" blockf lucid
zplugin light zdharma/fast-syntax-highlighting

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Menu completion
# auto-select first completion option
zstyle ':completion:*' menu yes select

setopt NO_BEEP

if ((HAVE_BREW)); then
    COREUTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec"
    if [ -d "$COREUTILS_PATH" ]; then
        export PATH="$COREUTILS_PATH/gnubin:$PATH"
        export MANPATH="$COREUTILS_PATH/gnuman:$MANPATH"
    fi
fi

# Aliases ----------------------------------------------------------------------

alias ls='ls --color'
alias ll='ls -goAh'

if have_cmd nvim; then
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

# Give command history to tclsh
if have_cmd rlwrap; then
    alias tclsh="rlwrap -Ar -pcyan tclsh"
fi

if have_cmd rg; then
    _rg () {
        \rg --heading --color always "$@" | less -RFX
    }

    alias rg="_rg --colors 'match:bg:yellow' --colors 'match:fg:19' --colors 'line:fg:20' --colors 'path:fg:cyan'"
fi

if have_cmd highlight; then
    alias ccat="highlight --out-format=ansi --force"
fi

# if have_cmd rg; then
#     export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --glob "!.git/*" 2> /dev/null'
# fi

alias re-csh="exec zsh -l"
alias tree="tree -AC"

alias gcd='cd $(git rev-parse --show-toplevel)'

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

# add-zsh-hook precmd refresh_display

notify_tmux() {
    echo -n -e "\a"
}

# add-zsh-hook precmd notify_tmux

# export FZF_DEFAULT_COMMAND='
#   (git ls-tree -r --name-only HEAD ||
#    find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
#       sed s/^..//) 2> /dev/null'

# export FZF_DEFAULT_COMMAND='
#    find . -path "*/\.*" -prune -o -type f -print -o -type l -print |
#       sed s/^..// 2> /dev/null'

[ -f ~/.aliases     ] && source ~/.aliases
[ -f ~/.fzf.zsh     ] && source ~/.fzf.zsh
[ -f ~/.zshrc_local ] && source ~/.zshrc_local
