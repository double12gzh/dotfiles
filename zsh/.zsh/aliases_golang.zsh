#!/usr/bin/zsh

go_test() {
    local test_path="./..."
    local cover_file="coverage.out"
    local goarch="amd64"
    local open_report=true
    local skip_race=false
    local cover_mode="atomic"
    local skip_cover=false
    local verbose=false
    local extra_args 

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--path)
                test_path="$2"
                shift 2
                ;;
            -o|--output)
                cover_file="$2"
                shift 2
                ;;
            -a|--arch)
                goarch="$2"
                shift 2
                ;;
            -m|--cover-mode)
                cover_mode="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --no-race)
                skip_race=true
                shift
                ;;
            --no-cover)
                skip_cover=true
                shift
                ;;
            --no-open)
                open_report=false
                shift
                ;;
            --)
                shift
                extra_args="$@"
                break
                ;;
            -h|--help)
                cat << EOF
用法: go_test [选项] [额外的 go test 参数...]

功能: 运行 Go 测试，支持覆盖率报告和竞态检测

选项:
  -p, --path PATH      测试路径 (默认: ./...)
  -o, --output FILE    覆盖率文件 (默认: coverage.out)
  -a, --arch ARCH      目标架构 (默认: amd64)
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
                return 0
                ;;
            *)
                # 如果参数以 - 开头，可能是未知选项
                if [[ "$1" == -* ]]; then
                    echo "错误: 未知选项 '$1'"
                    echo "使用 'go_test --help' 查看帮助"
                    return 1
                else
                    # 否则作为额外的 go test 参数
                    extra_args="$extra_args $1"
                    shift
                fi
                ;;
        esac
    done
    
    # 构建命令
    local cmd="GOARCH=$goarch go test"
    
    # 添加基础参数
    cmd="$cmd -v -count=1 -failfast"
    
    # 条件添加覆盖率
    if [[ $skip_cover != true ]]; then
        cmd="$cmd -cover -covermode=$cover_mode -coverprofile=\"$cover_file\""
    fi
    
    # 条件添加竞态检测
    if [[ $skip_race != true ]]; then
        cmd="$cmd -race"
    fi
    
    # 添加其他固定参数
    cmd="$cmd -mod=vendor"
    cmd="$cmd -gcflags='-N -l'"
    
    # 添加测试路径
    cmd="$cmd $test_path"
    
    # 添加额外参数
    if [[ -n "$extra_args" ]]; then
        cmd="$cmd $extra_args"
    fi
    
    # 显示命令
    echo "🚀 执行命令: $cmd"
    echo ""
    
    # 执行测试
    if eval $cmd; then
        local test_result=$?
        
        # 条件打开报告
        if [[ $skip_cover != true ]] && [[ $open_report == true ]]; then
            echo ""
            echo "✅ 测试通过，打开覆盖率报告..."
            go tool cover -html="$cover_file"
        elif [[ $skip_cover != true ]]; then
            echo ""
            echo "✅ 测试通过"
            echo "📊 覆盖率报告: $cover_file"
            echo "📈 查看报告: go tool cover -html=$cover_file"
            echo "📋 文本报告: go tool cover -func=$cover_file | tail -1"
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
                local cache_file="/tmp/go_test_completion_$$.txt"
                local cache_age=300  # 5分钟缓存
                
                # 检查是否有有效的缓存
                if [[ -f "$cache_file" ]] && \
                   [[ $(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || echo 0))) -lt $cache_age ]]; then
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
