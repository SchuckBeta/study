#!/bin/sh

#bin=$(cd `dirname $0`; pwd)

start_redis(){
    echo  '启动redis..'
    a=` ps -ef |grep redis|grep -v grep|awk '{print $2}' `
    if [ $a ];then
    ps -ef |grep redis|grep -v grep|awk '{print $2}'|xargs kill -9
           echo  'kill pid'$a
           sleep 2
    fi

      a=` ps -ef |grep redis|grep -v grep|awk '{print $2}' `
     nohup /usr/sbin/redis-server  /etc/redis/redis.conf  &
      sleep 3
      echo  'redis启动完成pid:'` ps -ef |grep redis|grep -v grep|awk '{print $2}'`

}

start_nginx(){
	nginx -t
    a=` ps -ef |grep nginx|grep -v grep|awk '{print $2}' |wc -l`
    if [  $a -eq 0 ];then
        echo  'start nginx..'
        nginx -c /etc/nginx/nginx.conf
    else
        echo  'reload nginx..'
        nginx  -c /etc/nginx/nginx.conf -s reload
    fi
    sleep 2
     a=` ps -ef |grep nginx|grep -v grep|awk '{print $2}' |wc -l`
    if [  $a -eq 0 ];then
         echo  'nginx start fail ...'
    else
        echo  'nginx start sucess ...'
    fi
}

start_mysql(){
    echo  '启动mysql..'
    a=` ps -ef |grep mysql|grep -v grep|awk '{print $2}' `
    if [ $a ];then
            ps -ef |grep mysql|grep -v grep|awk '{print $2}'|xargs kill -9
           echo  'kill mysql...'
           sleep 3
    fi

    a=` ps -ef |grep mysql|grep -v grep|awk '{print $2}' `
    if [ ! $a ];then
           systemctl start mysqld.service
    else
           systemctl restart mysqld.service
    fi

    # 判断mysql收启动成功
     a=` ps -ef |grep mysql|grep -v grep|awk '{print $2}' `
     if [ $a ];then
           echo  'mysql启动完成！pid is'$a
      else
           echo  'mysql启动失败，请重新启动'
     fi

}

start_vsftp(){
	echo '重启ftp..'
	systemctl restart vsftpd
	sleep 2
}

show(){
	echo -e "\n"
	echo "----------------------------------"  
	echo "please enter your choise:"  
	echo "(0) default  start all service"
	echo "(1) restart redis"
	echo "(2) restart nginx"
	echo "(3) restart mysql"
	echo "(4) restart vsftp"
	echo "(5) Exit Menu"
	echo "----------------------------------"  
}
menu(){
	input=0
	while [ $input -ne 6 ]
	do
	show
	read input
	case $input in  
		0) default_start_all;;
		1) start_redis;;
		2) start_nginx;;
		3) start_mysql;;
		4) start_vsftp;;
		5) exit;;
	esac
	done
}
default_start_all(){
	start_redis
	start_nginx
	start_mysql
	start_vsftp
}
menu
