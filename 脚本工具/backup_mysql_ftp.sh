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
    /bin/nice -n 19 /usr/bin/mysqldump -u${USER} -p${PASSWORD} --skip-lock-tables $db > $basepath$db-$(date +%Y%m%d).sql  
    
    # 将生成的SQL文件压缩
    /bin/nice -n 19 tar -zcvf $basepath$db-$(date +%Y%m%d).sql.tar.gz $db-$(date +%Y%m%d).sql
    
    # 删除7天之前的备份数据
    find $basepath -mtime +2 -name "*.sql.tar.gz" -exec rm -rf {} \;
  done

  # 删除生成的SQL文件
  rm -rf $basepath/*.sql


# 备份上传的附件
#cd /data0/redmine-3.3.0-1/apps/redmine/htdocs/files/$(date +%Y)

# 压缩备份上传的附件
#tar -zcvf $basepath$(date +%Y%m%d)UploadFile.tar.gz $(date +%m)
#find $basepath -mtime +2 -name "*UploadFile.tar.gz" -exec rm -rf {} \;

# 拷贝到备份服务器硬盘
#scp -r $basepath$(date +%Y%m%d)UploadFile.tar.gz $basepath$db-$(date +%Y%m%d).sql.tar.gz root@computer2:/dataBak/vmDataBak/OA/


#压缩备份文件
#tar -zcvf $(date +%Y%m%d)MysqlBak.tar.gz *$(date +%Y%m%d).sql.tar.gz

#ftp设置
Host=192.168.0.91
Username=web1
Passwd=q1w2e3r4

#上传到ftp
echo "open $Host
user $Username $Passwd
bin
mkdir $(date +%Y%m%d)
cd $(date +%Y%m%d)
prompt off
mput $(date +%Y%m%d)MysqlBak.tar.gz
printf "/n"
close
bye"|ftp -i -n
#删除旧的备份文件
#rm -rf $(date +%Y%m%d)*
rm -rf $(date +%Y%m%d)MysqlBak.tar.gz




