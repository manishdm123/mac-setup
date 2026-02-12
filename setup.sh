#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

# shellcheck source=lib/util.sh
source "$ROOT_DIR/lib/util.sh"
# shellcheck source=lib/brew.sh
source "$ROOT_DIR/lib/brew.sh"

TAPS_FILE="${TAPS_FILE:-$ROOT_DIR/brew-taps.txt}"
CASKS_FILE="${CASKS_FILE:-$ROOT_DIR/brew-casks.txt}"
FORMULAE_FILE="${FORMULAE_FILE:-$ROOT_DIR/brew-formulae.txt}"

DO_TAPS=1
DO_CASKS=1
DO_FORMULAE=1
DO_POST=1
DRY_RUN=0

usage() {
  cat <<EOF
Usage: ./setup.sh [options]

Options:
  --dry-run            Print what would run (no installs)
  --skip-taps          Skip brew tap section
  --skip-casks         Skip cask installs
  --skip-formulae      Skip formula installs
  --skip-post          Skip post steps (node postinstall + npm global)
  -h, --help           Show help

Env overrides:
  TAPS_FILE=...        Default: brew-taps.txt
  CASKS_FILE=...       Default: brew-casks.txt
  FORMULAE_FILE=...    Default: brew-formulae.txt
EOF
}

main() {
  require_macos

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1; shift ;;
      --skip-taps) DO_TAPS=0; shift ;;
      --skip-casks) DO_CASKS=0; shift ;;
      --skip-formulae) DO_FORMULAE=0; shift ;;
      --skip-post) DO_POST=0; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "Unknown option: $1 (use --help)" ;;
    esac
  done

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log_warn "Dry-run mode enabled (no changes will be made)"
    echo "[dry-run] ensure Homebrew installed"
  else
    ensure_brew
  fi

  if [[ "$DO_TAPS" -eq 1 ]]; then
    local tap
    while IFS= read -r tap; do
      [[ -n "$tap" ]] || continue
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] brew tap $tap"
      else
        ensure_tap "$tap"
      fi
    done < <(read_list_file "$TAPS_FILE")
  fi

  if [[ "$DO_CASKS" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] brew install --cask <tokens from $CASKS_FILE>"
    else
      install_casks_from_file "$CASKS_FILE"
    fi
  fi

  if [[ "$DO_FORMULAE" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] brew install <tokens from $FORMULAE_FILE>"
    else
      install_formulae_from_file "$FORMULAE_FILE"
    fi
  fi

  if [[ "$DO_POST" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] brew postinstall node"
      echo "[dry-run] npm install -g cline"
    else
      log_info "Post step: brew postinstall node"
      brew postinstall node || log_warn "brew postinstall node failed (continuing)"

      if command_exists npm; then
        log_info "Post step: npm install -g cline"
        npm install -g cline || log_warn "npm install -g cline failed (continuing)"
      else
        log_warn "npm not found; skipping cline install"
      fi
    fi
  fi

  log_ok "All done"
}

main "$@"
