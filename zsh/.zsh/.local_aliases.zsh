#!/bin/zsh

alias jm='expect $HOME/.auto_login {username} {hostip} {passwd}'
alias prem='jm {username}@{hostip} "{password}"'

# 替换 jmpserver_ip, jmpserver_passwd, remote_passwd, username 为实际的值
alias k8s='server_me="$(\cat $HOME/.zsh/sshs/hosts/k8s | fzf)" && $HOME/.auto_login root {jmpserver_ip} {jmpserver_passwd} "-p10000 {username}@$server_me" {remote_passwd}'
## cat  ~/.zsh/sshs/hosts/k8s
##  ===========deploy-registry
##  1.2.3.4
##  ===========worker-0003
##  1.2.3.5

alias example='mycolorfulssh example'

proxy="http://127.0.0.1:7890"
noproxy="127.0.0.1,localhost,.gitlab.centos.cn"

__setup_proxies() {
    # export {http_proxy,https_proxy,all_proxy}=$proxy

    export http_proxy="$proxy"
    export https_proxy="$proxy"
    export all_proxy="$proxy"

    export no_proxy="$noproxy"
}

__teardown_proxies() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    unset no_proxy
}

__check_proxies() {
    echo "current proxies used:"
    echo "  http_proxy:     $http_proxy"
    echo "  https_proxy:    $https_proxy"
    echo "  all_proxy:      $all_proxy"
    echo "  no_proxy:       $no_proxy"
    if [[ `uname -s` == "Darwin" ]];then
        echo "\n>>>> scutil --proxy <<<<\n"
        scutil --proxy
    fi
}

__help() {
    echo "Usage: $0 [options]"
    echo "  -s, --setup     Setup proxies"
    echo "  -d, --destroy   Teardown proxies"
    echo "  -c, --check     Check proxies status"
    echo "  -i, --ip        Check ip"
}

__ip() {
     curl cip.cc
}

cmd() {
    if [[ "$#" -eq 0 ]]; then
        __help
        return
    fi

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -s|--setup)
                __setup_proxies
                __check_proxies
                ;;
            -c|--check)
                __check_proxies
                ;;
            -i|--ip)
                __ip
                ;;
            -d|--destroy)
                __teardown_proxies
                __check_proxies
                ;;
            -h|--help)
                __help
                __check_proxies
                ;;
            *)
                __help
        esac
        shift
    done
}
