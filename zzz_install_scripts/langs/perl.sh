#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                      Perl/Cpan/Cpanm Install                       #
######################################################################
PERL_VERSION="5.38.2"
PERL_DIR="$TOOLS_DIR/perl"
PERL_SRC_NAME="$PACKAGES_DIR/perl-${PERL_VERSION}.tar.gz"
PERL_LINK="https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz"
CPANM_DIR="$TOOLS_DIR/cpanm"

if [[ ! -x "$PERL_DIR/bin/perl" ]]; then
    info_install "Perl (${PERL_VERSION}) & cpanm"
    download_file "$PERL_LINK" "$PERL_SRC_NAME"
    mkdir -p "$CPANM_DIR"
    extract_archive "$PERL_SRC_NAME" "$PERL_DIR" 1
    (
        cd "$PERL_DIR"
        ./Configure -des -Dprefix="$PERL_DIR"
        make -j"$CPU_CORES"
        make install
        export PERL_CPANM_HOME="$CPANM_DIR"
        curl -fsSL https://cpanmin.us | "$PERL_DIR/bin/perl" - App::cpanminus
    )

    append_rc_once "tools/perl/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/perl/bin"
export PERL_CPANM_HOME="$HOME/tools/cpanm"
EOT
else
    info_skip "Perl & Cpanm"
fi
