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

# Set up git config
source gitconfig

# Set up ctags
cp -v ctags ~/.ctags

# Set up ag
cp -v agignore ~/.agignore

# Set up bash
cp -v bashrc ~/.bashrc

# Clean ~/.vim
rm -rf ~/.vim

# Set up pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

pushd ~/.vim/bundle
# # git clone git://github.com/WeiChungWu/vim-SystemVerilog.git
git clone https://github.com/vhda/verilog_systemverilog.vim.git
git clone https://github.com/ervandew/supertab.git
git clone git://github.com/godlygeek/tabular.git
git clone git://github.com/tpope/vim-fugitive.git
git clone https://github.com/bling/vim-airline
git clone https://github.com/tpope/vim-commentary.git
popd

# # Set up bash syntax
wget http://www.panix.com/~elflord/vim/syntax/bash.vim
wget http://ftp.vim.org/vim/runtime/syntax/awk.vim
mkdir ~/.vim/syntax
mv bash.vim ~/.vim/syntax/
mv awk.vim ~/.vim/syntax/

# # Set up powerline fonts
pushd ~
git clone https://github.com/powerline/fonts.git
cd fonts
./install
cd
rm -rf fonts
popd

# Set up vimrc
cp -r vimrc ~/.vimrc

