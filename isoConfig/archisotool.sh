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
WORKINGDIR="${PWD}"
DIRISO="${WORKINGDIR}/customiso"
FILE="${WORKINGDIR}/archlinux-${RELEASE}-dual.iso"
ARCH="x86_64"
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
	-s [folder]	Add default installation strap, if folder
			copy the contain to the strap location must
			have an install.sh file to start the strap	

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

[ $# -eq 0 ] && { echo "Argument requireds !"; usage; exit $E_NOARGS; }
source ./funcIso.sh
fetch_req
while (( $# > 0 )) ; do
 case "$1" in
	-d)
	  if [[ $2 != "-*" && $2 != "" ]]; then
	    MIRROR=$1
		shift 1
	    #Could valid mirror
      fi
  	  download_iso
	;;
	-f)
	  if [[ $2 != "-*" && $2 != "" ]]; then
	  	if [[ -f $2 ]]; then
		  echo "Use this iso for later operation $2"
		  FILE=$2
		else
		  echo "File do not exists ! Please try again"
		  exit 1
		fi
	  fi
	;;
	-e)
		#If iso is present on working dir do the magic
		copy_iso 
	;;
	-s)
	  if [[ $2 != "-*" && $2 != "" ]]; then
	    if [[ -d $2 && -f $2/install.sh ]]; then
	      arg=$2
	      shift 1
	    fi
	  fi
	  add_install_strap $arg
	;;	
	-h)
	  usage ; exit 0
	;;
 esac
 shift 1
done
