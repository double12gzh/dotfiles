#!/usr/bin/zsh
########################################################
# 功能说明:
#   自动扫描指定目录，将符合命名模式的 WAV 文件按前缀分组并合并
########################################################

# 显示帮助信息
_wavs_merge_help() {
    echo "用法: wavs_merge [选项]"
    echo ""
    echo "功能: 扫描目录，将符合模式的 WAV 文件自动合并"
    echo "      默认模式: '前缀_序号.wav' → '前缀_merged.wav'"
    echo ""
    echo "选项:"
    echo "  -i, --input DIR     输入目录 (默认: 当前目录)"
    echo "  -o, --output DIR    输出目录 (默认: 与输入目录相同)"
    echo "  -p, --pattern PAT   文件匹配模式 (默认: *_*.wav)"
    echo "  -l, --log-level LVL ffmpeg日志级别: quiet, error, warning, info, debug"
    echo "  -d, --delete        合并后删除原文件"
    echo "  -k, --keep-list     保留临时文件列表"
    echo "  --dry-run           试运行，显示将要执行的操作但不实际执行"
    echo "  -h, --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  wavs_merge -i ./recordings -o ./merged"
    echo "  wavs_merge -p 'sample_*.wav' -d --dry-run"
    echo "  wavs_merge -i ./sounds -l info -k"
}

# 验证参数和依赖
_wavs_merge_validate() {
    local input_dir="$1"
    local output_dir="$2"
    
    # 检查输入目录
    if [[ ! -d "$input_dir" ]]; then
        echo "❌ 错误: 输入目录 '$input_dir' 不存在" >&2
        return 1
    fi
    
    # 规范化路径
    input_dir="$(cd "$input_dir" && pwd)" || return 1
    
    # 设置输出目录
    if [[ -z "$output_dir" ]]; then
        output_dir="$input_dir"
    else
        if ! mkdir -p "$output_dir" 2>/dev/null; then
            echo "❌ 错误: 无法创建输出目录 '$output_dir'" >&2
            return 1
        fi
        output_dir="$(cd "$output_dir" && pwd)" || return 1
    fi
    
    # 检查 ffmpeg
    if ! command -v ffmpeg &> /dev/null; then
        echo "❌ 错误: 需要 ffmpeg，但未在 PATH 中找到" >&2
        echo "请安装 ffmpeg:" >&2
        echo "  macOS: brew install ffmpeg" >&2
        echo "  Ubuntu/Debian: sudo apt install ffmpeg" >&2
        echo "  CentOS/RHEL: sudo yum install ffmpeg" >&2
        return 1
    fi
    
    echo "$input_dir|$output_dir"
}

# 提取文件前缀
_wavs_merge_extract_prefixes() {
    local files=("$@")
    local prefixes=()
    
    for file in "${files[@]}"; do
        [[ "$file" =~ '_merged\.wav$' ]] && continue
        if [[ "$file" =~ '^(.+)_[0-9]+\.wav$' ]] || [[ "$file" =~ '^(.+)_[^_]+\.wav$' ]]; then
            prefixes+=("${match[1]}")
        fi
    done
    
    (( ${#prefixes[@]} > 0 )) && print -rl -- "${(u)prefixes[@]}"
}

# 处理单个前缀组
_wavs_merge_process_group() {
    local prefix="$1"
    local input_dir="$2"
    local output_dir="$3"
    local delete_origin="$4"
    local keep_list="$5"
    local log_level="$6"
    local dry_run="$7"
    
    [[ -z "$prefix" ]] && return 1
    
    # 获取文件列表
    local group_files=( ${prefix}_*.wav(nNon) )
    group_files=( "${(@)group_files:#*_merged.wav}" )
    
    if [[ ${#group_files[@]} -le 1 ]]; then
        echo "   ⚠️  跳过: $prefix ($([[ ${#group_files[@]} -eq 0 ]] && echo "无文件" || echo "只有一个文件"))"
        return 2
    fi
    
    # 确定输出文件路径
    local output_file
    if [[ "$output_dir" == "$input_dir" ]]; then
        output_file="${prefix}_merged.wav"
    else
        output_file="${output_dir}/${prefix}_merged.wav"
    fi
    
    # 检查输出文件是否已存在
    if [[ -f "$output_file" ]]; then
        echo "   ⚠️  跳过: $prefix (输出文件已存在: $(basename "$output_file"))"
        return 2
    fi
    
    echo "   📁 处理分组: $prefix"
    echo "     📄 文件: ${#group_files[@]} 个"
    
    if [[ "$dry_run" == true ]]; then
        echo "     🔍 试运行: 将创建 $output_file"
        echo "     📋 列表文件: .ffmpeg_list_${prefix}.txt"
        [[ "$delete_origin" == true ]] && echo "     🗑️  删除原文件: 是"
        echo ""
        return 0
    fi
    
    # 创建临时列表文件
    local list_file
    list_file="$(mktemp "${input_dir}/.ffmpeg_list_${prefix}.XXXXXX.txt")" || {
        echo "     ❌ 失败: 无法创建临时列表文件"
        return 1
    }
    
    # 写入文件列表
    for file in "${group_files[@]}"; do
        if [[ "$output_dir" != "$input_dir" ]]; then
            echo "file '$(realpath "$file" 2>/dev/null || echo "$file")'" >> "$list_file"
        else
            echo "file '$file'" >> "$list_file"
        fi
    done
    
    # 执行合并
    echo -n "     ⚙️  合并中..."
    if ffmpeg -loglevel "$log_level" -f concat -safe 0 -i "$list_file" \
        -c copy -y "$output_file" 2>/dev/null; then
        echo -e "\r     ✅ 完成: $(basename "$output_file")"
        
        if [[ "$delete_origin" == true ]]; then
            echo -n "     🗑️  删除原文件..."
            rm -f "${group_files[@]}"
            echo -e "\r     🗑️  删除原文件: 完成"
        fi
        
        [[ "$keep_list" == false ]] && rm -f "$list_file" || echo "     📋 保留列表文件: $list_file"
        echo ""
        return 0
    else
        echo -e "\r     ❌ 失败: $prefix 合并出错"
        rm -f "$output_file" "$list_file"
        echo ""
        return 1
    fi
}

# 显示汇总信息
_wavs_merge_summary() {
    local processed="$1"
    local skipped="$2"
    local failed="$3"
    local dry_run="$4"
    
    echo "========================================"
    echo "📊 处理完成:"
    echo "   ✅ 成功合并: $processed 个分组"
    echo "   ⚠️  跳过: $skipped 个分组"
    [[ $failed -gt 0 ]] && echo "   ❌ 失败: $failed 个分组"
    
    if [[ "$dry_run" == true ]]; then
        echo ""
        echo "💡 提示: 这是试运行模式，未实际执行任何操作"
        echo "       使用 'wavs_merge [相同参数]' (去掉 --dry-run) 来实际执行"
    fi
    echo ""
}

# 主函数
wavs_merge() {
    local input_dir="."
    local output_dir=""
    local delete_origin=false
    local keep_list=false
    local log_level="error"
    local dry_run=false
    local pattern="*_*.wav"
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input) input_dir="$2"; shift 2 ;;
            -o|--output) output_dir="$2"; shift 2 ;;
            -p|--pattern) pattern="$2"; shift 2 ;;
            -l|--log-level) log_level="$2"; shift 2 ;;
            -d|--delete) delete_origin=true; shift ;;
            -k|--keep-list) keep_list=true; shift ;;
            --dry-run) dry_run=true; shift ;;
            -h|--help) _wavs_merge_help; return 0 ;;
            -*)
                echo "错误: 未知选项 '$1'" >&2
                echo "使用 'wavs_merge --help' 查看帮助" >&2
                return 1
                ;;
            *)
                if [[ "$input_dir" == "." ]]; then
                    input_dir="$1"
                else
                    echo "错误: 未知参数 '$1'" >&2
                    echo "使用 'wavs_merge --help' 查看帮助" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # 验证参数
    local dirs
    dirs="$(_wavs_merge_validate "$input_dir" "$output_dir")" || return $?
    input_dir="${dirs%%|*}"
    output_dir="${dirs##*|}"
    
    # 执行合并
    (
        cd "$input_dir" || { echo "❌ 错误: 无法进入目录 '$input_dir'" >&2; exit 1; }
        
        echo "🔍 扫描目录: $(pwd)"
        echo "📁 输出到: $output_dir"
        echo "🔧 文件模式: $pattern"
        [[ "$dry_run" == true ]] && echo "🔍 试运行模式: 只显示将要执行的操作"
        echo ""
        
        # 查找匹配的文件
        local files=( $~pattern(N) )
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "⚠️  该目录下没有匹配模式 '$pattern' 的文件"
            exit 0
        fi
        
        echo "📊 找到 ${#files[@]} 个匹配的文件"
        
        # 提取前缀
        local prefixes=( ${(f)"$(_wavs_merge_extract_prefixes "${files[@]}")"} )
        if [[ ${#prefixes[@]} -eq 0 ]]; then
            echo "⚠️  没有找到可合并的文件组"
            exit 0
        fi
        
        echo "📋 找到 ${#prefixes[@]} 个文件组: ${prefixes[@]}"
        echo ""
        
        # 处理每个分组
        local processed=0 skipped=0 failed=0 exit_code=0
        for prefix in "${prefixes[@]}"; do
            _wavs_merge_process_group "$prefix" "$input_dir" "$output_dir" \
                "$delete_origin" "$keep_list" "$log_level" "$dry_run"
            case $? in
                0) ((processed++)) ;;
                1) ((failed++)); exit_code=1 ;;
                2) ((skipped++)) ;;
            esac
        done
        
        _wavs_merge_summary "$processed" "$skipped" "$failed" "$dry_run"
        exit $exit_code
    )
    
    return $?
}

# === 添加命令自动补全 ===
_wavs_merge_completion() {
    local -a options
    options=(
        '-i[输入目录]:目录:_files'
        '--input[输入目录]:目录:_files'
        '-o[输出目录]:目录:_files'
        '--output[输出目录]:目录:_files'
        '-p[文件匹配模式]:模式:'
        '--pattern[文件匹配模式]:模式:'
        '-l[日志级别]:级别:(quiet error warning info debug)'
        '--log-level[日志级别]:级别:(quiet error warning info debug)'
        '-d[合并后删除原文件]'
        '--delete[合并后删除原文件]'
        '-k[保留临时文件列表]'
        '--keep-list[保留临时文件列表]'
        '--dry-run[试运行模式]'
        '-h[显示帮助信息]'
        '--help[显示帮助信息]'
    )
    
    _arguments $options
}

# 注册自动补全函数（如果存在）
if type compdef &>/dev/null; then
    compdef _wavs_merge_completion wavs_merge
fi