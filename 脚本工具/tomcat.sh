#!/bin/bash
#-*- utf-8 -*-
#Created by : victor.zhang
#Date       : 26/10/2016
#Desc       : checkout/update svn

PRO_FILE_NAME='ROOT';
PRO_BACK_TIME='2017092310';
PRO_BACK_PATH='/opt/server/tomcats/jeecms';
TOMCAT_BIN_PATH='/opt/server/tomcats/tomcat-jeecms-7.0.79/bin';
TOMCAT_LOGS_PATH='/opt/server/tomcats/tomcat-jeecms-7.0.79/logs';
TOMCAT_WEBAPP_PATH='/opt/server/tomcats/tomcat-jeecms-7.0.79/webapps';
case "$1" in
    upback)
         echo "update and backup..." ;
         zip -r ${PRO_BACK_PATH}/${PRO_FILE_NAME}${PRO_BACK_TIME}.zip ${TOMCAT_WEBAPP_PATH}/${PRO_FILE_NAME}/*
         rm -rf ${TOMCAT_WEBAPP_PATH}/${PRO_FILE_NAME}
#        mv ${PRO_BACK_PATH}/${PRO_FILE_NAME}.war ${TOMCAT_WEBAPP_PATH}
         cp -rf ${PRO_BACK_PATH}/${PRO_FILE_NAME}.war ${TOMCAT_WEBAPP_PATH}
         echo `pwd`;
        ;;
    backup)
         echo "backup..." ;
         zip -r ${PRO_BACK_PATH}/${PRO_FILE_NAME}${PRO_BACK_TIME}.zip ${TOMCAT_WEBAPP_PATH}/${PRO_FILE_NAME}/*
         echo `pwd`;
        ;;
    update)
         echo "update..." ;
         rm -rf ${TOMCAT_WEBAPP_PATH}/${PRO_FILE_NAME}
         cp -rf ${PRO_BACK_PATH}/${PRO_FILE_NAME}.war ${TOMCAT_WEBAPP_PATH}
         echo `pwd`;
        ;;
    start)
         echo  "tomcat server start...";
         ${TOMCAT_BIN_PATH}/startup.sh
         tail -f ${TOMCAT_LOGS_PATH}/catalina.out
         echo `pwd`;
        ;;
    stop)
         echo  "tomcat server stop...";
         ${TOMCAT_BIN_PATH}/shutdown.sh
         ps -aux | grep tomcat
         echo `pwd`;
        ;;
    logs)
         echo  "tomcat server stop...";
         cd ${TOMCAT_LOGS_PATH}
         tail -f ./catalina.out
         echo `pwd`;
        ;;
    *)
        echo "Usage: tomcat {upback|start|stop|logs|backup|update}"
        exit 1
        ;;
esac
##END
