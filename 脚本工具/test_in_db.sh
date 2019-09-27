#!/bin/bash
ip=`ifconfig eth0 |grep "inet " |grep -v grep|awk '{print $2}'`
for ((i=0;i<1000;i++))
do
    #echo $i
    #mysql -ucluster -p123456 -p 192.168.0.234 -e "select count(id) from  galera.test_cluster"
   # mysql -ucluster -p123456  -e "insert into galera.test_cluster (ip,name, time) values ('$ip','$i', now())"

 mysql -ucluster -p123456 -P3366 -h192.168.0.234  -e "insert into galera.test_cluster (ip,name, time) values ('192.168.0.234','$i', now())"

       #mysql -ucluster -p123456 -P3366 -h192.168.0.234 -e "select count(id) from  galera.test_cluster"
done
