#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                           Install Neovim                           #
######################################################################
NVIM_DIR="$TOOLS_DIR/nvim"
NVIM_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "macos" || echo "linux")"
NVIM_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "arm64" || echo "x86_64")"
NVIM_SRC_NAME="$PACKAGES_DIR/nvim-${NVIM_OS}-${NVIM_ARCH}.tar.gz"
NVIM_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_OS}-${NVIM_ARCH}.tar.gz"

if ! has_cmd nvim && [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
    info_install "Neovim (${NVIM_OS}-${NVIM_ARCH})"
    download_file "$NVIM_LINK" "$NVIM_SRC_NAME"
    extract_archive "$NVIM_SRC_NAME" "$NVIM_DIR" 1

    append_rc_once "tools/nvim/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/nvim/bin"
EOT
else
    info_skip "Neovim"
fi
