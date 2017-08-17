#!/bin/bash
#auto install LNMP scripts
#配置好本地源和网络源
#注意该脚本也可以在Centos6系统上执行，需要修改第190行内容wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo，就ok
#关闭Firewalld和SELINUX
setenforce 0 && iptables -F && cd ~
yum install wget -y >/dev/null
wget https://ftp.pcre.org/pub/pcre/pcre-8.38.tar.gz
tar -xf pcre-8.38.tar.gz -C /usr/local/src/
#解决依赖
yum -y install make gcc gcc-c++ flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel gd freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel gettext gettext-devel ncurses-devel gmp-devel unzip libcap lsof
#download nginx
wget http://nginx.org/download/nginx-1.13.4.tar.gz
tar -xf nginx-1.13.4.tar.gz -C /usr/local/src/
cd /usr/local/src/nginx-1.13.4/
./configure --prefix=/usr/local/nginx --with-http_dav_module --with-http_stub_status_module --with-http_addition_module --with-http_sub_module --with-http_flv_module --with-http_mp4_module --with-pcre=/usr/local/src/pcre-8.38/
[ $? -eq 0 ] && make -j 2 && make install 
[ $? -eq 0 ] && echo "nignx install successfull"
#添加运行Nginx服务的用户
useradd -M -s /sbin/nologin -r nginx 
#修改配置文件，让Nginx支持PHP页面解析
cat > /usr/local/nginx/conf/nginx.conf <<WWW
user nginx nginx;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.php index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html$fastcgi_script_name;
            include        fastcgi_params;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.php index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.php index.html index.htm;
    #    }
    #}

}
WWW
#sed -i 's/#user  nobody;/user nginx nginx;/' /usr/local/nginx/conf/nginx.conf
#sed -i 's/index  index.html index.htm;/index  index.php index.html index.htm;/' /usr/local/nginx/conf/nginx.conf
#echo "脚本执行完成之后记得，修改Nginx主配置文件。第65-71行，69行内容替换为fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html$fastcgi_script_name;。其他取消注释即可。"
#sleep 10
#启动服务
/usr/local/nginx/sbin/nginx 
[ $? -eq 0 ] && echo "服务启动成功"
clear && cd ~;
#安装MySQL
echo "download Mysql5.7" && cd ~;
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-boost-5.7.18.tar.gz
[ $? -eq 0 ] && echo "begin install Mysql-5.7"
yum remove boost-* -y ; yum remove mysql -y ; yum remove mariadb* -y
#解决依赖
yum install -y cmake make gcc gcc-c++ bison ncurses ncurses-devel
#添加用户和组
#groupadd mysql && useradd -M -s /sbin/nologin -r -g mysql mysql
#创建数据存放目录，和安装目录
mkdir -p /server/mysql
cd ~;
tar -xf mysql-boost-5.7.18.tar.gz
cd /root/mysql-5.7.18 ; mv boost/ /server/mysql
userdel -r mysql ; groupadd mysql && useradd -M -s /sbin/nologin -r -g mysql mysql
echo "begin"
  cmake -DCMAKE_INSTALL_PREFIX=/server/mysql -DMYSQL_DATADIR=/server/mysql/data -DSYSCONFDIR=/etc -DMYSQL_UNIX_ADDR=/server/mysql/mysql.sock -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DMYSQL_UNIX_ADDR=l -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/server/mysql/boost
if [ $? -eq 0 ];then
  echo "commple ok"
  make -j 4 && make install
else
  echo "commple fause"
fi
if [ $? -eq 0 ];then
 echo "will be configure"
else
 echo " 编译安装失败"
 exit
fi
[ $? -eq 0 ] && echo "mysql install successful!"
chown mysql.mysql /server/mysql/ -R
cp /etc/my.cnf{,.bak}
cat  > /etc/my.cnf << Yang
[mysqld]
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
#default
user = mysql
basedir = /server/mysql
datadir = /server/mysql/data
port = 3306
pid-file = /server/mysql/data/mysql.pid
socket = /server/mysql/mysql.sock
character-set-server=utf8
[client]
socket = /server/mysql/mysql.sock
Yang
#生成服务启动脚本
cp /server/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
#初始化数据库
 /server/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/server/mysql --datadir=/server/mysql/data
#启动服务
/etc/init.d/mysqld start && echo "Mysql 启动成功"
ln -s /server/mysql/bin/* /usr/local/bin
#安装PHP
cd ~;
wget http://cn2.php.net/distributions/php-7.1.8.tar.gz
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#解决依赖
 yum install php-mcrypt libmcrypt libmcrypt-devel php-pear libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel -y > /dev/null
tar -xf php-7.1.8.tar.gz -C /usr/local/src/
cd /usr/local/src/php-7.1.8/
 ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/ --enable-fpm  --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo --enable-maintainer-zts && make -j 4 && make install
[ $? -eq 0 ] && echo "PHP install successfull"
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.conf
sed -i 's/user = nobody/user = nginx/' /usr/local/php/etc/php-fpm.conf
sed -i 's/group = nobody/group = nginx/' /usr/local/php/etc/php-fpm.conf
cp /usr/local/src/php-7.1.8/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
/etc/init.d/php-fpm start && echo "PHP-FPM start ok"
echo " " > /usr/local/nginx/html/Yang.php
cat > /usr/local/nginx/html/Yang.php <<QQQ
<?php
	phpinfo();
?>
QQQ
chown nginx.nginx /usr/local/nginx/html/ -R
sed -i 's:fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html;:fastcgi_param  SCRIPT_FILENAME  /usr/local/nginx/html$fastcgi_script_name;:' /usr/local/nginx/conf/nginx.conf
/etc/init.d/php-fpm restart
/usr/local/nginx/sbin/nginx -s reload
chkconfig mysqld on
chkconfig php-fpm on
echo "/usr/local/nginx/sbin/nginx  &" >> /etc/rc.local 
chmod +x /etc/rc.local 
echo "LNMP is ok " && echo "pelase input IP/Yang.php"
