#!/bin/bash

function handle_error() {
    echo "错误发生，脚本已终止。错误信息：$1"
    exit 1
}

set -e

trap 'handle_error $? "脚本执行时发生未知错误"' ERR

function setup_docker {
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg lsb-release apt-transport-https  software-properties-common\
  || { handle_error "apt-get install 失败"; return 1; }

  # 添加 Docker 官方 GPG 密钥
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o  /tmp/docker.gpg\
  || { handle_error "添加 Docker 官方 GPG 密钥 失败"; return 1; }
 mv -f /tmp/docker.gpg /etc/apt/keyrings/docker.gpg

  # 设置 Docker 仓库
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null\
  || { handle_error "设置 Docker 仓库 失败"; return 1; }

  # 授权 Docker 文件
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  sudo apt-get update
  # 更新APT包列表
  sudo apt-get update -qq

  # 获取Docker最新版本号
  latest_version=$(apt-cache madison docker-ce | head -n 1 | awk '{print $3}')
if command -v docker &> /dev/null 
then
  local_version=$(docker version --format '{{.Server.Version}}')
fi

  # 输出最新版本
echo "Docker 信息#################################"
echo "Docker官方最新版本: $latest_version"
if [ -v local_version ]; then
  echo "Docker本地版本:$local_version"
fi

  # 安装 Docker 最新版本
  read -p "要安装最新版本Docker吗？(y/n)" agree_setup
  case "$agree_setup" in
  [yY][eE][sS]|[yY]|"")
        echo "开始安装Docker最新版本."
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y\
        || { handle_error "安装 Docker 最新版本 失败"; return 1; };;
    *) echo "取消操作";;
  esac
}
