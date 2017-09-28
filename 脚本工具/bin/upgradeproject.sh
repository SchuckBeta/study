#!/bin/sh
#  -----------------------------------------------------------------------------------------
#     （需要替换ROOT.war 的时候执行）
#           2）备份项目
#           3）升级
#          4）清空缓存
#----------------------------------------------------------------------------------------- 
ip=`ifconfig eth0 |grep "inet " |grep -v grep|awk '{print $2}'`
echo --------------------
echo '获取本机ip['$ip']'
echo --------------------
rep={ip_address}

# 备份 并导入数据库
backup_db(){
   ./backupmysql.sh
    sleep 5
}

import_db(){
    pushd ..
    DB_DIR="$PWD"
    PW='Oseasy@123'
    DB='creative';

    mysql -uroot -p${PW} <<  EOF
        CREATE DATABASE IF NOT EXISTS ${DB} default character set utf8 COLLATE utf8_bin;
        USE ${DB};
        source ${DB_DIR}/update/creative.sql;
EOF
    popd
}


#停服务tomcat
stop_tomcat(){
    a=` ps -ef |grep tomcat-admin|grep -v grep|awk '{print $2}' |wc -l `
	#查看摸个端口对应的pid
	#echo  `netstat -nlp | grep 3000 |awk '{print $7}' | awk -F/ '{print $1}'`
	 if [  $a -ne 0 ];then
	    echo  'start kill tomcat...'
	    ps -ef |grep tomcat|grep -v grep|awk '{print $2}'|xargs kill -9
        sleep 2
	fi
    a=` ps -ef |grep tomcat-admin|grep -v grep|awk '{print $2}' |wc -l `
    if [  $a -eq 0 ];then
        echo  'tomcat stop sucess.'
    fi
}

backup(){
    pushd ..
    ROOT_DIR="$PWD"
    DATA=/home/www/${ret}
    mkdir -p /opt/backup
    MYDATE=$(date +%Y%m%d)-$(date +%H%M)
    FILENAME=/opt/backup/${ret}_${MYDATE}.tar.gz
    log=/opt/backup/back.log
    cd $DATA
    echo '开始备份目录:'$DATA
    echo $(date +"%Y%m%d %H:%M:%S")  >> $log
    tar -zcvf $FILENAME ROOT/
    if [[ $? == 0 ]]; then
        echo "$FILENAME   tar finished!" >> $log
        echo $(date +"%Y%m%d %H:%M:%S")  >> $log
    else
        echo "$FILENAME tar fail!" >> $log
    fi
    echo "---------------" >> $log
   popd
  # unset ret
}

backup_code(){
    ret='admin'
    backup
    sleep 2
    ret='front'
    backup
    exit 0
}

flushall_cache(){
    echo "开始清空缓存...."
    redis-cli<<  EOF
    flushall
    keys *
EOF
}


#解压项目到到指定目录
update_project(){
   stop_tomcat
    sleep 3
   pushd ..
   dire="/home/www"
   ROOT_DIR="$PWD"
   war=${ROOT_DIR}/ROOT.war
   echo '升级包所在的目录:'${war}
   rm  -rf  ${dire}/admin  ${dire}/front
   sleep 2
   mkdir -p ${dire}/admin   ${dire}/front
   unzip -o ${war} -d ${dire}/admin/ROOT
   sleep 2
   \cp  -rf ${dire}/admin/ROOT    ${dire}/front/
   #解压安装包
    \cp -f  ${ROOT_DIR}/conf/admin/initiate.properties  /home/www/admin/ROOT/WEB-INF/classes/
    \cp -f  ${ROOT_DIR}/conf/front/initiate.properties  /home/www/front/ROOT/WEB-INF/classes/
    sleep 1
    #系统配置文件ip替换
    echo  "修改properties文件中的ip"
    ap=/home/www/admin/ROOT/WEB-INF/classes/initiate.properties
    af=/home/www/front/ROOT/WEB-INF/classes/initiate.properties
    if cat ${ap} |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g"  ${ap}
    fi
    if cat ${af} |grep ${rep} > /dev/null;then
        sed -i  "s/$rep/$ip/g"  ${af}
    fi
    echo 'check  admin ip address  is:'
    cat ${ap} |grep $ip
    echo 'check front ip address  is:'
    cat ${af} |grep $ip
popd
unset ap af
}
start_tomcat(){
   # echo '开始启动tomcat....'
   ./startup.sh
}
show(){
	echo -e "\n"
	echo "----------------------------------"
	echo "please enter your choise:"
	echo "(1) 停服务同时升级项目"
	echo "(2) 备份数据库"
	echo "(3) 导入数据导数据库"
	echo "(4) 清空缓存"
	echo "(5) 启动tomcat"
	echo "(6) 退出菜单"
	echo "----------------------------------"
}

menu(){
	input=0
	while [ $input -ne 6 ]
	do
	show
	read input
	case $input in
		1) update_project;;  #升级项目
		2) backup_db;;      #备份数据库
		3) import_db;;      #导入数据库
		4) flushall_cache;; #清空缓存
		5) start_tomcat;; #清空缓存
		6) exit;;
	esac
	done
}

menu





