#!/bin/sh
#ip_address=172.18.0.18
hosts=f.oseasy.com
ip=`ifconfig eth0 |grep "inet " |grep -v grep|awk '{print $2}'`
echo 'get ip address is ：'$ip

show_config(){
    echo 'the contents of nginx ip address in the admin.conf is:'
    cat /etc/nginx/domains/admin.conf |grep 'server'
    echo 'the contents of nginx ip address in the front.conf is:'
    cat /etc/nginx/domains/front.conf |grep 'server'
    echo 'the contents of admin ip address in the initiate.properties is: '
    cat /home/www/admin/ROOT/WEB-INF/classes/initiate.properties | grep ${ip}
    echo 'the contents of front ip address in the initiate.properties is: '
    cat /home/www/front/ROOT/WEB-INF/classes/initiate.properties | grep ${ip}

    #echo 'the contents in the hosts is :'
    #cat /etc/hosts | grep ${hosts}
    #echo
    #cat /etc/nginx/domains/front.conf |grep ${hosts}
    #echo
    #cat /etc/nginx/domains/admin.conf |grep ${hosts}

}


check_redis(){
    echo 'check redis ...'
    ps -ef |grep redis
    #/usr/bin/redis-cli -h 127.0.0.1 -p 6379
    #/usr/bin/redis-cli -h 127.0.0.1 -p 6379 -a Msxxsdsdsfaqqqqqq

}
check_vsftp(){
    echo 'check vsftp ...'
    ps -ef |grep vsftpd

}

check_nginx(){
    echo 'check nginx ...'
    ps -ef |grep nginx
}
check_mysql(){
    echo 'check mysql..'
    ps -ef |grep mysql
}



show(){
	echo -e "\n"
	echo "----------------------------------"
	echo "please enter your choise:"
	echo "(0) show config"
	echo "(1) check redis"
	echo "(2) check nginx"
	echo "(3) check mysql"
	echo "(4) check vsftp"
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
	    0) show_config;;
		1) check_redis;;
		2) check_nginx;;
		3) check_mysql;;
		4) check_vsftp;;
		5) exit;;
	esac
	done
}

menu