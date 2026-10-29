#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2059,SC2154
set -e
set -o pipefail

# 获取 zzz_install_scripts 目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT_DIR="$(dirname "$SCRIPT_DIR")"

# 导入公共函数与平台探测变量 (OS_TYPE, ARCH_TYPE, CPU_CORES)
source "${SCRIPT_DIR}/util.sh"

# 幂等加载守卫：防止 setup.sh 连续执行 langs 与 apps 时重复初始化和打印横幅
if [[ -n "${_DOTFILES_INSTALL_CONFIG_LOADED:-}" ]]; then
    return 0 2>/dev/null || true
fi
readonly _DOTFILES_INSTALL_CONFIG_LOADED=1

USERNAME="Jeffrey Guan"
EMAIL="double12gzh@gmail.com"

if [ -z "${BASH_VERSION:-}" ]; then
    abort "Bash is required to interpret this script."
fi

if ! has_cmd git; then
    abort "You must install Git before executing this script (https://git-scm.com/)."
fi

# 是否将工具路径写入 RC_FILE（默认由 home/dot_zshenv 统一管理 PATH，故为 false）
ADD_TO_SYSTEM_PATH="${ADD_TO_SYSTEM_PATH:-false}"
USE_BASH_SHELL="${USE_BASH_SHELL:-false}"
USE_ZSH_SHELL="${USE_ZSH_SHELL:-true}"

if [[ "$ADD_TO_SYSTEM_PATH" == "true" ]]; then
    if [[ "$USE_BASH_SHELL" == "true" ]]; then
        RC_FILE="$HOME/.bashrc"
    elif [[ "$USE_ZSH_SHELL" == "true" ]]; then
        RC_FILE="$HOME/.zshrc"
    else
        abort "Please select a shell (USE_BASH_SHELL or USE_ZSH_SHELL)."
    fi
    printf "Chosen rc file: ${tty_blue}%s${tty_reset}\n" "$RC_FILE"
fi

PACKAGES_DIR="${HOME}/packages"
TOOLS_DIR="${HOME}/tools"
MAN_PATH="${DOT_DIR}/home/dot_local/share/man/man1"
LOCAL_MAN="${HOME}/.local/share/man/man1"
export SCRIPT_DIR DOT_DIR PACKAGES_DIR TOOLS_DIR MAN_PATH LOCAL_MAN

# 注入已有工具目录至当前 Bash 会话 PATH，确保幂等检测 (has_cmd) 准确识别已安装二进制
for _dir in \
    "/opt/homebrew/bin" \
    "$HOME/.local/bin" \
    "$HOME/.bin" \
    "$HOME/.cargo/bin" \
    "$TOOLS_DIR/golang/bin" \
    "$HOME/go/bin" \
    "$TOOLS_DIR/nvim/bin" \
    "$TOOLS_DIR/tmux/bin" \
    "$TOOLS_DIR/tmux" \
    "$TOOLS_DIR/fzf/bin" \
    "$TOOLS_DIR/jq" \
    "$TOOLS_DIR/rg"
do
    if [[ -d "$_dir" && ":$PATH:" != *":$_dir:"* ]]; then
        PATH="$_dir:$PATH"
    fi
done
export PATH

CheckDir() {
    mkdir -p "$PACKAGES_DIR" "$TOOLS_DIR" "$HOME/.local/bin"
}

if [[ "${1:-}" != "--source-only" ]]; then
    CheckDir
    printf "Platform detected: ${tty_green}%s/%s${tty_reset} (%s cores)\n" "$OS_TYPE" "$ARCH_TYPE" "$CPU_CORES"
    printf "Packages cache:    ${tty_blue}%s${tty_reset}\n" "$PACKAGES_DIR"
    printf "Tools directory:   ${tty_blue}%s${tty_reset}\n" "$TOOLS_DIR"
    if [[ "${INTERACTIVE_CONFIRM:-false}" == "true" ]]; then
        wait_for_user
    fi
    printf "\n${tty_yellow}==================== Install Session Ready ====================${tty_reset}\n"
fi
