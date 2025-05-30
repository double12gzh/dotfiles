#!/usr/bin/zsh

# Add Homebrew bin to PATH on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# for profiling zsh
# https://unix.stackexchange.com/a/329719/27109
#
#zmodload zsh/zprof

# https://blog.patshead.com/2011/04/improve-your-oh-my-zsh-startup-time-maybe.html
skip_global_compinit=1

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt extendedglob nomatch notify
unsetopt autocd beep
setopt extended_history
# 可选：实时追加历史记录（而不是退出时写入）
setopt inc_append_history
# 可选：共享不同终端间的历史记录
setopt share_history
setopt hist_ignore_dups
bindkey -v
# End of lines configured by zsh-newuser-install

# Begin speedup zsh
# https://carlosbecker.com/posts/speeding-up-zsh/
# https://htr3n.github.io/2018/07/faster-zsh/
# https://github.com/htr3n/zsh-config
# https://github.com/mattmc3/zdotdir
# https://gist.github.com/ctechols/ca1035271ad134841284
# https://github.com/sorin-ionescu/prezto/blob/e149367445d2bcb9faa6ada365dfd56efec39de8/modules/completion/init.zsh#L34
zstyle :compinstall filename "$HOME/.zshrc"                                                                                                                      
fpath[1,0]=~/.zsh/completion/ # local comp files                                                                                                                 
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]];then
    compinit 
else
    compinit -C;                                                                                                          
fi 
# End speedup zsh

# XDG PATH
export XDG_CONFIG_HOME="$HOME/.config"

# Program languages PATH
path=(~/tools/golang/bin $path)
path=(~/go/bin $path)
path=(~/tools/java/bin $path)
path=(~/tools/julia/bin $path)
path=(~/tools/lua/src $path)
path=(~/tools/luajit/src $path)
export LUA_LIBRARY="$HOME/tools/luajit/src/libluajit.so"
path=(~/tools/luarocks $path)
path=(~/tools/nodejs/bin $path)
path=(~/tools/perl/bin $path)
export PERL_CPANM_HOME="$HOME/tools/cpanm"
path=(~/tools/php/bin $path)
path=(~/tools/ruby/bin $path)
[ -f ~/.cargo/env ] && source "$HOME/.cargo/env"

# Utility tools PATH
path=(~/.local/bin $path)
path=(~/tools/btop/bin $path)
path=(~/tools/cpufetch $path)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'
export FZF_DEFAULT_OPTS='--ansi --height 40% --layout=reverse --border=double --border-label="╣ FZF ╠" --header="E to edit" --preview="pistol {}" --bind="E:execute(nvim {})" --preview-label="┓ ⟪Preview⟫ ┏" --preview-window=right,border-bold --color=border:#7ba46c,label:#7ba46c'
export FZF_CTRL_T_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS='--height 40% --layout=reverse --border=double --border-label="╣ History ╠" --preview-window=hidden --no-preview'
export FZF_ALT_C_COMMAND='fd -H --type d . --color=never'
export FZF_ALT_T_OPTS="$FZF_DEFAULT_OPTS"
path=(~/tools/fzf/bin $path)
path=(~/tools/fzy $path)
path=(~/tools/jq $path)
path=(~/tools/lnav $path)
path=(~/tools/nvim/bin $path)
path=(~/tools/stow/bin $path)
path=(~/tools/tmux $path)
path=(~/tools/treesitter $path)
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
path=(~/tools/ugrep/bin $path)
path=(~/tools/qfc/bin $path)
[ -f ~/.config/lf/icon.sh ] && source "$HOME/.config/lf/icon.sh"
export PISTOL_CHROMA_FORMATTER=terminal16m
export PISTOL_CHROMA_STYLE=monokai

# Batcat for man & help
if compgen -G "/etc/*-release" > /dev/null 2>&1; then
    _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }' | tr -d '"')
    if [ "$_distro" = "void" ]; then
        export MANPAGER="batman"
    else
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    fi
else
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# usage: `help git`, `help git commit`, `help bat -h`
alias bathelp='bat --plain --language=cmd-help'
help() (
    set -o pipefail
    "$@" --help 2>&1 | bathelp
)

## neovim support
export EDITOR='nvim'
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

## Truecolor support
# NOTE: https://github.com/termstandard/colors
# Don't change $TERM in your zshrc/bashrc!
# Setting $TERM in zshrc/bashrc add confusions when your terminal emulators cannot actually supoorts it.
case $TERM in screen-256color | tmux-256color | xterm-256color)
        # COLORTERM opts:no|yes|truecolor
        export COLORTERM=truecolor
        ;;
    vte*) ;;
esac

# Init zoxide
# [ -x ~/tools/zoxide/zoxide ] && eval "$(zoxide init zsh)" || echo "zoxide not found!"
eval "$(zoxide init zsh)" || echo "zoxide not found!"

# Init Starship
# [ -x ~/tools/starship/starship ] && eval "$(starship init zsh)" || echo "starship not found!"]
eval "$(starship init zsh)" || echo "starship not found!"

# Init direnv
# eval "$(direnv hook zsh)"

# Init shelden
# [ -x  ~/tools/sheldon/sheldon ] && eval "$(sheldon source)" || echo "sheldon not found!"
# eval "$(sheldon source)" || echo "sheldon not found!"
#bindkey '^[[a' history-substring-search-up
#bindkey '^[[b' history-substring-search-down
#bindkey ',' autosuggest-accept

# Init qfc
[[ -s $HOME/tools/qfc/bin/qfc.sh ]] && source "$HOME/tools/qfc/bin/qfc.sh"
qfc_quick_command 'cd' '\C-b' "cd $0"
qfc_quick_command 'nvim' '\C-p' "nvim $0"

# >>> conda initialize >>>
if [ -f $HOME/tools/anaconda/etc/profile.d/conda.sh ]; then
    source "$HOME/tools/anaconda/etc/profile.d/conda.sh"
else
    path=(~/tools/anaconda/bin $path)
fi
path=($HOME/tools/anaconda/bin $path)
export CONDA_PREFIX=$HOME/tools/anaconda
# <<< conda initialize <<<

# Fcitx5 env
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT5_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Custom env and aliases
[[ -f ~/.zsh/zinit.zsh ]] && source ~/.zsh/zinit.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/keybind.zsh ]] && source ~/.zsh/keybind.zsh
[[ -f ~/.zsh/starship.zsh ]] && source ~/.zsh/starship.zsh
[[ -f ~/.zsh/fzf-tab.zsh ]] && source ~/.zsh/fzf-tab.zsh
[[ -f ~/.zsh/wsl2fix.zsh ]] && source ~/.zsh/wsl2fix.zsh
[[ -f ~/.zsh/ssh_menu.zsh ]] && source ~/.zsh/ssh_menu.zsh
#[[ -f ~/.zsh/zplug.zsh ]] && source ~/.zsh/zplug.zsh
# [[ -f ~/.zsh/proxies.zsh ]] && source ~/.zsh/proxies.zsh
# [[ -f ~/.bash/wayland.zsh ]] && source ~/.zsh/wayland.zsh

[[ -f ~/.local_aliases.zsh ]] && source ~/.local_aliases.zsh
