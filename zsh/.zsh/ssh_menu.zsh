#!/bin/zsh

default_ssh_config="$HOME/.ssh/config"
custom_ssh_config="$HOME/.zsh/sshs/hosts"
ssh_config_awk="$HOME/.zsh/sshs/ssh_config.awk"

myssh ()
{
    # 如果提供了文件名，会使用 $custom_ssh_config/文件名
    # 如果没有提供，则使用 $HOME/.ssh/config
    # 提供文件的内容示例如下：
    # Host root@127.0.0.1
    #   Message: xxxxx
    # Host 169.254.169.254
    #   Info: xxxx
    # 文件路径: $HOME/.zsh/sshs/hosts

    [ $# -eq 1 ] && ssh_config=$custom_ssh_config/$1 || ssh_config=$default_ssh_config

    host=$(grep '^[[:space:]]*Host[[:space:]]' $ssh_config | cut -d ' ' -f 2 | fzf --height=20% --reverse --prompt="SSH > " --preview="awk -v HOST={} -f $ssh_config_awk $ssh_config")

    [ $? -eq 0 ] && ssh "$host"
}
