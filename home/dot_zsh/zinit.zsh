### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

#####################
# PLUGINS           #
#####################
# TAB COMPLETIONS (load first in 0a before fzf-tab)
zinit ice wait="0a" lucid blockf
zinit light zsh-users/zsh-completions

# FZF-TAB (must load after compinit/completions and before autosuggestions/syntax-highlighting)
zinit ice wait="0a" lucid
zinit light Aloxaf/fzf-tab

# AUTOSUGGESTIONS, TRIGGER PRECMD HOOK UPON LOAD
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
zinit ice wait="0b" lucid atload="_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# ENHANCD
# disable always pop-up dirs chosen
#zinit ice wait="0b" lucid
#zinit light b4b4r07/enhancd
#export ENHANCD_FILTER=fzf:fzy:peco

# HISTORY SUBSTRING SEARCHING
zinit ice wait="0b" lucid atload='
    [[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
    [[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    bindkey -M vicmd "k" history-substring-search-up
    bindkey -M vicmd "j" history-substring-search-down
'
zinit light zsh-users/zsh-history-substring-search

# FZF BINARY (only fetch from GitHub Releases if fzf is not already installed locally)
if (( ! $+commands[fzf] )); then
    zinit ice lucid wait="0c" from="gh-r" as="command"
    zinit light junegunn/fzf
fi

# FZF TMUX HELPER SCRIPT
zinit ice lucid wait="0c" as="command" id-as="junegunn/fzf-tmux" pick="bin/fzf-tmux"
zinit light junegunn/fzf

# BIND MULTIPLE WIDGETS USING FZF
zinit ice lucid wait="0c" multisrc"shell/{completion,key-bindings}.zsh" id-as="junegunn/fzf_completions" pick="/dev/null"
zinit light junegunn/fzf

# SYNTAX HIGHLIGHTING (replay compdefs without re-running full compinit)
zinit ice wait="0c" lucid atinit="zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# BAT (only fetch from GitHub Releases if bat is not already installed locally)
if (( ! $+commands[bat] )); then
    zinit ice lucid wait="0c" from="gh-r" as="program" mv="bat* -> bat" pick="bat/bat" atload="alias cat=bat"
    zinit light sharkdp/bat
fi

# BAT-EXTRAS (merge duplicate zinit ice and set aliases after scripts are added to PATH)
zinit ice lucid wait="0c" as="program" pick="src/bat*.sh" \
    atload="alias rg=batgrep.sh; alias bd=batdiff.sh; alias man=batman.sh"
zinit light eth-p/bat-extras
