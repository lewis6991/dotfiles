GIT_PROMPT_ONLY_IN_REPO=1

#Hierarchy Viewer Variable
export ANDROID_HVPROTO=ddm

export CLICOLOR=1

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
