#!/usr/bin/env bash

# 检查 bash 版本
if [ "${BASH_VERSINFO[0]}" -lt 5 ]; then
	echo "错误: 需要 bash 5.0 或更高版本"
	echo "当前版本: $BASH_VERSION"
	echo "请升级 bash 或使用 'bash setup.sh' 执行脚本"
	exit 1
fi

set -e

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

function show_help() {
	echo "用法: $0 [选项]"
	echo
	echo "选项:"
	echo "  -h, --help              显示帮助信息"
	echo "  -a, --all               执行所有操作（默认）"
	echo "  -s, --sys-apps          仅安装系统应用"
	echo "  -l, --langs             仅安装编程语言"
	echo "  -p, --apps              仅安装应用"
	echo "  -n, --nerd-fonts        仅检查 nerd fonts"
	echo "  -m, --macos             仅配置 macOS 环境"
	echo "  -c, --configs           仅链接配置"
	echo "  --custom                仅显示本地定制化配置信息"
	echo
	echo "示例:"
	echo "  $0                      # 执行所有操作"
	echo "  $0 -s -l                # 安装系统应用和编程语言"
	echo "  $0 --configs --macos    # 链接配置并配置 macOS 环境"
	exit 0
}

function setup_macos() {
	blue_echo "----------------------------"
	blue_echo "开始配置 macOS 环境..."
	blue_echo "----------------------------"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		source ${SCRIPT_PATH}/macos/setup-default.sh
	else
		yellow_echo "当前系统不是 macOS，跳过配置"
	fi
}

function check_nerd_fonts() {
	blue_echo "----------------------------"
	blue_echo "检查 nerd fonts 是否安装..."
	blue_echo "----------------------------"

	# 检查是否安装了Nerd Font
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS系统，检查字体目录
		if ! fc-list | grep -i "nerd" >/dev/null; then
			red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
			yellow_echo "可以通过以下命令安装:"
			yellow_echo "brew tap homebrew/cask-fonts"
			yellow_echo "brew install --cask font-hack-nerd-font"
			exit 1
		fi
	else
		# Linux系统
		if ! fc-list | grep -i "nerd" >/dev/null; then
			red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
			yellow_echo "可以参考: https://www.nerdfonts.com/font-downloads"
			exit 1
		fi
	fi

	source $SCRIPT_PATH/nerd-font-smoke-test.sh

	green_echo "✓ Nerd Font已安装"
}

function stow_configs() {
	blue_echo "----------------------------"
	blue_echo "开始链接配置..."
	blue_echo "----------------------------"
	local configs=(
		bash
		batcat
		conda
		fdfind
		git
		lazygit
		lf
		local
		luarocks
		starship
		ssh
		tmux
		tmuxp
		zsh
		wezterm
		gotests
	)

	for config in "${configs[@]}"; do
		echo "正在链接 $config 配置..."

		# 检查配置目录是否存在
		if [ ! -d "$config" ]; then
			yellow_echo "警告: 配置目录 $config 不存在，跳过"
			continue
		fi

		# 实际执行链接操作
		stow "$config"
	done

	green_echo "----------------------------"
	green_echo "所有配置已链接完成。链接目录为 ~/.config/ 和 ~"
	green_echo "----------------------------"
}

function install_sys_apps() {
	blue_echo "----------------------------"
	blue_echo "开始安装系统应用..."
	blue_echo "----------------------------"
	if [[ "$OSTYPE" == "darwin"* ]]; then
		yellow_echo "macOS 系统，跳过安装系统应用"
	else
		source ${SCRIPT_PATH}/zzz_install_scripts/sys-apps/apt_install.sh
	fi

	if [[ $? -eq 0 ]]; then
		green_echo "系统应用安装成功"
	else
		red_echo "系统应用安装失败"
	fi
}

function install_apps() {
	blue_echo "----------------------------"
	blue_echo "开始安装应用..."
	blue_echo "----------------------------"
	source ${SCRIPT_PATH}/zzz_install_scripts/install_app.sh
	if [[ $? -eq 0 ]]; then
		green_echo "应用安装成功"
	else
		red_echo "应用安装失败"
	fi
}

function install_langs() {
	blue_echo "----------------------------"
	blue_echo "开始安装编程语言..."
	blue_echo "----------------------------"
	source ${SCRIPT_PATH}/zzz_install_scripts/install_lang.sh
	if [[ $? -eq 0 ]]; then
		green_echo "编程语言安装成功"
	else
		red_echo "编程语言安装失败"
	fi
}

function local_custom_configs() {
	blue_echo "----------------------------"
	blue_echo "可能需要的本地定制化配置..."
	blue_echo "----------------------------"

	echo "按需要配置本地其它文件"
	echo "本地 alias: $HOME/.local_aliases.zsh"
	yellow_echo "    $HOME/.local_aliases.zsh 中的配置会覆盖 $HOME/.zsh/aliases.zsh 中的配置"
	echo "本地 ssh: $HOME/.ssh/config.d/*.conf"
	yellow_echo "    $HOME/.ssh/config.d/*.conf 中的配置覆盖 $HOME/.ssh/config 中的配置"
}

# 默认执行所有操作
declare -A OPERATIONS=(
	["sys-apps"]=0
	["langs"]=0
	["apps"]=0
	["nerd-fonts"]=0
	["macos"]=0
	["configs"]=0
	["custom"]=0
	["all"]=0
)

# 函数映射表 - 将操作名映射到对应的函数
declare -A OPERATION_FUNCTIONS=(
	["sys-apps"]="install_sys_apps"
	["langs"]="install_langs"
	["apps"]="install_apps"
	["nerd-fonts"]="check_nerd_fonts"
	["macos"]="setup_macos"
	["configs"]="stow_configs"
	["custom"]="local_custom_configs"
)

# 执行指定操作的函数
execute_operation() {
	local operation=$1
	local function_name=${OPERATION_FUNCTIONS[$operation]}

	if [ ${OPERATIONS["all"]} -eq 1 ] || [ ${OPERATIONS[$operation]} -eq 1 ]; then
		$function_name
	fi
}

# 解析命令行参数
if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		case "$1" in
		-h | --help)
			show_help
			;;
		-a | --all)
			OPERATIONS["all"]=1
			;;
		-s | --sys-apps)
			OPERATIONS["sys-apps"]=1
			;;
		-l | --langs)
			OPERATIONS["langs"]=1
			;;
		-p | --apps)
			OPERATIONS["apps"]=1
			;;
		-n | --nerd-fonts)
			OPERATIONS["nerd-fonts"]=1
			;;
		-m | --macos)
			OPERATIONS["macos"]=1
			;;
		-c | --configs)
			OPERATIONS["configs"]=1
			;;
		--custom)
			OPERATIONS["custom"]=1
			;;
		*)
			red_echo "未知选项: $1"
			echo "使用 '$0 --help' 查看帮助信息"
			exit 1
			;;
		esac
		shift
	done
else
	# 不提供参数时显示帮助信息
	show_help
fi

# 执行所有选定的操作
for operation in "${!OPERATION_FUNCTIONS[@]}"; do
	execute_operation "$operation"
done
