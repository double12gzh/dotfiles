#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            Zinit Part                              #
######################################################################

ZINIT_HOME="${HOME}/.local/share}/zinit/zinit.git"
git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
