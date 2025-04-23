#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

######################################################################
#                            Node Install                            #
######################################################################
NODE_DIR=$HOME/tools/nodejs
NODE_SRC_NAME=$HOME/packages/nodejs.tar.gz
if [[ "$OSTYPE" == "darwin"* ]]; then
    NODE_LINK="https://nodejs.org/dist/v16.16.0/node-v16.16.0-darwin-arm64.tar.xz"
else
    NODE_LINK="https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz"
fi
if [[ ! -f "$NODE_DIR/bin/node" ]]; then
    echo "Install Node.js"
    if [[ ! -f $NODE_SRC_NAME ]]; then
        echo "Downloading Node.js and renaming"
        wget $NODE_LINK -O "$NODE_SRC_NAME"
    fi

    if [[ ! -d "$NODE_DIR" ]]; then
        echo "Creating Node.js directory under tools directory"
        mkdir -p "$NODE_DIR"
        echo "Extracting to $HOME/tools/nodejs directory"
        tar xvf "$NODE_SRC_NAME" -C "$NODE_DIR" --strip-components 1
    fi

    if [[ "$ADD_TO_SYSTEM_PATH" = true ]]; then
        cat <<EOT >>"$RC_FILE"
alias node='$HOME/tools/nodejs/bin/node'
alias npm='$HOME/tools/nodejs/bin/npm'
alias npx='$HOME/tools/nodejs/bin/npx'
export PATH="$PATH:$HOME/tools/nodejs/bin"
EOT
    fi
else
    "$NODE_DIR/bin/npm" config set fund false
    printf "${tty_blue}Nodejs${tty_reset} is already installed, skip it.\n"
fi
