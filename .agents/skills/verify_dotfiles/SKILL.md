---
name: verify_dotfiles
description: 自动执行 dotfiles 仓库全链路健康检查与配置校验，覆盖 Zsh/Bash/Expect 脚本语法、GNU Stow 软链完整性、~/.bin 与 ~/.local/bin 目录隔离、Nerd Fonts 4 字节 UTF-8 图标透传及敏感配置防泄漏检查。
---

# Verify Dotfiles Configuration & Environment Skill

使用此 Skill 在修改 `dotfiles` 仓库中的脚本、终端配置或 Stow 模块后，自动化验证配置语法、软链状态、编码兼容性与工作区安全性。

## 验证范围与核心指标

1. **Shell 与 Expect 脚本语法检查**：
   - 校验 `zsh/.zshenv`、`zsh/.zshrc`、`zsh/.zsh/*.zsh` 语法无报错（`zsh -n`）；
   - 校验 `setup.sh`、`nerd-font-smoke-test.sh`、`local/.bin/*` 中的 Bash 脚本语法无报错（`bash -n`）；
   - 校验 `local/.bin/auto_login` 在无参数调用时正常打印帮助信息且退出码为 `0`。
2. **GNU Stow 软链与目录边界核查**：
   - 验证 `~/.bin` 是指向 `dotfiles/local/.bin` 的软链；
   - 验证 `~/.local/bin` 与 `~/.local/share` 为**真实物理目录**（而非指向仓库的目录级软链），确保第三方 CLI 不会污染 Git 仓库；
   - 验证 `stow -n -R -d "$PWD" -t "$HOME" local zsh tmux` 干跑（dry-run）无冲突报错。
3. **Expect 4 字节 UTF-8 (Nerd Fonts v3) 透传校验**：
   - 通过 `/usr/bin/expect` 以 `binary` 通道模式运行 `./nerd-font-smoke-test.sh`，核验输出的 4 字节图标（`󰐊` `f3 b0 90 8a` 等）未被 Tcl 8.5 损坏为 `ó` (`c3 b3`)。
4. **安全与大文件防泄漏检查**：
   - 检查 `git status` 中是否意外混入大于 1MB 的未追踪二进制文件；
   - 检查暂存区是否包含非 `example*` 的 `ssh/.ssh/config.d/` 或 `zsh/.zsh/sshs/hosts/` 私密主机配置。

## 执行指令

### 1. 运行一键全量校验
```bash
# 1. Zsh 与 Bash 语法检查
zsh -n zsh/.zshenv zsh/.zshrc zsh/.zsh/*.zsh
bash -n setup.sh nerd-font-smoke-test.sh

# 2. 目录边界与软链检查
test -L "$HOME/.bin" && echo "OK: ~/.bin is symlink" || echo "FAIL: ~/.bin not symlink"
test ! -L "$HOME/.local/bin" && test -d "$HOME/.local/bin" && echo "OK: ~/.local/bin is real dir" || echo "FAIL: ~/.local/bin should be real dir"

# 3. Expect 4 字节 UTF-8 图标透传验证
/usr/bin/expect -c '
log_user 0
spawn ./nerd-font-smoke-test.sh
fconfigure $spawn_id -encoding binary
fconfigure $user_spawn_id -encoding binary
interact
' | tail -n 1

# 4. 检查 PATH 解析与 Git 状态
zsh -c 'source ~/.zshenv && which auto_login'
git status -s
```
