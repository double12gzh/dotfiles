#!/usr/bin/env bash
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

# ogham/exa 已停更归档，升级为其现代维护继任版 eza
install_cargo_pkg eza eza --locked
