#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                          Java/JDK Install                          #
######################################################################
JAVA_VERSION="21.0.2"
JAVA_DIR="$TOOLS_DIR/java"
JAVA_OS="$([[ "$OS_TYPE" == "macos" ]] && echo "macos" || echo "linux")"
JAVA_ARCH="$([[ "$ARCH_TYPE" == "arm64" ]] && echo "aarch64" || echo "x64")"
JAVA_SRC_NAME="$PACKAGES_DIR/openjdk-${JAVA_VERSION}_${JAVA_OS}-${JAVA_ARCH}.tar.gz"
JAVA_LINK="https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-${JAVA_VERSION}_${JAVA_OS}-${JAVA_ARCH}_bin.tar.gz"

if [[ ! -x "$JAVA_DIR/bin/java" ]]; then
    info_install "OpenJDK (${JAVA_VERSION} ${JAVA_OS}/${JAVA_ARCH})"
    download_file "$JAVA_LINK" "$JAVA_SRC_NAME"
    # macOS JDK 归档内部结构为 jdk-21.0.2.jdk/Contents/Home/bin/java (3 层)，Linux 为 jdk-21.0.2/bin/java (1 层)
    local_strip="$([[ "$OS_TYPE" == "macos" ]] && echo 3 || echo 1)"
    extract_archive "$JAVA_SRC_NAME" "$JAVA_DIR" "$local_strip"

    append_rc_once "tools/java/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/java/bin"
EOT
else
    info_skip "Java"
fi
