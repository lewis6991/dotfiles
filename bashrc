#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Variables                                                                    #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
GIT_PROMPT_ONLY_IN_REPO=1

export CLICOLOR=1

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Bindings                                                                     #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
# Aliases                                                                      #
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#
alias ll='ls -oAh'
alias vim='nvim'
alias re-bashrc='source ~/.bashrc'
alias edit-bashrc='vim ~/.bashrc'
#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––#

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi
