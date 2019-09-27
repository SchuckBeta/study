创建数据库，开启远程连接，并指定用户使用权限

执行脚本：db-mysql.sh
数据库权限脚本：db-privileges.sql
数据库结构及初始化数据脚本：db-schema.sql


使用说明：直接执行 ./db-mysql.sh 脚本运行
执行结果：
	创建数据库：os_creative
	创建数据库用户：crmj 密码：1qazse4
	给用户crmj授权os_creative管理权限


注意：
	更改数据库名及属性请更改 db-schema.sql 脚本文件
	更改数据库用户名密码请更改 db-privileges.sql 脚本文件