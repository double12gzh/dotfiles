#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                              Jq Part                               #
######################################################################
JQ_VERSION="jq-1.7.1"
JQ_DIR="$TOOLS_DIR/jq"
JQ_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "macos" || echo "linux")"
JQ_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "amd64")"
JQ_LINK="https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-${JQ_OS}-${JQ_ARCH}"

if ! has_cmd jq && [[ ! -x "$JQ_DIR/jq" ]]; then
    info_install "jq (${JQ_VERSION} ${JQ_OS}-${JQ_ARCH})"
    mkdir -p "$JQ_DIR"
    download_file "$JQ_LINK" "$JQ_DIR/jq"
    chmod +x "$JQ_DIR/jq"

    append_rc_once "tools/jq" <<'EOT'
export PATH="$PATH:$HOME/tools/jq"
EOT
else
    info_skip "Jq"
fi
