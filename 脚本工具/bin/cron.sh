#!/bin/sh
#  -----------------------------------------------------------------------------------------
# cron 自动备份数据
#-----------------------------------------------------------------------------------------
DB_DIR="$PWD"
#crontab -e<< EOF
#*/1 * * * * echo "Good morning." >> /home/mysqlData/test.txt
## 0 1 * * * root ${DB_DIR}/backup_mysq.sh
#EOF


