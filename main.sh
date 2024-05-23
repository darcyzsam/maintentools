#!/bin/bash
source ./init.sh
source ./info.sh
source ./setup_docker.sh
source ./setup_nodejs.sh


function handle_error() {
   echo "错误发生。错误信息：$1"
}



trap 'handle_error $? "脚本执行时发生未知错误"' ERR
function main_menu() {
    while true; do
        clear
        echo "1. 系统信息"
        echo "2. 系统初始化,换apt源"
        echo "3. 安装Docker"
        echo "4. 安装NodeJs,Npm,Pm2"
        read -p "请输入选项（1-4）: " OPTION

        
        case $OPTION in
        1)
            sysinfo
            #process_port_info
            ;;
        2)
            init
            ;;
        3)
            setup_docker
            ;;
        4)
            install_nodejs_and_npm_and_pm2
            ;;
        *)
            echo "无效选项。"
            ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
    
}

# 显示主菜单
main_menu
