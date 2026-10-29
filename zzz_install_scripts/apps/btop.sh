#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            Btop++ Part                             #
######################################################################
BTOP_VERSION="v1.4.0"
BTOP_DIR="$TOOLS_DIR/btop"

if has_cmd btop || [[ -x "$BTOP_DIR/bin/btop" ]]; then
    info_skip "Btop++"
    return 0 2>/dev/null || exit 0
fi

if [[ "$OS_TYPE" == "macos" ]]; then
    if has_cmd brew; then
        info_install "Btop++ (via Homebrew)"
        brew install btop
    else
        info_skip "Btop++ (macOS without Homebrew)"
    fi
else
    BTOP_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "aarch64" || echo "x86_64")"
    BTOP_SRC_NAME="$PACKAGES_DIR/btop-${BTOP_VERSION}-${BTOP_ARCH}.tbz"
    BTOP_LINK="https://github.com/aristocratos/btop/releases/download/${BTOP_VERSION}/btop-${BTOP_ARCH}-linux-musl.tbz"

    info_install "Btop++ (${BTOP_VERSION} linux-${BTOP_ARCH})"
    download_file "$BTOP_LINK" "$BTOP_SRC_NAME"
    extract_archive "$BTOP_SRC_NAME" "$BTOP_DIR" 1

    append_rc_once "tools/btop/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/btop/bin"
EOT
fi
