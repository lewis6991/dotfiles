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

function link_file {
    rm -rf $2
    ln -srv $1 $2
    # If last command failed then coreutils probably doesnt support -r switch (<8.16)
    if [ $? -ne 0 ]; then
        echo "link failed... attempting alternate command that doesn't use -r"
        local current_dir=`pwd`
        pushd `dirname $2`
        ln -sv $current_dir/$1 `basename $2`
        popd
    fi
}

# Check that required commands are installed
if ! check_cmd git  ; then exit; fi
if ! check_cmd rsync; then exit; fi
if ! check_cmd wget ; then exit; fi
if ! check_cmd curl ; then exit; fi

# source git_config

# rm -rf ~/.vim

# link_file vimrc ~/.vimrc
# link_file vimrc ~/.nvimrc

# vim +PlugInstall +qall

# link_file ~/.vim ~/.nvim

# ## Set up config files
# link_file agignore  ~/.agignore
# link_file bashrc    ~/.bashrc
# link_file bashrc    ~/.bash_profile
# link_file tmux.conf ~/.tmux.conf
# link_file headers   ~/headers

# mkdir -p ~/.config/fish
# link_file config.fish ~/.config/fish/config.fish

# Set up powerline fonts
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

