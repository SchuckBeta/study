#!/bin/sh
#bin=$(cd `dirname $0` ; pwd)
#cd ..
war=ROOT.war
bin=/opt/download/jenkins
cd $bin
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

filename=`date +%Y%m%d`
echo 'ROOT.war.'
mv  /opt/download/jenkins/ROOT.war  /opt/download/jenkins/'ROOT'${filename}.war
