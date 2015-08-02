GIT_PROMPT_ONLY_IN_REPO=1

#Hierarchy Viewer Variable
export ANDROID_HVPROTO=ddm

alias ls="ls -G"

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

bind '"\eOA": history-search-backward'
bind '"\eOB": history-search-forward'
