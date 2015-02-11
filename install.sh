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

# Set up systemverilog suport for vim
git clone https://github.com/nachumk/systemverilog.vim.git sv_vim_temp
rsync -rv sv_vim_temp/ftdetect ~/.vim/
rsync -rv sv_vim_temp/syntax   ~/.vim/
rsync -rv sv_vim_temp/indent   ~/.vim/
rm -rf sv_vim_temp

# Set up vimrc
git clone https://github.com/lewis6991/vimrc.git vimrc_temp
cp -rv vimrc_temp/.vimrc ~/
rm -rf vimrc_temp

