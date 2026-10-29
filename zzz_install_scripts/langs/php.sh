#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                        PHP/Composer Install                        #
######################################################################
PHP_DIR="$TOOLS_DIR/php"
PHP_LINK="https://github.com/php/php-src.git"

if ! has_cmd php && [[ ! -x "$PHP_DIR/bin/php" ]]; then
    info_install "PHP & Composer"
    if [[ ! -d "$PHP_DIR/src" ]]; then
        git clone --depth=1 "$PHP_LINK" "$PHP_DIR/src"
    fi
    (
        cd "$PHP_DIR/src"
        ./buildconf --force
        CONF_OPTS=(--prefix="$PHP_DIR" --with-openssl --with-zlib)
        if [[ "$OS_TYPE" == "macos" ]] && has_cmd brew && brew --prefix libiconv >/dev/null 2>&1; then
            CONF_OPTS+=("--with-iconv=$(brew --prefix libiconv)")
        fi
        ./configure "${CONF_OPTS[@]}"
        make -j"$CPU_CORES"
        make install
    )

    PHP_BIN="$PHP_DIR/bin/php"
    (
        cd "$PACKAGES_DIR"
        EXPECTED_CHECKSUM="$("$PHP_BIN" -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        "$PHP_BIN" -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_CHECKSUM="$("$PHP_BIN" -r "echo hash_file('sha384', 'composer-setup.php');")"
        if [[ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]]; then
            rm -f composer-setup.php
            abort "ERROR: Invalid Composer installer checksum"
        fi
        "$PHP_BIN" composer-setup.php --quiet
        rm -f composer-setup.php
        mv composer.phar "$PHP_DIR/bin/composer"
    )

    append_rc_once "tools/php/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/php/bin"
EOT
else
    info_skip "PHP & Composer"
fi
