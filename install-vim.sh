#!/bin/bash

[ ! "$HOME" ] && HOME=$(bash <<< "echo ~$SUDO_USER")
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -h "$HOME/.vim" ] && unlink "$HOME/.vim"
ln -s "$DIR/.vim" "$HOME/.vim"
[ -h "$HOME/.vimrc" ] && unlink "$HOME/.vimrc"
ln -s "$DIR/.vimrc" "$HOME/.vimrc"

vimp="alias vi='vi -p'\nvim='vim -p'\n"
print $vimp >> ~/.bashrc
print $vimp >> ~/.bash_profile
