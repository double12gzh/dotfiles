export ZSH="/root/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(
 git extract last-working-dir zsh-autosuggestions
 wd #zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

umask 0022
export DISPLAY=localhost:0.0

eval $(dircolors -b $HOME/.dircolors)
eval "$(direnv hook zsh)"

export PATH=/root/anaconda3/bin:$PATH
umask 0022

export DISPLAY=localhost:0.0
export JAVA_HOME=/opt/jdk1.8.0_231
export PATH=$JAVA_HOME/bin:$PATH

[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u
unsetopt BG_NICE

alias vimz='vim $(fzf --height=100% --layout=reverse --info=inline --border --margin=1 --padding=1 --preview-window "70%,wrap" --preview "bat --color=always --style=numbers
--line-range=:500 {}")'
# --bind "enter:execute:vim {}" 用 vim 打开选中的文件并出退出后，仍然保持 fzf 搜索历史框
alias f='fzf --bind "enter:execute:vim {}" --height=100% --layout=reverse --info=inline --border --margin=1 --padding=1 --preview-window "70%,wrap" --preview "bat --color=always --style=numbers --line-ra
nge=:500 {}"'
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ccat='highlight -O ansi --force'
alias tp='tmuxp load /root/.tmuxp.yaml'
alias sshList='server_me="$(cat /root/host_lists | fzf)" && ssh root@$server_me'

PROMPT="%B%F{2}[%f%b%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{yellow}%m%f%b%B%F{yellow} %f%b%B%F{green}%~%f%b%B%F{green}]%f%b "

export GOPATH=/root/.go
export GOROOT=/usr/local/go
export GOPROXY=http://goproxy.cn
export GO111MODULE=on
export PATH=/usr/local/go/bin:/root/.go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export FZF_DEFAULT_COMMAND='rg'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
export DISABLE_AUTO_TITLE='true'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
export BAT_THEME=grubbox-dark
