#!/bin/bash

function handle_error() {
    echo "错误发生，脚本已终止。错误信息：$1"
    exit 1
}
set -e
trap 'handle_error $? "脚本执行时发生未知错误"' ERR
# 获取Node.js 16以上的版本号

function install_nodejs_and_npm_and_pm2() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，准备安装..."
        fetch_versions
        
        select_version "$versions"
        if [[ ! "$version_index" =~ ^[0-9]+$ ]] || (( version_index < 0 || version_index >= ${#versions[@]} )); then
          echo "返回主菜单"
          return 0
        fi
        selected_version=${versions[$version_index]}
        echo "安装$selected_version版本"
        doinstall
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        apt-get install -y npm
    fi

    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}
# 主程序
function fetch_versions() {
  versions=$(get_node_versions)
  if [ -z "$versions" ]; then
    echo "提取官方版本失败，请检查网络"
    exit 1
  fi

}

function get_node_versions() {
  curl -s https://nodejs.org/dist/index.json | jq -r '.[] | select(.lts != false) | .version' | \
  sort -Vr | awk -F'[v.]' '$2 >= 16 && !seen[$2]++ {print $2}'\
  || { handle_error "获取nodejs版本json文件失败"; return 1; }
}

# 提示用户选择版本
function select_version() {
  versions=($1)
  if [ ${#versions[@]} -eq 0 ]; then
    echo "没找到nodejs版本"
    exit 1
  fi

  echo "Nodejs版本有: "
  for i in "${!versions[@]}"; do
    echo "$i)安装版本：${versions[$i]}"
  done
  echo "*) 返回主菜单"
  echo ""
  read -r -p  "输入选择: " version_index

  
}

# 安装选择的版本
function doinstall() {
  curl -fsSL https://deb.nodesource.com/setup_${selected_version%%.*}.x | bash -
  apt-get install -y nodejs
  echo "Node.js $selected_version 版本安装完成"
}

