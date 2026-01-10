#!/usr/bin/env zsh
########################################################
# 功能说明：
#   音频文件播放工具，使用 ffplay 播放 WAV 和 PCM 格式的音频文件
#   支持自动检测文件类型，并提供交互式参数选择对话框
########################################################

# 帮助信息
_playpcm_help() {
    echo "用法: playpcm [选项] 文件路径
选项:
  -c, --channels <1|2>     声道数 (默认: 1)
  -f, --format <格式>      采样格式: s16le,s32le,f32le,s16be,s32be,f32be (默认: s16le)
  -r, --rate <采样率>      采样率: 16000,24000,44100,48000,96000 (默认: 48000)
  -x, --width <宽度>       窗口宽度 (默认: 800)
  -y, --height <高度>      窗口高度 (默认: 400)
  -n, --no-top             取消始终置顶
  -s, --silent             不打印执行的命令
  -t, --type <类型>        强制指定文件类型: wav,pcm,raw
  --no-dialog              禁用PCM参数选择弹窗，使用默认值
  -h, --help               显示帮助信息"
}

# 解析命令行参数
_playpcm_parse_args() {
    local -A config
    config[channels]=1
    config[format]="s16le"
    config[rate]=48000
    config[width]=800
    config[height]=400
    config[alwaysontop]="-alwaysontop"
    config[silent]=false
    config[force_type]=""
    config[pcm_file]=""
    config[channels_set]=false
    config[format_set]=false
    config[rate_set]=false
    config[no_dialog]=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--channels)
                if [[ "$2" =~ ^[12]$ ]]; then
                    config[channels]="$2"
                    config[channels_set]=true
                    shift 2
                else
                    echo "错误: 声道数必须是1或2"
                    return 1
                fi
                ;;
            -f|--format)
                case "$2" in
                    s16le|s32le|f32le|s16be|s32be|f32be)
                        config[format]="$2"
                        config[format_set]=true
                        shift 2
                        ;;
                    *)
                        echo "错误: 不支持的格式 '$2'"
                        echo "支持的格式: s16le,s32le,f32le,s16be,s32be,f32be"
                        return 1
                        ;;
                esac
                ;;
            -r|--rate)
                if [[ "$2" =~ ^(16000|24000|44100|48000|96000)$ ]]; then
                    config[rate]="$2"
                    config[rate_set]=true
                    shift 2
                else
                    echo "错误: 不支持的采样率 '$2'"
                    echo "支持的采样率: 16000,24000,44100,48000,96000"
                    return 1
                fi
                ;;
            -x|--width)
                if [[ "$2" =~ ^[0-9]+$ ]]; then
                    config[width]="$2"
                    shift 2
                else
                    echo "错误: 宽度必须是数字"
                    return 1
                fi
                ;;
            -y|--height)
                if [[ "$2" =~ ^[0-9]+$ ]]; then
                    config[height]="$2"
                    shift 2
                else
                    echo "错误: 高度必须是数字"
                    return 1
                fi
                ;;
            -n|--no-top)
                config[alwaysontop]=""
                shift
                ;;
            -s|--silent)
                config[silent]=true
                shift
                ;;
            -t|--type)
                case "$2" in
                    wav|pcm|raw)
                        config[force_type]="$2"
                        shift 2
                        ;;
                    *)
                        echo "错误: 不支持的类型 '$2'"
                        echo "支持的类型: wav, pcm, raw"
                        return 1
                        ;;
                esac
                ;;
            --no-dialog)
                config[no_dialog]=true
                shift
                ;;
            -h|--help)
                _playpcm_help
                return 0
                ;;
            -*)
                echo "错误: 未知选项 '$1'"
                _playpcm_help
                return 1
                ;;
            *)
                config[pcm_file]="$1"
                shift
                ;;
        esac
    done
    
    # 检查文件是否存在
    if [[ -z "${config[pcm_file]}" ]]; then
        echo "错误: 必须指定音频文件路径"
        _playpcm_help
        return 1
    fi
    
    if [[ ! -f "${config[pcm_file]}" ]]; then
        echo "错误: 文件 '${config[pcm_file]}' 不存在"
        return 1
    fi
    
    # 返回配置（通过全局变量）
    typeset -gA _playpcm_config
    _playpcm_config=("${(@kv)config}")
}

# 检测文件类型
_playpcm_detect_file_type() {
    local file="$1"
    local force_type="$2"
    local silent="$3"
    local file_type=""
    
    if [[ -n "$force_type" ]]; then
        file_type="$force_type"
        if [[ $silent == false ]]; then
            echo "使用用户指定的文件类型: $file_type"
        fi
    else
        if command -v file >/dev/null 2>&1; then
            local file_info=$(file -b "$file")
            if [[ $silent == false ]]; then
                echo "文件检测信息: $file_info"
            fi
            
            if [[ "$file_info" == *"WAVE audio"* ]] || \
               [[ "$file_info" == *"RIFF"* && "$file_info" == *"WAVE"* ]]; then
                file_type="wav"
            elif [[ "$file_info" == *"Audio file"* ]] || [[ "$file_info" == *"audio"* ]]; then
                file_type="audio"
            elif [[ "$file_info" == *"data"* ]] || [[ "$file_info" == *"raw"* ]]; then
                file_type="raw"
            else
                file_type="pcm"
            fi
        else
            if [[ $silent == false ]]; then
                echo "警告: 未找到 file 命令，使用文件扩展名判断类型"
            fi
            local file_ext="${file##*.}"
            file_ext="${file_ext:l}"
            
            case "$file_ext" in
                wav) file_type="wav" ;;
                pcm|raw|dat) file_type="pcm" ;;
                *)
                    file_type="pcm"
                    if [[ $silent == false ]]; then
                        echo "警告: 未知的文件扩展名 '.$file_ext'，假定为PCM格式"
                    fi
                    ;;
            esac
        fi
    fi
    
    echo "$file_type"
}

# 通过对话框选择参数
_playpcm_show_dialog() {
    local title="$1"
    local prompt="$2"
    local default="$3"
    shift 3
    local options=("$@")
    
    # 构建选项列表字符串
    local options_list=""
    for opt in "${options[@]}"; do
        options_list="${options_list}\"${opt}\", "
    done
    options_list="${options_list%, }"  # 移除最后的逗号和空格
    
    local script="tell application \"System Events\" to activate
set result to choose from list {${options_list}} with prompt \"${prompt}\" default items {\"${default}\"} with title \"${title}\"
if result is not false then
    return item 1 of result
else
    return \"cancel\"
end if"
    
    osascript -e "$script" 2>/dev/null
}

# 处理PCM参数选择
_playpcm_handle_pcm_params() {
    local -A config
    config=("${(@kv)_playpcm_config}")
    
    if [[ ${config[channels_set]} == false || \
          ${config[format_set]} == false || \
          ${config[rate_set]} == false ]]; then
        if [[ ${config[no_dialog]} == true ]]; then
            if [[ ${config[silent]} == false ]]; then
                echo "检测到PCM格式，使用默认参数（弹窗已禁用）"
            fi
        else
            if [[ ${config[silent]} == false ]]; then
                echo "检测到PCM格式，显示参数选择对话框..."
            fi
            
            if [[ ${config[channels_set]} == false ]]; then
                local selected=$(_playpcm_show_dialog \
                    "PCM参数 - 声道数" "选择声道数:" "1" "1" "2")
                if [[ -n "$selected" && "$selected" != "cancel" ]]; then
                    config[channels]="$selected"
                fi
            fi
            
            if [[ ${config[format_set]} == false ]]; then
                local selected=$(_playpcm_show_dialog \
                    "PCM参数 - 采样格式" "选择采样格式:" "s16le" \
                    "s16le" "s32le" "f32le" "s16be" "s32be" "f32be")
                if [[ -n "$selected" && "$selected" != "cancel" ]]; then
                    config[format]="$selected"
                fi
            fi
            
            if [[ ${config[rate_set]} == false ]]; then
                local selected=$(_playpcm_show_dialog \
                    "PCM参数 - 采样率" "选择采样率:" "48000" \
                    "16000" "24000" "44100" "48000" "96000")
                if [[ -n "$selected" && "$selected" != "cancel" ]]; then
                    config[rate]="$selected"
                fi
            fi
        fi
    fi
    
    _playpcm_config=("${(@kv)config}")
}

# 播放WAV文件
_playpcm_play_wav() {
    local file="$1"
    local width="$2"
    local height="$3"
    local alwaysontop="$4"
    local silent="$5"
    
    if [[ $silent == false ]]; then
        echo "播放音频文件: $file"
        echo "命令: ffplay -autoexit -showmode 1 -stats -x $width -y $height -autoexit $alwaysontop -i \"$file\""
    fi
    
    ffplay -autoexit \
        -showmode 1 -stats -x $width -y $height -autoexit $alwaysontop \
        -i "$file"
}

# 播放PCM文件
_playpcm_play_pcm() {
    local file="$1"
    local channels="$2"
    local format="$3"
    local rate="$4"
    local width="$5"
    local height="$6"
    local alwaysontop="$7"
    local silent="$8"
    
    local ch_layout=$([[ $channels -eq 1 ]] && echo "mono" || echo "stereo")
    
    if [[ $silent == false ]]; then
        echo "播放原始PCM数据: $file"
        echo "参数: 格式=$format, 采样率=$rate, 声道=$channels ($ch_layout)"
        echo "命令: ffplay -autoexit -ch_layout $ch_layout -showmode 1 -stats -x $width -y $height -autoexit $alwaysontop -f $format -ar $rate -i \"$file\""
    fi
    
    ffplay -autoexit \
        -ch_layout $ch_layout \
        -showmode 1 -stats -x $width -y $height -autoexit $alwaysontop \
        -f $format \
        -ar $rate \
        -i "$file"
}

# 主函数
ffmplayme() {
    # 解析参数
    if ! _playpcm_parse_args "$@"; then
        return $?
    fi
    
    local -A config
    config=("${(@kv)_playpcm_config}")
    
    # 检测文件类型
    local file_type=$(_playpcm_detect_file_type \
        "${config[pcm_file]}" \
        "${config[force_type]}" \
        "${config[silent]}")
    
    # 如果是PCM格式，处理参数选择
    if [[ "$file_type" == "pcm" || "$file_type" == "raw" ]]; then
        _playpcm_handle_pcm_params
        config=("${(@kv)_playpcm_config}")
    fi
    
    # 根据文件类型播放
    case "$file_type" in
        wav|audio)
            _playpcm_play_wav \
                "${config[pcm_file]}" \
                "${config[width]}" \
                "${config[height]}" \
                "${config[alwaysontop]}" \
                "${config[silent]}"
            ;;
        pcm|raw)
            _playpcm_play_pcm \
                "${config[pcm_file]}" \
                "${config[channels]}" \
                "${config[format]}" \
                "${config[rate]}" \
                "${config[width]}" \
                "${config[height]}" \
                "${config[alwaysontop]}" \
                "${config[silent]}"
            ;;
        *)
            echo "错误: 无法识别的文件类型: $file_type"
            return 1
            ;;
    esac
}

# zsh 自动补全函数
_playpcm() {
    local context curcontext="$curcontext" state line
    typeset -A opt_args
    
    _arguments \
        '(-c --channels)-c[声道数]:channels:(1 2)' \
        '(-c --channels)--channels[声道数]:channels:(1 2)' \
        '(-f --format)-f[采样格式]:format:(s16le s32le f32le s16be s32be f32be)' \
        '(-f --format)--format[采样格式]:format:(s16le s32le f32le s16be s32be f32be)' \
        '(-r --rate)-r[采样率]:rate:(16000 24000 44100 48000 96000)' \
        '(-r --rate)--rate[采样率]:rate:(16000 24000 44100 48000 96000)' \
        '(-x --width)-x[窗口宽度]:width:' \
        '(-x --width)--width[窗口宽度]:width:' \
        '(-y --height)-y[窗口高度]:height:' \
        '(-y --height)--height[窗口高度]:height:' \
        '(-n --no-top)-n[取消始终置顶]' \
        '(-n --no-top)--no-top[取消始终置顶]' \
        '(-s --silent)-s[不打印执行的命令]' \
        '(-s --silent)--silent[不打印执行的命令]' \
        '(-t --type)-t[强制指定文件类型]:type:(wav pcm raw)' \
        '(-t --type)--type[强制指定文件类型]:type:(wav pcm raw)' \
        '--no-dialog[禁用PCM参数选择弹窗，使用默认值]' \
        '(-h --help)-h[显示帮助信息]' \
        '(-h --help)--help[显示帮助信息]' \
        '*:file:_files'
}

# 注册自动补全
compdef _playpcm playpcm
