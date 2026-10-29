#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

DEFAULT_LANGS=(
    conda
    golang
    java
    julia
    lua
    nodejs
    perl
    ruby
    rust
)

# 支持按参数指定安装单个或多个语言（如: bash install_lang.sh golang rust），无参数则安装默认列表
if [[ $# -gt 0 ]]; then
    TARGET_LANGS=("$@")
    set --
else
    TARGET_LANGS=("${DEFAULT_LANGS[@]}")
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

for lang in "${TARGET_LANGS[@]}"; do
    lang_script="${SCRIPT_DIR}/langs/${lang%.sh}.sh"
    if [[ -f "$lang_script" ]]; then
        source "$lang_script"
    else
        warn "Language installer not found: $lang_script"
    fi
done

printf "\n${tty_yellow}==================== Language Install Complete ====================${tty_reset}\n"
