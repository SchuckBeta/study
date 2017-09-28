#!/bin/sh
#  -----------------------------------------------------------------------------------------
# Set the JVM Performance Options
#     INITIAL_SIZE	Specify the initial size, in bytes, of the memory allocation pool.
#                    This value must be a multiple of 1024 greater than 1MB. Append the
#                    letter k or K to indicate kilobytes, or m or M to indicate megabytes.
#     MAX_SIZE       Specify the maximum size, in bytes, of the memory allocation pool.
#                    This value must be a multiple of 1024 greater than 2MB. Append the
#                    letter k or K to indicate kilobytes, or m or M to indicate megabytes.
#     MAX_NEW_SIZE   Maximum size of new generation.
#     PERM_SIZE      Size of the Permanent Generation.
#     MAX_PERM_SIZE  Maximum size of the Permanent Generation.
#----------------------------------------------------------------------------------------- 

# check current user
[ "$USER" != "root" ] && exit 1

#设置tomcat的java_opt



