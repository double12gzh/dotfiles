#!/usr/bin/env bash

set -e

# 检查 bash 版本
if [ "${BASH_VERSINFO[0]}" -lt 5 ]; then
	echo "错误: 需要 bash 5.0 或更高版本"
	echo "当前版本: $BASH_VERSION"
	echo "请升级 bash 或使用 'bash setup.sh' 执行脚本"
	exit 1
fi

# 定义所有支持的操作
declare -A SUPPORTED_OPERATIONS=(
	["sys-apps"]="仅安装系统应用"
	["langs"]="仅安装编程语言"
	["apps"]="仅安装应用"
	["nerd-fonts"]="仅检查 nerd fonts"
	["macos"]="仅配置 macOS 环境"
	["configs"]="仅通过 chezmoi 应用配置"
	["custom"]="仅显示本地定制化配置信息"
)

# 定义操作对应的函数
declare -A OPERATION_FUNCTIONS=(
	["sys-apps"]="install_sys_apps"
	["langs"]="install_langs"
	["apps"]="install_apps"
	["nerd-fonts"]="check_nerd_fonts"
	["macos"]="setup_macos"
	["configs"]="apply_configs"
	["custom"]="local_custom_configs"
)

# 定义操作执行顺序
declare -a OPERATION_ORDER=(
	"sys-apps"
	"langs"
	"apps"
	"configs"
	"nerd-fonts"
	"macos"
	"custom"
)

# 定义命令行选项和对应的操作
declare -A OPTION_MAP=(
	["help"]="-h --help"
	["all"]="-a --all"
	["sys-apps"]="-s --sys-apps"
	["langs"]="-l --langs"
	["apps"]="-p --apps"
	["nerd-fonts"]="-n --nerd-fonts"
	["macos"]="-m --macos"
	["configs"]="-c --configs"
	["custom"]="-u --custom"
)

#======================#
#        main          #
#======================#

# 定义操作状态常量
readonly OP_ENABLE="enable"
readonly OP_DISABLE="disable"

SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)

function green_echo() {
	echo -e "\033[32m$1\033[0m"
}

function red_echo() {
	echo -e "\033[31m$1\033[0m"
}

function yellow_echo() {
	echo -e "\033[33m$1\033[0m"
}

function blue_echo() {
	echo -e "\033[34m$1\033[0m"
}

function gray_echo() {
	echo -e "\033[90m$1\033[0m"
}

function show_help() {
	echo "用法: $0 [选项]"
	echo
	echo "选项:"

	# 显示帮助和全部选项
	echo "  -h, --help              显示帮助信息（默认）"
	echo "  -a, --all               执行所有操作"
	echo

	# 根据 SUPPORTED_OPERATIONS 和 OPTION_MAP 自动生成选项说明
	for operation in "${!SUPPORTED_OPERATIONS[@]}"; do
		local options="${OPTION_MAP[$operation]}"
		local short_opt=$(echo "$options" | awk '{print $1}')
		local long_opt=$(echo "$options" | awk '{print $2}')
		local description="${SUPPORTED_OPERATIONS[$operation]}"

		# 使用 printf 格式化输出，确保对齐
		printf "  %-2s %-20s %s\n" "$short_opt," "$long_opt" "$description"
	done | sort -k2 # 按长选项名排序

	echo
	echo "示例:"
	printf "  %-30s # 显示帮助信息\n" "$0"

	# 生成示例命令
	local example_cmd=""
	for operation in "${!SUPPORTED_OPERATIONS[@]}"; do
		local short_opt=$(echo "${OPTION_MAP[$operation]}" | awk '{print $1}')
		if [ -z "$example_cmd" ]; then
			example_cmd="$0 $short_opt"
		else
			printf "  %-30s # 组合使用多个选项\n" "$example_cmd $short_opt"
			break
		fi
	done

	printf "  %-30s # 执行所有操作\n" "$0 --all"
	echo
	echo "================================================"
	blue_echo "添加新操作步骤:"
	blue_echo "  1. 在 SUPPORTED_OPERATIONS 数组中添加新操作名称和描述"
	blue_echo "     例如: declare -A SUPPORTED_OPERATIONS=([\"docker\"]=\"仅配置 Docker 环境\")"
	blue_echo
	blue_echo "  2. 在 OPERATION_FUNCTIONS 中添加对应的函数映射"
	blue_echo "     例如: declare -A OPERATION_FUNCTIONS=([\"docker\"]=\"setup_docker\")"
	blue_echo
	blue_echo "  3. 在 OPTION_MAP 中指定选项映射"
	blue_echo "     例如: declare -A OPTION_MAP=([\"docker\"]=\"-d --docker\")"
	blue_echo
	blue_echo "  4. 实现对应的操作函数"
	blue_echo "     例如:"
	blue_echo "     function setup_docker() {"
	blue_echo "         local operation=\$1"
	blue_echo "         blue_echo \"----------------------------------\""
	blue_echo "         blue_echo \"\$operation: 开始配置 Docker 环境...\""
	blue_echo "         blue_echo \"----------------------------------\""
	blue_echo "         # 添加具体的配置命令"
	blue_echo "         if [[ \$? -eq 0 ]]; then"
	blue_echo "             green_echo \"Docker 环境配置成功\""
	blue_echo "         else"
	blue_echo "             red_echo \"Docker 环境配置失败\""
	blue_echo "         fi"
	blue_echo "     }"
	echo
	exit 0
}

function setup_macos() {
	local operation=$1
	blue_echo "--------------------------------"
	blue_echo "$operation: 开始配置 macOS 环境..."
	blue_echo "--------------------------------"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		source "${SCRIPT_PATH}/macos/setup-default.sh"
	else
		yellow_echo "当前系统不是 macOS，跳过配置"
	fi
}

function check_nerd_fonts() {
	local operation=$1
	blue_echo "-------------------------------------"
	blue_echo "$operation: 检查 nerd fonts 是否安装..."
	blue_echo "-------------------------------------"

	# 检查是否安装了Nerd Font
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS系统，检查字体目录
		if command -v fc-list >/dev/null 2>&1; then
			if ! fc-list | grep -qi "nerd"; then
				red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
				yellow_echo "可以通过以下命令安装:"
				yellow_echo "brew install --cask font-hack-nerd-font"
				exit 1
			fi
		elif ! ls "$HOME/Library/Fonts" /Library/Fonts 2>/dev/null | grep -qi "nerd"; then
			red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
			yellow_echo "可以通过以下命令安装:"
			yellow_echo "brew install --cask font-hack-nerd-font"
			exit 1
		fi
	else
		# Linux系统
		if command -v fc-list >/dev/null 2>&1 && ! fc-list | grep -qi "nerd"; then
			red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
			yellow_echo "可以参考: https://www.nerdfonts.com/font-downloads"
			exit 1
		fi
	fi

	source "${SCRIPT_PATH}/nerd-font-smoke-test.sh"

	green_echo "✓ Nerd Font已安装"
}

function cleanup_legacy_stow_links() {
	local backup_dir=$1
	mkdir -p "${backup_dir}/ssh_config_d" "${backup_dir}/zsh_hosts"

	# 备份旧版 Stow 目录软链下的本地私有 SSH 配置与主机列表
	if [ -d "${HOME}/.ssh/config.d" ]; then
		find -H "${HOME}/.ssh/config.d" -maxdepth 1 -type f ! -name "example*" -exec cp -p {} "${backup_dir}/ssh_config_d/" \; 2>/dev/null || true
	fi
	if [ -d "${SCRIPT_PATH}/ssh/.ssh/config.d" ]; then
		find -H "${SCRIPT_PATH}/ssh/.ssh/config.d" -maxdepth 1 -type f ! -name "example*" -exec cp -p {} "${backup_dir}/ssh_config_d/" \; 2>/dev/null || true
	fi
	if [ -d "${HOME}/.zsh/sshs/hosts" ]; then
		find -H "${HOME}/.zsh/sshs/hosts" -maxdepth 1 -type f ! -name "example*" -exec cp -p {} "${backup_dir}/zsh_hosts/" \; 2>/dev/null || true
	fi
	if [ -d "${SCRIPT_PATH}/zsh/.zsh/sshs/hosts" ]; then
		find -H "${SCRIPT_PATH}/zsh/.zsh/sshs/hosts" -maxdepth 1 -type f ! -name "example*" -exec cp -p {} "${backup_dir}/zsh_hosts/" \; 2>/dev/null || true
	fi

	# 清理指向旧版 Stow 仓库的软链接，以便 chezmoi 创建实体目录和文件
	local link target
	while IFS= read -r link; do
		[ -z "$link" ] && continue
		target=$(readlink "$link" 2>/dev/null || true)
		if [[ "$target" == *"dotfiles/"* ]]; then
			yellow_echo "清理旧版 Stow 软链: $link -> $target"
			rm "$link"
		fi
	done < <(
		find "${HOME}" -maxdepth 1 -type l 2>/dev/null
		find "${HOME}/.config" "${HOME}/.ssh" "${HOME}/.local/share" -maxdepth 3 -type l 2>/dev/null
	)
}

function restore_legacy_local_configs() {
	local backup_dir=$1
	if [ -d "${backup_dir}/ssh_config_d" ]; then
		mkdir -p "${HOME}/.ssh/config.d"
		find "${backup_dir}/ssh_config_d" -maxdepth 1 -type f -exec cp -np {} "${HOME}/.ssh/config.d/" \; 2>/dev/null || true
	fi
	if [ -d "${backup_dir}/zsh_hosts" ]; then
		mkdir -p "${HOME}/.zsh/sshs/hosts"
		find "${backup_dir}/zsh_hosts" -maxdepth 1 -type f -exec cp -np {} "${HOME}/.zsh/sshs/hosts/" \; 2>/dev/null || true
	fi
	rm -rf "${backup_dir}"
}

function apply_configs() {
	local operation=$1
	blue_echo "----------------------------"
	blue_echo "$operation: 开始通过 chezmoi 应用配置..."
	blue_echo "----------------------------"

	mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.local/share"
	export PATH="${HOME}/.local/bin:${PATH}"

	if ! command -v chezmoi >/dev/null 2>&1; then
		yellow_echo "未检测到 chezmoi，正在自动安装至 ${HOME}/.local/bin..."
		sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
	fi

	local backup_dir
	backup_dir=$(mktemp -d)
	cleanup_legacy_stow_links "${backup_dir}"

	chezmoi init --apply --promptDefaults --source "${SCRIPT_PATH}"

	restore_legacy_local_configs "${backup_dir}"

	green_echo "-----------------------------------------"
	green_echo "所有配置已通过 chezmoi 同步完成（目标目录: ~）"
	green_echo "-----------------------------------------"
}

function install_sys_apps() {
	local operation=$1
	blue_echo "----------------------------"
	blue_echo "$operation: 开始安装系统应用..."
	blue_echo "----------------------------"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		yellow_echo "macOS 系统，跳过安装系统应用"
	else
		source "${SCRIPT_PATH}/zzz_install_scripts/sys-apps/apt_install.sh"
	fi

	if [[ $? -eq 0 ]]; then
		green_echo "系统应用安装成功"
	else
		red_echo "系统应用安装失败"
	fi
}

function install_apps() {
	local operation=$1
	blue_echo "----------------------------"
	blue_echo "$operation: 开始安装应用...   "
	blue_echo "----------------------------"
	source "${SCRIPT_PATH}/zzz_install_scripts/install_app.sh"
	if [[ $? -eq 0 ]]; then
		green_echo "应用安装成功"
	else
		red_echo "应用安装失败"
	fi
}

function install_langs() {
	local operation=$1
	blue_echo "----------------------------"
	blue_echo "$operation: 开始安装编程语言..."
	blue_echo "----------------------------"
	source "${SCRIPT_PATH}/zzz_install_scripts/install_lang.sh"
	if [[ $? -eq 0 ]]; then
		green_echo "编程语言安装成功"
	else
		red_echo "编程语言安装失败"
	fi
}

function local_custom_configs() {
	local operation=$1
	blue_echo "-----------------------------------"
	blue_echo "$operation: 可能需要的本地定制化配置..."
	blue_echo "-----------------------------------"

	gray_echo "按需要配置本地其它文件"
	gray_echo "本地 alias: $HOME/.local_aliases.zsh"
	gray_echo "    $HOME/.local_aliases.zsh 中的配置会覆盖 $HOME/.zsh/aliases.zsh 中的配置"
	gray_echo "本地 ssh: $HOME/.ssh/config.d/*.conf"
	gray_echo "    $HOME/.ssh/config.d/*.conf 中的配置覆盖 $HOME/.ssh/config 中的配置"
}

# 初始化操作映射
function init_operation_map() {
	# 初始化 OPERATIONS 数组
	declare -gA OPERATIONS=(
		["all"]="$OP_DISABLE"
	)

	# 基于 SUPPORTED_OPERATIONS 生成 OPERATIONS
	for operation in "${!SUPPORTED_OPERATIONS[@]}"; do
		# 初始化 OPERATIONS
		OPERATIONS["$operation"]="$OP_DISABLE"
	done
}

# 执行指定操作的函数
function execute_operation() {
	local operation=$1
	local function_name=${OPERATION_FUNCTIONS[$operation]}
	$function_name "$operation"
}

init_operation_map

# 显示操作状态的函数
function show_operation_status() {
	# 计算最长的操作名长度
	local max_len=0
	for op in "${!OPERATIONS[@]}"; do
		if [ ${#op} -gt $max_len ]; then
			max_len=${#op}
		fi
	done

	# 先显示 enable 的操作
	for op in "${!OPERATIONS[@]}"; do
		if [ "${OPERATIONS[$op]}" = "$OP_ENABLE" ]; then
			local formatted=$(printf "  %-${max_len}s: %s" "$op" "${OPERATIONS[$op]}")
			green_echo "$formatted"
		fi
	done

	# 再显示 disable 的操作
	for op in "${!OPERATIONS[@]}"; do
		if [ "${OPERATIONS[$op]}" = "$OP_DISABLE" ]; then
			printf "  %-${max_len}s: %s\n" "$op" "${OPERATIONS[$op]}"
		fi
	done
}

# 解析命令行参数
if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		option="$1"
		# 查找对应的操作
		operation=""
		for op in "${!OPTION_MAP[@]}"; do
			if [[ " ${OPTION_MAP[$op]} " =~ " $option " ]]; then
				operation="$op"
				break
			fi
		done

		if [ -z "$operation" ]; then
			red_echo "未知选项: $option"
			echo "使用 '$0 --help' 查看帮助信息"
			exit 1
		fi

		if [ "$operation" = "help" ]; then
			show_help
		elif [ "$operation" = "all" ]; then
			OPERATIONS["all"]="$OP_ENABLE"
		else
			OPERATIONS["$operation"]="$OP_ENABLE"
		fi

		shift
	done

	echo "当前 OPERATIONS 状态:"
	show_operation_status
	echo -e "\n开始执行...\n"
else
	show_help
fi

# 执行选定的操作
if [ "${OPERATIONS['all']}" = "$OP_ENABLE" ]; then
	# 如果指定了 all，则执行所有操作
	for operation in "${OPERATION_ORDER[@]}"; do
		execute_operation "$operation"
	done
	green_echo "\n所有操作执行成功\n"
else
	# 否则只执行指定的操作
	for operation in "${OPERATION_ORDER[@]}"; do
		if [ "${OPERATIONS[$operation]}" = "$OP_ENABLE" ]; then
			execute_operation "$operation"
			if [ $? -eq 0 ]; then
				green_echo "\n操作 $operation 执行成功\n"
			else
				red_echo "\n操作 $operation 执行失败\n"
			fi
		fi
	done
fi
