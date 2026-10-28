# dotfiles

个人跨平台（macOS & Linux/Ubuntu）开发环境与终端配置仓库，基于 [GNU Stow](https://www.gnu.org/software/stow/) 进行符号链接管理，并提供一键式环境初始化与软件编译安装脚本（`setup.sh` 与 `zzz_install_scripts/`）。

作为 AI 编码助手（包括但不限于 Claude Code、Antigravity、Cursor、OpenCode、Codex 等），在本仓库进行任务时必须严格遵守以下架构约定与提交规范。

## Architecture

```
setup.sh                           统一入口脚本（Bash 5+，支持分步安装系统包/语言/应用/Stow链接/macOS设置）
nerd-font-smoke-test.sh            Nerd Fonts 图标与终端字体属性冒烟测试脚本
zsh/
  .zshenv                          环境变量与 PATH 初始化（非交互/交互 Shell 均加载，保持极简快速）
  .zshrc                           交互式 Zsh 入口（按需加载 ~/.zsh/*.zsh 模块）
  .zsh/
    aliases.zsh / aliases/         通用别名与分类别名（git/golang/ffmpeg 等）
    .local_aliases.zsh             本地定制化别名与代理切换工具函数（cmds/cmd）
    zinit.zsh / starship.zsh       插件管理（Zinit）与提示符初始化
    ssh_menu.zsh / sshs/hosts/     基于 fzf + awk 的交互式 SSH 登录菜单（私有主机列表被 gitignore）
    completion/                    自定义补全脚本
local/
  .bin/                            个人编写的可执行脚本（通过 Stow 软链至 ~/.bin，如 auto_login、ta、tat、cht、yank）
  .local/share/                    自定义 man 手册与 bash-completion 补全文件（软链至 ~/.local/share/）
ssh/
  .ssh/config                      SSH 基础配置（Include config.d/*.conf）
  .ssh/config.d/                   SSH 主机配置目录（仅追踪 example*，真实主机配置被 gitignore）
tmux/ & tmuxp/                     Tmux 终端复用器配置（~/.config/tmux）与会话编排模板
wezterm/ & kitty/ & alacritty/     现代 GPU 终端模拟器配置（~/.config/<term>）
iterm2/ & raycast/ & macos/        macOS 专属配置、Raycast 脚本命令与系统 defaults 初始化脚本
git/ & lazygit/ & batcat/ & lf/    Git、LazyGit、Bat、lf、fd 等 CLI 工具配置（~/.config/<tool>）
zzz_install_scripts/
  config.sh / util.sh              安装路径常量（默认 $HOME/tools）与公共日志/编译辅助函数
  sys-apps/apt_install.sh          Linux (Ubuntu/Debian) 系统级依赖安装
  langs/ & install_lang.sh         编程语言环境安装（Go, Rust, Node, Python/Conda, Lua/LuaJIT, Java 等）
  apps/ & install_app.sh           核心 CLI 工具源码编译/二进制安装（Neovim, Tmux, Fzf, Ripgrep, Stow 等）
```

## Key Patterns & Stow 边界纪律

- **GNU Stow 软链机制**：
  - 顶层每个配置模块目录（如 `zsh/`, `tmux/`, `local/`）内部结构镜像 `$HOME` 目录结构。
  - 执行 `stow -R -d "$PWD" -t "$HOME" <module>` 将模块软链至 `$HOME`。
- **个人脚本与第三方 CLI 物理隔离（核心红线）**：
  - **`~/.bin`（对应仓库 `local/.bin/`）**：专门存放个人编写并受 Git 追踪的脚本（如 `auto_login`, `ta`, `tat`, `tks`, `cht`, `yank`, `fcd`, `rmm` 等）。
  - **`~/.local/bin`（本地真实目录，严禁 Stow 软链）**：专供第三方工具（`uv`, `pipx`, `claude`, `cursor-agent`, `omp`, `agy` 等）自动写入二进制或软链，**严禁**将 `~/.local/bin` 软链回本仓库，避免数百 MB 二进制污染 Git 工作区。
- **防止共享目录被 Stow Tree Folding 折叠**：
  - `~/.config`、`~/.local/bin`、`~/.local/share`、`~/.ssh` 必须保持为真实的物理目录，不得被整体折叠为指向仓库的目录级软链。`setup.sh` 在执行 `stow` 前会预先 `mkdir -p` 这些基础目录。
- **Zsh 启动性能分离**：
  - `zsh/.zshenv` 仅放置 `PATH`、Locale 与核心环境变量，**严禁**在 `.zshenv` 中执行耗时命令（如 `brew --prefix` 子进程、交互式插件加载或外部网络调用）。
  - 交互式初始化、补全（`compinit`）、插件（`zinit`）与别名统一放在 `zsh/.zshrc` 及 `zsh/.zsh/*.zsh`。
- **跨平台兼容（macOS & Linux）**：
  - 区分平台的逻辑统一通过 `[[ "$OSTYPE" == darwin* ]]` / `[[ "$OSTYPE" == linux* ]]` 或 `uname -s` 分支处理。
  - macOS 系统自带 `/usr/bin/expect` 基于陈旧的 Tcl 8.5.9（仅支持 3 字节 UTF-8），在编写 Expect 脚本进入 `interact` 前必须设置 `fconfigure $spawn_id -encoding binary` 与 `fconfigure $user_spawn_id -encoding binary`，防止破坏 4 字节 Nerd Font 图标与 Emoji。
- **敏感信息与隐私隔离**：
  - 真实服务器 IP、跳板机密码、私钥与内部域名**严禁**提交到 Git。
  - `ssh/.ssh/config.d/*` 与 `zsh/.zsh/sshs/hosts/*` 仅追踪 `example*` 模板文件，真实配置全部由 `.gitignore` 忽略。

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
./setup.sh -h                                  # 查看安装与配置脚本帮助信息
./setup.sh -c                                  # 仅通过 GNU Stow 重新链接所有配置模块
./setup.sh -n                                  # 检查 Nerd Fonts 安装并运行图标冒烟测试
stow -R -d "$PWD" -t "$HOME" <module>          # 单独重新链接某个配置模块（如 zsh, local, tmux）
zsh -n zsh/.zshenv zsh/.zshrc zsh/.zsh/*.zsh   # 校验所有 Zsh 配置文件语法
bash -n setup.sh nerd-font-smoke-test.sh       # 校验 Bash 脚本语法
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
`zsh`, `bash`, `local`, `auto_login`, `ssh`, `tmux`, `wezterm`, `kitty`, `alacritty`, `iterm2`, `git`, `lazygit`, `starship`, `batcat`, `lf`, `fdfind`, `raycast`, `macos`, `setup`, `install`, `alias`, `config`

示例：
- `fix(auto_login): 修复图标不正常显示的问题`
- `refactor(local): 将个人脚本迁移至 local/.bin 并隔离第三方二进制`
- `perf(zsh): 分离 zshenv 与 zshrc 职责并优化启动速度`
- `feat(raycast): 添加 raycast script commands 播放 pcm 音频`

规则：`subject` 用中文，不加句号，不超过 50 字。优先使用单行提交信息，或按下方标准 3 段式 `-m` 结构组织变更要点。

### 2. 严禁裸用 `cat` 命令（防 alias 装饰符污染）

- **背景**：本地终端环境已将 `cat` 别名（alias）为 `bat`（见 `zsh/.zsh/aliases.zsh`）。直接使用 `cat` 会输出行号和 `STDIN ─────────` 装饰框。
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
