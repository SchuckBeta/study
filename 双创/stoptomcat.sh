
#!/bin/sh

     a=` ps -ef |grep tomcat |grep -v grep|awk '{print $2}' |wc -l `
        #查看摸个端口对应的pid
        #echo  `netstat -nlp | grep 3000 |awk '{print $7}' | awk -F/ '{print $1}'`
         if [  $a -ne 0 ];then
            echo  '     正在关闭tomcat'
            ps -ef |grep tomcat|grep -v grep|awk '{print $2}'|xargs kill -9
        sleep 2
        fi
    a=` ps -ef |grep tomcat |grep -v grep|awk '{print $2}' |wc -l `
    if [  $a -eq 0 ];then
        echo  "
        tomcat已停止"
    fi

