#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                          ImageMagick Part                          #
######################################################################
MAGICK_DIR="$TOOLS_DIR/magick"
MAGICK_LINK="https://github.com/ImageMagick/ImageMagick.git"

if ! has_cmd magick && [[ ! -x "$MAGICK_DIR/bin/magick" ]]; then
    info_install "ImageMagick"
    if [[ ! -d "$MAGICK_DIR/src" ]]; then
        git clone --depth=1 "$MAGICK_LINK" "$MAGICK_DIR/src"
    fi
    (
        cd "$MAGICK_DIR/src"
        ./configure --prefix="$MAGICK_DIR" --with-modules
        make -j"$CPU_CORES"
        make install
    )
    rm -rf "$MAGICK_DIR/src"

    append_rc_once "tools/magick/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/magick/bin"
export MAGICK_HOME="$HOME/tools/magick"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$MAGICK_HOME/lib"
EOT
else
    info_skip "ImageMagick"
fi
