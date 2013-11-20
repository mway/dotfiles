#!/bin/sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in .*; do
    if [[ ! $f =~ ^\.(git|\.)?$ ]]; then
        unlink "$HOME/$f"
        ln -s "$DIR/$f" "$HOME/$f"
    fi
done

