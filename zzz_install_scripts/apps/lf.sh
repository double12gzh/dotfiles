#!/usr/bin/env bash
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

install_go_pkg lf github.com/gokcehan/lf@latest nocgo

append_rc_once ".config/lf/icon.sh" <<'EOT'
[ -f "$HOME/.config/lf/icon.sh" ] && source "$HOME/.config/lf/icon.sh"
EOT
