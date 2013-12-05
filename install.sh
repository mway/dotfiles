#!/bin/bash

[ ! "$HOME" ] && HOME=$(bash <<< "echo ~$SUDO_USER")
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in .*; do
    if [[ ! $f =~ ^\.(git|\.)?$ ]]; then
        [ -h "$HOME/$f" ] && unlink "$HOME/$f"
        ln -s "$DIR/$f" "$HOME/$f"
    fi
done

src='source ~/.envrc'
echo $src >> ~/.bashrc
echo $src >> ~/.bash_profile

source ~/.envrc
