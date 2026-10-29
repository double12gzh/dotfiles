#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            Zinit Part                              #
######################################################################
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    info_install "Zinit"
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
    info_skip "Zinit"
fi
