#!/bin/sh
#bin=$(cd `dirname $0` ; pwd)
#cd ..
war=ROOT.war
bin=/opt/download/jenkins

stop_tomcat(){
    a=` ps -ef |grep tomcat |grep -v grep|awk '{print $2}' |wc -l `
        #查看摸个端口对应的pid
        #echo  `netstat -nlp | grep 3000 |awk '{print $7}' | awk -F/ '{print $1}'`
         if [  $a -ne 0 ];then
            echo  '     正在关闭tomcat'
            ps -ef |grep tomcat|grep -v grep|awk '{print $2}'|xargs kill -9
        sleep 2
	 fi
    a=` ps -ef |grep tomcat |grep -v grep|awk '{print $2}' |wc -l `
    if [  $a -eq 0 ];then
        echo  "
        tomcat已停止"
	return
    fi
}
#stop_tomcat;



# a=` ps -ef |grep tomcat |grep -v grep|awk '{print $2}' |wc -l `
        #查看摸个端口对应的pid
        #echo  `netstat -nlp | grep 3000 |awk '{print $7}' | awk -F/ '{print $1}'`
 #  if [  $a -ne 0 ];then
  #          echo  '     正在关闭tomcat'
   #         ps -ef |grep tomcat|grep -v grep|awk '{print $2}'|xargs kill -9
    #   sleep 2
 # fi


#sleep 10
 # cd /home/www/admin/ROOT
# rm -rf *
cd /home/www/front/ROOT
rm -rf *

cd $bin

filename=`date +%Y%m%d`

#unzip -oq 'ROOT'${filename}.war -d /home/www/admin/ROOT
#sleep 3
unzip -oq 'ROOT'${filename}.war -d /home/www/front/ROOT
sleep 3

#\cp -f /opt/download/creative/conf/admin/initiate.properties /home/www/admin/ROOT/WEB-INF/classes/
\cp -f /opt/download/creative/conf/front/initiate.properties /home/www/front/ROOT/WEB-INF/classes/

#\cp -f /opt/download/creative/conf/admin/redis-alone.properties /home/www/admin/ROOT/WEB-INF/classes/
\cp -f /opt/download/creative/conf/front/redis-alone.properties /home/www/front/ROOT/WEB-INF/classes/


ip=`ifconfig eth0 |grep "inet " |grep -v grep|awk '{print $2}'`

echo -e "\n"
echo '获取到的本机ip为'$ip

rep={ip_address}

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

 echo  "     修改成功"


#\cp -f /opt/download/config/spring-context.xml /home/www/front/ROOT/WEB-INF/classes/
#\cp -f /opt/download/config/spring-context.xml /home/www/admin/ROOT/WEB-INF/classes/

    echo "      开始清理缓存数据...."
    redis-cli<<  EOF
    flushall
    keys *
EOF

    echo "
        缓存清理完成"


start_admin(){
	admin_bin=/usr/local/apache-tomcat-admin
	adminlog=${admin_bin}/logs/catalina.out

	echo  "start tomcat admin..."
	a=` ps -ef |grep tomcat-admin|grep -v grep|awk '{print $2}' `
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
}

start_front(){
	front_bin=/usr/local/apache-tomcat-front
	fronlog=${front_bin}/logs/catalina.out

	echo  "start tomcat front..."
	a=` ps -ef |grep tomcat-front|grep -v grep|awk '{print $2}' `
	if [ $a ];then
	   ps -ef |grep tomcat-front|grep -v grep|awk '{print $2}'|xargs kill -9
       echo  'start kill tomcat'
       sleep 2
	fi
	echo "Startup..."

	# 判断 catalina.out是否存在
	if [ ! -f "$fronlog" ]; then
		touch $fronlog
	fi
	sh ${front_bin}/bin/startup.sh start ;

}


#start_admin
#sleep 15;
start_front

