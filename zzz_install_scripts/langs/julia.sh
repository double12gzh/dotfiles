#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                           Julia Install                            #
######################################################################
JULIA_VERSION="1.10.8"
JULIA_DIR="$TOOLS_DIR/julia"
JULIA_SRC_NAME="$PACKAGES_DIR/julia-${JULIA_VERSION}-${OS_TYPE}-${ARCH_TYPE}.tar.gz"

if [[ "$OS_TYPE" == "macos" && "$ARCH_TYPE" == "arm64" ]]; then
    JULIA_LINK="https://julialang-s3.julialang.org/bin/mac/aarch64/1.10/julia-${JULIA_VERSION}-macaarch64.tar.gz"
elif [[ "$OS_TYPE" == "macos" ]]; then
    JULIA_LINK="https://julialang-s3.julialang.org/bin/mac/x64/1.10/julia-${JULIA_VERSION}-mac64.tar.gz"
elif [[ "$ARCH_TYPE" == "arm64" ]]; then
    JULIA_LINK="https://julialang-s3.julialang.org/bin/linux/aarch64/1.10/julia-${JULIA_VERSION}-linux-aarch64.tar.gz"
else
    JULIA_LINK="https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
fi

if [[ ! -x "$JULIA_DIR/bin/julia" ]]; then
    info_install "Julia (${JULIA_VERSION})"
    download_file "$JULIA_LINK" "$JULIA_SRC_NAME"
    extract_archive "$JULIA_SRC_NAME" "$JULIA_DIR" 1

    append_rc_once "tools/julia/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/julia/bin"
EOT
else
    info_skip "Julia"
fi
