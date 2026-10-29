#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                              Qfc Part                              #
######################################################################
QFC_DIR="$TOOLS_DIR/qfc"
QFC_LINK="https://github.com/pindexis/qfc.git"

if [[ ! -d "$QFC_DIR" ]]; then
    info_install "qfc"
    git clone --depth=1 "$QFC_LINK" "$QFC_DIR"

    append_rc_once "tools/qfc/bin/qfc.sh" <<'EOT'
[[ -s "$HOME/tools/qfc/bin/qfc.sh" ]] && source "$HOME/tools/qfc/bin/qfc.sh"
qfc_quick_command 'cd' '\C-b' 'cd $0'
qfc_quick_command 'nvim' '\C-p' 'nvim $0'
EOT
else
    info_skip "Qfc"
fi
