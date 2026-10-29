#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                            Node Install                            #
######################################################################
NODE_VERSION="${NODE_VERSION:-v22.14.0}"
NODE_DIR="$TOOLS_DIR/nodejs"
NODE_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "darwin" || echo "linux")"
NODE_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x64")"
NODE_EXT="$([[ "$OS_TYPE" == "macos" ]] && echo "tar.gz" || echo "tar.xz")"
NODE_SRC_NAME="$PACKAGES_DIR/node-${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}.${NODE_EXT}"
NODE_LINK="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_OS}-${NODE_ARCH}.${NODE_EXT}"

if ! has_cmd node && [[ ! -x "$NODE_DIR/bin/node" ]]; then
    info_install "Node.js (${NODE_VERSION} ${NODE_OS}/${NODE_ARCH})"
    download_file "$NODE_LINK" "$NODE_SRC_NAME"
    extract_archive "$NODE_SRC_NAME" "$NODE_DIR" 1
    "$NODE_DIR/bin/npm" config set fund false || true

    append_rc_once "tools/nodejs/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/nodejs/bin"
EOT
else
    info_skip "Node.js"
fi
