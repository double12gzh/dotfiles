<h1 align="center">
    dotfiles
</h1>

# Usage

```bash
./setup.sh -h
用法: ./setup.sh [选项]

选项:
  -h, --help              显示帮助信息（默认）
  -a, --all               执行所有操作

  -p, --apps               仅安装应用
  -c, --configs            仅链接配置
  -u, --custom             仅显示本地定制化配置信息
  -l, --langs              仅安装编程语言
  -m, --macos              仅配置 macOS 环境
  -n, --nerd-fonts         仅检查 nerd fonts
  -s, --sys-apps           仅安装系统应用

示例:
  ./setup.sh                     # 显示帮助信息
  ./setup.sh -n -l               # 组合使用多个选项
  ./setup.sh --all               # 执行所有操作

================================================
添加新操作步骤:
  1. 在 SUPPORTED_OPERATIONS 数组中添加新操作名称和描述
     例如: declare -A SUPPORTED_OPERATIONS=(["docker"]="仅配置 Docker 环境")

  2. 在 OPERATION_FUNCTIONS 中添加对应的函数映射
     例如: declare -A OPERATION_FUNCTIONS=(["docker"]="setup_docker")

  3. 在 OPTION_MAP 中指定选项映射
     例如: declare -A OPTION_MAP=(["docker"]="-d --docker")

  4. 实现对应的操作函数
     例如:
     function setup_docker() {
         local operation=$1
         blue_echo "----------------------------"
         blue_echo "$operation: 开始配置 Docker 环境..."
         blue_echo "----------------------------"
         # 添加具体的配置命令
         if [[ $? -eq 0 ]]; then
             green_echo "Docker 环境配置成功"
         else
             red_echo "Docker 环境配置失败"
         fi
     }
```

## Prerequest

- Install Perl
- Install Test::Output `cpanm install Test::Output`
- Install Test::More `cpanm install Test::More`
- Install [GNU stow](https://www.gnu.org/software/stow/)

```bash
# NOTE: make sure perl is installed
# NOTE: also, cpanm install Test::Output and Test::More

bash zzz_install_scripts/apps/stow.sh
```

## Stow

- clone this repo

```bash
git clone git@github.com:double12gzh/dotfiles.git ~
```

- create symlink

```bash
stow */

# or

stow Git
```

## Ref

- -D: remove the created symlink.
- -S: create assigned symlink.
- -R: remove & recreate assigned symlink.
- -n: dry-run
