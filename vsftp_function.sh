#!/bin/bash
IP=`ifconfig  |grep inet |awk  'NR=1{print $2}' |head -1 |awk -F: '{print $2}'`
function install_vsftp {
    yum install vsftpd -y &>/dev/null
    setenforce 0 && iptables -F
    service vsftpd restart
    echo -e "\033[33m please input $IP to access\033[0m"
}
function configure_anonymous {
  sed -i.bak 's/#anon_upload_enable=YES/anon_upload_enable=YES/' /etc/vsftpd/vsftpd.conf
  sed -i 's/#anon_mkdir_write_enable=YES/anon_mkdir_write_enable=YES/' /etc/vsftpd/vsftpd.conf
  read -p "please input you share dirname" DIR
  mkdir -p /var/ftp/$DIR
  chown ftp.ftp /var/ftp/$DIR
  service vsftpd restart
  echo -e "\033[32m configuer ok,please input ftp://$IP to access\033[0m"
}
function configuer_www {
 read -p "please input you add two user name:[test1 test2]" NAME1 NAME2
 useradd -s  /sbin/nologin $NAME1
 useradd -s /sbin/nologin  $NAME2
 read -p "please input you password for add user1:" PASSWD
 echo "$PASSWD" |passwd --stdin $NAME1 &>/dev/null
 read -p "please input you password for add user2:" PASSWD1
 echo "$PASSWD1" |passwd --stdin $NAME2 &>/dev/null
 rm -rf /etc/vsftpd/vsftpd.conf &&  mv /etc/vsftpd/vsftpd.conf.bak /etc/vsftpd/vsftpd.conf
 sed -i.bak 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
 sed -i 's/#chroot_list_enable=YES/chroot_list_enable=YES/' /etc/vsftpd/vsftpd.conf
 sed -i '/chroot_list_enable=YES/ilocal_root=/var/www/html' /etc/vsftpd/vsftpd.conf
 sed -i 's\#chroot_list_file=/etc/vsftpd/chroot_list\chroot_list_file=/etc/vsftpd/chroot_list\' /etc/vsftpd/vsftpd.conf
 touch /etc/vsftpd/chroot_list
 echo "$NAME1" > /etc/vsftpd/chroot_list
 echo "$NAME2" >> /etc/vsftpd/chroot_list
 yum install httpd -y &>/dev/null
 chmod -R o+w /var/www/html/
 service vsftpd restart
 echo -e "\033[33m config ok please input $IP to access \033[0m"
}
function configuer_virtuser {
 read -p "please input virtuser two name:[virt1 virt2]" V1 V2
 read -p "please input  password for NOVIP user1:" VP1
 read -p "please input password for VIP user2:"  VP2
 echo "$V1" > /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$VP1" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$V2" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$VP2" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 db_load -T -t hash -f /etc/vsftpd/vsftpd_virtualuser.txt /etc/vsftpd/vsftpd_virtualuser.db
 chmod 600 /etc/vsftpd/vsftpd_virtualuser.db && rm -rf /etc/vsftpd/vsftpd_virtualuser.txt
 >/etc/pam.d/vsftpd
 echo "auth     required        /lib64/security/pam_userdb.so  db=/etc/vsftpd/vsftpd_virtualuser" > /etc/pam.d/vsftpd
 echo "account  required        /lib64/security/pam_userdb.so  db=/etc/vsftpd/vsftpd_virtualuser" >> /etc/pam.d/vsftpd
 useradd -d  /var/ftp/share -s /sbin/nologin  ftpuser
 useradd -d  /var/ftp/vip -s /sbin/nologin  ftpvip
 chmod -R 500 /var/ftp/share/  && chmod -R 700 /var/ftp/vip/
 rm -rf /etc/vsftpd/vsftpd.conf &&  mv /etc/vsftpd/vsftpd.conf.bak /etc/vsftpd/vsftpd.conf
 sed -i.bak 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
 sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
 sed -i '/pam_service_name=vsftpd/auser_config_dir=/etc/vsftpd/vuserconfig' /etc/vsftpd/vsftpd.conf
 sed -i '/userlist_enable=YES/i\max_per_ip=10' /etc/vsftpd/vsftpd.conf
 sed -i '/max_per_ip=10/i\max_clients=300' /etc/vsftpd/vsftpd.conf
 mkdir /etc/vsftpd/vuserconfig
 touch /etc/vsftpd/vuserconfig/$V1
 yum install httpd -y &>/dev/null
 chmod -R o+w /var/www/html/
 service vsftpd restart
 echo -e "\033[33m config ok please input $IP to access \033[0m"
}
function configuer_virtuser {
 read -p "please input virtuser two name:[virt1 virt2]" V1 V2
 read -p "please input  password for NOVIP user1:" VP1
 read -p "please input password for VIP user2:"  VP2
 echo "$V1" > /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$VP1" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$V2" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 echo "$VP2" >>  /etc/vsftpd/vsftpd_virtualuser.txt
 db_load -T -t hash -f /etc/vsftpd/vsftpd_virtualuser.txt /etc/vsftpd/vsftpd_virtualuser.db
 chmod 600 /etc/vsftpd/vsftpd_virtualuser.db && rm -rf /etc/vsftpd/vsftpd_virtualuser.txt
 >/etc/pam.d/vsftpd
 echo "auth     required        /lib64/security/pam_userdb.so  db=/etc/vsftpd/vsftpd_virtualuser" > /etc/pam.d/vsftpd
 echo "account  required        /lib64/security/pam_userdb.so  db=/etc/vsftpd/vsftpd_virtualuser" >> /etc/pam.d/vsftpd
 useradd -d  /var/ftp/share -s /sbin/nologin  ftpuser
 useradd -d  /var/ftp/vip -s /sbin/nologin  ftpvip
 chmod -R 500 /var/ftp/share/  && chmod -R 700 /var/ftp/vip/
 rm -rf /etc/vsftpd/vsftpd.conf &&  mv /etc/vsftpd/vsftpd.conf.bak /etc/vsftpd/vsftpd.conf
 sed -i.bak 's/anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd/vsftpd.conf
 sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd/vsftpd.conf
 sed -i '/pam_service_name=vsftpd/auser_config_dir=/etc/vsftpd/vuserconfig' /etc/vsftpd/vsftpd.conf
 sed -i '/userlist_enable=YES/i\max_per_ip=10' /etc/vsftpd/vsftpd.conf
 sed -i '/max_per_ip=10/i\max_clients=300' /etc/vsftpd/vsftpd.conf
 mkdir /etc/vsftpd/vuserconfig
 touch /etc/vsftpd/vuserconfig/$V1
 touch /etc/vsftpd/vuserconfig/$V2
 cat > /etc/vsftpd/vuserconfig/$V1  <<Yang
  guest_enable=yes
  guest_username=ftpuser
  anon_world_readable_only=no
  anon_max_rate=50000
Yang
 cat > /etc/vsftpd/vuserconfig/$V2 <<VIP
 guest_enable=yes
 guest_username=ftpvip
 anon_world_readable_only=no
 write_enable=yes
 anon_mkdir_write_enable=yes
 anon_upload_enable=yes
 anon_max_rate=1000000
VIP
 service vsftpd restart
 dd if=/dev/zero of=/var/ftp/share/a.txt bs=100M count=10
 cp /var/ftp/share/a.txt /var/ftp/vip
 echo -e "\033[36m virtuser configure is successful,pelase to try\033[0m"
}
#configuer_virtuser
