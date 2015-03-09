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

# Clean ~/.vim
rm -rf ~/.vim

# Set up systemverilog suport for vim
git clone https://github.com/nachumk/systemverilog.vim.git sv_vim_temp
rsync -r sv_vim_temp/ftdetect ~/.vim/
rsync -r sv_vim_temp/syntax   ~/.vim/
rsync -r sv_vim_temp/indent   ~/.vim/
rm -rf sv_vim_temp

# Set up tabular
git clone https://github.com/godlygeek/tabular.git tabular_temp
rsync -r tabular_temp/autoload     ~/.vim/
rsync -r tabular_temp/doc          ~/.vim/
rsync -r tabular_temp/plugin       ~/.vim/
rsync -rv tabular_temp/after/plugin ~/.vim/
rm -rf tabular_temp

# Set up mips syntax
git clone https://github.com/vim-scripts/mips.vim.git mips_temp
rsync -r mips_temp/syntax ~/.vim
rm -rf mips_temp

# Set up bash syntax
wget http://www.panix.com/~elflord/vim/syntax/bash.vim
wget http://ftp.vim.org/vim/runtime/syntax/awk.vim
mv bash.vim ~/.vim/syntax/
mv awk.vim ~/.vim/syntax/

# Set up vimrc
git clone https://github.com/lewis6991/vimrc.git vimrc_temp
cp -r vimrc_temp/.vimrc ~/
cp -r vimrc_temp/ftdetect/ ~/.vim/
rm -rf vimrc_temp

# Set up git config
if hash git 2>/dev/null; then
    source gitconfig
fi
