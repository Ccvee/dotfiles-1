#!/usr/bin/env bash

set -eu

# =============================================================================
# Require DOTFILES
# =============================================================================

if [ -z "$DOTFILES" ]; then
  echo ".dotfiles repo is not set up"
  exit 1
fi
source "${DOTFILES}/shell/helpers.bash"

# =============================================================================
# Main
# =============================================================================

# loop through default-gems file and output if not installed
__find_missing() {
  while read -r gemname; do
    if ! gem list -i "$gemname" >/dev/null; then
      echo "${gemname} not installed"
    fi
  done < "${DOTFILES}/ruby/default-gems"
}

__find_missing
