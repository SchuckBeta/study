#!/bin/sh
#bin=$(cd `dirname $0` ; pwd)
#cd ..
pw='OS!@#$qwer'
war=ROOT.war
bin=/opt/download/jenkins/

tomcat_home=/usr/local/apache-tomcat-front
code_home=/home/www/front/ROOT

SHUTDOWN=${tomcat_home}/bin/shutdown.sh

STARTTOMCAT=${tomcat_home}/bin/startup.sh

a=`ps -ef|grep ${tomcat_home}/bin/bootstrap.jar |grep -v grep|wc -l`

echo $a


         if [  $a -ge 1 ];then
           echo  '     正在关闭tomcat'
            ps -ef |grep ${tomcat_home}/bin/bootstrap.jar |grep -v grep|awk '{print $2}'|xargs kill -9
        sleep 2
        else
		echo 'tomcat已关闭' 
	fi


rm -rf ${tomcat_home}/temp/*
rm -rf ${tomcat_home}/work/Catalina/


rm -rf ${code_home}/*

cd $bin

filename=`date +%Y%m%d`

#unzip -oq 'ROOT'${filename}.war -d /home/www/admin/ROOT
#sleep 3
unzip -oq 'ROOT'${filename}.war -d ${code_home}
sleep 3


\cp -f /opt/download/initiate.properties  ${code_home}/WEB-INF/classes/initiate.properties
#\cp -f /opt/download/creative/conf/front/spring-context-scheduler.xml ${code_home}/WEB-INF/classes/spring/

#    echo "      开始清理缓存数据...."
#    redis-cli <<  EOF
#    flushall
#EOF
#
#    echo "
#        缓存清理完成"

echo "      开始清理缓存数据...."
redis-cli -h 127.0.0.1  -p 16379 <<  EOF
   auth ${pw}
   flushall
EOF

echo "缓存清理完成"



start_tomcat(){

	fronlog=${tomcat_home}/logs/catalina.out

	#echo  "start tomcat_school..."
	a=` ps -ef |grep ${tomcat_home}/bin/bootstrap.jar |grep -v grep|awk '{print $2}' `
	if [ $a ];then
	   ps -ef |grep ${tomcat_home}/bin/bootstrap.jar |grep -v grep|awk '{print $2}'|xargs kill -9
       echo  'start kill tomcat'
       sleep 2
	fi
	echo "Startup..."

	# 判断 catalina.out是否存在
	if [ ! -f "$fronlog" ]; then
		touch $fronlog
	fi
	#nohup sh ${tomcat_home}/bin/startup.sh;tail -200f /usr/local/apache-tomcat-front/logs/catalina.out
        nohup sh ${tomcat_home}/bin/startup.sh

}

start_tomcat

