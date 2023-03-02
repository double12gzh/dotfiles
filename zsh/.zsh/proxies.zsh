IP="127.0.0.1"
HTTP_PORT="52088"
SOCKS5_PORT="52088"

PROXY_HTTP="http://${IP}:${HTTP_PORT}"
PROXY_HTTP_IP="${IP}:${HTTP_PORT}"
PROXY_SOCKS5="socks5://${IP}:${SOCKS5_PORT}"
PROXY_SOCKS5_IP="${IP}:${SOCKS5_PORT}"

help_() {
    echo "Commands:"
    echo "  ip_"
    echo "  proxy_npm"
    echo "  unproxy_npm"
    echo "  proxy_git"
    echo "  proxy_global_git"
    echo "  unproxy_global_git"
    echo "  proxies"
    echo "  unproxies"
}

ip_() {
    curl cip.cc/$1
}

proxy_npm() {
    npm config set proxy ${PROXY_HTTP}
    npm config set https-proxy ${PROXY_HTTP}
    yarn config set proxy ${PROXY_HTTP}
    yarn config set https-proxy ${PROXY_HTTP}
}

unproxy_npm() {
    npm config delete proxy
    npm config delete https-proxy
    yarn config delete proxy
    yarn config delete https-proxy
}

proxy_global_git() {
    git config --global http.proxy ${PROXY_HTTP}
    git config --global https.proxy ${PROXY_HTTP}
}

unproxy_global_git() {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}

proxy_git() {
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

proxies () {
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

    proxy_git
    proxy_npm
    proxy_global_git
}

unproxies () {
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

    echo "取消proxy成功"
    echo "可以继续执行"
    echo "unproxy_npm"
    echo "unproxy_global_git"
}
