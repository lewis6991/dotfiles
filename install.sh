#!/bin/bash

function check_cmd {
    echo -n Checking $1 is installed...
    if which $1 >/dev/null; then
        echo OK
        return 0
    else
        echo No
        if which brew >/dev/null; then
            echo Attempting to install $1 using brew...
            brew install $1
            return 0
        else
            echo Error: $1 is not installed.
            return 1
        fi
    fi
}

# Check that required commands are installed
if ! check_cmd git  ; then exit; fi
if ! check_cmd rsync; then exit; fi
if ! check_cmd wget ; then exit; fi
if ! check_cmd curl ; then exit; fi

source git_config

rm -rf ~/.vim
cp -r vimrc ~/.vimrc

vim +PlugInstall +qall

# Set up config files
# cp -v ctags    ~/.ctags
cp -v  agignore  ~/.agignore
cp -v  bashrc    ~/.bashrc
cp -v  tmux.conf ~/.tmux.conf
cp -vr headers   ~/

# # Set up powerline fonts
pushd ~
rm -rf fonts
rm -rf .fonts
rm -rf .fontconfig
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
cd
rm -rf fonts
popd

