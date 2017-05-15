#!/bin/bash

# 要备份的数据库名，多个数据库用空格分开
databases=(wf-mplatform)

USER="root"
PASSWORD="123456"

# 备份文件要保存的目录
basepath='/home/mysqlData/'

if [ ! -d "$basepath" ]; then
  mkdir -p "$basepath"
fi

cd $basepath

# 循环databases数组
for db in ${databases[*]}
  do
    # 备份数据库生成SQL文件 锁表失败叫 --skip-lock-tables
    /bin/nice -n 19 /usr/bin/mysqldump -u${USER} -p${PASSWORD} --skip-lock-tables $db > $basepath$db-$(date +%Y%m%d)-$(date +%H%M).sql  
    
    # 将生成的SQL文件压缩
    /bin/nice -n 19 tar -zcvf $basepath$db-$(date +%Y%m%d)-$(date +%H%M).sql.tar.gz $db-$(date +%Y%m%d)-$(date +%H%M).sql
    
    # 删除7天之前的备份数据
    find $basepath -mtime +2 -name "*.sql.tar.gz" -exec rm -rf {} \;
  done

  # 删除生成的SQL文件
  rm -rf $basepath/*.sql
