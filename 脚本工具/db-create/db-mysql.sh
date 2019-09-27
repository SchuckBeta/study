#!/bin/bash
#################################################################
# 要备份的数据库名
DATABASE=(os_creative)
# 数据库登录名
USER="root"
# 数据库密码
PASSWORD="123456"
# 初始化文件目录
initFile='./'
# mysq脚本命令目录
mysqlBin='/usr/local/mysql-5.7.17-linux-glibc2.5-x86_64/bin/'
#################################################################

set -e

echo `service mysql status`

echo '1.启动mysql....'

#启动mysql
service mysql start

sleep 3

echo `service mysql status`
echo 'show databases'

DATABASES=$(${mysqlBin}/mysql -u${USER} -p${PASSWORD} -e "show databases")
echo $DATABASES
echo $DATABASE
if [[ "$DATABASES" =~ "$DATABASE" ]];then

echo '--------mysql容器重启--------'
echo '2.数据库已存在,无需初始化数据....'

else

echo '--------mysql容器第一次启动--------'
echo '2.开始导入数据....'
#导入数据
${mysqlBin}/mysql -u${USER} -p${PASSWORD} < ${initFile}/db-schema.sql

echo '3.导入数据完毕....'

sleep 3
echo `service mysql status`

#重新设置mysql密码
echo '4.开始修改密码....'

${mysqlBin}/mysql -u${USER} -p${PASSWORD} < ${initFile}/db-privileges.sql

echo '5.修改密码完毕....'

#sleep 3
echo `service mysql status`
echo 'mysql容器启动完毕,且数据导入成功'

fi

tail -f /dev/null