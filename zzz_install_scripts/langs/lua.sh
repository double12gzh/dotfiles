#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                    Lua/LuaJIT/Luarocks Install                     #
######################################################################
LUA_VERSION="5.4.7"
LUA_DIR="$TOOLS_DIR/lua"
LUA_SRC_NAME="$PACKAGES_DIR/lua-${LUA_VERSION}.tar.gz"
LUA_LINK="https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"

if ! has_cmd lua && [[ ! -x "$LUA_DIR/src/lua" ]]; then
    info_install "Lua (${LUA_VERSION})"
    download_file "$LUA_LINK" "$LUA_SRC_NAME"
    extract_archive "$LUA_SRC_NAME" "$LUA_DIR" 1
    (
        cd "$LUA_DIR"
        make -j"$CPU_CORES" all
        make test
    )
    append_rc_once "tools/lua/src" <<'EOT'
export PATH="$PATH:$HOME/tools/lua/src"
EOT
else
    info_skip "Lua"
fi

LUAJIT_VERSION="2.1"
LUAJIT_DIR="$TOOLS_DIR/luajit"
LUAJIT_LINK="https://github.com/LuaJIT/LuaJIT.git"
if ! has_cmd luajit && [[ ! -x "$LUAJIT_DIR/src/luajit" ]]; then
    info_install "LuaJIT (${LUAJIT_VERSION})"
    rm -rf "$LUAJIT_DIR"
    git clone --depth=1 -b v2.1 "$LUAJIT_LINK" "$LUAJIT_DIR"
    (
        cd "$LUAJIT_DIR"
        if [[ "$OS_TYPE" == "macos" ]]; then
            export MACOSX_DEPLOYMENT_TARGET
            MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion | cut -d. -f1-2)"
        fi
        make -j"$CPU_CORES"
    )
    append_rc_once "tools/luajit/src" <<'EOT'
export PATH="$PATH:$HOME/tools/luajit/src"
export LUA_LIBRARY="$HOME/tools/luajit/src/libluajit.so"
EOT
else
    info_skip "LuaJIT"
fi

LUAROCKS_VERSION="3.11.1"
LUAROCKS_DIR="$TOOLS_DIR/luarocks"
LUAROCKS_SRC_NAME="$PACKAGES_DIR/luarocks-${LUAROCKS_VERSION}.tar.gz"
LUAROCKS_LINK="https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz"
if ! has_cmd luarocks && [[ ! -x "$LUAROCKS_DIR/luarocks" && ! -x "$LUAROCKS_DIR/bin/luarocks" ]]; then
    info_install "Luarocks (${LUAROCKS_VERSION})"
    download_file "$LUAROCKS_LINK" "$LUAROCKS_SRC_NAME"
    extract_archive "$LUAROCKS_SRC_NAME" "$LUAROCKS_DIR" 1
    (
        cd "$LUAROCKS_DIR"
        export PATH="$LUA_DIR/src:$PATH"
        ./configure --prefix="$LUAROCKS_DIR" --lua-version=5.4 --with-lua-include="$LUA_DIR/src"
        make -j"$CPU_CORES"
        make install
    )
    append_rc_once "tools/luarocks" <<'EOT'
export PATH="$PATH:$HOME/tools/luarocks/bin:$HOME/tools/luarocks"
EOT
else
    info_skip "Luarocks"
fi
