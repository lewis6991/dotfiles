HAVE_BREW=0
REPO_DIR=~/projects

function have_cmd {
    if ! hash $1 2>/dev/null; then
        echo "zshrc: Command '$1' is not installed"
        return 1
    fi
}

if have_cmd brew; then
    HAVE_BREW=1
    BREW_PREFIX=$(brew --prefix)
fi

if ((HAVE_BREW)); then
    COREUTILS_PATH="$BREW_PREFIX/opt/coreutils/libexec"
    if [ -d "$COREUTILS_PATH" ]; then
        PATH="$COREUTILS_PATH/gnubin:$PATH"
        MANPATH="$COREUTILS_PATH/gnuman:$MANPATH"
    fi
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
# enable meanu completion and highlighting current option
zstyle ':completion:*' menu yes select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $XDG_CACHE_HOME

# Set up ls colors
eval "$(dircolors -b)"  # Needed to set up completion colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# export LS_COLORS="$(ls_colors_generator)"

# Pager ------------------------------------------------------------------------
export PAGER="less"
export LESS="\
    --RAW-CONTROL-CHARS \
    --ignore-case \
    --LONG-PROMPT \
    --quit-if-one-screen \
    --chop-long-lines"

export MANPAGER="\
nvim \
-R \
-u NORC \
-c 'set ft=man nomod' \
-c 'set laststatus=0' \
-c 'map q :q<CR>' \
-c 'map <SPACE> <C-D>' \
-c 'map K :Man<CR>' \
-c 'map b <C-U>' \
-c 'map d <C-d>' \
-c 'map u <C-u>' -"

# Plugins ----------------------------------------------------------------------

### Added by Zplugin's installer
if ! [ -f "$HOME/.zplugin/bin/zplugin.zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"
fi

source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

# Spawns a concurrent child process
zplugin ice wait'0' atload'_zsh_autosuggest_start' lucid
zplugin light zsh-users/zsh-autosuggestions

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-history-substring-search

zplugin ice wait"0" blockf lucid
zplugin light zsh-users/zsh-completions

zplugin light mafredri/zsh-async

zplugin ice wait"0" blockf lucid
zplugin light zdharma/fast-syntax-highlighting

# Other ----------------------------------------------------------------------

autoload -U +X compinit && compinit
# autoload -Uz compinit && compinit
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
    alias tclsh="rlwrap -Ar -pcyan tclsh"
fi

if have_cmd rg; then
    _rg () {
        if [[ -t 1 ]]; then
            \rg --heading --ignore-case "$@" --color=always | less -RFX
        else
            \rg "$@"
        fi
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

# Use default emacs bindings
bindkey -e
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# function update-x11-forwarding {
#     if [ -z "$STY" -a -z "$TMUX" ]; then
#         echo $DISPLAY > ~/.display.txt
#     else
#         export DISPLAY=$(cat ~/.display.txt)
#     fi
# }

# add-zsh-hook precmd update-x11-forwarding

! [ -f ~/.aliases       ] || source ~/.aliases
! [ -f ~/.aliases_local ] || source ~/.aliases_local
! [ -f ~/.fzf.zsh       ] || source ~/.fzf.zsh
! [ -f ~/.zshrc_local   ] || source ~/.zshrc_local
