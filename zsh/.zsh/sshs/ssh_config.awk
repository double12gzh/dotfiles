# 解析~/.ssh/config 文件或用户提供的文件

BEGIN {
    n = 0
    red = "\033[0;31m"
    green = "\033[0;32m"
    blue = "\033[0;34m"
    reset_color = "\033[0m"
}

# 过滤注释
/^$/ || /^#/ {
    next
}

# 找到后退出
($1 == "Host" || $1 == "Match") && did_find_host {
    exit
}

# 查找用户输入的 Host
$1 == "Host" && $2 ~ HOST {
    did_find_host = 1
    next
}

did_find_host {
    keys[n] = $1

    temp_value = ""
    for (i= 2; i <=NF; ++i)
        temp_value = sprintf("%s %s", temp_value, $i)
    values[n++] = temp_value

    width = max(length($1), width)
}

END {
    for (i = 0; i < n; ++i)
        if (SEC == "1" && keys[i] == "password:" ) {
            printf "%-"width"s  %s\n", keys[i], "***"
        } else {
            if (keys[i] == "tag:" && index(values[i], "red") != 0) {
                printf "%s%-"width"s  %s%s\n", red, keys[i], values[i], reset_color
            } else if (keys[i] == "tag:" && index(values[i], "green") != 0){
                printf "%s%-"width"s  %s%s\n", green, keys[i], values[i], reset_color
            } else if (keys[i] == "tag:" && index(values[i], "blue") != 0){
                printf "%s%-"width"s  %s%s\n", blue, keys[i], values[i], reset_color
            } else {
                printf "%-"width"s  %s\n", keys[i], values[i]
            }
        }
}

function max(a, b) {
    return a > b ? a : b
}
