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
    #   cmd: ls -alh
    #   tag: red,xxx
    #   password: 12345
    # 文件路径: $HOME/.zsh/sshs/hosts

    [ $# -eq 1 ] && ssh_config=$custom_ssh_config/$1 || ssh_config=$default_ssh_config

    host=$(grep '^[[:space:]]*Host[[:space:]]' $ssh_config | cut -d ' ' -f 2 | fzf --height=20% --reverse --prompt="SSH > " --preview="awk -v SEC=1  -v HOST={} -f $ssh_config_awk $ssh_config")
    cmd=$(awk -v SEC=0 -v HOST=$host -f $ssh_config_awk $ssh_config | awk -F ':'  '{sub(/^ +/, "", $2);if ($1 == "cmd") print $2}')
    passwd=$(awk -v SEC=0 -v HOST=$host -f $ssh_config_awk $ssh_config | awk -F ':'  '{sub(/^ +/, "", $2);if ($1 == "password") print $2}')

    [ $? -eq 0 ] && sshpass -p "$passwd" ssh "$host" "$cmd"
}

mycolorfulssh ()
{
    # 如果提供了文件名，会使用 $custom_ssh_config/文件名
    # 如果没有提供，则使用 $HOME/.ssh/config
    # 提供文件的内容示例如下：
    # Host root@127.0.0.1
    #   Message: xxxxx
    #   tag: red,xx (必填)
    # Host 169.254.169.254
    #   Info: xxxx
    #   cmd: ls -alh
    #   password: 1234565
    #   tag: red,xx(必填)
    # 文件路径: $HOME/.zsh/sshs/hosts

    [ $# -eq 1 ] && ssh_config=$custom_ssh_config/$1 || ssh_config=$default_ssh_config

    # begin: with color
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    magenta=$(tput setaf 5)
    cyan=$(tput setaf 6)
    reset_color=$(tput sgr0)

    hosts=($(awk '/^Host / {print $2}' $ssh_config))
    tags=($(awk '/^    tag/ {print $2}' $ssh_config))
    formatted_options=""
    for (( i = 1; i <= ${#hosts[@]}; i++ )); do
        tag=${tags[$i]//\"/} # Remove quotes and whitespace from tag value
        tag=$(echo $tag | tr -d '[:space:]')
        if [[ "$tag" =~ "red" ]]; then
                color="$red"
        elif [[ "$tag" =~ "green" ]]; then
                color="$green"
        elif [[ "$tag" =~ "blue" ]]; then
                color="$blue"
        elif [[ "$tag" =~ "cyan" ]]; then
                color="$cyan"
        elif [[ "$tag" =~ "yellow" ]]; then
                color="$yellow"
        elif [[ "$tag" =~ "magenta" ]]; then
                color="$magenta"
        else
                color=""
        fi
        formatted_options+="${color}${hosts[$i]}${reset_color}\n"
    done
    host=$(echo -ne "$formatted_options" | fzf --ansi --height=20% --reverse --prompt="SSH > " --preview="awk -v SEC=1  -v HOST={} -f $ssh_config_awk $ssh_config")
    # end: with color

    cmd=$(awk -v SEC=0 -v HOST=$host -f $ssh_config_awk $ssh_config | awk -F ':'  '{sub(/^ +/, "", $2);if ($1 == "cmd") print $2}')
    passwd=$(awk -v SEC=0 -v HOST=$host -f $ssh_config_awk $ssh_config | awk -F ':'  '{sub(/^ +/, "", $2);if ($1 == "password") print $2}')

    [ $? -eq 0 ] && ssh -p "$passwd" ssh "$host" "$cmd"
}
