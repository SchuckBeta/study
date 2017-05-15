#################################################################
####Linux定义定时任务############################################
#################################################################
# crontab -e 更改配置
#	crontab -e，然后就会有个vi编辑界面，再输入0 3 * * 1 /clearigame2内容到里面 :wq 保存退出


# cron在3个地方查找配置文件
#	1、/var/spool/cron/ 这个目录下存放的是每个用户包括root的crontab任务，每个任务以创建者的名字命名，比如tom建的crontab任务对应的文件就是/var/spool/cron/tom。
#		一般一个用户最多只有一个crontab文件。
#	2、/etc/crontab 这个文件负责安排由系统管理员制定的维护系统以及其他任务的crontab。
#	3、/etc/cron.d/ 这个目录用来存放任何要执行的crontab文件或脚本。


#权限 crontab权限问题到/var/adm/cron/下一看，文件cron.allow和cron.deny是否存在
#用法如下： 
#	1、如果两个文件都不存在，则只有root用户才能使用crontab命令。 
#	2、如果cron.allow存在但cron.deny不存在，则只有列在cron.allow文件里的用户才能使用crontab命令，如果root用户也不在里面，则root用户也不能使用crontab。 
#	3、如果cron.allow不存在, cron.deny存在，则只有列在cron.deny文件里面的用户不能使用crontab命令，其它用户都能使用。 
#	4、如果两个文件都存在，则列在cron.allow文件中而且没有列在cron.deny中的用户可以使用crontab，如果两个文件中都有同一个用户，
#	以cron.allow文件里面是否有该用户为准，如果cron.allow中有该用户，则可以使用crontab命令。


#Cron服务
#　　cron是一个linux下 的定时执行工具，可以在无需人工干预的情况下运行作业。
#　　/sbin/service crond start    //启动服务
#　　/sbin/service crond stop     //关闭服务
#　　/sbin/service crond restart  //重启服务
#　　/sbin/service crond reload   //重新载入配置
#　　/sbin/service crond status   //查看服务状态 


# find /opt/reveive/data/done -type f -mtime +7 -print | xargs rm -rf

#每分钟执行一次
# 	*/1 * * * * echo "Good morning." >> /tmp/test.txt
#
#每天1点执行脚本
#	0 1 * * * /opt/shell/backup_mysq.sh
#################################################################



