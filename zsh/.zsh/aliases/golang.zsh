#!/usr/bin/zsh

########################################################
# 功能说明：
#   Go 测试工具，支持覆盖率报告和竞态检测
########################################################

# 帮助信息
_go_test_help() {
    cat << EOF
用法: go_test [选项] [额外的 go test 参数...]

功能: 运行 Go 测试，支持覆盖率报告和竞态检测

选项:
  -p, --path PATH      测试路径 (默认: ./...)
  -o, --output FILE    覆盖率文件 (默认: coverage.out)
  -a, --arch ARCH      目标架构 (默认: $(go env GOARCH 2>/dev/null || echo amd64))
  -m, --cover-mode MODE
                       覆盖率模式: atomic, count, set (默认: atomic)
  -v, --verbose        显示详细输出
  --no-race            禁用竞态检测
  --no-cover           禁用覆盖率收集
  --no-open            不自动打开覆盖率报告
  --                   分隔符，后面的参数会传递给 go test
  -h, --help           显示此帮助信息

示例:
  go_test                           # 基本测试
  go_test -p ./pkg --no-race        # 测试特定包，禁用竞态检测
  go_test -o test_cov.html -v       # 详细输出，指定输出文件
  go_test -- -run TestMyFunction    # 运行特定测试函数
  go_test -m count --no-open        # 使用 count 模式，不自动打开报告

注意: 使用 '--' 分隔符可以传递额外的 go test 参数
EOF
}

# 解析命令行参数
_go_test_parse_args() {
    local -A config
    config[test_path]="./..."
    config[cover_file]="coverage.out"
    config[goarch]="$(go env GOARCH 2>/dev/null || echo amd64)"
    config[open_report]=true
    config[skip_race]=false
    config[cover_mode]="atomic"
    config[skip_cover]=false
    config[verbose]=false
    config[extra_args]=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--path)
                config[test_path]="$2"
                shift 2
                ;;
            -o|--output)
                config[cover_file]="$2"
                shift 2
                ;;
            -a|--arch)
                config[goarch]="$2"
                shift 2
                ;;
            -m|--cover-mode)
                config[cover_mode]="$2"
                shift 2
                ;;
            -v|--verbose)
                config[verbose]=true
                shift
                ;;
            --no-race)
                config[skip_race]=true
                shift
                ;;
            --no-cover)
                config[skip_cover]=true
                shift
                ;;
            --no-open)
                config[open_report]=false
                shift
                ;;
            --)
                shift
                config[extra_args]="$@"
                break
                ;;
            -h|--help)
                _go_test_help
                return 2
                ;;
            *)
                if [[ "$1" == -* ]]; then
                    echo "错误: 未知选项 '$1'"
                    echo "使用 'go_test --help' 查看帮助"
                    return 1
                else
                    config[extra_args]="${config[extra_args]} $1"
                    shift
                fi
                ;;
        esac
    done
    
    typeset -gA _go_test_config
    _go_test_config=("${(@kv)config}")
}

# 构建 go test 命令
_go_test_build_cmd() {
    local -A config
    config=("${(@kv)_go_test_config}")
    
    local cmd="GOARCH=${config[goarch]} go test"
    
    # 添加基础参数
    cmd="$cmd -count=1 -failfast"
    if [[ "${_go_test_config[verbose]}" == "true" ]]; then
        cmd="$cmd -v"
    fi
    
    # 条件添加覆盖率
    if [[ ${config[skip_cover]} != true ]]; then
        cmd="$cmd -cover -covermode=${config[cover_mode]} -coverprofile=\"${config[cover_file]}\""
    fi
    
    # 条件添加竞态检测
    if [[ ${config[skip_race]} != true ]]; then
        cmd="$cmd -race"
    fi
    
    # 添加其他固定参数
    if [[ -d "vendor" ]]; then
        cmd="$cmd -mod=vendor"
    fi
    cmd="$cmd -gcflags='-N -l'"
    
    # 添加测试路径
    cmd="$cmd ${config[test_path]}"
    
    # 添加额外参数
    if [[ -n "${config[extra_args]}" ]]; then
        cmd="$cmd ${config[extra_args]}"
    fi
    
    echo "$cmd"
}

# 执行测试并处理结果
_go_test_execute() {
    local cmd="$1"
    local -A config
    config=("${(@kv)_go_test_config}")
    
    # 显示命令
    echo "🚀 执行命令: $cmd"
    echo ""
    
    # 执行测试
    if eval $cmd; then
        local test_result=$?
        
        # 条件打开报告
        if [[ ${config[skip_cover]} != true ]] && [[ ${config[open_report]} == true ]]; then
            echo ""
            echo "✅ 测试通过，打开覆盖率报告..."
            go tool cover -html="${config[cover_file]}"
        elif [[ ${config[skip_cover]} != true ]]; then
            echo ""
            echo "✅ 测试通过"
            echo "📊 覆盖率报告: ${config[cover_file]}"
            echo "📈 查看报告: go tool cover -html=${config[cover_file]}"
            echo "📋 文本报告: go tool cover -func=${config[cover_file]} | tail -1"
        else
            echo ""
            echo "✅ 测试通过 (未收集覆盖率)"
        fi
        
        return $test_result
    else
        local test_result=$?
        echo ""
        echo "❌ 测试失败 (退出码: $test_result)"
        return $test_result
    fi
}

# 主函数
go_test() {
    # 解析参数
    _go_test_parse_args "$@"
    local parse_ret=$?
    if [[ $parse_ret -eq 2 ]]; then
        return 0
    elif [[ $parse_ret -ne 0 ]]; then
        return 1
    fi
    
    # 构建命令
    local cmd=$(_go_test_build_cmd)
    
    # 执行测试
    _go_test_execute "$cmd"
}

# === 自动补全函数 ===
_go_test() {
    local curcontext="$curcontext" state line
    typeset -A opt_args
    
    # 定义选项
    local -a options=(
        '(-p --path)'{-p,--path}'[测试路径]:路径:_path_files -/'
        '(-o --output)'{-o,--output}'[覆盖率输出文件]:文件:_files'
        '(-a --arch)'{-a,--arch}'[目标架构]:架构:(amd64 arm64 386 arm)'
        '(-m --cover-mode)'{-m,--cover-mode}'[覆盖率模式]:模式:(atomic count set)'
        '(-v --verbose)'{-v,--verbose}'[显示详细输出]'
        '(--no-race)'--no-race'[禁用竞态检测]'
        '(--no-cover)'--no-cover'[禁用覆盖率收集]'
        '(--no-open)'--no-open'[不自动打开覆盖率报告]'
        '(--)'--'[传递额外参数给 go test]'
        '(-h --help)'{-h,--help}'[显示帮助信息]'
    )
    
    # 定义参数（测试路径）
    local -a arguments
    
    # 使用 _arguments 生成补全
    _arguments -C \
        "$options[@]" \
        "*:: :->args" \
        && return
    
    # 处理额外的参数（可能是测试名称）
    case $state in
        args)
            # 如果当前词以 Test 开头，尝试补全测试函数
            if [[ ${words[CURRENT]} == Test* ]]; then
                # 获取可能的测试函数列表
                local pkg_path="./..."
                local cover_file="coverage.out"
                
                # 解析已经输入的选项，获取测试路径
                for i in {1..$((CURRENT-1))}; do
                    case ${words[i]} in
                        -p|--path)
                            pkg_path=${words[i+1]}
                            ;;
                        -o|--output)
                            cover_file=${words[i+1]}
                            ;;
                    esac
                done
                
                # 运行 go test -list 获取测试函数列表（缓存结果）
                local cache_key="${PWD//\//_}"
                local cache_file="/tmp/go_test_completion_${$$}_${cache_key}.txt"
                local cache_age=300  # 5分钟缓存
                
                # 检查是否有有效的缓存
                if [[ -f "$cache_file" ]] && \
                   [[ $(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]]; then
                    # 使用缓存
                    compadd $(cat "$cache_file")
                else
                    # 获取测试函数列表
                    echo "🔍 获取测试函数列表..." >&2
                    local test_list=$(GOARCH=amd64 go test -list ".*" "$pkg_path" 2>/dev/null | grep "^Test" | head -20)
                    
                    if [[ -n "$test_list" ]]; then
                        # 保存到缓存
                        echo "$test_list" > "$cache_file"
                        # 提供补全
                        compadd $(echo "$test_list")
                    else
                        # 如果没有获取到测试函数，使用普通文件补全
                        _files
                    fi
                fi
            else
                # 否则使用路径补全
                _alternative \
                    'packages:Go包:_go_packages' \
                    'paths:路径:_path_files -/'
            fi
            ;;
    esac
}

# === Go 包补全辅助函数 ===
_go_packages() {
    # 获取当前目录下的 Go 包
    local -a packages
    packages=($(go list ./... 2>/dev/null))
    _describe 'Go packages' packages
}

# === 注册自动补全 ===
if type compdef &>/dev/null; then
    compdef _go_test go_test
fi
