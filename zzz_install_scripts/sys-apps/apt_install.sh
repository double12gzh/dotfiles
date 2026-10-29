#!/usr/bin/env bash
set -e
set -o pipefail

if [[ "${OSTYPE:-}" == darwin* ]]; then
    echo "macOS detected, skipping apt_install.sh"
    exit 0
fi

sudo apt-get update -y
if ! command -v nala >/dev/null 2>&1; then
    sudo apt-get install -y nala || true
fi

APT_CMD="apt-get"
if command -v nala >/dev/null 2>&1; then
    APT_CMD="nala"
fi

# 核心编译与系统依赖（使用通用 python3-venv 替代硬编码的 python3.10-venv）
sudo "$APT_CMD" install -y \
    ssh vim htop git curl wget clang tree ninja-build \
    make cmake build-essential software-properties-common mercurial binutils bison re2c \
    python3-apt python3-pip python3-dev python3-setuptools python3-venv \
    pandoc highlight gzip tar plocate pkg-config bzip2 openssl unzip xz-utils \
    libxml2-dev libevent-dev libbz2-dev libcurl4-openssl-dev libpng-dev libssl-dev \
    libjpeg-dev libonig-dev libtidy-dev libxslt1-dev libzip-dev libstdc++6 \
    autoconf automake libyaml-dev libreadline-dev zlib1g-dev libncurses-dev \
    libffi-dev libgdbm-dev libdb-dev uuid-dev sqlite3 libsqlite3-dev \
    libfreetype6-dev librsvg2-dev libtiff-dev libwebp-dev libtool gtk-doc-tools \
    libimage-exiftool-perl atool libmagic-dev \
    libx11-dev libxmu-headers libxt-dev libxmu-dev \
    libpcre2-dev liblzma-dev liblz4-dev libzstd-dev \
    libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev libexpat1-dev libxcb-composite0-dev libharfbuzz-dev \
    caca-utils ffmpeg librsvg2-bin p7zip-full lldb sshfs

# 可选娱乐与展示工具（兼容 Ubuntu 24.04+ 移除部分旧包的情况）
for opt_pkg in fastfetch neofetch cmatrix jp2a speedtest-cli toilet lolcat ascii-image-converter unrar p7zip-rar; do
    sudo "$APT_CMD" install -y "$opt_pkg" 2>/dev/null || true
done

# LaTeX 工具链
sudo "$APT_CMD" install -y latexmk biber texlive-fonts-extra texlive-fonts-recommended texlive-latex-extra --no-install-recommends || true

# Python 辅助工具（兼容 Ubuntu 23.04+ PEP 668 externally-managed-environment）
PIP_EXTRA_ARGS=()
if pip3 install --help 2>&1 | grep -q -- "--break-system-packages"; then
    PIP_EXTRA_ARGS+=(--break-system-packages)
fi
sudo pip3 install "${PIP_EXTRA_ARGS[@]}" --no-cache-dir pynvim gdown "ntfy[emoji]" asciinema || true
