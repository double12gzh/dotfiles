#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            Pistol Part                             #
######################################################################
# INFO: needed packages: libmagic, file, file-devel
go install github.com/doronbehar/pistol/cmd/pistol@latest
#PISTOL_LINK="https://github.com/doronbehar/pistol.git"
#if [[ -z $(command -v pistol) ]]; then
#    echo "Install Pistol"
#    cd $HOME/tools
#    git clone "$PISTOL_LINK" --depth=1
#    cd $HOME/tools/pistol
#    go mod tidy
#    make
#    make install
#    cd "${SCRIT_DIR}"
#else
#    printf "${tty_blue}Pistol${tty_reset} is already installed, skip it.\n"
#fi
#
#cd "${SCRIPT_DIR}"
