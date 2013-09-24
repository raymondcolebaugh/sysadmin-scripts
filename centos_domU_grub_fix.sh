#!/bin/bash
# centos_domU_grub_fix.sh
# This script fixes the initial ram disk line in the default
# grub menu.lst on CentOS.
#

function usage {
	echo "This script fixes a CentOS domU's GRUB configuration."
	echo "Usage: $0 <path-to-domU-disk>"
	exit 1
}

# Set up disk path
if [ $# -ne 1 ]; then
	usage
fi
DISK="$1"

if [ -d /tmp/mnt ]; then
	echo "/tmp/mnt directory already exists! Exiting."
	exit 1
fi
mkdir -p /tmp/mnt/domU

echo "Mounting image..."
mount $DISK /tmp/mnt/domU
if [ $? -eq 1 ]; then
	echo "Failed to mount directory. Try 'sudo'."
	exit 1
fi

cd /tmp/mnt/domU/boot
echo "Writing initrd line..."
sed -i "s/init.*.img/initrd        \/boot\/`ls | grep init`/" grub/menu.lst
cd /tmp
umount mnt/domU
rmdir mnt/domU mnt
echo " [Done]"
