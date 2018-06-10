#!/bin/bash
set -euo pipefail

readonly   RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly  CYAN='\033[0;36m'
readonly  GREY='\033[1;30m'
readonly   MAG='\033[0;34m'
readonly    NC='\033[0m' # No Color

function echo_error {
    echo -e "${RED}Error:" $@ "$NC"
}

function check_cmd {
    echo -en Checking if $CYAN$1$NC is installed...
    if which $1 >/dev/null; then
        echo -e ${GREEN}OK${NC}
        return 0
    else
        echo No
        if which brew >/dev/null; then
            echo Attempting to install $1 using brew...
            brew install $1
            return 0
        else
            echo_error $1 is not installed.
            return 1
        fi
    fi
}

function link_file {
    rm -rf $2
    ln -srv $1 $2
    # If last command failed then coreutils probably doesn't support -r switch (<8.16)
    if [ $? -ne 0 ]; then
        echo "link failed... attempting alternate command that doesn't use -r"
        local current_dir=`pwd`
        pushd `dirname $2`
        ln -sv $current_dir/$1 `basename $2`
        popd
    fi
}

function check_dependencies {
    for tool in $@; do
        if ! check_cmd $tool; then
            exit
        fi
    done
}

function install_dotfile {
    link_file "$1" "$HOME/.$1"
}

function install_vim {
    rm -rf ~/.vim
    mkdir -p ~/.vim/tmp/backup

    install_dotfile vimrc
    install_dotfile gvimrc

    # nvim
    mkdir -p ~/.config/
    mkdir -p ~/.config/autoload
    link_file ~/.vim ~/.config/nvim
    link_file ~/.vimrc ~/.vim/init.vim

    nvim +PlugInstall +quitall
}

check_dependencies \
    git   \
    rsync \
    wget  \
    curl  \
    nvim  \
    tmux  \
    tree

install_vim

install_dotfile tmux.conf
install_dotfile gitconfig
install_dotfile bashrc
install_dotfile zshrc
install_dotfile bash_functions
install_dotfile bash_completion
install_dotfile inputrc

./modules/fancy-prompt/install.sh

echo -e "${GREEN}Finished successfully${NC}"
