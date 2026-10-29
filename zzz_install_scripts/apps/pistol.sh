#!/usr/bin/env bash
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

# INFO: needed packages: libmagic, file, file-devel
install_go_pkg pistol github.com/doronbehar/pistol/cmd/pistol@latest
