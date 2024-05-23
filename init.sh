#!/bin/bash


function handle_error() {
    echo "错误发生，脚本已终止。错误信息：$1"
    exit 1
}
# 确保在遇到错误时立即退出
set -e
trap 'handle_error $? "脚本执行时发生未知错误"' ERR

function init() {
ubuntu_major_version=$(lsb_release -rs | cut -d. -f1)

# 判断大版本号
if [[ $ubuntu_major_version == "22" ]]; then
    echo "当前系统是Ubuntu 22.x 版本"
    ubuntu22_init
elif [[ $ubuntu_major_version == "24" ]]; then
    # 注意：截至编写此脚本时，Ubuntu 24.04尚未发布
    echo "当前系统是Ubuntu 24.x 版本"
    ubuntu24_init
else
    echo "当前系统是Ubuntu的其他版本: $ubuntu_major_version.x 暂不提供初始化"
fi
apt update && sudo apt upgrade -y
}

function ubuntu22_init() {
#更换清华源
if [[ ! -e "/etc/apt/sources.list.bak" ]]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.bak || { handle_error "备份sources.list失败"; return 1; }
else
    rm /etc/apt/sources.list
fi
touch /etc/apt/sources.list || { handle_error "创建sources.list失败"; return 1; }
cat <<EOF >> /etc/apt/sources.list || { handle_error "写入sources.list内容失败"; return 1; }
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF
echo "清华源更换完成。"
}

function ubuntu24_init() {
#更换清华源
if [[ ! -e "/etc/apt/sources.list.d/ubuntu.sources.bak" ]]; then
    mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak || { handle_error "备份sources.list失败"; return 1; }
else
    rm /etc/apt/sources.list.d/ubuntu.sources
fi
touch /etc/apt/sources.list.d/ubuntu.sources || { handle_error "创建sources.list失败"; return 1; }
 #echo "Types: deb" >> /etc/apt/sources.list.d/ubuntu.sources || handle_error "写入Types失败"
 #echo "URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu/" >> /etc/apt/sources.list.d/ubuntu.sources\
 #|| handle_error "写入/etc/apt/sources.list.d/ubuntu.sources失败"
 #echo "Suites: noble noble-updates noble-security" >> /etc/apt/sources.list.d/ubuntu.sources\
 #|| handle_error "写入/etc/apt/sources.list.d/ubuntu.sources失败"
 #echo "Components: main restricted universe multiverse" >> /etc/apt/sources.list.d/ubuntu.sources\
 #|| handle_error "写入/etc/apt/sources.list.d/ubuntu.sources失败"
 #echo "Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg" >> /etc/apt/sources.list.d/ubuntu.sources\
 #|| handle_error "写入/etc/apt/sources.list.d/ubuntu.sources失败"
cat <<EOF >>  /etc/apt/sources.list.d/ubuntu.sources   || { handle_error "创建sources.list失败"; return 1; }
Types: deb
URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
echo "清华源更换完成。"
}
