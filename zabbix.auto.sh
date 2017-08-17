#!/bin/bash
#注意使用该脚本时，必须确定你服务器可以正常上网和配置好本地yum源
#关闭防火墙和Selinux
setenforce 0 && systemctl stop firewalld 
yum install wget -y
#配置网络源
#wget http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
#rpm -ivh zabbix-release-3.2-1.el7.noarch.rpm
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
#sed -i 's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo
yum clean all && yum install  zabbix-get zabbix-server zabbix-web-mysql zabbix-web zabbix-agent -y
yum install mariadb-server -y #安装数据库
#启动服务
systemctl start mariadb && systemctl enable mariadb
#设置数据库的root密码
mysqladmin -uroot password yang 
mysql -uroot -pyang -e 'create database zabbix character set utf8;'
\mysql -uroot -pyang -e 'grant all privileges on zabbix.* to zabbix@localhost identified by "zabbix";'
mysql -uroot -pyang -e 'flush privileges;'
cd /usr/share/doc/zabbix-server-mysql-3.2.6/
gzip -d create.sql.gz
mysql -uzabbix -pzabbix zabbix < create.sql
#配置zabbix_server.conf
sed -i 's/# DBPassword=/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf 
mkdir /etc/zabbix/{alertscripts,externalscriptscripts}
#启动zabbix-server和httpd服务
systemctl start zabbix-server && systemctl start httpd
#设置开机启动
systemctl enable zabbix-server && systemctl enable httpd 
#修改php.ini文件
sed -i 's_;date.timezone =_date.timezone = Asia/Shanghai_' /etc/php.ini 
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini 
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php.ini 
systemctl restart httpd
echo "install successful"
echo "访问使用http://IP/zabbix"

