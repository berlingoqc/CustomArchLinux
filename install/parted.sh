#!/bin/bash -
#===============================================================================
#
#          FILE: parted.sh
#
#         USAGE: ./parted.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 11/30/2016 09:16:01 PM
#      REVISION:  ---
#============================================================

#Valid the argument of the script witch block device
BLK=$1
CMD="parted /dev/$BLK"
MKP="mkpart primary"
$CMD mklabel msdos
$CMD $MKP ext4 1MiB 100MiB
$CMD set 1 boot on
$CMD $MKP linux-swap 100MiB 4GiB
$CMD $MKP ext4 4GiB 35GiB
$CMD $MKP ext4 35GIB 100%

mkfs.ext4 /dev/${BLK}{1,3,4}
CMD="/dev/${BLK}2"
mkswap $CMD
swapon $CMD

mount /dev/${BLK}3 /mnt
mkdir /mnt/{home,boot}
mount /dev/${BLK}1 /mnt/boot
mount /dev/${BLK}4 /mnt/home
