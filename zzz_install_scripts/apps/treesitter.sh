#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                          Tree-sitter Part                          #
######################################################################
TS_VERSION="v0.25.3"
TS_DIR="$TOOLS_DIR/treesitter"
TS_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "macos" || echo "linux")"
TS_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x64")"
TS_SRC_NAME="$PACKAGES_DIR/tree-sitter-${TS_OS}-${TS_ARCH}.gz"
TS_LINK="https://github.com/tree-sitter/tree-sitter/releases/download/${TS_VERSION}/tree-sitter-${TS_OS}-${TS_ARCH}.gz"

if ! has_cmd tree-sitter && [[ ! -x "$TS_DIR/tree-sitter" ]]; then
    info_install "tree-sitter (${TS_VERSION} ${TS_OS}-${TS_ARCH})"
    download_file "$TS_LINK" "$TS_SRC_NAME"
    mkdir -p "$TS_DIR"
    # 使用 gunzip -c 保留原始 .gz 归档文件不删除
    gunzip -c "$TS_SRC_NAME" >"$TS_DIR/tree-sitter"
    chmod u+x "$TS_DIR/tree-sitter"

    append_rc_once "tools/treesitter" <<'EOT'
export PATH="$PATH:$HOME/tools/treesitter"
EOT
else
    info_skip "Tree-sitter"
fi
