#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

DEFAULT_APPS=(
    ascii-image-converter
    batcat
    btop
    chezmoi
    cpufetch
    delta
    dua
    exa
    fdfind
    fzf
    fzy
    glow
    jq
    lazygit
    lf
    lnav
    navi
    nvim
    pistol
    qfc
    ripgrep
    starship
    termpix
    tmux
    treesitter
    ugrep
    viu
    xplr
    zoxide
    zinit
)

# 支持按参数指定安装单个或多个应用（如: bash install_app.sh nvim fzf），无参数则安装默认列表
if [[ $# -gt 0 ]]; then
    TARGET_APPS=("$@")
    set --
else
    TARGET_APPS=("${DEFAULT_APPS[@]}")
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

for app in "${TARGET_APPS[@]}"; do
    app_script="${SCRIPT_DIR}/apps/${app%.sh}.sh"
    if [[ -f "$app_script" ]]; then
        source "$app_script"
    else
        warn "App installer not found: $app_script"
    fi
done

printf "\n${tty_yellow}==================== App Install Complete ====================${tty_reset}\n"
