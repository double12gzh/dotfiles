---
name: verify_dotfiles
description: 自动执行 dotfiles 仓库全链路健康检查与配置校验，覆盖 Zsh/Bash/Expect 脚本语法、Chezmoi 源状态渲染、~/.bin 与 ~/.local/bin 目录隔离、Nerd Fonts 4 字节 UTF-8 图标透传及敏感配置防泄漏检查。
---

# Verify Dotfiles Configuration & Environment Skill

使用此 Skill 在修改 `dotfiles` 仓库中的脚本、终端配置或 Chezmoi `home/` 源状态后，自动化验证配置语法、模板渲染、编码兼容性与工作区安全性。

## 验证范围与核心指标

1. **Shell 与 Expect 脚本语法检查**：
   - 校验 `home/dot_zshenv`、`home/dot_zshrc`、`home/dot_zsh/*.zsh` 语法无报错（`zsh -n`）；
   - 校验 `setup.sh`、`nerd-font-smoke-test.sh` 语法无报错（`bash -n`）；
   - 校验 `home/dot_bin/executable_auto_login` 在无参数调用时正常打印帮助信息且退出码为 `0`。
2. **Chezmoi 源状态与目录边界核查**：
   - 验证 `chezmoi managed --source "$PWD"` 与模板渲染无报错；
   - 验证 `home/dot_local/` 下不存在 `bin` 目录，确保 `~/.local/bin` 保持独立物理目录；
   - 验证 `~/.ssh` 与 `~/.ssh/config` 在目标侧具备 `0700` / `0600` (`private_`) 权限。
3. **Expect 4 字节 UTF-8 (Nerd Fonts v3) 透传校验**：
   - 通过 `/usr/bin/expect` 以 `binary` 通道模式运行 `./nerd-font-smoke-test.sh`，核验输出的 4 字节图标未被 Tcl 8.5 损坏。
4. **安全与大文件防泄漏检查**：
   - 检查 `git status` 中是否意外混入大于 1MB 的未追踪二进制文件；
   - 检查暂存区是否包含非 `*example*` 的私密主机配置。

## 执行指令

```bash
# 1. Zsh 与 Bash 语法检查
zsh -n home/dot_zshenv home/dot_zshrc home/dot_zsh/*.zsh home/dot_zsh/aliases/*.zsh home/dot_zsh/standalone/*
bash -n setup.sh nerd-font-smoke-test.sh zzz_install_scripts/apps/chezmoi.sh

# 2. Chezmoi 源状态与模板校验
chezmoi managed --source "$PWD" >/dev/null && echo "OK: chezmoi source state valid"

# 3. Expect 4 字节 UTF-8 图标透传验证
/usr/bin/expect -c '
log_user 0
spawn ./nerd-font-smoke-test.sh
fconfigure $spawn_id -encoding binary
fconfigure $user_spawn_id -encoding binary
interact
' | tail -n 1

# 4. 检查 Git 状态
git status -s
```
