---
name: manage_stow_package
description: 指导在 dotfiles 仓库（基于 chezmoi）中新增、迁移或重构配置模块及个人脚本的标准流程，确保正确遵循 home/ 下的 chezmoi 属性前缀命名并隔离 ~/.local/bin。
---

# Manage Chezmoi Dotfiles & Scripts Skill

当需要在 `dotfiles` 仓库中新增一个工具的配置目录（如新增某个 CLI/终端配置）、添加新的个人可执行脚本或重构现有 `home/` 模块路径时使用此 Skill。

## 标准操作流程

### 场景 A：新增个人可执行脚本
1. **存放位置与命名**：
   所有个人编写的可执行脚本统一放入 `home/dot_bin/executable_<script_name>`（若为非可执行数据文件则不加 `executable_` 前缀），**严禁**放入 `home/dot_local/bin`。
2. **应用生效**：
   ```bash
   chezmoi apply --source "$PWD" ~/.bin/<script_name>
   ```
   Chezmoi 会自动将其安装至 `~/.bin/<script_name>` 并赋予 `0755` 可执行权限。

### 场景 B：新增一个独立的配置模块
1. **按 Chezmoi 源状态规则在 `home/` 下创建目录**：
   - 若目标路径为 `~/.config/<app>/config.toml`，则在仓库中创建：
     ```bash
     mkdir -p home/dot_config/<app>
     ```
   - 若目标路径直接位于 `$HOME/.<rcfile>`，则创建 `home/dot_<rcfile>`。
   - 若需要跨平台条件忽略（如仅限 macOS 或 Linux），在 `home/.chezmoiignore` 中添加条件判断。
   - 若包含多机差异变量（如用户名、邮箱、路径），将文件命名为 `<file>.tmpl` 并在 `home/.chezmoi.toml.tmpl` 中声明默认变量。
2. **预览与应用**：
   ```bash
   chezmoi diff --source "$PWD"
   chezmoi apply --source "$PWD"
   ```
