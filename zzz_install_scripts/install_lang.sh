#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config.sh"

source "$SCRIPT_DIR/langs/conda.sh"
source "$SCRIPT_DIR/langs/golang.sh"
source "$SCRIPT_DIR/langs/java.sh"
source "$SCRIPT_DIR/langs/julia.sh"
source "$SCRIPT_DIR/langs/lua.sh"
source "$SCRIPT_DIR/langs/nodejs.sh"
source "$SCRIPT_DIR/langs/perl.sh"
#source "$SCRIPT_DIR/langs/php.sh"
source "$SCRIPT_DIR/langs/ruby.sh"
source "$SCRIPT_DIR/langs/rust.sh"

printf "\n${tty_yellow}====================Script ends====================${tty_reset}\n\n"
printf "Remember ${tty_yellow}\"source ~/.bashrc or source ~/.zshrc\"${tty_reset} to make \$PATH valid.\n"
