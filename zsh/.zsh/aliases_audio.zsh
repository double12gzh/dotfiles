#!/usr/bin/zsh

# === WAV 批量合并工具 ===
wavs_merge() {
    # --- 默认参数 ---
    local input_dir="."          # 输入目录，默认为当前目录
    local output_dir=""          # 输出目录，空表示使用输入目录
    local delete_origin=false    # 是否删除原文件
    local keep_list=false        # 是否保留临时列表文件
    local log_level="error"      # ffmpeg日志级别: quiet, error, warning, info, debug
    local dry_run=false          # 试运行，不实际执行合并
    local pattern="*_*.wav"      # 文件匹配模式
    
    # --- 解析参数 ---
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--input)
                input_dir="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -p|--pattern)
                pattern="$2"
                shift 2
                ;;
            -l|--log-level)
                log_level="$2"
                shift 2
                ;;
            -d|--delete)
                delete_origin=true
                shift
                ;;
            -k|--keep-list)
                keep_list=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -h|--help)
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
                return 0
                ;;
            *)
                # 如果第一个参数不是选项，则认为是输入目录
                if [[ -z "$input_dir" || "$input_dir" == "." ]]; then
                    input_dir="$1"
                else
                    echo "错误: 未知参数 '$1'"
                    echo "使用 'wavs_merge --help' 查看帮助"
                    return 1
                fi
                shift
                ;;
        esac
    done
    
    # --- 参数验证和处理 ---
    
    # 检查输入目录
    if [[ ! -d "$input_dir" ]]; then
        echo "❌ 错误: 输入目录 '$input_dir' 不存在"
        return 1
    fi
    
    # 设置输出目录（如果未指定则使用输入目录）
    if [[ -z "$output_dir" ]]; then
        output_dir="$input_dir"
    else
        # 创建输出目录（如果不存在）
        mkdir -p "$output_dir"
        if [[ $? -ne 0 ]]; then
            echo "❌ 错误: 无法创建输出目录 '$output_dir'"
            return 1
        fi
    fi
    
    # 检查ffmpeg是否可用
    if ! command -v ffmpeg &> /dev/null; then
        echo "❌ 错误: 需要 ffmpeg，但未在 PATH 中找到"
        echo "请安装 ffmpeg:"
        echo "  macOS: brew install ffmpeg"
        echo "  Ubuntu/Debian: sudo apt install ffmpeg"
        echo "  CentOS/RHEL: sudo yum install ffmpeg"
        return 1
    fi
    
    # --- 核心逻辑 ---
    (
        cd "$input_dir" || {
            echo "❌ 错误: 无法进入目录 '$input_dir'"
            return 1
        }
        
        echo "🔍 扫描目录: $(pwd)"
        echo "📁 输出到: $output_dir"
        echo "🔧 文件模式: $pattern"
        [[ "$dry_run" == true ]] && echo "🔍 试运行模式: 只显示将要执行的操作"
        echo ""
        
        # 检查是否有匹配的文件
        local files=( $~pattern )
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "⚠️  该目录下没有匹配模式 '$pattern' 的文件"
            return 0
        fi
        
        echo "📊 找到 ${#files[@]} 个匹配的文件"
        
        # 提取前缀分组
        local prefixes=()
        for file in "${files[@]}"; do
            if [[ "$file" =~ '^(.+)_[^_]+\.wav$' ]]; then
                prefixes+=("${match[1]}")
            elif [[ "$file" =~ '^(.+)_merged\.wav$' ]]; then
                echo "   ⚠️  跳过已合并文件: $file"
            else
                echo "   ⚠️  跳过不符合命名规则的文件: $file"
            fi
        done
        
        prefixes=(${(u)prefixes})  # 去重
        
        if [[ ${#prefixes[@]} -eq 0 ]]; then
            echo "⚠️  没有找到可合并的文件组"
            return 0
        fi
        
        echo "📋 找到 ${#prefixes[@]} 个文件组: ${prefixes[@]}"
        echo ""
        
        # 处理每个前缀组
        local processed_count=0
        local skipped_count=0
        local failed_count=0
        
        for prefix in "${prefixes[@]}"; do
            # 跳过空行或已合并文件
            if [[ -z "$prefix" ]] || [[ "$prefix" == *"_merged" ]]; then
                continue
            fi
            
            # 获取该前缀的所有文件（自然排序）
            local group_files=($(ls -v ${prefix}_*.wav 2>/dev/null))
            
            if [[ ${#group_files[@]} -eq 0 ]]; then
                echo "   ⚠️  跳过: $prefix (无文件)"
                ((skipped_count++))
                continue
            fi
            
            if [[ ${#group_files[@]} -eq 1 ]]; then
                echo "   ⚠️  跳过: $prefix (只有一个文件)"
                ((skipped_count++))
                continue
            fi
            
            local output_file="${output_dir}/${prefix}_merged.wav"
            
            # 检查输出文件是否已存在
            if [[ -f "$output_file" ]]; then
                echo "   ⚠️  跳过: $prefix (输出文件已存在: $(basename "$output_file"))"
                ((skipped_count++))
                continue
            fi
            
            echo "   📁 处理分组: $prefix"
            echo "     📄 文件: ${#group_files[@]} 个"
            
            if [[ "$dry_run" == true ]]; then
                echo "     🔍 试运行: 将创建 $output_file"
                echo "     📋 列表文件: .ffmpeg_list_${prefix}.txt"
                if [[ "$delete_origin" == true ]]; then
                    echo "     🗑️  删除原文件: 是"
                fi
                echo ""
                ((processed_count++))
                continue
            fi
            
            # 创建临时列表文件
            local list_file=".ffmpeg_list_${prefix}.txt"
            rm -f "$list_file"
            
            for file in "${group_files[@]}"; do
                echo "file '$file'" >> "$list_file"
            done
            
            # 执行合并
            echo -n "     ⚙️  合并中..."
            
            if ffmpeg -f concat -safe 0 -i "$list_file" -c copy "$output_file" \
                -y -loglevel "$log_level" 2>/dev/null; then
                echo -e "\r     ✅ 完成: $(basename "$output_file")"
                
                # 删除原文件（如果启用）
                if [[ "$delete_origin" == true ]]; then
                    echo -n "     🗑️  删除原文件..."
                    rm -f "${group_files[@]}"
                    echo -e "\r     🗑️  删除原文件: 完成"
                fi
                
                ((processed_count++))
            else
                echo -e "\r     ❌ 失败: $prefix 合并出错"
                rm -f "$output_file"
                ((failed_count++))
            fi
            
            # 清理临时文件
            if [[ "$keep_list" == false ]]; then
                rm -f "$list_file"
            else
                echo "     📋 保留列表文件: $list_file"
            fi
            
            echo ""
        done
        
        # --- 清理和汇总 ---
        echo "========================================"
        echo "📊 处理完成:"
        echo "   ✅ 成功合并: $processed_count 个分组"
        echo "   ⚠️  跳过: $skipped_count 个分组"
        if [[ $failed_count -gt 0 ]]; then
            echo "   ❌ 失败: $failed_count 个分组"
        fi
        
        if [[ "$dry_run" == true ]]; then
            echo ""
            echo "💡 提示: 这是试运行模式，未实际执行任何操作"
            echo "       使用 'wavs_merge [相同参数]' (去掉 --dry-run) 来实际执行"
        fi
        
        echo ""
    )
    
    # 返回子shell的退出状态
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