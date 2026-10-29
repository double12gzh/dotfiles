#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#               Install Miniconda/Anaconda (Python env)              #
######################################################################

# 默认安装轻量级 Miniconda3；如需完整版 Anaconda 可设置 INSTALL_ANACONDA=true
INSTALL_ANACONDA="${INSTALL_ANACONDA:-false}"

if [[ "$INSTALL_ANACONDA" == "true" ]]; then
    CONDA_DIR="$TOOLS_DIR/anaconda"
    CONDA_NAME="Anaconda-${OS_TYPE}-${ARCH_TYPE}.sh"
    if [[ "$OS_TYPE" == "macos" && "$ARCH_TYPE" == "arm64" ]]; then
        CONDA_LINK="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-MacOSX-arm64.sh"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        CONDA_LINK="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-MacOSX-x86_64.sh"
    elif [[ "$ARCH_TYPE" == "arm64" ]]; then
        CONDA_LINK="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-aarch64.sh"
    else
        CONDA_LINK="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh"
    fi
else
    CONDA_DIR="$TOOLS_DIR/miniconda"
    CONDA_NAME="Miniconda3-${OS_TYPE}-${ARCH_TYPE}.sh"
    if [[ "$OS_TYPE" == "macos" && "$ARCH_TYPE" == "arm64" ]]; then
        CONDA_LINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        CONDA_LINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
    elif [[ "$ARCH_TYPE" == "arm64" ]]; then
        CONDA_LINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
    else
        CONDA_LINK="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    fi
fi

if [[ ! -d "$CONDA_DIR" && ! -d "$TOOLS_DIR/anaconda" && ! -d "$TOOLS_DIR/miniconda" ]]; then
    info_install "Conda ($CONDA_NAME)"
    download_file "$CONDA_LINK" "$PACKAGES_DIR/$CONDA_NAME"
    bash "$PACKAGES_DIR/$CONDA_NAME" -b -p "$CONDA_DIR"

    append_rc_once "conda initialize" <<EOT
# >>> conda initialize >>>
if [ -f "$CONDA_DIR/etc/profile.d/conda.sh" ]; then
    . "$CONDA_DIR/etc/profile.d/conda.sh"
else
    export PATH="$CONDA_DIR/bin:\$PATH"
fi
# <<< conda initialize <<<
EOT
else
    info_skip "Conda(Python)"
fi
