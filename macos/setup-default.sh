#!/usr/bin/env bash
# shellcheck disable=SC2059,SC2154
set -e
set -o pipefail

# Get the dotfiles directory
DOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
tty_blue=$(tput setaf 4)
tty_yellow=$(tput setaf 3)
tty_red=$(tput setaf 1)
tty_reset=$(tput sgr0)

# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#   https://github.com/holman/dotfiles/blob/master/macos/set-defaults.sh
#
# Run ./set-defaults.sh and you'll be good to go.

function setup_finder() {
	# 禁用动画（提升响应速度）
	defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

	# 不显示隐藏文件
	defaults write com.apple.finder AppleShowAllFiles -bool false

	# Always open everything in Finder's list view. This is important.
	defaults write com.apple.Finder FXPreferredViewStyle Nlsv

	# Show the ~/Library folder.
	chflags nohidden ~/Library

	# Set a really fast key repeat.
	defaults write NSGlobalDomain KeyRepeat -int 1

	# Set the Finder prefs for showing a few different volumes on the Desktop.
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

	# Run the screensaver if we're in the bottom-left hot corner.
	defaults write com.apple.dock wvous-bl-corner -int 5
	defaults write com.apple.dock wvous-bl-modifier -int 0

	# Set up Safari for development.
	defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
	defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true
	defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari.plist "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
	defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true

	# Avoid creating .DS_Store files on network or USB volumes
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

	# Use list view in all Finder windows by default
	# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

	# 重启 Finder 和 Dock
	killall Finder
	killall Dock
}

function setup_iterm2() {
	# 通过命令行设置配置路径
	defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config/iterm2"
	
	# 检查 iTerm2 进程是否存在
	if pgrep -x "iTerm2" > /dev/null; then
		killall iTerm2
	fi
}

function setup_autologin() {
	script_dir=$(dirname "$(readlink -f "$0")")
	ln -sf $script_dir/macos/auto_login $HOME/.auto_login
}

function install_apps() {
	printf "\n${tty_yellow}Installing apps from Brewfile...${tty_reset}\n"
	
	# Check if Brewfile exists
	BREWFILE_PATH="$DOT_DIR/brew/Brewfile"
	if [[ ! -f "$BREWFILE_PATH" ]]; then
		printf "${tty_red}Error: Brewfile not found at $BREWFILE_PATH${tty_reset}\n"
		printf "${tty_yellow}Current directory: $(pwd)${tty_reset}\n"
		printf "${tty_yellow}Dot directory: $DOT_DIR${tty_reset}\n"
		return 1
	fi
	
	# Install apps from Brewfile
	if brew bundle --file="$BREWFILE_PATH"; then
		printf "${tty_blue}Successfully installed apps from Brewfile${tty_reset}\n"
	else
		printf "${tty_red}Failed to install some apps from Brewfile${tty_reset}\n"
		return 1
	fi
}

setup_finder
setup_autologin

# Check for iTerm2 using ls and grep
if ls -d "/Applications/iTerm"*".app" >/dev/null 2>&1; then
	setup_iterm2
else
	echo "iTerm2 not installed, skipping iTerm2 setup."
fi

# Main execution
if [[ "$(uname)" == "Darwin" ]]; then
	install_apps
else
	printf "${tty_yellow}This script is only for macOS${tty_reset}\n"
	exit 1
fi
