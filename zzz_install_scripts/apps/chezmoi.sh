#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            chezmoi Part                            #
######################################################################
CHEZMOI_BIN_DIR="${HOME}/.local/bin"
if [[ -z $(command -v chezmoi) ]]; then
    echo "Installing chezmoi to ${CHEZMOI_BIN_DIR}"
    mkdir -p "${CHEZMOI_BIN_DIR}"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}"
else
    printf "${tty_blue}chezmoi${tty_reset} is already installed, skip it.\n"
fi
