# dotfiles

个人跨平台（macOS & Linux/Ubuntu）开发环境与终端配置仓库，基于 [chezmoi](https://www.chezmoi.io/) 进行点文件状态、模板与外部依赖管理（通过 `.chezmoiroot` 将源状态收敛于 `home/` 目录），并提供一键式环境初始化与软件编译安装脚本（`setup.sh` 与 `zzz_install_scripts/`）。

作为 AI 编码助手（包括但不限于 Claude Code、Antigravity、Cursor、OpenCode、Codex 等），在本仓库进行任务时必须严格遵守以下架构约定与提交规范。

## Architecture

```
setup.sh                           统一入口脚本（Bash 5+，支持分步安装系统包/语言/应用/chezmoi配置/macOS设置）
nerd-font-smoke-test.sh            Nerd Fonts 图标与终端字体属性冒烟测试脚本
.chezmoiroot                       声明 home/ 为 chezmoi 源状态根目录（隔离仓库级安装脚本与文档）
home/
  .chezmoi.toml.tmpl               跨机器模板变量定义（Git user.name / user.email 等，支持非交互默认值）
  .chezmoiexternal.toml            外部 Git 仓库声明（自动拉取与更新 .tmux 与 gotest-template，替代 Git Submodule）
  .chezmoiignore                   跨平台条件忽略规则（如非 macOS 忽略 iTerm2、非 Windows 忽略 alacritty_windows.yml）
  dot_zshenv                       环境变量与 PATH 初始化（映射至 ~/.zshenv，保持极简快速）
  dot_zshrc                        交互式 Zsh 入口（映射至 ~/.zshrc，按需加载 ~/.zsh/*.zsh 模块）
  dot_zsh/
    aliases.zsh / aliases/         通用别名与分类别名（git/golang/ffmpeg 等）
    dot_local_aliases.zsh          本地定制化别名与代理切换工具函数（cmds/cmd）
    zinit.zsh / starship.zsh       插件管理（Zinit）与提示符初始化
    executable_ssh_menu.zsh        基于 fzf + awk 的交互式 SSH 登录菜单
    sshs/hosts/                    SSH 菜单主机列表（仅追踪 example*，真实主机位于本地 ~/.zsh/sshs/hosts/）
    standalone/                    单文件便携版 zshrc（minimal / standalone / ohmyzsh，供直接 scp 到远程裸机使用）
    completion/                    自定义补全脚本
  dot_bin/                         个人编写的可执行脚本（executable_* 映射至 ~/.bin/*，如 auto_login、ta、tat、cht、yank）
  dot_local/share/                 自定义 man 手册与 bash-completion 补全文件（映射至 ~/.local/share/）
  private_dot_ssh/
    private_config                 SSH 基础配置（0600 权限，Include config.d/*.conf）
    private_config.d/              SSH 主机配置目录（0700 权限，仅追踪 empty_example.conf）
  dot_config/
    tmux/ & tmuxp/                 Tmux 配置（symlink_tmux.conf*）与会话编排模板
    wezterm/ & kitty/ & alacritty/ 现代 GPU 终端模拟器配置
    iterm2/                        macOS iTerm2 配置
    git/ & lazygit/ & bat/ & lf/   Git（config.tmpl 模板）、LazyGit、Bat、lf、fd、starship 等 CLI 工具配置
raycast/ & macos/ & brew/          macOS 专属 Raycast 脚本命令、系统 defaults 初始化脚本与 Brewfile
zzz_install_scripts/
  config.sh / util.sh              安装路径常量（默认 $HOME/tools）与公共日志/编译辅助函数
  sys-apps/apt_install.sh          Linux (Ubuntu/Debian) 系统级依赖安装
  langs/ & install_lang.sh         编程语言环境安装（Go, Rust, Node, Python/Conda, Lua/LuaJIT, Java 等）
  apps/ & install_app.sh           核心 CLI 工具源码编译/二进制安装（Neovim, Tmux, Fzf, Ripgrep, Chezmoi 等）
```

## Key Patterns & Chezmoi 边界纪律

- **Chezmoi 源状态属性命名约定（位于 `home/` 下）**：
  - 隐藏目录与文件：`.` 前缀映射为 `dot_`（如 `dot_zshenv` $\rightarrow$ `~/.zshenv`，`dot_config/` $\rightarrow$ `~/.config/`）。
  - 可执行脚本：`0755` 脚本添加 `executable_` 前缀（如 `home/dot_bin/executable_auto_login` $\rightarrow$ `~/.bin/auto_login`）。
  - 私密权限：SSH 目录与配置使用 `private_` 前缀（`private_dot_ssh/private_config` 确保 `~/.ssh` 为 `0700`、`~/.ssh/config` 为 `0600`）。
  - 符号链接：使用 `symlink_` 前缀（如 `home/dot_config/tmux/symlink_tmux.conf` 内容为目标路径 `.tmux/.tmux.conf`）。
  - 空文件占位：0 字节文件需添加 `empty_` 前缀（如 `empty_example.conf`），否则会被 chezmoi 默认忽略。
  - 模板文件：以 `.tmpl` 结尾（如 `home/dot_config/git/config.tmpl`），使用 `{{ get . "key" | default "..." }}` 保证无配置文件时亦可安全渲染。
- **个人脚本与第三方 CLI 物理隔离（核心红线）**：
  - **`~/.bin`（对应仓库 `home/dot_bin/`）**：专门存放个人编写并受 Git 追踪的脚本（如 `auto_login`, `ta`, `tat`, `tks`, `cht`, `yank`, `fcd`, `rmm` 等）。
  - **`~/.local/bin`（本地真实目录，严禁纳入仓库）**：专供第三方工具（`chezmoi`, `uv`, `pipx`, `claude`, `cursor-agent`, `omp`, `agy` 等）写入二进制，**严禁**在 `home/dot_local/` 下创建 `bin` 目录。
- **Zsh 启动性能分离**：
  - `home/dot_zshenv` 仅放置 `PATH`、Locale 与核心环境变量，**严禁**在 `.zshenv` 中执行耗时命令（如 `brew --prefix` 子进程、交互式插件加载或外部网络调用）。
  - 交互式初始化、补全（`compinit`）、插件（`zinit`）与别名统一放在 `home/dot_zshrc` 及 `home/dot_zsh/*.zsh`。
- **跨平台兼容（macOS & Linux）**：
  - 区分平台的逻辑统一通过 `[[ "$OSTYPE" == darwin* ]]` / `[[ "$OSTYPE" == linux* ]]`、Chezmoi `.chezmoiignore` 或 `.tmpl` 中 `.chezmoi.os` 分支处理。
  - macOS 系统自带 `/usr/bin/expect` 基于陈旧的 Tcl 8.5.9（仅支持 3 字节 UTF-8），在编写 Expect 脚本进入 `interact` 前必须设置 `fconfigure $spawn_id -encoding binary` 与 `fconfigure $user_spawn_id -encoding binary`，防止破坏 4 字节 Nerd Font 图标与 Emoji。
- **敏感信息与隐私隔离**：
  - 真实服务器 IP、跳板机密码、私钥与内部域名**严禁**明文提交到 Git；仅在本地 `~/.ssh/config.d/` 与 `~/.zsh/sshs/hosts/` 维护（由于 chezmoi 按文件管理而非目录级软链，本地新增文件天然不会污染 Git 工作区）。

## Coding & Scripting Rules

- **Shell 语法与安全**：
  - `setup.sh` 要求 Bash 5.0+（使用关联数组 `declare -A`），顶部声明 `#!/usr/bin/env bash` 与 `set -e`。
  - 修改任何 `.sh` / `.zsh` 脚本后，必须通过 `bash -n <file>` 或 `zsh -n <file>` 语法检查。
- **注释语言**：脚本注释与说明文档统一使用中文。
- **新增 `setup.sh` 操作步骤**：
  1. 在 `SUPPORTED_OPERATIONS` 注册操作名与描述；
  2. 在 `OPERATION_FUNCTIONS` 绑定处理函数；
  3. 在 `OPTION_MAP` 定义短/长选项映射；
  4. 在 `OPERATION_ORDER` 安排执行顺序并实现对应函数。

## Commands

```bash
./setup.sh -h                                                 # 查看安装与配置脚本帮助信息
./setup.sh -c                                                 # 通过 chezmoi 初始化并应用所有配置（自动迁移旧版 Stow 软链）
./setup.sh -n                                                 # 检查 Nerd Fonts 安装并运行图标冒烟测试
chezmoi diff --source "$PWD"                                  # 预览当前仓库对 $HOME 的变更差异
chezmoi apply --source "$PWD"                                 # 将仓库源状态应用到 $HOME
zsh -n home/dot_zshenv home/dot_zshrc home/dot_zsh/*.zsh      # 校验所有 Zsh 配置文件语法
bash -n setup.sh nerd-font-smoke-test.sh                      # 校验 Bash 脚本语法
```

---

## Commit Convention & Git 提交规范 (所有 Agent 强制遵守)

### 1. Commit Message 格式

格式：`<type>(<scope>): <subject>`

类型（`type`）：
- `feat`: 新增功能、脚本或配置模块
- `fix`: 修复脚本/配置 bug 或兼容性问题
- `perf`: 性能优化（如 Zsh 启动耗时优化）
- `refactor`: 重构脚本结构或目录布局（不影响外部行为）
- `style`: 格式、缩进或样式微调
- `docs`: 文档或注释变更
- `chore`: 常规配置同步、依赖或构建辅助变动

Scope 对应配置模块：
`zsh`, `bash`, `local`, `auto_login`, `ssh`, `tmux`, `wezterm`, `kitty`, `alacritty`, `iterm2`, `git`, `lazygit`, `starship`, `batcat`, `lf`, `fdfind`, `raycast`, `macos`, `setup`, `install`, `alias`, `config`, `chezmoi`

示例：
- `fix(auto_login): 修复图标不正常显示的问题`
- `refactor(chezmoi): 将配置管理从 GNU Stow 迁移至 chezmoi`
- `perf(zsh): 分离 zshenv 与 zshrc 职责并优化启动速度`
- `feat(raycast): 添加 raycast script commands 播放 pcm 音频`

规则：`subject` 用中文，不加句号，不超过 50 字。优先使用单行提交信息，或按下方标准 3 段式 `-m` 结构组织变更要点。

### 2. 严禁裸用 `cat` 命令（防 alias 装饰符污染）

- **背景**：本地终端环境已将 `cat` 别名（alias）为 `bat`（见 `home/dot_zsh/aliases.zsh`）。直接使用 `cat` 会输出行号和 `STDIN ─────────` 装饰框。
- **强制规则**：
  - **严禁**使用 `cat <<'EOF'` 或 `cat` 管道生成/写入 commit message，否则会导致提交日志充斥 `STDIN ─` 脏字符！
  - 编写含正文的 commit 时，必须组织为标准 3 段结构（3 个 `-m`：第 1 段为标题，第 2 段为正文变更列表，第 3 段为署名尾注）。**严禁为每条变更点单独分配一个 `-m`**（Git 会在每个 `-m` 之间自动插入空行导致列表稀疏）；所有变更要点必须合并在同一个 `-m` 参数内换行。
  - 读取文件内容优先使用 Agent 专用的读文件工具（Read/View），禁止在 Shell 中使用裸 `cat`。若必须在 Shell 中调用，请使用转义绕过：`\cat`。

### 3. Git 身份归属与 AI 协同署名规范（架构 2：人类主权 + AI 审计）

- **Author & Committer 归属人类**：执行 `git commit` 时，必须直接继承并使用当前操作者本地配置的个人身份（`user.name` 与 `user.email`），**严禁**使用 `--author` 或 `GIT_COMMITTER_*` 篡改或抹除人类主责任人。
- **AI 协同署名（强制附加）**：提交信息末尾**必须显式附加** `Co-Authored-By: ClaudeCode <noreply@anthropic.com>`（或对应 Agent，如 `Gemini <noreply@google.com>`）尾注。
- **名称与邮箱规范**：Claude Code 统一使用 `ClaudeCode <noreply@anthropic.com>`（严禁使用内部代号或带版本号的模型名）。
- **标准提交命令模板**：
  ```bash
  git commit -m "<type>(<scope>): <subject>" \
    -m "- <变更要点 1>
  - <变更要点 2>" \
    -m "Co-Authored-By: ClaudeCode <noreply@anthropic.com>"
  ```

### 4. 独立功能变更与 Worktree 隔离

- 在进行跨模块实验性特性开发、大型重构或未经用户显式要求在主工作区修改的独立功能时，优先使用 `git worktree` 创建隔离分支：
  ```bash
  git worktree add ../dotfiles-{name} -b feature/{YYYYMMDDHHmmss}-{name}
  ```
