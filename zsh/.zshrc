#!/usr/bin/zsh

# for profiling zsh
# https://unix.stackexchange.com/a/329719/27109
# zmodload zsh/zprof

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt extendedglob nomatch notify
unsetopt autocd beep
setopt extended_history
# 实时追加历史记录（而不是退出时写入）
setopt inc_append_history
# 共享不同终端间的历史记录
setopt share_history
setopt hist_ignore_dups
bindkey -v
# End of lines configured by zsh-newuser-install

# Begin speedup zsh compinit (rebuild dump at most once every 24 hours)
zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"
[[ -d ${ZDOTDIR:-$HOME}/.zsh/completion ]] && fpath=(${ZDOTDIR:-$HOME}/.zsh/completion $fpath)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
# End speedup zsh

# FZF & Pistol & LF configuration
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'
export FZF_DEFAULT_OPTS='--ansi --height 40% --layout=reverse --border=double --border-label="╣ FZF ╠" --header="E to edit" --preview="pistol {}" --bind="E:execute(nvim {})" --preview-label="┓ ⟪Preview⟫ ┏" --preview-window=right,border-bold --color=border:#7ba46c,label:#7ba46c'
export FZF_CTRL_T_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS='--height 40% --layout=reverse --border=double --border-label="╣ History ╠" --preview-window=hidden --no-preview'
export FZF_ALT_C_COMMAND='fd -H --type d . --color=never'
export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS"
[[ -f ~/.config/lf/icon.sh ]] && source "$HOME/.config/lf/icon.sh"
export PISTOL_CHROMA_FORMATTER=terminal16m
export PISTOL_CHROMA_STYLE=monokai

# Batcat for man & help
if [[ "$OSTYPE" == linux* ]] && [[ -f /etc/os-release ]] && grep -qi '^ID=.*void' /etc/os-release 2>/dev/null; then
    export MANPAGER="batman"
else
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# usage: `help git`, `help git commit`, `help bat -h`
alias bathelp='bat --plain --language=cmd-help'
help() (
    set -o pipefail
    "$@" --help 2>&1 | bathelp
)

## Truecolor support
# NOTE: https://github.com/termstandard/colors
# Don't change $TERM in your zshrc/bashrc!
case $TERM in
    screen-256color | tmux-256color | xterm-256color)
        export COLORTERM=truecolor
        ;;
    vte*) ;;
esac

# Init zoxide
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# Init Starship
if [[ "$TERM" != "dumb" ]] && (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

# Init direnv
# (( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Init qfc
if [[ -s "$HOME/tools/qfc/bin/qfc.sh" ]]; then
    source "$HOME/tools/qfc/bin/qfc.sh"
    qfc_quick_command 'cd' '\C-b' "cd $0"
    qfc_quick_command 'nvim' '\C-p' "nvim $0"
fi

# >>> conda initialize (lazy load on first invocation) >>>
if [[ -f "$HOME/tools/anaconda/etc/profile.d/conda.sh" ]]; then
    conda() {
        unfunction conda
        source "$HOME/tools/anaconda/etc/profile.d/conda.sh"
        conda "$@"
    }
fi
# <<< conda initialize <<<

# Custom plugins, env, and aliases
_zsh_mod_dir="${ZDOTDIR:-$HOME}/.zsh"
[[ -f "$_zsh_mod_dir/zinit.zsh" ]] && source "$_zsh_mod_dir/zinit.zsh"
[[ -f "$_zsh_mod_dir/aliases.zsh" ]] && source "$_zsh_mod_dir/aliases.zsh"
[[ -f "$_zsh_mod_dir/keybind.zsh" ]] && source "$_zsh_mod_dir/keybind.zsh"
[[ -f "$_zsh_mod_dir/starship.zsh" ]] && source "$_zsh_mod_dir/starship.zsh"
[[ -f "$_zsh_mod_dir/fzf-tab.zsh" ]] && source "$_zsh_mod_dir/fzf-tab.zsh"
[[ -f "$_zsh_mod_dir/wsl2fix.zsh" ]] && source "$_zsh_mod_dir/wsl2fix.zsh"
[[ -f "$_zsh_mod_dir/ssh_menu.zsh" ]] && source "$_zsh_mod_dir/ssh_menu.zsh"
# [[ -f "$_zsh_mod_dir/zplug.zsh" ]] && source "$_zsh_mod_dir/zplug.zsh"
# [[ -f "$_zsh_mod_dir/proxies.zsh" ]] && source "$_zsh_mod_dir/proxies.zsh"
# [[ -f "$_zsh_mod_dir/wayland.zsh" ]] && source "$_zsh_mod_dir/wayland.zsh"

# Load all alias files from ~/.zsh/aliases/
if [[ -d "$_zsh_mod_dir/aliases" ]]; then
    for file in "$_zsh_mod_dir"/aliases/*.zsh(N); do
        [[ -f "$file" ]] && source "$file"
    done
fi
unset _zsh_mod_dir

[[ -f ~/.local_aliases.zsh ]] && source ~/.local_aliases.zsh
