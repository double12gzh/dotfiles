#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                           Install Neovim                           #
######################################################################
NVIM_DIR=$HOME/tools/nvim
NVIM_SRC_NAME=$HOME/packages/nvim.tar.gz
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$(uname -m)" == "arm64" ]]; then
        NVIM_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz"
    else
        NVIM_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-x86_64.tar.gz"
    fi
else
    if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
        NVIM_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
    else
        NVIM_LINK="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    fi
fi
if [[ ! -f "$NVIM_DIR/bin/nvim" ]]; then
    echo "Installing Nvim"
    echo "Creating nvim directory under tools directory"

    if [[ ! -d "$NVIM_DIR" ]]; then
        mkdir -p "$NVIM_DIR"
    fi

    if [[ ! -f $NVIM_SRC_NAME ]]; then
        echo "Downloading Nvim"
        wget "$NVIM_LINK" -O "$NVIM_SRC_NAME"
    fi
    echo "Extracting neovim"
    tar zxvf "$NVIM_SRC_NAME" --strip-components 1 -C "$NVIM_DIR"

    if [[ "$ADD_TO_SYSTEM_PATH" = true ]]; then
        cat <<'EOT' >>"$RC_FILE"
export PATH="$PATH:$HOME/tools/nvim/bin"
EOT
    fi
else
    printf "${tty_blue}Neovim${tty_reset} is already installed, skip it.\n"
fi
