#!/usr/bin/env bash

_install_dotfiles() {
  local DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local files=$(\ls -a "${DIR}" | grep '^\.' | grep -vE '^(\.|\.\.|\.git|\.gitmodules)$')

  bash -c "cd ${DIR} && git submodule update --init --recursive"

  if [ "$1" == "force" ]; then
    for f in $files; do
      if [ -d "${HOME}/${f}" ]; then
        rm -r "${HOME}/${f}"
      elif [ -e "${HOME}/${f}" ]; then
        unlink "${HOME}/${f}"
      fi
    done
  fi

  for f in $files; do
    if [ ! -e "${HOME}/${f}" ]; then
      ln -s "${DIR}/${f}" "${HOME}/${f}"
      echo "Created ${HOME}/${f}."
    elif [ -s "${HOME}/${f}" ]; then
      echo "${HOME}/${f} is already a symlink."
    else
      echo "${HOME}/${f} exists, but is not a symlink."
    fi
  done
}

_install_dotfiles $@
