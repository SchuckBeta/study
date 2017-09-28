#!/bin/sh
## 2017-06-16
##email: zhangchuansheng@os-easy.com
##zhangchuansheng
##centos 7

bin=$(cd `dirname $0`; pwd)
#pw='Oseasy@123'
#echo 'please enter your ip address ：\n'
#read ip
#echo 'ip adress:'$ip

#获取ip地址
ip=`ifconfig eth0 |grep "inet " |grep -v grep|awk '{print $2}'`
echo ----------------------------------
echo '获取本机ip['$ip']'
echo ----------------------------------
hosts=f.oseasy.com
rep={ip_address}

#系统设置
set_init(){
    ulimit -n 65535
    install_set_ulimit
    #防火墙设置   对外放开的端口有  81 82 80
   #systemctl stop firewalld.service
    #systemctl status firewalld.service
    #禁止firewall开机启动
   # systemctl disable firewalld.service
    echo ----------------------------------
    echo [开始设置端口]
   firewall-cmd --permanent --add-service=ftp  > /dev/null 2>&1
   firewall-cmd --permanent --add-port=3306/tcp > /dev/null 2>&1
   firewall-cmd --permanent --add-port=80/tcp > /dev/null 2>&1
   firewall-cmd --permanent --add-port=81/tcp > /dev/null 2>&1
   firewall-cmd --permanent --add-port=82/tcp > /dev/null 2>&1
   firewall-cmd --permanent --add-port=8081/tcp > /dev/null 2>&1
   firewall-cmd --permanent --add-port=8082/tcp > /dev/null 2>&1
  # firewall-cmd --permanent --add-port=21/tcp
    firewall-cmd --reload   > /dev/null 2>&1
    sleep 2;

    #设置文件打开最大数限制

    #TODO
    #set cron 备份数据
	#timezone setting
	#timedatectl set-timezone Asia/Shanghai
	#echo "0 2 * * * /sbin/reboot"  >> /var/spool/cron/root
	#service crond restart
    #ip 域名设置
    install_set_hosts
}

install_set_hosts(){
    echo ----------------------------------
    echo [开始设置域名]
    #域名设置
    if cat /etc/hosts | grep ${hosts} > /dev/null;then
           echo ""
    else
            echo ${ip} ${hosts} >>  /etc/hosts
    fi
}

install_set_ulimit(){
    echo --------------------
    echo [设置系统内核参数]
    if cat /etc/security/limits.conf | grep "* soft nofile 65535" > /dev/null;then
        echo ""
    else
        echo "* soft nofile 65535" >> /etc/security/limits.conf
    fi

    if cat /etc/security/limits.conf | grep "* hard nofile 65535" > /dev/null ;then
        echo ""
    else
        echo "* hard nofile 65535" >> /etc/security/limits.conf
    fi

    #redis 配置
    if cat /etc/sysctl.conf  |grep "vm.overcommit_memory=1"  > /dev/null ;then
           echo "";
     else
        echo vm.overcommit_memory=1 >> /etc/sysctl.conf
        sysctl -p
     fi



}

#mysql设置配置  /var/log/mysqld.log
set_mysql(){
    echo ----------------------------------
    echo [开始设置数据库参数]
    cp  -rf  ../conf/my.cnf  /etc/
    mkdir -p /usr/local/mysql/data   /usr/local/mysql/log/
    echo '' > /usr/local/mysql/log/error.log
    echo '' >/usr/local/mysql/log/slow-query.log

    sleep 1
    #设置开机启动
    systemctl enable mysqld.service
      #停止开机启动
	#systemctl disable mysqld.service
    sleep 2
    start_mysql
}

start_mysql(){
    echo ----------------------------------
    echo [开始启动数据库]
    a=` ps -ef |grep mysql|grep -v grep|awk '{print $2}' `
    if [ $a ];then
            ps -ef |grep mysql|grep -v grep|awk '{print $2}'|xargs kill -9
           echo  'kill mysql...'
    fi
    #开启mysql服务
    systemctl start mysqld.service
    # 判断mysql收启动成功
     a=` ps -ef |grep mysql|grep -v grep|awk '{print $2}' `
    if [ $a ];then
            echo  'mysql start  ok'
     else
            echo 'mysql start fail'
    fi
}



update_mysql_default_passwd(){
    echo ----------------------------------
    echo [开始修改数据库密码]
     echo 'set mysql passwd..'
    # 设置访问的用户名和密码
    defaultmysqlpwd=`grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}'`
     #defaultmysqlpwd=`grep 'temporary password' /usr/local/mysql/log/error.log | awk '{print $NF}'`
    #defaultmysqlpwd='Oseasy@123'
    #mysqladmin -uroot -p${defaultmysqlpwd} password "Oseasy@123"
    #设置mysql安全级别
   # mysql -uroot -pOseasy@123 -e  "set global validate_password_policy = 0";
    #mysql -uroot -pOseasy@123 -e "grant all privileges on *.* to 'root'@'%' identified by 'Oseasy@123' with grant option;"
    #mysql -uroot -pOseasy@123 -e "flush privileges;"

    mysql -uroot -p${defaultmysqlpwd} -b --connect-expired-password<<  EOF
    set global validate_password_policy = 0;
    SET PASSWORD = PASSWORD('Oseasy@123');
    grant all privileges on *.* to root@'%' identified by 'Oseasy@123';
    flush privileges;
EOF

    sleep 2
}

#vsftp设置服务  ok
set_vsftpd(){
    echo ----------------------------------
    echo [开始设置FTP参数并启动]
    \cp  -rf ../conf/vsftpd.conf   /etc/vsftpd/
    userdel -f ftponly
    useradd -d /userRemoteFilePath  ftponly
    usermod -s /sbin/nologin ftponly

     #解压ftp文件到指定目录
    rm -rf  /userRemoteFilePath/tool/oseasy
    mkdir -p /userRemoteFilePath/tool/oseasy
    unzip -o ../ftpdata.zip -d  /userRemoteFilePath/tool/oseasy
    chown -R ftponly.ftponly  /userRemoteFilePath
    chmod a-w  /userRemoteFilePath/tool/
   # echo 'allow_writeable_chroot=YES' >> /etc/vsftpd/vsftd.conf
    #修改密码
   ( echo "1qazse4";sleep 1; echo "1qazse4") | passwd  ftponly> /dev/null
    systemctl restart vsftpd
    # 开机自启动
    chkconfig vsftpd on
    #chkconfig --list | grep vsftpd
    sleep 2
}

start_vsftpd(){
  systemctl restart vsftpd
  sleep 2
}


#nginx的设置 ok
set_nginx(){
 #nginx ip替换
    echo ----------------------------------
    echo [开始设置nginx参数]
    pkill nginx
    \cp  -rf  ../conf/nginx/*  /etc/nginx/
   # sleep 1;
    echo '将'$rep'替换成'$ip
    if cat /etc/nginx/domains/admin.conf |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g" /etc/nginx/domains/admin.conf
    fi
    if cat /etc/nginx/domains/front.conf |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g" /etc/nginx/domains/front.conf
    fi

    echo 'check nginx admin.conf is:'
    cat /etc/nginx/domains/admin.conf |grep 'server'
    echo 'check nginx front.conf is:'
    cat /etc/nginx/domains/front.conf |grep 'server'

    #sleep 1
    start_nginx
}

start_nginx(){
    echo ----------------------------------
    echo [开始重启nginx.]
    #\cp  -rf  ../conf/nginx/*  /etc/nginx/
    #b=` ps -ef |grep nginx|grep -v grep|awk '{print $2}' `
    b=` netstat -anpt | grep "/nginx" | awk '{print $6}' `
    nginx -t
    if [ $b ]
    then
        echo 'reload  nginx..'
       nginx  -c /etc/nginx/nginx.conf -s reload
    else
        echo 'start  nginx...'
        nginx -c /etc/nginx/nginx.conf
    fi
    sleep 1
    #设置开机启动
   #chkconfig nginxd on
    systemctl enable nginx.service
	  #停止开机启动
	#systemctl disable nginx.service
}

#redis启动 ok
set_redis(){
    echo ----------------------------------
    echo [开始设置缓存并启动.]
    pwd
    rpm -ivh  ../redis-3.0.4-6.1.x86_64.rpm
    #rpm -ql redis
    \cp -f ../conf/redis.service   /usr/lib/systemd/system/
    \cp -f ../conf/redis.conf  /etc/redis/
    mkdir -p /data/redis/
    echo '' > /data/redis/redis.log
    #刷新配置
    systemctl daemon-reload
    #systemctl start redis.service
    a=` ps -ef |grep redis|grep -v grep|awk '{print $2}' `
    # ps -ef |grep redis|grep -v grep|awk '{print $2}'|xargs kill -9
    #nohup /usr/sbin/redis-server  /etc/redis/redis.conf  &
    #启动redis
    start_redis
    sleep 1
     #开机启动
   # auto_start_redis
}

auto_start_redis(){
   # systemctl enable redis
   echo
   echo 该命令将会将Redis安装为开机自运行服务...
   echo [This command will install the Redis as system daemon service...]
    a=` grep autostartredis /etc/rc.d/rc.local |wc -l `
    if [  $a -eq 0 ];then
       \cp -f autostartredis.sh /etc/rc.d/
        sleep 2
         echo  '/etc/rc.d/autostartredis.sh' >> /etc/rc.d/rc.local
        chmod 775 /etc/rc.d/rc.local /etc/rc.d/autostartredis.sh
    fi

}


start_redis(){
     #echo  "启动redis..."
    #systemctl restart redis.service
    nohup /usr/sbin/redis-server  /etc/redis/redis.conf  &
    sleep 5
    a=` ps -ef |grep redis|grep -v grep|awk '{print $2}' |wc -l `
    if [  $a -eq 1 ];then
         echo  'redis start  success'
      else
         echo  'redis start  fail'
    fi
}


set_tomcat(){
    #tomcat的设置
    #echo  "替换配置文件"
    echo ----------------------------------
    echo [开始设置tomcat参数.]
    \cp  -f ../conf/admin/server.xml  /usr/local/apache-tomcat-admin/conf/
    \cp -f  ../conf/front/server.xml  /usr/local/apache-tomcat-front/conf/
    \cp -f  ../conf/admin/initiate.properties  /home/www/admin/ROOT/WEB-INF/classes/
    \cp -f  ../conf/front/initiate.properties  /home/www/front/ROOT/WEB-INF/classes/
    sleep 1
    #系统配置文件ip替换
    #echo  "修改properties文件中的ip"
    ap=/home/www/admin/ROOT/WEB-INF/classes/initiate.properties
    af=/home/www/front/ROOT/WEB-INF/classes/initiate.properties
    if cat ${ap} |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g"  ${ap}
    fi

    if cat ${af} |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g"  ${af}
    fi
    #unset ap af

    echo 'check  admin ip address  is:'
    cat ${ap} |grep $ip
    echo 'check front ip address  is:'
    cat ${af} |grep $ip

    sleep 1
    sh  startup.sh
}

start_tomcat(){
    # echo 'start tomcat...'
    echo ----------------------------------
    echo [开始启动Tomcat服务.]
    sh  startup.sh
}


start_server_menu(){
 echo 'start server menu '
input=0
	while [ $input -ne 7 ]
	do
	show_start_server
	read input
	case $input in
		0) start_mysql;;
		1) start_vsftpd;;
	    2) start_nginx;;
		3) start_redis;;
		4) start_tomcat;;
		5) exit;;
	esac
	done
}


import_mysql(){
    echo ----------------------------------
    echo [开始导入数据.]
    sh importmyql.sh
    sleep 4;
}

show(){
	echo -e "\n"
	echo "----------------------------------"
	echo "please enter your choise:"
	echo "(0) set init"
	echo "(1) set and start mysql"
	echo "(2) update mysql default passwd"
    echo "(3) set and start vsftpd"
    echo "(4) set and start  nginx "
    echo "(5) set and start  redis"
    echo "(6) import data to mysql "
    echo "(7) set and start tomcat "
	echo "(8) Exit Menu"
	echo "(9) auto start redis on reboot"
	echo "----------------------------------"
}
menu(){
	input=0
	while [ $input -ne 9 ]
	do
	show
	read input
	case $input in
		0) set_init;;
		1) set_mysql;;
		2) update_mysql_default_passwd;;
		3) set_vsftpd;;
		4) set_nginx;;
		5) set_redis;;
		6) import_mysql;;
		7) set_tomcat;;
		8) exit;;
		9) auto_start_redis;;
	esac
	done
}



default_auto_setting(){
	echo 'set all..'
    set_init
    set_mysql
    set_vsftpd
    set_nginx
    set_redis
    import_mysql
    set_tomcat
}

menu
