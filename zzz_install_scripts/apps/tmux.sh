#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                             Tmux Part                              #
######################################################################
TMUX_VERSION="3.5a"
TMUX_DIR="$TOOLS_DIR/tmux"
TMUX_SRC_NAME="$PACKAGES_DIR/tmux-${TMUX_VERSION}.tar.gz"
TMUX_LINK="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"

if ! has_cmd tmux && [[ ! -x "$TMUX_DIR/bin/tmux" && ! -x "$TMUX_DIR/tmux" ]]; then
    info_install "tmux (${TMUX_VERSION})"
    download_file "$TMUX_LINK" "$TMUX_SRC_NAME"
    extract_archive "$TMUX_SRC_NAME" "$TMUX_DIR" 1
    (
        cd "$TMUX_DIR"
        CONF_ARGS=(--prefix="$TMUX_DIR")
        CPPFLAGS_VAL=""
        LDFLAGS_VAL=""

        if [[ "$OS_TYPE" == "macos" ]] && has_cmd brew; then
            if brew --prefix utf8proc >/dev/null 2>&1; then
                utf8proc_prefix="$(brew --prefix utf8proc)"
                CONF_ARGS+=(--enable-utf8proc)
                CPPFLAGS_VAL+=" -I${utf8proc_prefix}/include"
                LDFLAGS_VAL+=" -L${utf8proc_prefix}/lib"
            fi
            if brew --prefix libevent >/dev/null 2>&1; then
                libevent_prefix="$(brew --prefix libevent)"
                CPPFLAGS_VAL+=" -I${libevent_prefix}/include"
                LDFLAGS_VAL+=" -L${libevent_prefix}/lib"
            fi
            if brew --prefix ncurses >/dev/null 2>&1; then
                ncurses_prefix="$(brew --prefix ncurses)"
                CPPFLAGS_VAL+=" -I${ncurses_prefix}/include"
                LDFLAGS_VAL+=" -L${ncurses_prefix}/lib"
            fi
        fi

        ./configure "${CONF_ARGS[@]}" \
            ${CPPFLAGS_VAL:+CPPFLAGS="${CPPFLAGS_VAL# }"} \
            ${LDFLAGS_VAL:+LDFLAGS="${LDFLAGS_VAL# }"}
        make -j"$CPU_CORES"
        make install
    )

    append_rc_once "tools/tmux/bin" <<'EOT'
export PATH="$PATH:$HOME/tools/tmux/bin:$HOME/tools/tmux"
EOT
else
    info_skip "Tmux"
fi

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    info_install "tmux plugin manager (tpm)"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
