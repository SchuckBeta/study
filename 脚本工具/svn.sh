#!/bin/bash
#-*- utf-8 -*-
#Created by : victor.zhang
#Date       : 26/10/2016
#Desc       : checkout/update svn

SVNPATH='svn://192.168.0.104/creativecloud/peoject/branches/creativecloud-bugs-v1.2.0';
TARDIR='creativecloud';
case "$1" in
    update)
         echo "update..." ;
         cd `dirname $0`/creativecloud ;
         echo `pwd`;
         svn update;
        ;;
    checkout)
         echo  "checkout...";
         cd `dirname $0`;
         echo `pwd`;
         svn checkout  $SVNPATH  $TARDIR --username zhangchuansheng;
        ;;
    *)
        echo "Usage: svn {checkout|update}"
        exit 1
        ;;
esac
##END
