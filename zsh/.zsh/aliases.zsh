#!/usr/bin/zsh

# Alias
alias sozsh='source ~/.zshenv && source ~/.zshrc'
alias nvzsh='nvim ~/.zshrc'
alias nv='nvim'
alias cat='bat'  # wrapper for bat
alias py='python'
alias nvf='nvim `fzf`'
alias ls='ls --color=auto'
alias l='exa -l'
alias lt='exa -l -T'
alias ll='exa -1 -l -T -F --colour always --icons -a -L=1 \
    --group-directories-first -b -h --git --time-style long-iso --no-permissions --octal-permissions'
#alias rm='trash' # mv to trash bin
alias lg='lazygit'
alias CA='conda activate'
alias CD='conda deactivate'
alias tb='tensorboard --logdir'
[[ $TMUX != "" ]] && export TERM="tmux-256color"
alias tmux="~/tools/tmux/tmux -f ~/.config/tmux/tmux.conf"

# upgrep Alias
alias uq='ug -Q'  # short & quick query TUI (interactive, uses .ugrep config)
alias ux='ug -UX' # short & quick binary pattern search (uses .ugrep config)
alias uz='ug -z'  # short & quick compressed files and archives search (uses .ugrep config)

alias ugit='ug -R --ignore-files' # works like git-grep & define your preferences in .ugrep config

alias grep='ugrep -G'  # search with basic regular expressions (BRE)
alias egrep='ugrep -E' # search with extended regular expressions (ERE)
alias fgrep='ugrep -F' # find string(s)
alias pgrep='ugrep -P' # search with Perl regular expressions
alias xgrep='ugrep -W' # search (ERE) and output text or hex for binary

alias zgrep='ugrep -zG'  # search compressed files and archives with BRE
alias zegrep='ugrep -zE' # search compressed files and archives with ERE
alias zfgrep='ugrep -zF' # find string(s) in compressed files and/or archives
alias zpgrep='ugrep -zP' # search compressed files and archives with Perl regular expressions
alias zxgrep='ugrep -zW' # search (ERE) compressed files/archives and output text or hex for binary

alias xdump='ugrep -X ""' # hexdump files without searching

alias sshh='server_me="$(cat $HOME/.zsh/sshs/hosts/host_lists | fzf)" && ssh root@$server_me'
alias vimz='vim $(fzf --height=100% --layout=reverse --info=inline --border --margin=1 --padding=1 --preview-window "70%,wrap" --preview "bat --color=always --style=numbers --line-range=:500 {}")'
alias f='fzf --bind "enter:execute:vim {}" --height=100% --layout=reverse --info=inline --border --margin=1 --padding=1 --preview-window "70%,wrap" --preview "bat --color=always --style=numbers --line-range=:500 {}"'

alias cdh='cd /home/AFiles'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
#alias grep='grep --color=auto'
#alias fgrep='fgrep --color=auto'
#alias egrep='egrep --color=auto'
alias ccat='highlight --line-numbers -O ansi --force'
alias tp='tmuxp load ~/.config/tmuxp/tmuxp.yaml'
alias tpr='export TERM=xterm && tmuxp load ~/.config/tmuxp/tmuxp.yaml'
alias expect='export LC_CTYPE=en_US && expect'

alias p="BAT_THEME=GitHub fzf --height=100% --info=right --border=thinblock --preview-window=border-thinblock \
    --margin=3 --scrollbar=▏▕ --preview='bat --color=always --style=numbers {}' --preview-window "90%,wrap" \
    --color=light,query:238,fg:238,bg:251,bg+:249,gutter:251,border:248,preview-bg:253"
