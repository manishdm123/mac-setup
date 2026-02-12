#!/usr/bin/env bash
set -euo pipefail

if [[ -t 1 ]]; then
  _CLR_RED='\033[0;31m'
  _CLR_GRN='\033[0;32m'
  _CLR_YLW='\033[0;33m'
  _CLR_BLU='\033[0;34m'
  _CLR_RST='\033[0m'
else
  _CLR_RED=''
  _CLR_GRN=''
  _CLR_YLW=''
  _CLR_BLU=''
  _CLR_RST=''
fi

log_info() { echo -e "${_CLR_BLU}[info]${_CLR_RST} $*"; }
log_ok()   { echo -e "${_CLR_GRN}[ok]${_CLR_RST}   $*"; }
log_warn() { echo -e "${_CLR_YLW}[warn]${_CLR_RST} $*"; }
log_err()  { echo -e "${_CLR_RED}[err]${_CLR_RST}  $*" 1>&2; }

die() { log_err "$*"; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This setup script currently supports macOS only.";
}

read_list_file() {
  # Reads a list file (one item per line), ignoring blanks and comments.
  local file="$1"
  [[ -f "$file" ]] || die "Missing required file: $file"
  sed -e 's/#.*$//' -e 's/[[:space:]]*$//' "$file" | awk 'NF { print $0 }'
}
