#!/bin/sh

war=$1
bin=$(cd `dirname $0`; pwd)
echo ${bin}
cd ..
if [ ! -n "${war}" ]; then
    echo "***Usage: $0 [ROOT.war]"
	war='ROOT.war'
    ##exit 0
fi
if [ ! -f "${war}" ]; then
    echo "***Error: ${war} does not exist."
    exit 0
fi
if [ ! "${war##*.}" = "war" ]; then
    echo "***Error: ${war} is not a war file."
    exit 0
fi
echo "Deploy ${war##*/}..."

dire="/home/www"
sleep 1
#echo dire
#if [ -d "$dire" ]; then   
#	rmdir "$dire"
#	mkdir "$dire"
#else
#	mkdir "$dire"
#fi
rm  -rf  ${dire}/admin  ${dire}/front
mkdir -p ${dire}/admin   ${dire}/front
unzip -o ${war} -d ${dire}/admin/ROOT

sleep 1
\cp  -rf ${dire}/admin/ROOT    ${dire}/front/
rm -rf /usr/local/apache-tomcat-front  &&  tar zxvf apache-tomcat-front.tar.gz -C /usr/local
rm -rf /usr/local/apache-tomcat-admin  && tar zxvf apache-tomcat-admin.tar.gz -C /usr/local

rm -rf  /usr/local/apache-tomcat-front/webapps/*
rm -rf  /usr/local/apache-tomcat-admin/webapps/*

#echo "install tomcat sucess"



