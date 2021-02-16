#!/usr/bin/python3

import libmicon
import platform
import subprocess
import time

#############################################################
###Requires the Buffalo libmicon library to function#########
###https://github.com/1000001101000/Python_buffalo_libmicon##
#############################################################
###Script designed to be ran every minute or two, you can####
###adjust the timings yourself if the data is displayed######
###too fast for your liking. Putting it in crontab to########
###run it every minute or so works fine for me at least.#####
#############################################################

#Select which folder to check the partition size utilization from
diskToMeasure = "/"

##try reading micon version from each port to determine the right one
for port in ["/dev/ttyS1","/dev/ttyS3"]:
        test = libmicon.micon_api(port)
        micon_version = test.send_read_cmd(0x83)
        if micon_version:
                break
        test.port.close()

micon_version=micon_version.decode('utf-8')

#Set display color and brightness
test.set_lcd_brightness(libmicon.LCD_BRIGHT_FULL)
test.set_lcd_color(libmicon.LCD_COLOR_BLUE)

#Display hostname and uptime and sleep 10 seconds
hostHostname = open("/etc/hostname", "r")
hostHostname = hostHostname.readline().strip().center(16)

hostUptimeCmd = "uptime | awk '{print \"Uptime: \" substr($3, 1, length($3)-1)}'"
hostUptimeCmdOutput = subprocess.Popen(hostUptimeCmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
hostUptimeCmdOutput = hostUptimeCmdOutput.communicate()[0]
hostUptimeCmdOutput = hostUptimeCmdOutput.decode('utf-8')[:-1]

test.set_lcd_buffer(0x90,hostHostname,hostUptimeCmdOutput)
test.cmd_force_lcd_disp(libmicon.lcd_disp_buffer0)
test.send_write_cmd(1,libmicon.lcd_set_dispitem,0x20)

time.sleep(10)

#Display eth0 IPv4 address and sleep for 10 seconds
cmd2 = "ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
cmd2output = subprocess.Popen(cmd2,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
cmd2output = cmd2output.communicate()[0]
cmd2output = cmd2output.decode('utf-8')[:-1]
title = "Interface eth0:"

if not cmd2output:
        cmd2output = "DOWN"

test.set_lcd_buffer(0x91,title,cmd2output)
test.cmd_force_lcd_disp(libmicon.lcd_disp_buffer1)
test.send_write_cmd(1,libmicon.lcd_set_dispitem,0x20)

time.sleep(10)

cmd3 = "ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
cmd3output = subprocess.Popen(cmd3,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
cmd3output = cmd3output.communicate()[0]
cmd3output = cmd3output.decode('utf-8')[:-1]
title = "Interface eth1:"

if not cmd3output:
        cmd3output = "DOWN"

test.set_lcd_buffer(0x91,title,cmd3output)
test.cmd_force_lcd_disp(libmicon.lcd_disp_buffer1)
test.send_write_cmd(1,libmicon.lcd_set_dispitem,0x20)

time.sleep(9)
#Sleep only for 9 seconds instead of 10 as the awk script sleeps for one sec as well
#https://stackoverflow.com/a/26791392/8387708
#This is pure magic
cmd4 = "awk -v a=\"$(awk '/cpu /{print $2+$4,$2+$4+$5}' /proc/stat; sleep 1)\" '/cpu /{split(a,b,\" \"); printf( \"%3.2f\", 100*($2+$4-b[1])/($2+$4+$5-b[2]))}'  /proc/stat"
#Checking memory and CPU usage loop. Set to 20 seconds since we have 60 seconds to fill and this seems the most useful data
for memLoop in range(20):
        cmd3 = "free -m | awk 'NR==2{print $1 \" \" $2 \"mb/\" $3 \"mb\"}'"
        cmd3output = subprocess.Popen(cmd3,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        cmd3output = cmd3output.communicate()[0]
        cmd3output = cmd3output.decode('utf-8')

        cmd4output = subprocess.Popen(cmd4,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        cmd4output = cmd4output.communicate()[0]
        cmd4output = cmd4output.decode('utf-8')
        cmd4output = "CPU: " + cmd4output + "%"

        test.set_lcd_buffer(0x91,cmd3output[:-1],cmd4output)
        test.cmd_force_lcd_disp(libmicon.lcd_disp_buffer1)
        test.send_write_cmd(1,libmicon.lcd_set_dispitem,0x20)
        #print(memLoop)
        time.sleep(1)

#Display disk usage of partition of selected folder
diskCmd = "df -hl --total " + diskToMeasure + " | awk 'NR==2{print $2 \"/\" $3}'"
diskCmdOutput = subprocess.Popen(diskCmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
diskCmdOutput = diskCmdOutput.communicate()[0]
diskCmdOutput = diskCmdOutput.decode('utf-8')[:-1]
title = "Storage use:"

test.set_lcd_buffer(0x91,title,diskCmdOutput)
test.cmd_force_lcd_disp(libmicon.lcd_disp_buffer1)
test.send_write_cmd(1,libmicon.lcd_set_dispitem,0x20)

#if (micon_version.find("HTGL") == -1):
#       test.set_lcd_color(libmicon.LCD_COLOR_GREEN)
#
#test.cmd_set_led(libmicon.LED_ON,libmicon.POWER_LED)
#
test.port.close()
quit()
