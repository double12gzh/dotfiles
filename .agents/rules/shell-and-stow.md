# Dotfiles Shell、Chezmoi 与安全完整规范

本规则约束 `dotfiles` 仓库中 Shell 脚本（Zsh / Bash / Expect）、Chezmoi 源状态管理以及敏感主机配置的修改行为。

---

## 一、Chezmoi 与目录边界规则

### 1.1 源状态目录与前缀规范
- 仓库根目录通过 `.chezmoiroot` 将源状态收敛在 `home/` 下，根级安装脚本（`setup.sh`、`zzz_install_scripts/` 等）不会污染 `$HOME`。
- `home/` 内文件严格遵守 Chezmoi 命名属性：
  - `dot_` 表示以 `.` 开头的隐藏文件或目录；
  - `executable_` 表示目标文件权限为 `0755`（源文件中保持 `0644` 即可）；
  - `private_` 表示目标文件/目录权限为 `0600`/`0700`（如 `home/private_dot_ssh/private_config`）；
  - `symlink_` 表示目标为符号链接（文件内容为指向的目标路径）；
  - `empty_` 表示允许创建 0 字节空文件（如 `empty_example.conf`）；
  - `.tmpl` 表示 Go `text/template` 模板文件。

### 1.2 个人脚本与第三方可执行文件隔离
- **个人脚本目录（`home/dot_bin/` $\rightarrow$ `~/.bin`）**：
  - 仓库中所有个人编写的 Shell / Expect / Python 脚本统一存放在 `home/dot_bin/executable_<name>`，由 Chezmoi 同步至 `~/.bin/<name>`。
- **第三方二进制目录（`~/.local/bin`）**：
  - `~/.local/bin` 必须保持为 `$HOME` 下的真实物理目录，仅供 `chezmoi`、`uv`、`pipx`、`claude`、`cursor-agent`、`omp`、`agy` 等外部工具写入二进制文件。
  - **严禁**在 `home/dot_local/` 下创建 `bin` 子目录。

---

## 二、Zsh / Bash / Expect 脚本编写规范

### 2.1 Zsh 启动性能红线
- `home/dot_zshenv` 被所有 Zsh 进程（含非交互脚本、IDE 终端探测、子 Shell）加载：
  - 仅允许设置 `PATH`、`fpath`、`LANG`/`LC_ALL`、`XDG_CONFIG_HOME` 等纯变量操作；
  - 使用 `typeset -U path PATH fpath FPATH` 自动去重；
  - **禁止**在 `.zshenv` 中调用外部慢速子进程（如 `$(brew --prefix)`、`eval "$(starship init zsh)"`）或输出任何文本（会破坏 `scp`/`rsync` 等非交互协议）。
- 交互式特性（Zinit 插件、Starship 提示符、`fzf-tab`、别名、按键绑定）必须放在 `home/dot_zshrc` 或 `home/dot_zsh/*.zsh`。

### 2.2 macOS Expect 脚本 UTF-8 编码保护
- macOS 自带 `/usr/bin/expect` 链接的是 Apple 系统内置 **Tcl 8.5.9**（`TCL_UTF_MAX = 3`），其默认 `utf-8` 通道编码无法识别 4 字节 UTF-8 字符（如 Nerd Fonts v3 `nf-md-*` 图标 `U+F0001`..`U+F1AF0` 及 Emoji），会将其拆解为 Latin-1 字符（如 `ó`）。
- 任何使用 `/usr/bin/expect` 并在最后调用 `interact` 的脚本（如 `home/dot_bin/executable_auto_login`），必须在 `interact` 前将输入输出通道设为 `binary`：
  ```tcl
  fconfigure $spawn_id -encoding binary
  fconfigure $user_spawn_id -encoding binary
  interact
  ```

### 2.3 跨平台兼容规范
- 仓库同时服务于 macOS (`darwin*`) 与 Linux (`linux*`)：
  - 平台专属配置文件在 `home/.chezmoiignore` 中按 `.chezmoi.os` 条件排除；
  - Shell 脚本中的平台专属路径必须包裹在 `[[ "$OSTYPE" == darwin* ]]` 或 `[[ "$OSTYPE" == linux* ]]` 判断中。

---

## 三、隐私与安全红线

### 3.1 禁止提交真实主机凭证
- `home/private_dot_ssh/private_config.d/*`（除 `*example*` 外）与 `home/dot_zsh/sshs/hosts/*`（除 `*example*` 外）已在 `.gitignore` 中排除。
- **严禁**使用 `git add -f` 强制添加包含真实服务器 IP、跳板机地址、用户名、密码或私钥的配置文件。
- 在 `home/dot_zsh/dot_local_aliases.zsh` 或 `home/dot_bin/executable_auto_login` 中编写示例时，必须使用占位符（如 `{username}`、`{hostip}`、`{passwd}`）。

---

## 四、提交前检查清单

在执行 `git commit` 前，Agent 必须确保以下检查全部通过：

```bash
# 1. 语法检查
zsh -n home/dot_zshenv home/dot_zshrc home/dot_zsh/*.zsh
bash -n setup.sh nerd-font-smoke-test.sh

# 2. 检查工作区是否混入未忽略的二进制大文件或真实凭证
git status -s
```
