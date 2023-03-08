#!/usr/bin/env bash

set -eo pipefail

source "$(chezmoi source-path)/bin/executable_ansi"

ansi::muted() {
  ansi::faint
  ansi::white
}

ansi::reset() {
  ansi::resetForeground
  ansi::resetAttributes
}

_manage() {
  local _manage_name="$1"
  local _manage_func="$2"

  echo "[$(ansi --green --bold chezmoi)] $(ansi --bold --white "Managing $_manage_name")"
  ansi::muted
  $_manage_func >/dev/null
  ansi::reset
}

_brew() {
  local _brew_pkg="$1"
  local _brew_tap="$2"
  local _brew_args="$3"

  _fn() {
    [ -z "$_brew_tap" ] || brew tap -q "$_brew_tap" 2>/dev/null
    ansi::muted
    brew install -q $_brew_args "$_brew_pkg" >/dev/null
    ansi::reset
  }

  _manage "$_brew_pkg" _fn
}

_apt() {
  local _apt_pkg="$1"

  _fn() {
    sudo apt install -yqqq "$_apt_pkg" 2>&1 | grep -v '(WARNING:|^\n$)'
  }

  _manage "$_apt_pkg" _fn
}

_apt_update() {
  echo "[$(ansi --green --bold chezmoi)] $(ansi --bold --white "Updating apt")"
  ansi::muted
  sudo apt update -qqq
  ansi::reset
}

_wrapper() {
  local _wrapper_src="$1"
  local _wrapper_dst="$2"

  mkdir -p "$(dirname "$_wrapper_dst")"
  echo "#!/usr/bin/env bash" > "$_wrapper_dst"
  echo "exec \"$_wrapper_src\" \"\$@\"" >> "$_wrapper_dst"
  chmod +x "$_wrapper_dst"
}
