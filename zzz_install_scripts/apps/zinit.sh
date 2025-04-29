#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            Zinit Part                              #
######################################################################

ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    echo "Installing Zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
else
    echo "$ZINIT_HOME alreay exists, skipped"
fi
