#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            chezmoi Part                            #
######################################################################
CHEZMOI_BIN_DIR="${HOME}/.local/bin"

if ! has_cmd chezmoi && [[ ! -x "${CHEZMOI_BIN_DIR}/chezmoi" ]]; then
    info_install "chezmoi"
    mkdir -p "${CHEZMOI_BIN_DIR}"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}"
else
    info_skip "chezmoi"
fi
