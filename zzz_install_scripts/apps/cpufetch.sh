#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                           Cpufetch Part                            #
######################################################################
CPUFETCH_DIR=$HOME/tools/cpufetch
if [[ ! -d $CPUFETCH_DIR ]]; then
    echo "Creating cpufetch directory under tools directory"
    mkdir -p "$CPUFETCH_DIR"
fi

function install_cpufetch_for_macos() {
    local src_dir="$CPUFETCH_DIR"_src
    # 添加trap，确保在函数退出时删除临时目录
    trap 'rm -rf "$src_dir"; echo "清理临时文件 $src_dir"' EXIT ERR INT TERM
    
    git clone https://github.com/Dr-Noob/cpufetch "$src_dir"
    cd "$src_dir"
    make
    cp cpufetch "$CPUFETCH_DIR/cpufetch"
    chmod +x "$CPUFETCH_DIR/cpufetch"
    cd ..
    rm -rf "$src_dir"
    # 成功完成后移除trap
    trap - EXIT ERR INT TERM
}

function install_cpufetch_for_linux() {
    CPUFETCH_LINK="https://github.com/Dr-Noob/cpufetch/releases/download/v1.03/cpufetch_x86-64_linux"
    echo "Download to $HOME/tools/cpufetch directory"
    wget "$CPUFETCH_LINK" -O "$CPUFETCH_DIR/cpufetch"
    chmod +x "$CPUFETCH_DIR/cpufetch"
}

if [[ -z $(command -v cpufetch) ]]; then
    echo "Install cpufetch"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        install_cpufetch_for_macos
    else
        install_cpufetch_for_linux
    fi

    if [[ "$ADD_TO_SYSTEM_PATH" = true ]]; then
        cat <<EOT >>"$RC_FILE"
export PATH="$PATH:$HOME/tools/cpufetch"
EOT
    fi
else
    printf "${tty_blue}Cpufetch${tty_reset} is already installed, skip it.\n"
fi
