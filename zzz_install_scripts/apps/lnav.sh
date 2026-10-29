#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                             Lnav Part                              #
######################################################################
LNAV_VERSION="0.12.2"
LNAV_DIR="$TOOLS_DIR/lnav"

if has_cmd lnav || [[ -x "$LNAV_DIR/lnav" ]]; then
    info_skip "Lnav"
    return 0 2>/dev/null || exit 0
fi

if [[ "$OS_TYPE" == "macos" ]]; then
    if has_cmd brew; then
        info_install "lnav (via Homebrew)"
        brew install lnav
        return 0 2>/dev/null || exit 0
    fi
    LNAV_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x86_64")"
    LNAV_LINK="https://github.com/tstack/lnav/releases/download/v${LNAV_VERSION}/lnav-${LNAV_VERSION}-os-x-${LNAV_ARCH}.zip"
else
    LNAV_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x86_64")"
    LNAV_LINK="https://github.com/tstack/lnav/releases/download/v${LNAV_VERSION}/lnav-${LNAV_VERSION}-linux-musl-${LNAV_ARCH}.zip"
fi

LNAV_SRC_NAME="$PACKAGES_DIR/lnav-${LNAV_VERSION}-${OS_TYPE}-${ARCH_TYPE}.zip"
info_install "lnav (${LNAV_VERSION})"
download_file "$LNAV_LINK" "$LNAV_SRC_NAME"
mkdir -p "$LNAV_DIR"
unzip -q -o "$LNAV_SRC_NAME" -d "$LNAV_DIR"
for f in "$LNAV_DIR"/lnav-*/*; do
    [[ -e "$f" ]] && mv "$f" "$LNAV_DIR/"
done
rm -rf "$LNAV_DIR"/lnav-*

append_rc_once "tools/lnav" <<'EOT'
export PATH="$PATH:$HOME/tools/lnav"
EOT
