#!/bin/zsh

readonly IP="127.0.0.1"
readonly HTTP_PORT="7890"
readonly SOCKS5_PORT="7890"

PROXY_HTTP="http://${IP}:${HTTP_PORT}"
PROXY_HTTP_IP="${IP}:${HTTP_PORT}"
PROXY_SOCKS5="socks5://${IP}:${SOCKS5_PORT}"
PROXY_SOCKS5_IP="${IP}:${SOCKS5_PORT}"

__check_proxies() {
    git_http_proxy=$(git config --global --get http.proxy)
    git_https_proxy=$(git config --global --get https.proxy)

    echo "current proxies used:"
    echo "      http_proxy:             $http_proxy"
    echo "      https_proxy:            $https_proxy"
    echo "      all_proxy:              $all_proxy"
    echo "      ftp_proxy:              $ftp_proxy"
    echo "      rsync_proxy:            $rsync_proxy"
    echo "      git__http_proxy:        $git_http_proxy"
    echo "      git_https_proxy:        $git_https_proxy"
}

__help() {
    echo "Usage: $0 [options]"
    echo "  -s, --setup     Setup proxies"
    echo "  -d, --destroy   Teardown proxies"
    echo "  -c, --check     Check proxies status"
}


help_() {
    echo "Commands:"
    echo "  ip_"
    echo "  proxy_npm"
    echo "  unproxy_npm"
    echo "  proxy_git"
    echo "  proxy_global_git"
    echo "  unproxy_global_git"
    echo "  proxies"
}

ip_() {
    curl cip.cc/$1
}

check_proxy_() {
    curl --head www.google.com
}

proxy_npm_() {
    npm config set proxy ${PROXY_HTTP}
    npm config set https-proxy ${PROXY_HTTP}
    yarn config set proxy ${PROXY_HTTP}
    yarn config set https-proxy ${PROXY_HTTP}
}

unproxy_npm_() {
    npm config delete proxy
    npm config delete https-proxy
    yarn config delete proxy
    yarn config delete https-proxy
}

proxy_global_git_() {
    git config --global http.proxy ${PROXY_HTTP}
    git config --global https.proxy ${PROXY_HTTP}
}

unproxy_global_git_() {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}

proxy_git_() {
    git config --global http.https://github.com.proxy ${PROXY_HTTP}
    if ! grep -qF "Host github.com" ~/.ssh/config ; then
        echo "" >> ~/.ssh/config
        echo "Host github.com" >> ~/.ssh/config
        echo "    User git" >> ~/.ssh/config
        echo "    ProxyCommand nc -X 5 -x ${PROXY_SOCKS5_IP} %h %p" >> ~/.ssh/config
    else
        lino=$(($(awk '/Host github.com/{print NR}'  ~/.ssh/config)+2))
        sed -i "${lino}c\    ProxyCommand nc -X 5 -x ${PROXY_SOCKS5_IP} %h %p" ~/.ssh/config
    fi
}

__setup_proxies() {
    # pip can read http_proxy & https_proxy
    export http_proxy="${PROXY_HTTP}"
    export HTTP_PROXY="${PROXY_HTTP}"

    export https_proxy="${PROXY_HTTP}"
    export HTTPS_proxy="${PROXY_HTTP}"

    export ftp_proxy="${PROXY_HTTP}"
    export FTP_PROXY="${PROXY_HTTP}"

    export rsync_proxy="${PROXY_HTTP}"
    export RSYNC_PROXY="${PROXY_HTTP}"

    export ALL_PROXY="${PROXY_SOCKS5}"
    export all_proxy="${PROXY_SOCKS5}"

#    proxy_git_
#    proxy_npm_
    proxy_global_git_

    sed -i "s/    # ProxyCommand nc -X 5 -x 127.0.0.1:7890 %h %p/    ProxyCommand nc -X 5 -x 127.0.0.1:7890 %h %p/g" ~/.ssh/config
}

__teardown_proxies() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset ftp_proxy
    unset FTP_PROXY
    unset rsync_proxy
    unset RSYNC_PROXY
    unset ALL_PROXY
    unset all_proxy

    unproxy_global_git_

    sed -i "s/    ProxyCommand nc -X 5 -x 127.0.0.1:7890 %h %p/    # ProxyCommand nc -X 5 -x 127.0.0.1:7890 %h %p/g" ~/.ssh/config
}

proxies() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -s|--setup)
                __setup_proxies
                __check_proxies
                ;;
            -c|--check)
                __check_proxies
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
