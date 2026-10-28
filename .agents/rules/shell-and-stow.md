# Dotfiles Shell、Stow 与安全完整规范

本规则约束 `dotfiles` 仓库中 Shell 脚本（Zsh / Bash / Expect）、GNU Stow 软链管理以及敏感主机配置的修改行为。

---

## 一、GNU Stow 与目录边界规则

### 1.1 个人脚本与第三方可执行文件隔离
- **个人脚本目录（`local/.bin/` $\rightarrow$ `~/.bin`）**：
  - 仓库中所有个人编写的 Shell / Expect / Python 脚本统一存放在 `local/.bin/` 下，通过 `stow -R local` 软链为 `~/.bin`。
- **第三方二进制目录（`~/.local/bin`）**：
  - `~/.local/bin` 必须保持为 `$HOME` 下的**真实物理目录**，仅供 `uv`、`pipx`、`claude`、`cursor-agent`、`omp`、`agy` 等外部包管理器自动安装二进制文件。
  - **严禁**在 `local/.local/` 下重新创建 `bin` 子目录或将 `~/.local/bin` 软链回本仓库。

### 1.2 防 Tree Folding 目录污染
- 在 `setup.sh` 或手动执行 `stow` 前，必须确保以下共享基础目录已在 `$HOME` 中作为真实目录存在：
  ```bash
  mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.local/share"
  ```
- 重新链接配置模块时统一使用 `-R`（`--restow`）：
  ```bash
  stow -R -d "${SCRIPT_PATH}" -t "${HOME}" "$config"
  ```

---

## 二、Zsh / Bash / Expect 脚本编写规范

### 2.1 Zsh 启动性能红线
- `zsh/.zshenv` 被所有 Zsh 进程（含非交互脚本、IDE 终端探测、子 Shell）加载：
  - 仅允许设置 `PATH`、`fpath`、`LANG`/`LC_ALL`、`XDG_CONFIG_HOME` 等纯变量操作；
  - 使用 `typeset -U path PATH fpath FPATH` 自动去重；
  - **禁止**在 `.zshenv` 中调用外部慢速子进程（如 `$(brew --prefix)`、`eval "$(starship init zsh)"`）或输出任何文本（会破坏 `scp`/`rsync` 等非交互协议）。
- 交互式特性（Zinit 插件、Starship 提示符、`fzf-tab`、别名、按键绑定）必须放在 `zsh/.zshrc` 或 `zsh/.zsh/*.zsh`。

### 2.2 macOS Expect 脚本 UTF-8 编码保护
- macOS 自带 `/usr/bin/expect` 链接的是 Apple 系统内置 **Tcl 8.5.9**（`TCL_UTF_MAX = 3`），其默认 `utf-8` 通道编码无法识别 4 字节 UTF-8 字符（如 Nerd Fonts v3 `nf-md-*` 图标 `U+F0001`..`U+F1AF0` 及 Emoji），会将其拆解为 Latin-1 字符（如 `ó`）。
- 任何使用 `/usr/bin/expect` 并在最后调用 `interact` 的脚本（如 `local/.bin/auto_login`），必须在 `interact` 前将输入输出通道设为 `binary`：
  ```tcl
  fconfigure $spawn_id -encoding binary
  fconfigure $user_spawn_id -encoding binary
  interact
  ```

### 2.3 跨平台兼容规范
- 仓库同时服务于 macOS (`darwin*`) 与 Linux (`linux*`)：
  - 平台专属路径（如 `/opt/homebrew/bin`、`LD_LIBRARY_PATH`、`fcitx`、macOS `networksetup`）必须包裹在 `[[ "$OSTYPE" == darwin* ]]` 或 `[[ "$OSTYPE" == linux* ]]` 判断中。
  - `setup.sh` 使用了 Bash 5+ 关联数组（`declare -A` / `declare -gA`），在 macOS 上运行时需使用 `/opt/homebrew/bin/bash` 而非系统自带的 `/bin/bash` (Bash 3.2)。

---

## 三、隐私与安全红线

### 3.1 禁止提交真实主机凭证
- `ssh/.ssh/config.d/*`（除 `example*` 外）与 `zsh/.zsh/sshs/hosts/*`（除 `example*` 外）已在 `.gitignore` 中排除。
- **严禁**使用 `git add -f` 强制添加包含真实服务器 IP、跳板机地址、用户名、密码或私钥的配置文件。
- 在 `zsh/.zsh/.local_aliases.zsh` 或 `local/.bin/auto_login` 中编写示例时，必须使用占位符（如 `{username}`、`{hostip}`、`{passwd}`）。

---

## 四、提交前检查清单

在执行 `git commit` 前，Agent 必须确保以下检查全部通过：

```bash
# 1. 语法检查
zsh -n zsh/.zshenv zsh/.zshrc zsh/.zsh/*.zsh
bash -n setup.sh nerd-font-smoke-test.sh

# 2. 检查工作区是否混入未忽略的二进制大文件或真实凭证
git status -s
```
