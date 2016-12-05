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
su_copy ()
{
  mkdir -p "/mnt/archiso"
  mount -t iso9660 "$FILE" "/mnt/archiso" && \
  echo "Copying files from iso in the ${DIRISO} it would not be long" && \ 
  cp -a /mnt/archiso ${DIRISO} && \
  umount ${FILE} && \
  rmdir /mnt/archiso
} #Copy the contain of the iso to a specific directory
#Execute the cmd past as argument with root privileges
with_su () 
{
 if [ $UID -ne 0 ]; then 
   echo "Must be root for this part"
   su "$1"
 else
   $1
 fi
}

#Valid if a accepted architecture have been past
valid_arch () 
{
  ARC="x86_64"
  if [[ "$1" == "i386" || "$1" == "x86_64"  ]]; then
    ARC=$1
  fi
  return $ARC
}

#Fetch required script to run programs
#and install missing dependecies
fetch_req ()
{
  #Fonction to download required script 
  #arch-chroot
  if [ ! -f "arch-chroot.in" ]; then
    wget https://git.archlinux.org/arch-install-scripts.git/plain/arch-chroot.in
  fi
}

#Unpack the contain of the airootfs to allow chroot into it
unsquash ()
{
  echo "Unsquashing the $ARCH system"
  PAT="${DIRISO}/arch/${ARCH}/airootfs.sfs"
  unsquashfs $PAT 
}

#Execut the argument in the root fs on the iso working on
arch_chroot ()
{
  #Pass as argument arch to use  and witch local files to copy
  #and run in the chroot environnement
  local ARC PRE FILES
  ARCH=valid_arch $1
  if [ $ARCH == "i386" ]; then
    PRE="setarch i686 "
  fi
  PATDIR=${DIRISO}/arch/$ARCH/squashfs-root
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
  wget ${MIRROR}${RELEASE}/{${FILE},md5sums.txt}
  [[ $1 -ne 0 ]] && { cat $?; exit 1; }
  md5sum -c md5sums.txt &> /dev/null
  if [ $? -ne 0 ]; then
    echo "Error with checksum , try again"
    exit $E_CS
  fi
}

copy_iso ()	
{
  [ -d $DIRISO ] && rm -r $DIRISO
  if [ ! -f ${FILE} ]; then
    download_iso
  fi #If not root run this command throw su and ask for passwd
  with_su su_copy
  unsquash

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
iso_repack ()
{
  #Valid if fs-root have been squash back and delete
  #if not error
  _iso_efi=""
  if [[ -f ${DIRISO}/EFI/archiso/efiboot.img ]]; then
  	_iso_efi="-eltorito-alt-boot
  	    	  -e ${DIRISO}/EFI/archiso/efiboot.img
    	    	  -no-emul-boot -isohybris-gpt-basdat"
  fi
  ISO_LABEL=$(date ARCH_+%Y%m)
  DRE=${DIRISO}/isolinux
  if [[ ! -d ${WORKINGDIR}/squashfs-root ]]; then
    if [[ $1 == "memstick" ]]; then
	echo "Create isomemstick named $(basename $2)"
	xorriso -as mkisofs \
	      -iso-level 3 \
	      -full-iso9660-filenames \
	      -volid $ISO_LABEL \
	      -eltorito-boot ${DRE}/isolinux.bin \
	      -eltorito-catalog ${DRE}/boot.cat \
	      -no-emul-boot -boot-load-size 4 -boot-info-table \
	      -isohybrid-mbr ${DRE}/isohdpfx.bin \
	      ${_iso_efi} \
	      -output $2 \
	      ${DIRISO}
    elif [[ $1 == "disk" ]]; then
      echo "Create iso for DVD/CD/BD name $(basename $2)"
      genisoimage -l -r -J -V $ISO_LABEL -b ${DRE}/isolinux.bin \
	      -no-emul-boot -boot-load-size 4 -boot-info-table -c \
	      ${DRE}/boot.cat -o $2 ${DIRISO}
    fi
  fi    
}

#add an installation bootstrap in the airootfs
add_install_strap ()
{
  #Create a directory and create the base script who gonna get execute at boot
  #by adding it to the .zlogin
  WKD=${WORKINGDIR}/squashfs-root/root
  if [[ -d $WKD ]]; then
    WKD=${WKD}/inststrap
    if [[ -d $WKD ]]; then
	echo "instrap folder already create do you want to replace (y/n)"
	read yn
        echo	
	if [[ $yn == "y" ]]; then
	  echo "Erasing folder"; rm -r $WKD 
	else
	  return
	fi
    fi
    mkdir -p ${WKD}
    if [[ $1 == "" ]]; then
      echo -e "#!/bin/bash\necho Default installation strap" > ${WKD}/install.sh
    else
      cp -R $1/* $WKD
    fi
    echo "~/instastrap/install.sh" >> ${WKD}/../.zlogin
  fi
}

