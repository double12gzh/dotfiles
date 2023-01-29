#!/usr/bin/zsh

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
    git extract last-working-dir zsh-autosuggestions
    wd #zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

[[ -f ~/.zshenv ]] && source ~/.zshenv
