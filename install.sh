#!/bin/bash

check_cmd() {
   echo -n Checking $1 is installed...
   if which $1 >/dev/null; then
      echo OK
      return 0
   else
      echo No
      echo Error: $1 is not installed.
      return 1
   fi
}

# Check that required commands are installed
if ! check_cmd git; then
   exit
fi
if ! check_cmd rsync; then
   exit
fi

# Set up git config
source gitconfig

# Set up ag
mv agignore ~/.agignore

# Clean ~/.vim
rm -rf ~/.vim

#Set up vundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Set up bash syntax
wget http://www.panix.com/~elflord/vim/syntax/bash.vim
wget http://ftp.vim.org/vim/runtime/syntax/awk.vim
mv bash.vim ~/.vim/syntax/
mv awk.vim ~/.vim/syntax/

# Set up vimrc
git clone https://github.com/lewis6991/vimrc.git vimrc_temp
cp -r vimrc_temp/vimrc ~/.vimrc
cp -r vimrc_temp/ftdetect/ ~/.vim/
rm -rf vimrc_temp

