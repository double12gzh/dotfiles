#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                           Golang Install                           #
######################################################################
GO_VERSION="${GO_VERSION:-1.24.1}"
GO_DIR="$TOOLS_DIR/golang"
GO_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "darwin" || echo "linux")"
GO_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "amd64")"
GO_SRC_NAME="$PACKAGES_DIR/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
GO_LINK="https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"

if ! has_cmd go && [[ ! -x "$GO_DIR/bin/go" ]]; then
    info_install "Golang (${GO_VERSION} ${GO_OS}/${GO_ARCH})"
    download_file "$GO_LINK" "$GO_SRC_NAME"
    extract_archive "$GO_SRC_NAME" "$GO_DIR" 1

    append_rc_once "tools/golang/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/golang/bin:$HOME/go/bin"
EOT
else
    info_skip "Golang"
fi

export PATH="$GO_DIR/bin:$HOME/go/bin:$PATH"
