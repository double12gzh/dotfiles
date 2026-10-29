#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                           Cpufetch Part                            #
######################################################################
CPUFETCH_VERSION="v1.06"
CPUFETCH_DIR="$TOOLS_DIR/cpufetch"

if has_cmd cpufetch || [[ -x "$CPUFETCH_DIR/cpufetch" ]]; then
    info_skip "Cpufetch"
    return 0 2>/dev/null || exit 0
fi

info_install "Cpufetch"
mkdir -p "$CPUFETCH_DIR"

if [[ "$OS_TYPE" == "macos" ]]; then
    # 使用子 Shell 与临时目录隔离编译，避免污染父 Shell 的工作目录与 EXIT trap
    (
        tmp_src="$(mktemp -d)"
        trap 'rm -rf "$tmp_src"' EXIT
        git clone --depth=1 https://github.com/Dr-Noob/cpufetch "$tmp_src"
        make -C "$tmp_src" -j"$CPU_CORES"
        cp "$tmp_src/cpufetch" "$CPUFETCH_DIR/cpufetch"
        chmod +x "$CPUFETCH_DIR/cpufetch"
    )
else
    CPUFETCH_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x86-64")"
    CPUFETCH_LINK="https://github.com/Dr-Noob/cpufetch/releases/download/${CPUFETCH_VERSION}/cpufetch_${CPUFETCH_ARCH}_linux"
    download_file "$CPUFETCH_LINK" "$CPUFETCH_DIR/cpufetch"
    chmod +x "$CPUFETCH_DIR/cpufetch"
fi

append_rc_once "tools/cpufetch" <<'EOT'
export PATH="$PATH:$HOME/tools/cpufetch"
EOT
