#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            Direnv Part                             #
######################################################################
if has_cmd direnv; then
    info_skip "Direnv"
elif [[ "$OS_TYPE" == "macos" ]] && has_cmd brew; then
    info_install "Direnv (via Homebrew)"
    brew install direnv
elif [[ "$OS_TYPE" == "linux" ]]; then
    info_install "Direnv (via apt)"
    sudo apt-get install -y direnv
fi
