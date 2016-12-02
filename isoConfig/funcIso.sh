#!/bin/bash - 
#===============================================================================
#
#          FILE: extractiso.sh
# 
#         USAGE: ./extractiso.sh 
# 
#   DESCRIPTION: Download the lastest iso from ArchLinux website and extract
#		 the files to customiso directory to allow modification
#		 and after modification call this script again to repack
#		 the arch linux iso
# 
#       OPTIONS: ---
#  REQUIREMENTS: wget
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/02/2016 10:07:38 AM
#      REVISION:  ---
#===============================================================================

#Execute the cmd past as argument with root privileges
with_su () 
{
 [ $UID -ne 0 && ! -n "$1" ] && \ 
 { echo "Must be root for this part : "; su -c "$1"; } || $1
}

#Valid if a accepted architecture have been past
valid_arch () 
{
  ARC=x86_64
  if [ -e "$1" && (( "$1" == "i386" || "$1" == "x86_64" ))  ]; then
    ARC=$1
  else
    return 0
  fi
  return $ARC
}

#Fetch required script to run programs
#and install missing dependecies
fetch_required ()
{
  #Fonction to download required script 
  #arch-chroot
  wget https://git.archlinux.org/arch-install-scripts.git/plain/arch-chroot.in
}

#Unpack the contain of the airootfs to allow chroot into it
unsquash ()
{
  ARC=valid_arch $1 
  echo "Unsquashing the $ARC system"
  PAT="${DIRISO}/arch/${ARC}/airootfs.sfs"
  unsquashfs $PAT
}

#Execut the argument in the root fs on the iso working on
arch_chroot ()
{
  #Pass as argument arch to use  and witch local files to copy
  #and run in the chroot environnement
  local ARC PRE FILES
  ARC=valid_arch $1
  if [ $ARC == "i386" ]; then
    PRE="setarch i686 "
  fi
  PATDIR=${DIRISO}/arch/$ARC/squashfs-root
  mkdir ${PATDIR}/configScript
  # Test if all script pass exists and create a file to call them alls
  FILES="#!/bin/bash\n\n"
  shift
  for arg in "$@"
  do
    if [ ! -f $arg ]; then
      echo "File : $arg don't exist, skipping"
    else
      FILES="${FILES}exec $arg\n"
      cp $arg ${PATDIR}/configScript/
    fi
  done
  $FILES > ${PATDIR}/configScript/cmdlist.sh

  with_su  "${PRE}arch-chroot $PATDIR ./configScript/cmdlist.sh"
  echo Done
}

#Download the lastest iso from mirror
download_iso ()
{
  echo "Downloading latest arch iso from $MIRROR"
  wget ${MIRROR}/${RELEASE}{${FILE},md5sums.txt}
  md5sum -c md5sums.txt &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error with checksum , try again"
    exit $E_CS
  fi
}

#Copy the contain of the iso to a specific directory
copy_iso ()	
{
  [ -d $DIRISO ] && . rm -r $DIRISO
  if [ ! -f ${FILE} ]; then
    download_iso
  fi
  #Mount the iso and copie the files
  cmd={
   mkdir -p /mnt/archiso
   mount -t iso9660 ${PWD}/$FILE /mnt/archiso
   echo "Copying files from iso in the ./customiso/ it won't be long"
   cp -a /mnt/archiso $DIRISO
   umount ${PWD}/$FILE
   rmdir /mnt/archiso
}
  #If not root run this command throw su and ask for passwd
  with_su $cmd
}

#Repack the airootfs after the modification where made
squash_back ()
{
  ARC=valid_arch $1
  PATDIR=${DIRISO}/arch/$ARC/
  rm $PATDIR/airootfs.sfs
  mksquashfs $PATDIR/squashfs-root airootfs.sfs
  rm -r $PATDIR/squashfs-root
  md5sum airootfs.sfs > airootfs.md5
}
#Missing part for repacking the iso for dvd or usbkey or UEFI system
