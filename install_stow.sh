#!/bin/bash

# NOTE: make sure perl is installed
# NOTE: also, cpanm install Test::Output and Test::More

STOW_DIR=$HOME/tools/stow
STOW_SRC_NAME=$HOME/packages/stow.tar.gz
STOW_LINK="https://ftp.gnu.org/gnu/stow/stow-2.3.1.tar.gz"

if [[ ! -d "$HOME/packages" ]]; then
    mkdir -p "$HOME/packages"
fi

if [[ -z "$(command -v stow)" ]]; then
    echo "Install GNU stow"
    if [[ ! -f $STOW_SRC_NAME ]]; then
        echo "Downloading stow and renaming"
        wget $STOW_LINK -O "$STOW_SRC_NAME"
    fi

    if [[ ! -d "$STOW_DIR" ]]; then
        echo "Creating stow directory under tools directory"
        mkdir -p "$STOW_DIR"

        echo "Assign perl location"
        export PERL_PREFIX="/usr/local/lib/x86_64-linux-gnu/perl/5.30.0"
        #export PERL_PREFIX="$HOME/.plenv/versions/5.30.0"

        echo "Extracting to $HOME/tools/stow directory"
        cd "$STOW_DIR" && tar -zxvf "$STOW_SRC_NAME" -C "$STOW_DIR" --strip-components 1
        ./configure --prefix="$PERL_PREFIX" && make && make install
    fi

    if [[ "$ADD_TO_SYSTEM_PATH" = true ]] && [[ "$USE_BASH_SHELL" = true ]]; then
        echo "export PATH=\"$STOW_DIR/bin:\$PATH\"" >>"$HOME/.bashrc"
        export PATH="$STOW_DIR/bin:$PATH"
    fi

    echo "add the following to your .bashrc"
    echo 'export PATH="$HOME/tools/stow/bin":$PATH'
else
    echo "GNU stow is already installed. Skip installing it."
fi
