#!/bin/bash
#-*- utf-8 -*-
#Created by : victor.zhang
#Date       : 26/10/2016
#Desc       : checkout/update svn

SVNPATH='https://project.rogrand.com/svn/shujia/代码/trunk/marsplus';
TARDIR='marsplus';
case "$1" in
    update)
         echo "update..." ;
         cd `dirname $0`/marsplus ;
         echo `pwd`;
         svn update;
        ;;
    checkout)
         echo  "checkout...";
         cd `dirname $0`;
         echo `pwd`;
         svn checkout  $SVNPATH  $TARDIR;
        ;;
    *)
        echo "Usage: svn {checkout|update}"
        exit 1
        ;;
esac
##END