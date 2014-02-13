#!/bin/bash
# Disable a swap partition on given Xen DomU images using LVM
# Raymond Colebaugh

REMOVEMNT=0
REMOVELV=0
VG="VolGroup"

function usage() {
   echo "Usage: ./xen-disableswap.sh [-d | --delete] [--vg VolGroup] host1.example.com [host2.example.com ...]"
   exit 1
}
TEMP=`getopt -o d --long delete,vg: -n 'xen-disableswap.sh' -- "$@"`
if [ $? != 0 ] ; then usage; fi
eval set -- "$TEMP"

while true; do
   case "$1" in
      -d|--delete) REMOVELV=1; shift;;
      --vg) 
         case "$2" in
            "") echo "You must specify a volume group!"; usage;;
            *)  VG="$2"; shift 2 ;;
         esac ;;
      --) shift ; break ;;
      *) echo "Internal error!"; usage; exit 1 ;;
   esac
done

if [ $# -eq 0 ]; then usage; fi
GUESTS="$@"

if [ ! -d /mnt/swapdisable ]; then
   sudo mkdir /mnt/swapdisable
   REMOVEMNT=1
fi

for guest in $GUESTS; do
   echo "Removing swap for ${guest}..."
   sudo mount /dev/${VG}/${guest}-disk /mnt/swapdisable

   # Comment out the swap entry in fstab and reassign the root disk to xvda1
   sudo sed -i '/swap/ s/^#*/#/; s/xvda2/xvda1/' /mnt/swapdisable/etc/fstab
   sudo sed -i 's/\(xvda\)2/\11/g' /mnt/swapdisable/boot/grub/menu.lst
   sudo umount /mnt/swapdisable

   # Comment out the swap entry for the domU and reassign the root disk to xvda1
   sudo sed -i '/swap/ s/^#*/#/; s/\(disk,xvda\)2/\11/' /etc/xen/${guest}.cfg
   sudo sed -i '/root/ s/\(\/dev\/xvda\)2/\11/g' /etc/xen/${guest}.cfg
   if [ $REMOVELV -eq 1 ]; then
      sudo lvremove -f /dev/${VG}/${guest}-swap
   fi
done

if [ $REMOVEMNT -eq 1 ]; then
   sudo rmdir /mnt/swapdisable
fi
