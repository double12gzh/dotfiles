#!/bin/zsh

readonly proxy="http://127.0.0.1:7890"

__setup_proxies() {
    # export {http_proxy,https_proxy,all_proxy}=$proxy

    export http_proxy="$proxy"
    export https_proxy="$proxy"
    export all_proxy="$proxy"
}

__teardown_proxies() {
    unset $http_proxy
    unset $https_proxy
    unset $all_proxy
}

__check_proxies() {
    echo "current proxies used:"
    echo "  http_proxy:     $http_proxy"
    echo "  https_proxy:    $https_proxy"
    echo "  all_proxy:      $all_proxy"
}

__help() {
    echo "Usage: $0 [options]"
    echo "  -s, --setup     Setup proxies"
    echo "  -d, --destroy   Teardown proxies"
    echo "  -c, --check     Check proxies status"
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
