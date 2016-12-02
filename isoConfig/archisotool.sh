#!/bin/bash - 
#===============================================================================
#
#          FILE: archisotool.sh
# 
#         USAGE: ./archisotool.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: Right now need to finish the argument parsing in order to test
#        AUTHOR: William Quintal
#  ORGANIZATION: 
#       CREATED: 12/02/2016 01:13:56 PM
#      REVISION:  ---
#===============================================================================

MIRROR="http://mirror.rackspace.com/archlinux/iso/"
RELEASE=$(date +%Y.%m.01)
DIRISO="${PWD}/customiso/"
FILE="archlinux-${RELEASE}-dual.iso"

E_CS=1
E_NOARGS=3


usage () {
  cat <<EOF
usage: ${0##*/} [-d [mirror] | -f <file>] [...]  

	-d [mirror]	Download the lastest iso from https server
       			default is $MIRROR	
	-f <file>	Use specify archlinux iso
        -a [arch]	Specify witch architecture to use
			default is $ARCH
	-l <dir>	Specify a directory to use for the other
			manipulation
			
	-e 		Extract iso to a default is ~/customiso
	
	-i <file>	Read from file package from pacman or AUR
       			and install them in the iso	
	-s <folder>	Copy folder and execute script in the iso root
			for specific configuration on the system, search
			for config.sh inside to run.
	
	-m <mode>       When repacking specify witch type of device
			iso gonna get burn to 
			mode = [ DISK , MEMBIOS , MEMUEFI ]

	-r [dst] 	Repack iso files, put dir location if is not
			the default one	
EOF
}

[ $# -eq 0 ] && { usage; exit $E_NOARGS; }

. funcIso.sh

while getopts "df:al:ei:s:m:r" o; do
 case ${o} in
	-d)
	
	;;
	-f)
	:
	;;
	-s)
	:
	;;	
 esac
done


