#!/usr/bin/env bash

set -eo pipefail

_manage() {
  local _manage_name="$1"
  local _manage_func="$2"

  echo -n "[chezmoi] Managing $_manage_name... "
  $_manage_func >/dev/null
  echo "done."
}

_brew() {
  local _brew_pkg="$1"
  local _brew_tap="$2"
  local _brew_args="$3"

  _fn() {
    [ -z "$_brew_tap" ] || brew tap -q "$_brew_tap" 2>/dev/null
    brew install -q $_brew_args "$_brew_pkg" >/dev/null
  }

  _manage "$_brew_pkg" _fn
}

_cargo() {
  local _cargo_pkg="$1"
  local _cargo_args="$2"

  _fn() {
    source "$HOME/.cargo/env"
    cargo install -q $_cargo_args "$_cargo_pkg"
  }

  _manage "$_cargo_pkg" _fn
}

_apt_key() {
  _pgp_key "$1" "$2" keyserver.ubuntu.com
}

_pgp_key() {
  local _pgp_key_name="$1"
  local _pgp_key_key="$2"
  local _pgp_key_server="$3"

  _fn() {
    sudo apt-key adv --keyserver "$_pgp_key_server" --recv-keys "$_pgp_key_key" >/dev/null
  }

  _manage "apt-key: $_pgp_key_name" _fn
}

_gpg_key() {
  local _gpg_key_name="$1"
  local _gpg_key_url="$2"
  local _gpg_key_args="$3"
  local _gpg_key_dst="$HOME/.local/gpg.d"

  _fn() {
    mkdir -m 0755 -p "$_gpg_key_dst"
    curl -fsSL "$_gpg_key_url" | gpg --yes $_gpg_key_args -o "$_gpg_key_dst/$_gpg_key_name.gpg"
    chmod a+r "$_gpg_key_dst/$_gpg_key_name.gpg"
  }

  _manage "gpg: $_gpg_key_name" _fn
}

_gpg_key_get() {
  local _gpg_key_get_name="$1"
  local _gpg_key_get_url="$2"
  local _gpg_key_get_args="$3"
  local _gpg_key_get_dst="$HOME/.local/gpg.d"

  _fn() {
    mkdir -m 0755 -p "$_gpg_key_get_dst"
    curl -fsSL "$_gpg_key_get_url" | dd of="$_gpg_key_get_dst/$_gpg_key_get_name.gpg"
    chmod a+r "$_gpg_key_get_dst/$_gpg_key_get_name.gpg"
  }

  _manage "gpg: $_gpg_key_get_name" _fn
}

_apt() {
  local _apt_pkg="$1"

  _fn() {
    sudo apt install -yqqq "$_apt_pkg" 2>&1 | grep -v '(WARNING:|^\n$)'
  }

  _manage "$_apt_pkg" _fn
}

_apt_repo() {
  local _apt_repo_name="$1"
  local _apt_repo_url="$2"
  local _apt_repo_qualifier="${3:-"stable"}"
  local _apt_repo_keyname="${4:-"$_apt_repo_name"}"
  local _apt_repo_key="$HOME/.local/gpg.d/$_apt_repo_keyname.gpg"
  
  _fn() {
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$_apt_repo_key] $_apt_repo_url $_apt_repo_qualifier" | \
      sudo tee "/etc/apt/sources.list.d/$_apt_repo_name.list" >/dev/null
    _apt_update
  }

  _manage "apt repo: $_apt_repo_name" _fn
}

_apt_update() {
  echo -n "[chezmoi] Updating apt... "
  sudo apt update -qqq
  echo "done."
}

_wrapper() {
  local _wrapper_src="$1"
  local _wrapper_dst="$2"

  mkdir -p "$(dirname "$_wrapper_dst")"
  echo "#!/usr/bin/env bash" > "$_wrapper_dst"
  echo "exec \"$_wrapper_src\" \"\$@\"" >> "$_wrapper_dst"
  chmod +x "$_wrapper_dst"
}
