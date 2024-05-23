#!/bin/bash


ESC="\033["

# 文本颜色设置函数
color_text() {
    local color=$1
    local text=$2
    echo -en "${ESC}${color}${text}${ESC}0m"
}

function sysinfo() {
set +e
# 获取当前终端的列数
term_columns=$(tput cols)
two_thirds_columns=$((term_columns * 2 / 3))
# 打印到屏幕边缘的 '#' 字符
printf '%*s\n' "$two_thirds_columns" | tr ' ' '#'
printf '\n'

# CPU型号和核心数量
color_text  "32m" "CPU Info:"
echo ""
echo "CPU Module: $(lscpu | grep 'Model name' | awk -F: '{print $2}' | sed 's/^[ \t]*//')"
echo "CPU Cors: $(nproc)"
echo ""
# 内存信息

color_text  "32m" "Memory Info:"
echo ""
free_info=$(free -m)
echo "Total Memory: $(echo "$free_info" | awk '/Mem/{print $2}') MB"
echo "Used Memory: $(echo "$free_info" | awk '/Mem/{printf "%.2f", $3/$2*100}')%"

echo ""

color_text  "32m" "Network Info:"
echo ""
ip addr show | awk '/inet / && !/127.0.0.1/{print "IP address: " $2}'
ip route | awk '/default via/{print "default route: " $3}'
echo "DNS Sever: $(grep 'nameserver' /etc/resolv.conf | awk '{print "DNS: " $2}')"
echo ""

color_text  "32m" "Disk Info:"
echo ""
partition_width=$((term_columns * 1 / 8))
fstype_width=$((term_columns * 1 / 8))
pct_used_width=$((term_columns * 1 / 8))
pct_avail_width=$((term_columns * 1 / 8))
mountpoint_width=$((term_columns * 2 / 8))

# 更新后的表头，显示百分比
printf "%-${partition_width}s %-${fstype_width}s %-${pct_used_width}s %-${pct_avail_width}s %-${mountpoint_width}s\n" \
       "Partition" "FS type" "Total Size" "Used%" "Mount Point"

# 使用df命令获取硬盘信息，移除第一行，并通过awk计算已用和可用空间的百分比，修正了列的引用
df -hT | tail -n +2 | awk -v pwidth="$partition_width" -v fstypewidth="$fstype_width" -v \
puwidth="$pct_used_width" -v pawidth="$pct_avail_width" -v mwidth="$mountpoint_width" '
    {
        printf("%-" pwidth "s %-" fstypewidth "s %-" puwidth "s %-" pawidth "s %-" mwidth "s\n", $1, $2, $3,$6, $7);
    }'
printf '\n'
color_text  "32m" "Docker Info:"
if ! command -v docker &> /dev/null || { handle_error "执行docker命令失败"; }
then
    color_text "31m" "Docker 未安装"
else
    docker_version=$(docker version --format '{{.Server.Version}}')
    color_text "32m" "Docker 已安装 Version: $docker_version"
fi
echo ""
 process_port_info
}

function process_port_info() {
    color_text  "32m" "Port Info:"
    echo ""
    # 获取当前终端的列数
    term_columns=$(tput cols)
    w_port=$((term_columns * 1 / 10))
    w_pid=$((term_columns * 1 / 10))
    w_command=$((term_columns * 1 / 6))
    w_cpu=$((term_columns * 1 / 10))
    w_mem=$((term_columns * 1 / 10))
    w_stat=$((term_columns * 1 / 10))
    w_lstart=$((term_columns * 1 / 6))
    w_etime=$((term_columns * 1 / 6))

    # 输出表头
    printf "%-${w_port}s %-${w_pid}s %-${w_command}s %-${w_cpu}s %-${w_mem}s %-${w_stat}s %-${w_lstart}s %-${w_etime}s\n" \
    "Port" "Pid" "Command" "Cpu%" "Mem(kb)" "Stat" "Launch Time" "Estimate Time"

    # 获取所有监听端口及对应PID
    ports_info=$(sudo lsof -iTCP -sTCP:LISTEN -P -n | tail -n +2)

    # 遍历端口信息，获取每个端口对应的详细进程信息
    while IFS= read -r line; do
        # 提取PID
        pid=$(echo "$line" | awk '{print $2}')

        port=$(echo "$line" | awk '{print $9}')
    #   echo "port=$port"

        # 获取进程信息
        process_info=$(ps -p "$pid" -o pid,comm,%cpu,rss,stat,lstart,etime --no-headers 2>/dev/null)
        all="$port $process_info"
        # 打印端口和进程信息
        echo "$all" | awk -v vport="$w_port" -v vpid="$w_pid" -v vcmd="$w_command" -v vcpu="$w_cpu" -v vmem="$w_mem" \
            -v vstat="$w_stat" -v vls="$w_lstart" -v vet="$w_etime" '
        {
            year=$11
            month=$8
            day=$9
            time=$10
            formatted_date_time = sprintf("%04d-%s-%02d %s", year, month, day, time)
        
            printf("%-" vport "s %-" vpid "s %-" vcmd "s %-" vcpu "s %-" vmem "s %-" vstat "s %-" vls "s %-" vet "s\n", \
            $1, $2, $3, $4, $5, $6, formatted_date_time, $12);
        }'
    done <<< "$ports_info"
    set -e
}