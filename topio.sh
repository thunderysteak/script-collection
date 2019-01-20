#!/bin/bash
###########################################################################
# topio.sh                                                                #
# Returns names of top 5 active processes consuming system I/O as reported#
# by 'iotop'. Used for custom Zabbix item. Remember to add the user into  #
# visudo to execute the script. iotop requires it.                        # 
# For the user 'zabbix':                                                  #
# zabbix  ALL=(ALL:ALL) NOPASSWD: /usr/sbin/iotop                         #
# For use with Zabbix:                                                    #
# UserParameter=system.topio[*],/etc/zabbix/userscript/ioreport.sh        #
# Replace "system.topio[*]" with any item key you want.                   #
###########################################################################
#                           By thunderysteak                              #
#                         Use at your own risk!                           #
###########################################################################
# Runs iotop in batch mode and displays only the active processes using IO
sudo iotop -b -d2 -n1 --only | \
# If there's no data to display, it sends blank to stop Zabbix from disabling an item.
awk 'BEGIN { reply=""} END {print reply, "" } \
# Sends only the data from 4th line to the 9th line and prints out the user of the 
# process, IO percentage and the process running.
NR>=4&&NR<=9 {reply=reply " User: " $3 " - "  $10 "% IO - Process: " $12 " " $13 " " $14 " " $15 " "}'
