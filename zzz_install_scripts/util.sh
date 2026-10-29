#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2059

# 防止重复加载
if [[ -n "${_DOTFILES_INSTALL_UTIL_LOADED:-}" ]]; then
    return 0 2>/dev/null || true
fi
readonly _DOTFILES_INSTALL_UTIL_LOADED=1

abort() {
    printf "%s\n" "$@" >&2
    exit 1
}

# 终端颜色格式化
if [[ -t 1 ]]; then
    tty_escape() { printf "\033[%sm" "$1"; }
else
    tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_yellow="$(tty_escape "0;33")"
tty_red="$(tty_mkbold 31)"
tty_green="$(tty_mkbold 32)"
tty_blue="$(tty_mkbold 34)"
tty_magenta="$(tty_mkbold 35)"
tty_cyan="$(tty_mkbold 36)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
    local arg
    printf "%s" "$1"
    shift
    for arg in "$@"; do
        printf " "
        printf "%s" "${arg// /\ }"
    done
}

execute() {
    if ! "$@"; then
        abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
    fi
}

chomp() {
    printf "%s" "${1/"$'\n'"/}"
}

prompt() {
    printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
    printf "${tty_yellow}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

info_skip() {
    printf "${tty_blue}%s${tty_reset} is already installed, skip it.\n" "$1"
}

info_install() {
    printf "${tty_green}==> Installing %s...${tty_reset}\n" "$1"
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 统一平台与架构探测
detect_platform() {
    if [[ "${OSTYPE:-}" == darwin* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
        OS_TYPE="macos"
    else
        OS_TYPE="linux"
    fi

    local machine
    machine="$(uname -m)"
    case "$machine" in
        arm64 | aarch64)
            ARCH_TYPE="arm64"
            ;;
        x86_64 | amd64)
            ARCH_TYPE="x86_64"
            ;;
        *)
            ARCH_TYPE="$machine"
            ;;
    esac

    CPU_CORES="$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"
    export OS_TYPE ARCH_TYPE CPU_CORES
}
detect_platform

getc() {
    local save_state
    save_state="$(/bin/stty -g)"
    /bin/stty raw -echo
    IFS='' read -r -n 1 -d '' "$@"
    /bin/stty "${save_state}"
}

ring_bell() {
    if [[ -t 1 ]]; then
        printf "\a"
    fi
}

wait_for_user() {
    local c
    echo
    echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} to continue or any other key to abort..."
    getc c
    if ! [[ "${c}" == $'\r' || "${c}" == $'\n' ]]; then
        echo "${tty_red}Aborted.${tty_reset}"
        exit 1
    fi
}

######################################################################
#                        原子下载与归档解压原语                        #
######################################################################

# 原子下载文件：优先使用 curl，回退 wget；下载至 .part 临时文件成功后重命名，防止半截损坏文件残留
download_file() {
    local url="$1"
    local dest="$2"
    if [[ -f "$dest" && -s "$dest" ]]; then
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    local tmp_dest="${dest}.part"
    rm -f "$tmp_dest"
    printf "Downloading ${tty_cyan}%s${tty_reset} -> %s\n" "$url" "$dest"
    if has_cmd curl; then
        if ! curl -fL --retry 3 --connect-timeout 15 -o "$tmp_dest" "$url"; then
            rm -f "$tmp_dest"
            warn "Failed to download: $url"
            return 1
        fi
    elif has_cmd wget; then
        if ! wget --tries=3 --timeout=15 -O "$tmp_dest" "$url"; then
            rm -f "$tmp_dest"
            warn "Failed to download: $url"
            return 1
        fi
    else
        abort "Neither curl nor wget is available."
    fi
    mv "$tmp_dest" "$dest"
}

# 统一解压归档文件：支持 tar.gz/tgz/tar.xz/txz/tbz/tar.bz2/zip
extract_archive() {
    local archive="$1"
    local dest_dir="$2"
    local strip="${3:-1}"
    mkdir -p "$dest_dir"
    case "$archive" in
        *.tar.gz | *.tgz)
            tar -xzf "$archive" -C "$dest_dir" --strip-components="$strip"
            ;;
        *.tar.xz | *.txz)
            tar -xJf "$archive" -C "$dest_dir" --strip-components="$strip"
            ;;
        *.tar.bz2 | *.tbz | *.tbz2)
            tar -xjf "$archive" -C "$dest_dir" --strip-components="$strip"
            ;;
        *.zip)
            unzip -q "$archive" -d "$dest_dir"
            ;;
        *)
            tar -xf "$archive" -C "$dest_dir" --strip-components="$strip"
            ;;
    esac
}

# 幂等追加配置到 RC_FILE
append_rc_once() {
    local marker="$1"
    if [[ "${ADD_TO_SYSTEM_PATH:-false}" != "true" ]] || [[ -z "${RC_FILE:-}" ]]; then
        \cat >/dev/null
        return 0
    fi
    touch "$RC_FILE"
    if ! grep -Fq "$marker" "$RC_FILE" 2>/dev/null; then
        \cat >>"$RC_FILE"
    else
        \cat >/dev/null
    fi
}

######################################################################
#                     Rust Cargo / Go 统一安装原语                    #
######################################################################

ensure_cargo_binstall() {
    export PATH="$HOME/.cargo/bin:$PATH"
    if has_cmd cargo-binstall; then
        return 0
    fi
    if ! has_cmd cargo; then
        return 1
    fi
    local binstall_url=""
    local pkg_ext="tgz"
    if [[ "$OS_TYPE" == "macos" && "$ARCH_TYPE" == "arm64" ]]; then
        pkg_ext="zip"
        binstall_url="https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-aarch64-apple-darwin.zip"
    elif [[ "$OS_TYPE" == "macos" && "$ARCH_TYPE" == "x86_64" ]]; then
        pkg_ext="zip"
        binstall_url="https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-apple-darwin.zip"
    elif [[ "$OS_TYPE" == "linux" && "$ARCH_TYPE" == "arm64" ]]; then
        binstall_url="https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-aarch64-unknown-linux-musl.tgz"
    elif [[ "$OS_TYPE" == "linux" && "$ARCH_TYPE" == "x86_64" ]]; then
        binstall_url="https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz"
    fi
    if [[ -n "$binstall_url" ]]; then
        local pkg_path="$HOME/packages/cargo-binstall.${pkg_ext}"
        mkdir -p "$HOME/.cargo/bin"
        if download_file "$binstall_url" "$pkg_path"; then
            if [[ "$pkg_ext" == "zip" ]]; then
                unzip -q -o "$pkg_path" -d "$HOME/.cargo/bin" || true
            else
                tar -xzf "$pkg_path" -C "$HOME/.cargo/bin" || true
            fi
            chmod +x "$HOME/.cargo/bin/cargo-binstall" 2>/dev/null || true
        fi
    fi
}

# 安装 Rust CLI 工具：优先使用 cargo-binstall 拉取预编译二进制，失败时自动回退 cargo install
install_cargo_pkg() {
    local bin_name="$1"
    local crate_name="${2:-$1}"
    shift $(( $# >= 2 ? 2 : 1 ))

    export PATH="$HOME/.cargo/bin:$PATH"
    if has_cmd "$bin_name"; then
        info_skip "$bin_name"
        return 0
    fi
    if ! has_cmd cargo; then
        warn "cargo not found, skipping $bin_name (run langs/rust.sh first)"
        return 0
    fi

    info_install "$bin_name ($crate_name)"
    ensure_cargo_binstall || true

    # 若未指定 --git 等特殊源码参数且存在 cargo-binstall，优先下载预编译二进制
    if [[ "${1:-}" != "--git" ]] && has_cmd cargo-binstall; then
        if cargo binstall -y --locked "$crate_name"; then
            return 0
        fi
        warn "cargo-binstall failed for $crate_name, falling back to cargo install..."
    fi

    if [[ $# -gt 0 ]]; then
        cargo install "$@"
    else
        cargo install "$crate_name" --locked
    fi
}

# 安装 Go CLI 工具
install_go_pkg() {
    local bin_name="$1"
    local pkg_url="$2"
    local cgo="${3:-}"

    export PATH="$HOME/tools/golang/bin:$HOME/go/bin:$PATH"
    if has_cmd "$bin_name"; then
        info_skip "$bin_name"
        return 0
    fi
    if ! has_cmd go; then
        warn "go not found, skipping $bin_name (run langs/golang.sh first)"
        return 0
    fi

    info_install "$bin_name ($pkg_url)"
    if [[ "$cgo" == "nocgo" ]]; then
        env CGO_ENABLED=0 go install -ldflags="-s -w" "$pkg_url"
    else
        go install "$pkg_url"
    fi
}

######################################################################
#                          Git & GitHub 辅助                          #
######################################################################
check_git_update() {
    local upstream=${1:-'@{u}'}
    local local_rev remote_rev base_rev
    local_rev=$(git rev-parse @)
    remote_rev=$(git rev-parse "$upstream")
    base_rev=$(git merge-base @ "$upstream")

    if [ "$local_rev" = "$remote_rev" ]; then
        echo false
    elif [ "$local_rev" = "$base_rev" ]; then
        echo true
    else
        echo false
    fi
}

get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/'
}

cat_ver() {
    echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
}

is_latest() {
    if [ "$(cat_ver "${1}")" -eq "$(cat_ver "${2}")" ]; then
        echo true
    elif [ "$(cat_ver "${1}")" -gt "$(cat_ver "${2}")" ]; then
        echo false
    else
        abort "${tty_red}Something is wrong. Please check the scripts or the original repo.${tty_reset}"
    fi
}
