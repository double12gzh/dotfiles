#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                              Fzy Part                              #
######################################################################
FZY_DIR="$TOOLS_DIR/fzy"
FZY_SRC_NAME="$PACKAGES_DIR/fzy-1.0.tar.gz"
FZY_LINK="https://github.com/jhawthorn/fzy/releases/download/1.0/fzy-1.0.tar.gz"

if ! has_cmd fzy && [[ ! -x "$FZY_DIR/fzy" ]]; then
    info_install "fzy"
    download_file "$FZY_LINK" "$FZY_SRC_NAME"
    extract_archive "$FZY_SRC_NAME" "$FZY_DIR" 1
    make -C "$FZY_DIR" -j"$CPU_CORES"

    append_rc_once "tools/fzy" <<'EOT'
export PATH="$PATH:$HOME/tools/fzy"
EOT
else
    info_skip "Fzy"
fi
