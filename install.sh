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
    mkdir ~/.vim
    mkdir ~/.vim/tmp
    mkdir ~/.vim/tmp/backup
    link_file vimrc ~/.vimrc
    vim +PlugInstall +qall
}

function install_dotfiles {
    link_file tmux.conf ~/.tmux.conf
    link_file tmux      ~/.tmux
    link_file gitconfig ~/.gitconfig

    if [ "$(uname)" == "Darwin" ]; then
        link_file bashrc ~/.bash_profile
    else
        link_file bashrc ~/.bashrc
    fi
}

function install_powerline_fonts {
    echo -en "Checking if ${CYAN}Powerline fonts${NC} are installed..."
    INSTALL=1
    if [ -d "$HOME/.local/share/fonts" ]; then
        POWERLINE_FONTS=$(ls $HOME/.local/share/fonts | grep Powerline | wc -l)
        if [ "$POWERLINE_FONTS" -gt "0" ]; then
            INSTALL=0
        fi
    fi

    if [ $INSTALL -eq 1 ]; then
        echo "No"
        echo "Installing Powerline fonts..."
        pushd ~
        rm -rf .local/share/fonts
        git clone https://github.com/powerline/fonts.git
        cd fonts
        ./install.sh
        cd -
        rm -rf fonts
        popd
    else
        echo_ok
    fi
}

function setup_nvim() {
    mkdir -p ~/.config
    link_file ~/.vim ~/.config/nvim
    link_file ~/.vimrc ~/.config/nvim/init.vim
}

# check_dependencies
source git_config
install_vim
install_dotfiles
./modules/fancy-prompt/install.sh
# install_powerline_fonts
