#!/bin/sh

#bin=$(cd `dirname $0`; pwd)

start_admin(){
	admin_bin=/usr/local/apache-tomcat-admin
	adminlog=${admin_bin}/logs/catalina.out
	
	echo  "start tomcat admin..."
	a=` ps -ef |grep tomcat-admin|grep -v grep|awk '{print $2}' `
	#查看摸个端口对应的pid
	#echo  `netstat -nlp | grep 3000 |awk '{print $7}' | awk -F/ '{print $1}'`
	if [ $a ];then
	   ps -ef |grep tomcat-admin|grep -v grep|awk '{print $2}'|xargs kill -9
       echo  'start kill tomcat'
       sleep 2
	fi
	echo "Startup..."
	
	
	if [ ! -f "$adminlog" ]; then
		touch $adminlog
	fi
	
	sh ${admin_bin}/bin/startup.sh start ;
	
	if [ "$input" != "0" ]; then
		tail -f ${admin_bin}/logs/catalina.out
	fi
}

start_front(){
	front_bin=/usr/local/apache-tomcat-front
	fronlog=${front_bin}/logs/catalina.out
	
	echo  "start tomcat front..."
	a=` ps -ef |grep tomcat-front|grep -v grep|awk '{print $2}' `
	if [ $a ];then
	   ps -ef |grep tomcat-front|grep -v grep|awk '{print $2}'|xargs kill -9
       echo  'start kill tomcat'
       sleep
	fi
	echo "Startup..."
	
	# 判断 catalina.out是否存在
	if [ ! -f "$fronlog" ]; then    
		touch $fronlog
	fi
	sh ${front_bin}/bin/startup.sh start ;
	
	if [ "$input" != "0" ]; then
		tail -f ${front_bin}/logs/catalina.out
	fi
	
	
}

show(){
	echo -e "\n"
	echo "----------------------------------"  
	echo "please enter your choise:"  
	#echo "(0) default auto start all tomcat"
	echo "(1) start tomcat front"  
	echo "(2) start tomcat admin"   
	echo "(3) Exit Menu"  
	echo "----------------------------------"  
}
menu(){
	input=0
	while [ $input -ne 4 ]
	do
	show
	read input
	case $input in  
		#0) default_auto_install;;
		1) start_front;;  
		2) start_admin;;  
		3) exit;;  
	esac
	done
}
default_auto_install(){	
	start_front 
	sleep 1;
	start_admin 
}
menu
