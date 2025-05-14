#!/bin/zsh

alias rsync='rsync -avpgolrz --progress --partial'

alias jm='expect $HOME/.local/bin/auto_login {username} {hostip} {passwd}'
alias prem='jm {username}@{hostip} "{password}"'
alias dev="ssh -t root@x.x.x.x \"zsh -i -c 'source ~/.mysrc; exec zsh'\""

# 替换 jmpserver_ip, jmpserver_passwd, remote_passwd, username 为实际的值
alias k8s='server_me="$(\cat $HOME/.zsh/sshs/hosts/k8s | fzf)" && $HOME/.local/bin/auto_login root {jmpserver_ip} {jmpserver_passwd} "-p10000 {username}@$server_me" {remote_passwd}'
## cat  ~/.zsh/sshs/hosts/k8s
##  ===========deploy-registry
##  1.2.3.4
##  ===========worker-0003
##  1.2.3.5

# 定义别名动态更新 KUBECONFIG
if [[ -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs/k8s/kubeconfig" ]] || [[ -d "$HOME/.kube" ]]; then
    export KUBECONFIG=$(find $HOME/Library/Mobile\ Documents/com~apple~CloudDocs/k8s/kubeconfig $HOME/.kube -type f \( -name "config" -o -name "*.yaml" -o -name "*.yml" \) -print0 | xargs -0 printf "%s:" | sed 's/:$//')
fi
alias kx='kubectx'
# }}

alias example='mycolorfulssh example'

DEFAULT_NOPROXY=(
    "127.0.0.1"
    "localhost"
    "*.local"
    "169.254/16"
)
DEFAULT_PROXY_IP=192.168.175.24
DEFAULT_PROXY_PORT=7897

__setup_system_proxies() {
    local proxy_ip="${1:-$DEFAULT_PROXY_IP}"
    local proxy_port="${2:-$DEFAULT_PROXY_PORT}"

    case "$(uname -s)" in
    Darwin)
        sudo networksetup -setwebproxy "Wi-Fi" ${proxy_ip} ${proxy_port}
        sudo networksetup -setsecurewebproxy "Wi-Fi" ${proxy_ip} ${proxy_port}
        sudo networksetup -setsocksfirewallproxy "Wi-Fi" ${proxy_ip} ${proxy_port}

        sudo networksetup -setproxybypassdomains "Wi-Fi" "${DEFAULT_NOPROXY[@]}"
        ;;
    Linux)   echo "TODO";;
    *)       echo "Unknown";;
    esac
}

__teardown_system_proxies() {
    case "$(uname -s)" in
    Darwin)
        sudo networksetup -setwebproxystate "Wi-Fi" off
        sudo networksetup -setsecurewebproxystate "Wi-Fi" off
        sudo networksetup -setsocksfirewallproxystate "Wi-Fi" off
        sudo networksetup -setproxybypassdomains "Wi-Fi" ""
        ;;
    Linux)  echo "TODO";;
    *)      echo "Unknown";;
    esac
}

__setup_proxies() {
    local proxy_ip="${1:-$DEFAULT_PROXY_IP}"
    local proxy_port="${2:-$DEFAULT_PROXY_PORT}"

    export http_proxy="http://${proxy_ip}:${proxy_port}"
    export https_proxy="http://${proxy_ip}:${proxy_port}"
    export all_proxy="socks5://${proxy_ip}:${proxy_port}"

    export no_proxy=$(IFS=,; echo "${DEFAULT_NOPROXY}")
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
    echo "Usage: cmd/cmds [options] [proxy_ip] [proxy_port]"
    echo "  -p, --proxy [proxy_ip] [proxy_port]     Setup system proxies"
    echo "  -t, --teardown                          Teardown system proxies"
    echo "  -s, --setup [proxy_ip] [proxy_port]     Setup proxies ENVs"
    echo "  -d, --destroy                           Teardown proxies ENVs"
    echo "  -c, --check                             Check proxies status"
    echo "  -i, --ip                                Check ip"
    echo "  --gen-pwd [length]                      Generate random password"
    echo "  -g, --gangsters [start|stop|status|aone_status|aone_disable|aone_enable] Kill gangsters process"
}

__gansters() {
    if [ ! -z "$1" ];then
        ~/.gangsters/gangsters "$1"
    else
        __help
    fi
}

__ip() {
     curl cip.cc
}

__gen_pwd() {
    pwd_len=$1
    pwgen -s -y -1 $pwd_len 6
}

cmds() {
    cmd "$@"
}

cmd() {
    if [[ "$#" -eq 0 ]]; then
        __help
        return
    fi

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --gen-pwd)
                shift
                __gen_pwd $1
                break
                ;;
            -p|--proxy)
                shift
                __setup_system_proxies $1 $2
                __check_proxies
                break
                ;;
            -t|--teardown)
                __teardown_system_proxies
                __check_proxies
                ;;
            -s|--setup)
                shift
                __setup_proxies $1 $2
                __check_proxies
                break
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
            -g|--gangsters)
                shift
                __gansters "$1"
                break
                ;;
            *)
                __help
        esac
        shift
    done
}
