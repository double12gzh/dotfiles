#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config.sh"

######################################################################
#                              Fzf Part                              #
######################################################################
FZF_DIR="$TOOLS_DIR/fzf"
FZF_LINK="https://github.com/junegunn/fzf.git"

if ! has_cmd fzf && [[ ! -x "$FZF_DIR/bin/fzf" ]]; then
    info_install "fzf"
    if [[ ! -d "$FZF_DIR/.git" ]]; then
        rm -rf "$FZF_DIR"
        git clone --depth=1 "$FZF_LINK" "$FZF_DIR"
    fi
    (
        cd "$FZF_DIR"
        ./install --bin --xdg --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish
    )

    append_rc_once "tools/fzf/bin" <<'EOT'
export FZF_DEFAULT_OPTS='--ansi --height 40% --layout=reverse --border=double --border-label="╣ FZF ╠" --preview-label="┓ ⟪Preview⟫ ┏" --preview-window=right,border-bold --color=border:#7ba46c,label:#7ba46c'
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
export FZF_ALT_C_COMMAND='fd -H --type d . --color=never'
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS"
export PATH="$PATH:$HOME/tools/fzf/bin"
EOT
else
    info_skip "Fzf"
fi
