#!/bin/bash
#===============================================================================
#
#          FILE:  basicConfig.sh
#
#         USAGE:  ./basicConfig.sh
#
#   DESCRIPTION:  Basic configuration of arch linux system
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  William Quintal
#       VERSION:  1.0
#       CREATED:  11/30/2016 07:29:07 PM EST
#===============================================================================

#test if connect to internet
IS_CONNECTED=True
. ping -c1 archlinu.org &> /dev/null
if [ $? -ne 0 ]; then
 #test if there is a wifi interface
 . ip link | grep wlp* &> /dev/null
 if [ $? -eq 0 ]; then . wifi-menu -o
 else
   echo "Can't set up a connecion" & $IS_CONNECTED=False
 fi
fi

loadkeys cf
timedatectl set-ntp true
${PWD}/parted.sh
pacstrap /mnt base base-devel os-prober grub
genfstab -U /mnt >> /mnt/etc/fstab
