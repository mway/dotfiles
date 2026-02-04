#!/usr/bin/env bash
#
# setup.sh - Bootstrap development environment
#
# Usage: ./setup.sh
#
# Environment variables:
#   NO_FORCE=1                - Don't pass --force to chezmoi
#   SETUP_PLAIN=1             - Force plain output (no terminal control)
#   SETUP_CONTINUE_ON_ERROR=1 - Continue on step failure
#   CI=true                   - Implies SETUP_PLAIN=1
#

set -euo pipefail

# Trap for cleanup on unexpected exit
_cleanup() {
  local exit_code=$?
  # Ensure cursor is visible and terminal is in good state
  if [[ -n "${_UI_IS_TTY:-}" ]]; then
    tput cnorm 2>/dev/null || true  # Show cursor
    printf '\n'  # Ensure we end on a newline
  fi
  exit "$exit_code"
}
trap _cleanup EXIT

# Trap for Ctrl+C
_interrupted() {
  printf '\n'
  _status_warn "Interrupted by user"
  exit 130
}
trap _interrupted INT

# ─────────────────────────────────────────────────────────────────
# Path Utilities
# ─────────────────────────────────────────────────────────────────

_ensure_paths() {
  _ensure_path /opt/homebrew/bin
  _ensure_path "${HOME}/.local/bin"
  _ensure_path "${HOME}/bin"
}

_ensure_path() {
  [[ $# -eq 0 || ":${PATH}:" == *":${1}:"* ]] || PATH="${1}${PATH:+:$PATH}"
  export PATH
}

# ─────────────────────────────────────────────────────────────────
# UI Primitives
# ─────────────────────────────────────────────────────────────────

# Detect if we should use fancy terminal features
_UI_IS_TTY=""
_UI_COLS=80

_ui_init() {
  if [[ -t 1 && -z "${CI:-}" && -z "${SETUP_PLAIN:-}" ]]; then
    _UI_IS_TTY=1
    _UI_COLS="$(tput cols 2>/dev/null || echo 80)"
  fi
}

_ui_is_tty() {
  [[ -n "$_UI_IS_TTY" ]]
}

# Move cursor to beginning of line (carriage return)
_ui_cr() {
  _ui_is_tty && printf '\r'
}

# Clear from cursor to end of line
_ui_clear_to_eol() {
  if _ui_is_tty; then
    tput el 2>/dev/null || printf '\033[K'
  fi
}

# Erase current line completely and move to start
_ui_clear_line() {
  if _ui_is_tty; then
    _ui_cr
    _ui_clear_to_eol
  fi
}

# Erase N lines above current position (for multi-line cleanup)
# Usage: _ui_erase_lines 2
_ui_erase_lines() {
  local n="${1:-1}"
  if _ui_is_tty; then
    local i
    for ((i = 0; i < n; i++)); do
      tput cuu1 2>/dev/null || printf '\033[A'  # Move up
      _ui_clear_line
    done
  fi
}

# Print text, replacing current line in TTY mode
# In non-TTY mode, prints a new line
_ui_print_transient() {
  if _ui_is_tty; then
    _ui_clear_line
    printf '%s' "$*"
  else
    printf '%s\n' "$*"
  fi
}

# Print text as final (non-transient) line
_ui_print_final() {
  if _ui_is_tty; then
    _ui_clear_line
  fi
  printf '%s\n' "$*"
}

# ─────────────────────────────────────────────────────────────────
# Status Helpers
# ─────────────────────────────────────────────────────────────────

# Icons (can be overridden for testing or accessibility)
readonly _ICON_CHECKING="${SETUP_ICON_CHECKING:-○}"
readonly _ICON_INSTALLING="${SETUP_ICON_INSTALLING:-○}"
readonly _ICON_OK="${SETUP_ICON_OK:-✅}"
readonly _ICON_SKIP="${SETUP_ICON_SKIP:-☑️}"
readonly _ICON_FAIL="${SETUP_ICON_FAIL:-❌}"
readonly _ICON_WARN="${SETUP_ICON_WARN:-⚠️}"

_status_checking() {
  _ui_print_transient "${_ICON_CHECKING} Checking $*..."
}

_status_installing() {
  _ui_print_transient "${_ICON_INSTALLING} Installing $*..."
}

_status_ok() {
  _ui_print_final "${_ICON_OK} Installed $*"
}

_status_skip() {
  _ui_print_final "${_ICON_SKIP} $* already installed"
}

_status_fail() {
  _ui_print_final "${_ICON_FAIL} Failed: $*"
}

_status_warn() {
  _ui_print_final "${_ICON_WARN} Warning: $*"
}

# ─────────────────────────────────────────────────────────────────
# Step Orchestration
# ─────────────────────────────────────────────────────────────────

# Execute a setup step with consistent status reporting
#
# Usage: with_step "Name" check_fn install_fn [verify_fn]
#
# Arguments:
#   $1 - Human-readable name for the step
#   $2 - Check function: returns 0 if already installed, 1 otherwise
#        May output version info to stdout (captured for display)
#   $3 - Install function: performs installation, returns 0 on success
#   $4 - Verify function (optional): verifies installation succeeded
#        If not provided, check_fn is reused for verification
#        May output version info to stdout (captured for display)
#
# Returns:
#   0 - Step completed successfully (either already installed or newly installed)
#   1 - Step failed (installation or verification failed)
#
# Environment:
#   SETUP_CONTINUE_ON_ERROR=1 - Don't exit on failure, just return 1
#
with_step() {
  local name="$1"
  local check_fn="$2"
  local install_fn="$3"
  local verify_fn="${4:-$check_fn}"

  local version_info=""

  # Phase 1: Check if already installed
  _status_checking "$name"
  if version_info="$($check_fn 2>/dev/null)"; then
    if [[ -n "$version_info" ]]; then
      _status_skip "$name ($version_info)"
    else
      _status_skip "$name"
    fi
    return 0
  fi

  # Phase 2: Install
  _status_installing "$name"
  if ! $install_fn; then
    _status_fail "$name (install)"
    [[ -n "${SETUP_CONTINUE_ON_ERROR:-}" ]] || exit 1
    return 1
  fi

  # Phase 3: Verify installation
  if version_info="$($verify_fn 2>/dev/null)"; then
    if [[ -n "$version_info" ]]; then
      _status_ok "$name ($version_info)"
    else
      _status_ok "$name"
    fi
    return 0
  else
    _status_fail "$name (verify)"
    [[ -n "${SETUP_CONTINUE_ON_ERROR:-}" ]] || exit 1
    return 1
  fi
}

# Simplified version for steps that don't have a "check" phase
# (e.g., deps installation that always runs)
#
# Usage: with_action "Name" action_fn [verify_fn]
#
with_action() {
  local name="$1"
  local action_fn="$2"
  local verify_fn="${3:-}"

  _status_installing "$name"
  if ! $action_fn; then
    _status_fail "$name"
    [[ -n "${SETUP_CONTINUE_ON_ERROR:-}" ]] || exit 1
    return 1
  fi

  if [[ -n "$verify_fn" ]]; then
    if ! $verify_fn >/dev/null 2>&1; then
      _status_fail "$name (verify)"
      [[ -n "${SETUP_CONTINUE_ON_ERROR:-}" ]] || exit 1
      return 1
    fi
  fi

  _status_ok "$name"
  return 0
}

# ─────────────────────────────────────────────────────────────────
# Legacy Notification Helpers (will be removed)
# ─────────────────────────────────────────────────────────────────

_notify_installing() {
  echo "○ Installing $*..."
}

_notify_exists() {
  echo "☑️ $* already installed"
}

_notify_not_installed() {
  echo "❌ Not available after running installer: $*"
}

_notify_installed() {
  echo "✅ Installed $*"
}

# ─────────────────────────────────────────────────────────────────
# Step Implementations
# ─────────────────────────────────────────────────────────────────

# Homebrew
check_homebrew() {
  local brew
  brew="$(command -v brew 2>/dev/null)" || return 1
  [[ -x "$brew" ]] || return 1
  "$brew" --version | head -1
}

install_homebrew() {
  local url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  /bin/bash -c "$(curl -fsSL "$url")"

  # Set up environment for subsequent steps
  local brew=/opt/homebrew/bin/brew
  [[ -x "$brew" ]] && eval "$("$brew" shellenv)"
  return 0  # Let verify handle success check
}

verify_homebrew() {
  local brew=/opt/homebrew/bin/brew
  [[ -x "$brew" ]] || return 1
  eval "$("$brew" shellenv)"
  "$brew" --version | head -1
}

# 1Password
check_1password() {
  local app_path="/Applications/1Password.app/Contents/MacOS/1Password"

  # Both app and CLI must be present
  [[ -x "$app_path" ]] || return 1
  command -v op >/dev/null 2>&1 || return 1

  local v_app v_cli
  v_app="$("$app_path" --version 2>/dev/null)" || return 1
  v_cli="$(op --version 2>/dev/null)" || return 1

  echo "app ${v_app}, cli ${v_cli}"
}

install_1password() {
  brew install 1password 1password-cli
}

# verify reuses check_1password

# Mise
check_mise() {
  local mise="${HOME}/bin/mise"
  [[ -x "$mise" ]] || return 1
  "$mise" --version 2>/dev/null | head -1
}

install_mise() {
  MISE_INSTALL_PATH="${HOME}/bin/mise" curl -fsSL https://mise.run | sh
}

verify_mise() {
  local mise="${HOME}/bin/mise"
  [[ -x "$mise" ]] || return 1
  "$mise" --version 2>/dev/null | head -1
}

# ─────────────────────────────────────────────────────────────────
# Legacy Step Functions (will be removed)
# ─────────────────────────────────────────────────────────────────

_ensure_homebrew() {
  local NAME="Homebrew"
  local BREW=""
  BREW="$(command -v brew 2>/dev/null || true)"
  if [[ -n "$BREW" ]]; then
    _notify_exists "$("$BREW" --version)"
    return 0
  fi

  _notify_installing "$NAME"
  local URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  /bin/bash -c "$(curl -fsSL "$URL")"
  BREW=/opt/homebrew/bin/brew
  if [[ ! -x "$BREW" ]]; then
    _notify_not_installed "$NAME"
    return 1
  fi

  [ ! -f "$BREW" ] || eval "$("$BREW" shellenv)"
  _notify_installed "$("$BREW" --version)"
}

_ensure_1password() {
  local NAME="1Password"

  local app_path="/Applications/1Password.app/Contents/MacOS/1Password"
  local n=0
  n=$(brew list -1 1password 1password-cli | grep -iE '/(op|1password\.app)$' | wc -l)
  if [[ $n -eq 2 ]]; then
    local version_1p="1Password $("$app_path" --version)"
    local version_op="1password-cli (op) $(op --version)"
    _notify_exists "${version_1p} and ${version_op}"
    return 0
  fi

  _notify_installing "$NAME"
  brew install 1password 1password-cli
  n=$(brew list -1 1password 1password-cli | grep -iE '/(op|1password\.app)$' | wc -l)
  if [[ $n -lt 2 ]]; then
    local name_1p="1Password"
    local name_op="1password-cli (op)"
    _notify_not_installed "${name_1p} and/or ${name_op}"
    return 1
  fi

  local version_1p="1Password $("$app_path" --version)"
  local version_op="1password-cli (op) $(op --version)"
  _notify_installed "${version_1p} and ${version_op}"
}

_ensure_mise() {
  local NAME="Mise"

  local MISE="${HOME}/bin/mise"
  if [[ -x "$MISE" ]]; then
    local version="$("$MISE" --version 2>/dev/null | grep -E '\d{4}-\d{2}-\d{2}')"
    _notify_exists "${NAME} ${version}"
    return 0
  fi

  _notify_installing "$NAME"
  export MISE_INSTALL_PATH="$MISE"
  curl https://mise.run | sh
  if [[ ! -x "$MISE" ]]; then
    _notify_not_installed "$NAME"
    return 1
  fi

  local version="$(mise --version 2>/dev/null | grep -E '\d{4}-\d{2}-\d{2}')"
  _notify_installed "${NAME} ${version}"
}

_ensure_deps() {
  local NAME="Dependencies"
  _notify_installing "$NAME"

  if ! mise trust 2>/dev/null; then
    _notify_not_installed "${MISE} (trust)"
    return 1
  fi

  if ! mise install --yes --quiet; then
    _notify_not_installed "$NAME"
    return 1
  fi

  _notify_installed "$NAME"
}

_ensure_chezmoi() {
  local NAME="Chezmoi"
  _notify_installing "$NAME"

  local FORCE="--force"
  if [[ -n "${NO_FORCE:-}" ]]; then
    FORCE=""
  else
    echo '⚠️ WARNING: --force will be supplied to `chezmoi` invocation; use NO_FORCE=... to disable'
  fi

  if ! chezmoi apply $FORCE --init; then
    _notify_not_installed "$NAME"
    return 1
  fi

  _notify_installed "$NAME"
}

_main() {
  _ensure_paths
  _ensure_homebrew
  _ensure_1password
  _ensure_mise
  _ensure_deps
  _ensure_chezmoi
}

_main "$@"
