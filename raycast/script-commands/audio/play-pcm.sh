#!/bin/bash

# ============================================================================
# 配置和初始化
# ============================================================================

# 启用错误追踪和详细日志
set -u  # 使用未定义变量时报错
set -o pipefail  # 管道中任何命令失败都会导致整个管道失败

# 调试模式（可以通过环境变量控制，默认关闭以减少输出）
DEBUG="${DEBUG:-false}"
if [ "$DEBUG" = "true" ]; then
    set -x  # 打印执行的每一行命令
fi

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Play PCM Audio
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔊
# @raycast.packageName Audio Tools
# @raycast.argument1 { "type": "dropdown", "placeholder": "Sample Rate", "defaultValue": "44100", "optional": true, "data": [{"title": "8000 Hz", "value": "8000"}, {"title": "16000 Hz", "value": "16000"}, {"title": "24000 Hz", "value": "24000"}, {"title": "44100 Hz", "value": "44100"}, {"title": "48000 Hz", "value": "48000"}, {"title": "96000 Hz", "value": "96000"}] }
# @raycast.argument2 { "type": "dropdown", "placeholder": "Channels", "defaultValue": "2", "optional": true, "data": [{"title": "Mono", "value": "1"}, {"title": "Stereo", "value": "2"}, {"title": "5.1", "value": "6"}] }
# @raycast.argument3 { "type": "dropdown", "placeholder": "Format", "defaultValue": "s16le", "optional": true, "data": [{"title": "s16le", "value": "s16le"}, {"title": "s32le", "value": "s32le"}, {"title": "f32le", "value": "f32le"}] }
# 注意：文件选择将通过文件选择器对话框完成，无需文本输入参数

# Documentation:
# @raycast.description Enhanced PCM audio player with file picker support
# @raycast.author JeffreyGuan
# @raycast.currentDirectoryPath ~
# @raycast.authorURL https://github.com/double12gzh

# ============================================================================
# 常量定义
# ============================================================================

# 颜色定义
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# 默认值
readonly DEFAULT_SAMPLE_RATE="44100"
readonly DEFAULT_CHANNELS="2"
readonly DEFAULT_FORMAT="s16le"

# ============================================================================
# 系统检查
# ============================================================================

check_system() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ 错误: 此脚本仅支持 macOS 系统${NC}"
        echo ""
        echo -e "${YELLOW}当前系统:${NC} $OSTYPE"
        echo ""
        echo -e "${CYAN}提示:${NC} 此脚本需要 macOS 系统才能运行，因为："
        echo "  • 使用了 macOS 的文件选择器 (AppleScript)"
        echo "  • 使用了 macOS 特定的系统命令"
        exit 1
    fi
}

# ============================================================================
# 工具函数：日志
# ============================================================================

log_debug() {
    if [ "$DEBUG" = "true" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" >&2
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

# ============================================================================
# 工具函数：格式化输出
# ============================================================================

print_separator() {
    echo "════════════════════════════════════════════════════════════"
}

# ============================================================================
# 模块：依赖检查
# ============================================================================

check_dependencies() {
    if ! command -v ffplay &> /dev/null; then
        echo -e "${RED}❌ ERROR: ffplay is not installed${NC}"
        echo ""
        echo "To install ffplay:"
        echo -e "  ${CYAN}macOS:${NC} brew install ffmpeg"
        echo -e "  ${CYAN}Ubuntu/Debian:${NC} sudo apt install ffmpeg"
        echo -e "  ${CYAN}Windows (via Chocolatey):${NC} choco install ffmpeg"
        return 1
    fi
    return 0
}

# ============================================================================
# 模块：文件选择
# ============================================================================

open_file_picker() {
    local selected_file
    local osa_exit_code
    
    # 系统检查已在主函数中完成，这里直接使用
    selected_file=$(osascript <<EOF 2>/dev/null
        tell application "System Events"
            activate
        end tell
        try
            set theFile to choose file with prompt "请选择要播放的 PCM 文件" default location (path to downloads folder) without showing package contents
            return POSIX path of theFile
        on error
            return ""
        end try
EOF
)
    osa_exit_code=$?
    
    # 清理路径：移除前后空白字符和换行符
    selected_file=$(echo "$selected_file" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ $osa_exit_code -eq 0 ] && [ -n "$selected_file" ]; then
        echo "$selected_file"
        return 0
    else
        echo -e "${YELLOW}⚠️  文件选择已取消${NC}" >&2
        return 1
    fi
}

# ============================================================================
# 模块：路径处理
# ============================================================================

normalize_file_path() {
    local file_path="$1"
    
    # 1. 移除可能的引号
    file_path=$(echo "$file_path" | sed "s/^['\"]//;s/['\"]$//")
    
    # 2. 将全角波浪号转换为半角
    file_path=$(echo "$file_path" | sed 's/～/~/g')
    
    # 3. 展开 ~ 到用户主目录
    if [ "${file_path:0:1}" = "~" ]; then
        file_path="${HOME}${file_path#~}"
    fi
    
    # 4. 处理相对路径，转换为绝对路径
    if [[ "$file_path" != /* ]]; then
        if [ -f "$file_path" ]; then
            file_path=$(cd "$(dirname "$file_path")" && pwd)/$(basename "$file_path")
        fi
    fi
    
    # 5. 规范化路径（移除多余的斜杠）
    file_path=$(echo "$file_path" | sed 's|//|/|g')
    
    echo "$file_path"
}

# ============================================================================
# 模块：文件信息
# ============================================================================

get_file_size() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$file"
    else
        stat -c%s "$file"
    fi
}

format_file_size() {
    local size="$1"
    if [ $size -ge $((1024*1024*1024)) ]; then
        echo "$(echo "scale=2; $size / (1024*1024*1024)" | bc) GB"
    elif [ $size -ge $((1024*1024)) ]; then
        echo "$(echo "scale=2; $size / (1024*1024)" | bc) MB"
    elif [ $size -ge 1024 ]; then
        echo "$(echo "scale=2; $size / 1024" | bc) KB"
    else
        echo "${size} B"
    fi
}

get_file_type() {
    local file="$1"
    if command -v file &> /dev/null; then
        file -b "$file"
    else
        echo "Unknown (install 'file' command for detection)"
    fi
}

display_file_info() {
    local file="$1"
    local filename=$(basename "$file")
    local filepath=$(dirname "$file")
    local filesize=$(get_file_size "$file")
    local size_readable=$(format_file_size "$filesize")
    local filetype=$(get_file_type "$file")
    
    # 将显示信息输出到 stderr，避免被捕获
    echo -e "${BLUE}📁 FILE INFORMATION${NC}" >&2
    echo -e "  ${CYAN}Name:${NC} ${GREEN}$filename${NC}" >&2
    echo -e "  ${CYAN}Path:${NC} $filepath" >&2
    echo -e "  ${CYAN}Size:${NC} $size_readable ($filesize bytes)" >&2
    echo -e "  ${CYAN}Type:${NC} $filetype" >&2
    
    # 只返回文件大小到 stdout，供后续使用
    echo "$filesize"
}

# ============================================================================
# 模块：音频参数计算
# ============================================================================

get_bytes_per_sample() {
    local format="$1"
    case "$format" in
        "u8") echo 1 ;;
        "s16le"|"s16be") echo 2 ;;
        "s32le"|"s32be"|"f32le") echo 4 ;;
        *) echo 2 ;;
    esac
}

get_bits_per_sample() {
    local format="$1"
    case "$format" in
        "u8") echo 8 ;;
        "s16le"|"s16be") echo 16 ;;
        "s32le"|"s32be"|"f32le") echo 32 ;;
        *) echo 16 ;;
    esac
}

calculate_duration() {
    local size="$1"
    local sample_rate="$2"
    local channels="$3"
    local format="$4"
    
    local bytes_per_sample=$(get_bytes_per_sample "$format")
    local total_samples=$(echo "scale=0; $size / ($bytes_per_sample * $channels)" | bc)
    local total_seconds=$(echo "scale=2; $total_samples / $sample_rate" | bc)
    
    # 格式化为 HH:MM:SS.ss
    if (( $(echo "$total_seconds >= 3600" | bc -l) )); then
        local hours=$(echo "$total_seconds / 3600" | bc)
        local minutes=$(echo "($total_seconds % 3600) / 60" | bc)
        local seconds=$(echo "$total_seconds % 60" | bc)
        printf "%02d:%02d:%05.2f" $hours $minutes $seconds
    elif (( $(echo "$total_seconds >= 60" | bc -l) )); then
        local minutes=$(echo "$total_seconds / 60" | bc)
        local seconds=$(echo "$total_seconds % 60" | bc)
        printf "%02d:%05.2f" $minutes $seconds
    else
        printf "00:%05.2f" $total_seconds
    fi
}

get_channel_layout() {
    local channels="$1"
    case "$channels" in
        "1") echo "mono" ;;
        "2") echo "stereo" ;;
        "6") echo "5.1" ;;
        *) echo "stereo" ;;
    esac
}

get_channel_description() {
    local channels="$1"
    case "$channels" in
        "1") echo "Mono (单声道)" ;;
        "2") echo "Stereo (立体声)" ;;
        "6") echo "5.1 Surround (环绕声)" ;;
        *) echo "$channels channels" ;;
    esac
}

get_format_description() {
    local format="$1"
    case "$format" in
        "u8") echo "8-bit unsigned" ;;
        "s16le") echo "16-bit signed little-endian" ;;
        "s32le") echo "32-bit signed little-endian" ;;
        "f32le") echo "32-bit float little-endian" ;;
        *) echo "$format" ;;
    esac
}

# ============================================================================
# 模块：显示信息
# ============================================================================

display_playback_settings() {
    local sample_rate="$1"
    local channels="$2"
    local format="$3"
    local duration="$4"
    
    local ch_desc=$(get_channel_description "$channels")
    local fmt_desc=$(get_format_description "$format")
    
    echo -e "${BLUE}⚙️  PLAYBACK SETTINGS${NC}"
    echo -e "  ${CYAN}Sample Rate:${NC} ${GREEN}$sample_rate Hz${NC}"
    echo -e "  ${CYAN}Channels:${NC} ${GREEN}$channels ($ch_desc)${NC}"
    echo -e "  ${CYAN}Format:${NC} ${GREEN}$format ($fmt_desc)${NC}"
    
    if [ -n "$duration" ]; then
        echo -e "  ${CYAN}Duration:${NC} ${GREEN}$duration${NC}"
    fi
}

display_technical_info() {
    local filesize="$1"
    local sample_rate="$2"
    local channels="$3"
    local format="$4"
    local total_seconds="$5"
    
    local bits_per_sample=$(get_bits_per_sample "$format")
    local bitrate=$(echo "scale=0; $sample_rate * $channels * $bits_per_sample / 1000" | bc)
    local data_rate="0"
    if [ -n "$total_seconds" ] && (( $(echo "$total_seconds > 0" | bc -l) )); then
        data_rate=$(echo "scale=1; $filesize / $total_seconds / 1000" | bc)
    fi
    
    echo -e "${BLUE}📊 TECHNICAL INFO${NC}"
    echo -e "  ${CYAN}Bitrate:${NC} ${GREEN}$bitrate kbps${NC}"
    echo -e "  ${CYAN}Data Rate:${NC} ${GREEN}$data_rate KB/s${NC}"
}

# ============================================================================
# 模块：音频播放
# ============================================================================

play_audio() {
    local file="$1"
    local format="$2"
    local sample_rate="$3"
    local channels="$4"
    local filename="$5"
    
    local channel_layout=$(get_channel_layout "$channels")
    
    local cmd_args=(
        ffplay
        -f "$format"
        -ar "$sample_rate"
        -ch_layout "$channel_layout"
        -i "$file"
        -window_title "PCM Audio: $filename"
        -showmode 1
        -loglevel quiet
        -x 800
        -y 400
        -alwaysontop
        -autoexit
    )
    
    # 显示播放命令（仅保留这个调试信息）
    echo -e "${CYAN}[播放命令]${NC} ${cmd_args[*]}"
    echo ""
    
    # 执行播放（ffplay 的输出会显示在窗口中，不会覆盖之前的文本输出）
    if "${cmd_args[@]}" 2>&1; then
        return 0
    else
        local exit_code=$?
        log_error "ffplay 执行失败，退出码: $exit_code"
        return $exit_code
    fi
}

# ============================================================================
# 主函数
# ============================================================================

main() {
    # 首先检查系统是否为 macOS
    check_system
    
    log_debug "参数数量: $#"
    log_debug "参数列表: $@"
    
    if ! check_dependencies; then
        log_error "依赖检查失败"
        exit 1
    fi
    
    # 解析参数
    local sample_rate="${1:-$DEFAULT_SAMPLE_RATE}"
    local channels="${2:-$DEFAULT_CHANNELS}"
    local sample_format="${3:-$DEFAULT_FORMAT}"
    
    log_debug "解析后的参数:"
    log_debug "  SAMPLE_RATE: '$sample_rate'"
    log_debug "  CHANNELS: '$channels'"
    log_debug "  SAMPLE_FORMAT: '$sample_format'"
    
    # 选择文件
    local pcm_file=$(open_file_picker)
    if [ $? -ne 0 ] || [ -z "$pcm_file" ]; then
        log_error "文件选择失败或已取消"
        echo ""
        echo -e "${YELLOW}错误: 未选择文件${NC}"
        echo ""
        echo -e "${CYAN}提示:${NC} 请从文件选择器中选择要播放的 PCM 文件"
        exit 1
    fi
    
    # 处理路径
    pcm_file=$(normalize_file_path "$pcm_file")

    local filesize=$(display_file_info "$pcm_file")
    echo ""
    
    local duration=$(calculate_duration "$filesize" "$sample_rate" "$channels" "$sample_format")
    local denom=$(( $(get_bytes_per_sample "$sample_format") * channels * sample_rate ))
    local total_seconds="0"
    if [ "$denom" -gt 0 ]; then
        total_seconds=$(echo "scale=2; $filesize / $denom" | bc)
    fi
    
    display_playback_settings "$sample_rate" "$channels" "$sample_format" "$duration"
    echo ""
    
    display_technical_info "$filesize" "$sample_rate" "$channels" "$sample_format" "$total_seconds"
    echo ""
    
    print_separator
    echo -e "${GREEN}▶️  Starting playback...${NC}"
    echo ""
    
    # 播放音频
    local filename=$(basename "$pcm_file")
    if play_audio "$pcm_file" "$sample_format" "$sample_rate" "$channels" "$filename"; then
        echo ""
        print_separator
        echo -e "${GREEN}✅ Playback completed successfully${NC}"
    else
        local exit_code=$?
        echo ""
        print_separator
        echo -e "${YELLOW}⚠️  Playback stopped${NC}"
        log_error "播放停止，退出码: $exit_code"
        exit $exit_code
    fi
}

# ============================================================================
# 脚本入口
# ============================================================================

trap 'log_error "脚本在行 $LINENO 处发生错误，退出码: $?"' ERR

main "${1:-}" "${2:-}" "${3:-}" || {
    exit_code=$?
    log_error "主函数执行失败，退出码: $exit_code"
    exit $exit_code
}
