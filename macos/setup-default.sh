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
	killall iTerm2
}

function setup_autologin() {
	script_dir=$(dirname "$(readlink -f "$0")")
	ln -sf $script_dir/autologin $HOME/.auto_login
}

setup_finder
setup_autologin

if command -v iTerm2 &>/dev/null; then
	setup_iterm2
else
	echo "iTerm2 not installed, skipping iTerm2 setup."
fi
