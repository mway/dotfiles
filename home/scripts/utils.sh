#!/usr/bin/env bash

set -eo pipefail

export MWAY_PREFIX="/opt/mway"
export MWAY_BIN="$MWAY_PREFIX/bin"

_manage() {
  local name="$1"
  local func="$2"

  echo -n "[chezmoi] Managing $name... "
  $func >/dev/null
  echo "done."
}

_brew() {
  local pkg="$1"
  local tap="$2"
  local args="$3"

  _fn() {
    [ -z "$tap" ] || brew tap -q "$tap" 2>/dev/null
    brew install -q $args "$pkg" >/dev/null
  }

  _manage "$pkg" _fn
}

_wrapper() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"
  echo "#!/usr/bin/env bash" > "$dst"
  echo "exec \"$src\" \"\$@\"" >> "$dst"
  chmod +x "$dst"
}
