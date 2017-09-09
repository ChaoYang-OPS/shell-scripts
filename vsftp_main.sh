#!/bin/bash
#THis scripts runing is system6 
. /root/vsftp_function.sh
while :
do
  clear
   cat<<EOF
   *************************************
   ******请将文件放到root家目录*********
   *************************************
   ******1 安装vsftpd服务***************
   ******2 配置匿名共享*****************
   ******3 关联网站根目录***************
   ******4 创建虚拟用户*****************
   ******5 依次执行该脚本***************
   ******6 Exit*************************
   **Warning 请按照顺序执行，不然报错***
   *************************************
EOF
  read -p "Pleaset input you select number:" OP
  case $OP in
   1) 
      install_vsftp
      sleep 10
   ;;
   2)
      configure_anonymous
      sleep 10
   ;;
   3) 
      configuer_www
      sleep 10
   ;;
   4)
     configuer_virtuser
     sleep 10
   ;;
   5)
      install_vsftp
      configure_anonymous
      configuer_www
      configuer_virtuser
      sleep 30
   ;;
   6)
     exit
   ;;
   *)
     echo "Error"
 esac
done
