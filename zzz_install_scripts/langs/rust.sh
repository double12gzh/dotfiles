#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                         Rust/Cargo Install                         #
######################################################################
export PATH="$HOME/.cargo/bin:$PATH"

if ! has_cmd cargo; then
    info_install "Rust & Cargo (via rustup)"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

    append_rc_once ".cargo/env" <<'EOT'
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
EOT
else
    info_skip "Rust & Cargo"
fi

export PATH="$HOME/.cargo/bin:$PATH"
