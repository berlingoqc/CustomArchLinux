#!/bin/bash 

KEYS="cf"
LANG="en_US.UTF-8"
HOSTNAME="ArchRolling"
TIMEZONE="Canada/Eastern"
BLK="sda"

rankMirror (){
  DIRM="/etc/pacman.d/mirrorlist"
  cp $DIRM ${DIRM}.backup
  . sed -s 's/^#Server/Server/' $DIRM
  . rankmirrors -n 10 ${DIRM}.backup > $DIRM 
}
