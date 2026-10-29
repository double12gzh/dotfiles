#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                          Ruby/Gem Install                          #
######################################################################
RUBY_VERSION="3.3.6"
RUBY_DIR="$TOOLS_DIR/ruby"
RUBY_TAR_DIR="$TOOLS_DIR/ruby/tarball"
RUBY_SRC_NAME="$PACKAGES_DIR/ruby-${RUBY_VERSION}.tar.gz"
RUBY_LINK="https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${RUBY_VERSION}.tar.gz"

if [[ ! -x "$RUBY_DIR/bin/ruby" ]]; then
    info_install "Ruby (${RUBY_VERSION})"
    download_file "$RUBY_LINK" "$RUBY_SRC_NAME"
    extract_archive "$RUBY_SRC_NAME" "$RUBY_TAR_DIR" 1
    (
        cd "$RUBY_TAR_DIR"
        OPENSSL_OPT=()
        if [[ "$OS_TYPE" == "macos" ]] && has_cmd brew && brew --prefix openssl >/dev/null 2>&1; then
            OPENSSL_OPT=("--with-openssl-dir=$(brew --prefix openssl)")
        fi
        ./configure --prefix="$RUBY_DIR" "${OPENSSL_OPT[@]}"
        make -j"$CPU_CORES"
        make install
    )
    rm -rf "$RUBY_TAR_DIR"

    append_rc_once "tools/ruby/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/ruby/bin"
EOT
else
    info_skip "Ruby & Gem"
fi
