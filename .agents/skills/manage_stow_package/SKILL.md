---
name: manage_stow_package
description: 指导在 dotfiles 仓库中新增、迁移或重构 GNU Stow 配置模块及个人脚本的标准流程，确保正确注册到 setup.sh 并避免 Stow 目录折叠污染 ~/.config 或 ~/.local。
---

# Manage GNU Stow Package & Scripts Skill

当需要在 `dotfiles` 仓库中新增一个工具的配置目录（如新增某个 CLI/终端配置）、添加新的个人可执行脚本或重构现有 Stow 模块路径时使用此 Skill。

## 标准操作流程

### 场景 A：新增个人可执行脚本
1. **存放位置**：
   所有个人编写的脚本统一放入 `local/.bin/<script_name>`，**严禁**放入 `local/.local/bin` 或直接只写在 `~/.local/bin`。
2. **赋予可执行权限**：
   ```bash
   chmod +x local/.bin/<script_name>
   ```
3. **验证生效**：
   由于 `~/.bin` 已通过 Stow 软链至 `dotfiles/local/.bin` 且已在 `zsh/.zshenv` 中加入 `PATH`，新脚本立即可通过 `which <script_name>` 访问。

### 场景 B：新增一个独立的配置模块（Stow Package）
1. **按 `$HOME` 相对结构创建目录**：
   - 若目标路径为 `~/.config/<app>/config.toml`，则在仓库根目录创建：
     ```bash
     mkdir -p <app>/.config/<app>
     ```
   - 若目标路径直接位于 `$HOME/.<rcfile>`，则创建：
     ```bash
     mkdir -p <app>
     ```
2. **防止运行时状态文件污染 Git**：
   - 如果该应用会在其配置目录内自动生成运行状态、缓存或历史文件（例如 `lazygit` 的 `state.yml`、`iterm2` 的 `AppSupport`），必须在 `.gitignore` 中将其排除。
3. **注册到 `setup.sh`**：
   - 编辑 `setup.sh` 中的 `stow_configs` 数组，将 `<app>` 加入列表。
4. **执行链接与验证**：
   ```bash
   mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.local/share"
   stow -R -d "$PWD" -t "$HOME" <app>
   ls -la "$HOME/.config/<app>"
   ```

### 场景 C：迁移或重命名已有模块中的子目录
1. 使用 `git mv` 移动受 Git 追踪的文件；
2. 若原目录曾被 Stow 折叠为目录软链（如旧软链指向已删除的仓库子目录），先移除 `$HOME` 下失效的软链；
3. 运行 `stow -R -d "$PWD" -t "$HOME" <module>` 重新建立软链；
4. 全局搜索仓库内是否有硬编码旧路径的脚本或别名（`grep -rn "<old_path>" .`），并同步更新。
