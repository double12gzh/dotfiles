#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            Zplug Part                              #
######################################################################

if [[ -z $(command -v git) ]]; then
        echo "please install git first"
        exit 1
fi

if [[ -z $(command -v zsh) ]]; then
        echo "please install zsh"
        exit 1
fi

if [[ -z $(command -v awk) ]]; then
        echo "please install awk"
        exit 1
fi

if [ -d "$HOME"/.zplug ]; then
        echo "skipped"
        exit 0
fi

ZPLUG_HOME="$HOME"/.zplug
git clone https://github.com/zplug/zplug "$ZPLUG_HOME"
