#!/usr/bin/env bash

_install_dotfiles() {
  local readlink="readlink -f"
  if [ ! $($readlink . 2>/dev/null) ]; then
    readlink="readlink"
  fi

  # Work around BSD readlink
  local FILE="$($readlink ${BASH_SOURCE[0]})"
  [ -n "${FILE}" ] || FILE="${BASH_SOURCE[0]}"

  local DIR="$(cd "$(dirname "${FILE}")" && pwd)"

  bash -c "cd ${DIR} && git submodule update --init --recursive"
  mkdir -p ~/.config

  local files=$(\ls -a "${DIR}" | grep -E '(^\.|Brewfile)' | grep -vE '^(\.|\.\.|\.git|\.gitmodules)$')
  local configs=$(\ls -a "${DIR}/config")

  if [ "$1" == "force" ]; then
    for f in $files; do
      if [ -d "${HOME}/${f}" ]; then
        rm -r "${HOME}/${f}"
      elif [ -e "${HOME}/${f}" ]; then
        unlink "${HOME}/${f}"
      fi
    done

    for c in $configs; do
      if [ -d "${HOME}/.config/${c}" ]; then
        rm -r "${HOME}/.config/${c}"
      elif [ -e "${HOME}/.config/${c}" ]; then
        unlink "${HOME}/${c}"
      fi
    done
  fi

  for f in $files; do
    if [ ! -e "${HOME}/${f}" ]; then
      ln -s "${DIR}/${f}" "${HOME}/${f}"
      echo "Created ${HOME}/${f}."
    elif [ -L "${HOME}/${f}" ]; then
      echo "${HOME}/${f} is already a symlink."
    else
      echo "${HOME}/${f} exists, but is not a symlink."
    fi
  done

  for c in $configs; do
    if [ ! -e "${HOME}/.config/${c}" ]; then
      ln -s "${DIR}/config/${c}" "${HOME}/.config/${c}"
      echo "Created ${HOME}/.config/${c}."
    elif [ -L "${HOME}/.config/${c}" ]; then
      echo "${HOME}/.config/${c} is already a symlink."
    else
      echo "${HOME}/.config/${c} exists, but is not a symlink."
    fi
  done
}

_install_dotfiles $@
