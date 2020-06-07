#!/bin/sh
#bin=$(cd `dirname $0` ; pwd)
#cd ..
###  auth  OS!@#$qwer
pw='OS!@#$qwer'
echo "      开始清理缓存数据...."
redis-cli -h 127.0.0.1  -p 16379 <<  EOF
   auth ${pw}
   flushall
EOF

echo "缓存清理完成"



