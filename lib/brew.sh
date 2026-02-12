#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/util.sh
source "$SCRIPT_DIR/util.sh"

ensure_brew() {
  if command_exists brew; then
    log_ok "Homebrew already installed"
  else
    log_info "Installing Homebrew"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_ok "Homebrew installed"
  fi

  # Ensure brew is on PATH for this session.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  command_exists brew || die "brew not found on PATH after install"
}

ensure_tap() {
  local tap="$1"
  if brew tap | grep -Fxq "$tap"; then
    log_ok "tap already present: $tap"
  else
    log_info "Adding tap: $tap"
    brew tap "$tap"
    log_ok "Added tap: $tap"
  fi
}

is_cask_installed() {
  local token="$1"
  brew list --cask "$token" >/dev/null 2>&1
}

is_formula_installed() {
  local token="$1"
  brew list --formula "$token" >/dev/null 2>&1
}

install_cask() {
  local token="$1"
  if is_cask_installed "$token"; then
    log_ok "cask already installed: $token"
    return 0
  fi

  log_info "Installing cask: $token"
  if brew install --cask "$token"; then
    log_ok "Installed cask: $token"
  else
    log_warn "Failed to install cask: $token (continuing)"
    return 0
  fi
}

install_formula() {
  local token="$1"
  if is_formula_installed "$token"; then
    log_ok "formula already installed: $token"
    return 0
  fi

  log_info "Installing formula: $token"
  if brew install "$token"; then
    log_ok "Installed formula: $token"
  else
    log_warn "Failed to install formula: $token (continuing)"
    return 0
  fi
}

install_casks_from_file() {
  local file="$1"
  local token
  while IFS= read -r token; do
    [[ -n "$token" ]] || continue
    install_cask "$token"
  done < <(read_list_file "$file")
}

install_formulae_from_file() {
  local file="$1"
  local token
  while IFS= read -r token; do
    [[ -n "$token" ]] || continue
    install_formula "$token"
  done < <(read_list_file "$file")
}
