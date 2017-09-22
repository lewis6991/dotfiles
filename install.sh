#!/bin/bash

readonly   RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly  CYAN='\033[0;36m'
readonly  GREY='\033[1;30m'
readonly   MAG='\033[0;34m'
readonly    NC='\033[0m' # No Color

function echo_error {
    echo -e "${RED}Error:" $@ "$NC"
}

function echo_ok {
    echo -e ${GREEN}OK${NC}
}

function check_cmd {
    echo -en Checking if $CYAN$1$NC is installed...
    if which $1 >/dev/null; then
        echo_ok
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
    # Check that required commands are installed
    if ! check_cmd git  ; then exit; fi
    if ! check_cmd rsync; then exit; fi
    if ! check_cmd wget ; then exit; fi
    if ! check_cmd curl ; then exit; fi
}

function install_vim {
    rm -rf ~/.vim
    mkdir -p ~/.vim/tmp/backup
    link_file vimrc ~/.vimrc

    # nvim
    mkdir -p ~/.config/
    link_file ~/.vim ~/.config/nvim
    link_file ~/.vimrc ~/.vim/init.vim

    nvim +qall
}

function install_dotfiles {
    link_file tmux.conf ~/.tmux.conf
    link_file tmux      ~/.tmux
    link_file gitconfig ~/.gitconfig
    link_file bashrc    ~/.bashrc
}

check_dependencies
install_vim
install_dotfiles
./modules/fancy-prompt/install.sh
