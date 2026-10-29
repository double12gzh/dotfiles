#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                             Ugrep Part                             #
######################################################################
UGREP_DIR="$TOOLS_DIR/ugrep"
UGREP_LINK="https://github.com/Genivia/ugrep.git"

if ! has_cmd ugrep && [[ ! -x "$UGREP_DIR/bin/ugrep" ]]; then
    info_install "ugrep"
    if [[ ! -d "$UGREP_DIR/.git" ]]; then
        rm -rf "$UGREP_DIR"
        git clone --depth=1 "$UGREP_LINK" "$UGREP_DIR"
    fi
    (
        cd "$UGREP_DIR"
        ./build.sh --enable-hidden --enable-pretty
    )

    append_rc_once "tools/ugrep/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/ugrep/bin"
EOT
else
    info_skip "Ugrep"
fi
