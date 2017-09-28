#!/bin/sh
#  -----------------------------------------------------------------------------------------
#数据库导入
#-----------------------------------------------------------------------------------------
pw='Oseasy@123'
bin=$(cd .. `dirname $0`; pwd;)
db='creative_test';
#echo ${bin}
echo 'please enter your db name ：\n'
read dbname
echo 'ip adress:'$dbname

mysql -uroot -p${pw} <<  EOF
    CREATE DATABASE IF NOT EXISTS ${db} default character set utf8 COLLATE utf8_bin;
    USE ${db};
    source /home/mysqlData/${dbname};
EOF







