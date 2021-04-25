#!/bin/bash
set -euo pipefail

readonly   RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly  CYAN='\033[0;36m'
readonly  GREY='\033[1;30m'
readonly   MAG='\033[0;34m'
readonly    NC='\033[0m' # No Color

function message() {
    echo -e "$@" | tee -a install.log
}

function message_install () {
    message -n "Installing ${CYAN}$1${NC}..."
}

function message_done () {
    message "${GREEN}DONE${NC}"
}

function message_ok () {
    message "${GREEN}OK${NC}"
}

function message_error {
    echo -e "${RED}Error:" $@ "$NC"
    exit 1
}

function check_cmd {
    command=$1
    message -n "Checking for ${CYAN}$command${NC}..."
    if command -v $command >/dev/null; then
        message_ok
    else
        message "${RED}NO${NC}"
        if command -v brew >/dev/null; then
            message_install $command
            brew install $command >> install.log
            message_done
        else
            message_error "$command is not installed"
        fi
    fi
}

function link_file {
    rm -rf $2
    mkdir -p $(dirname $2)
    message "Linking ${CYAN}$1${NC} to ${CYAN}$2${NC}"
    if ! ln -srv $1 $2 >/dev/null; then
        # If last command failed then coreutils probably doesn't support -r switch (<8.16)
        message "link failed... attempting alternate command that doesn't use -r"
        local current_dir=$(pwd)
        pushd $(dirname $2)
        ln -sv $current_dir/$1 $(basename $2)
        popd
    fi
}

function check_dependencies {
    for tool in "$@"; do
        check_cmd $tool
    done
}

function install_dotfile {
    link_file "$1" "$HOME/.$1"
}

function install_vim_config {
    message_install vim
    rm -rf ~/.vim
    mkdir -p ~/.vim/tmp/backup

    link_file nvim/init.vim "$HOME/.vimrc"
    link_file nvim "$XDG_CONFIG_HOME/vim"
    install_dotfile gvimrc
    message_done
}

function install_nvim_config {
    message_install neovim
    rm -rf $XDG_CONFIG_HOME/nvim
    link_file nvim "$XDG_CONFIG_HOME/nvim"
    nvim --headless +PackerCompile +quitall
    message_done
}

function install_brew_package() {
    command=$1
    package=$2
    shift 2
    brew_args="$@"
    message -n "Checking if $CYAN$command ($package)$NC is installed..."
    if ! command -v $command >/dev/null; then
        message_install $package
        brew install $package $brew_args >> install.log
        message_done
    else
        message_ok
    fi
}

function install_pip_package() {
    package=$1
    message_install $package
    pip3 install $package >> install.log
    message_done
}

install_extra_brew_packages() {
    installed=$(brew list)
    to_install=()

    for p in "$@"; do
        message -n "Checking for ${CYAN}$p${NC}..."
        if grep -v "$p" <<< $installed > /dev/null; then
            to_install+=($p)
            message "${RED}NO${NC}"
        else
            message_ok
        fi
    done

    to_install_l="${to_install[@]+"${to_install[@]}"}"

    if [ -n "$to_install_l" ]; then
        message_install "{$to_install_l}"
        brew install $to_install_l >> install.log
        message_done
    fi
}

function main {
    rm -rf install.log

    install_brew_package nvim neovim --HEAD

    check_dependencies \
        git   \
        rsync \
        wget  \
        curl

    git submodule update --init

    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-$HOME/.config}"

    mkdir -p "$XDG_CONFIG_HOME"

    link_file gitconfig "$XDG_CONFIG_HOME/git/config"

    install_dotfile tmux.conf
    install_dotfile bashrc
    install_dotfile zshrc
    install_dotfile zprofile
    install_dotfile bash_functions
    install_dotfile bash_completion
    install_dotfile inputrc
    install_dotfile aliases

    message_install fancy-prompt
    ./modules/fancy-prompt/install.sh >> install.log
    message_done

    install_vim_config
    install_nvim_config

    if ! command -v brew >/dev/null; then
        message_error "Cannot install brew packages. Please install brew"
    fi

    install_extra_brew_packages \
        bash       \
        bat        \
        git-delta  \
        make       \
        python     \
        rlwrap     \
        tmux       \
        tree       \
        ripgrep    \
        zsh

    if ! command -v pip3 >/dev/null; then
        message_error "pip3 is not installed"
    fi

    # install_pip_package gitlint
    # install_pip_package mypy
    # install_pip_package pylint
    # install_pip_package pynvim
    # install_pip_package vim-vint
    # install_pip_package yamllint

    message "${GREEN}Finished successfully${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
