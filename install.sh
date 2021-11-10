#!/bin/bash
set -euo pipefail

# brew packages:
# - bash
# - git-delta
# - make
# - python
# - rlwrap
# - tmux
# - tree
# - ripgrep
# - zsh

# pip packages:
# - gitlint
# - mypy
# - pylint
# - pynvim
# - vim-vint
# - yamllint

readonly GREEN='\033[0;32m'
readonly  CYAN='\033[0;36m'
readonly    NC='\033[0m' # No Color

function message() {
    echo -e "$@" | tee -a install.log
}

function link_file {
    rm -rf "$2"
    mkdir -p "$(dirname "$2")"
    message "Linking ${CYAN}$2${NC} to ${CYAN}$1${NC}"
    if ! ln -srv "$1" "$2" >/dev/null; then
        # If last command failed then coreutils probably doesn't support -r switch (<8.16)
        message "link failed... attempting alternate command that doesn't use -r"
        local current_dir; current_dir=$(pwd)
        pushd "$(dirname "$2")"
        ln -sv "$current_dir/$1" "$(basename "$2")"
        popd
    fi
}

function install_dotfile {
    link_file "$1" "$HOME/.$(basename "$1")"
}

function main {
    rm -rf install.log

    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME-$HOME/.config}"

    for filename in ./home/*; do
        install_dotfile "$filename"
    done

    message "${GREEN}Finished successfully${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
