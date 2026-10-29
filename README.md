<h1 align="center">
    dotfiles
</h1>

# Usage

Clone this repo and execute `./setup.sh -h` to check parameters:

```bash
./setup.sh -h
用法: ./setup.sh [选项]

选项:
  -h, --help              显示帮助信息（默认）
  -a, --all               执行所有操作

  -p, --apps               仅安装应用
  -c, --configs            仅通过 chezmoi 应用配置
  -u, --custom             仅显示本地定制化配置信息
  -l, --langs              仅安装编程语言
  -m, --macos              仅配置 macOS 环境
  -n, --nerd-fonts         仅检查 nerd fonts
  -s, --sys-apps           仅安装系统应用

示例:
  ./setup.sh                     # 显示帮助信息
  ./setup.sh -c                  # 仅通过 chezmoi 应用配置
  ./setup.sh -n -l               # 组合使用多个选项
  ./setup.sh --all               # 执行所有操作
```

## Chezmoi

This repository uses [chezmoi](https://www.chezmoi.io/) with `.chezmoiroot` pointing to `home/`.

- Install `chezmoi` and apply configurations in one step via `setup.sh`:

```bash
./setup.sh -c
```

- Or use `chezmoi` directly:

```bash
# Initialize and apply from local checkout
chezmoi init --apply --source "$PWD"

# Preview pending changes before applying
chezmoi diff --source "$PWD"

# Apply updates
chezmoi apply --source "$PWD"
```
