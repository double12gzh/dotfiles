#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            Zplug Part                              #
######################################################################
ZPLUG_HOME="$HOME/.zplug"

if [[ ! -d "$ZPLUG_HOME" ]]; then
    info_install "Zplug"
    git clone --depth=1 https://github.com/zplug/zplug "$ZPLUG_HOME"
else
    info_skip "Zplug"
fi
