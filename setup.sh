#!/bin/bash

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
		if ! fc-list | grep -i "nerd" > /dev/null; then
			red_echo "错误: 未检测到Nerd Font字体！请先安装Nerd Font字体。"
			yellow_echo "可以通过以下命令安装:"
			yellow_echo "brew tap homebrew/cask-fonts"
			yellow_echo "brew install --cask font-hack-nerd-font"
			exit 1
		fi
	else
		# Linux系统
		if ! fc-list | grep -i "nerd" > /dev/null; then
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
		source ${SCRIPT_PATH}/zzz_install_scripts/sys-apps/brew_install.sh
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

install_sys_apps
install_langs
install_app

check_nerd_fonts
setup_macos
stow_configs
