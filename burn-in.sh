#!/bin/bash
#
# Burn-in procedure for hard disks using
# SMART and badblocks.
#
# WARNING: This will destroy all data on the drive!

set -euo pipefail

if [ $# -ne 1 ]
then
    echo "Usage: $0 <device> (eg: /dev/sdb)"
    exit 1
fi

DRIVE="$1"

echo "Starting burn in procedure for drive ${DRIVE}..."

if [ ! -e "${DRIVE}" ]
then
    echo "Drive ${DRIVE} not found!"
    exit 1
fi

for dependency in parted smartctl badblocks
do
    if [ ! "$(which $dependency)" ]
    then
        echo "Error: Missing dependency $dependency"
        exit 1
    fi
done

if [ $EUID -ne 0 ]
then
    echo "Error: This script must be executed as root!"
    exit 1
fi

parted "${DRIVE}" print
BLOCK_SIZE=$(cat "/sys/block/${DRIVE/\/dev\//}/queue/physical_block_size")

echo -n "WARNING: The burn in procedure involves writing multiple passes of "
echo "data onto the disk."
echo "This will irrevocably destroy all data on the disk!"
echo "Is ${DRIVE} the correct disk with physical sector size ${BLOCK_SIZE}?"
echo -n "Type 'YES' to continue: "
read -r confirmation
if [ "$confirmation" != "YES" ]
then
    echo "Burn in procedure aborted!"
    exit 1
fi

echo -e "\nRunning initial SMART tests..."
smartctl -Ct long "${DRIVE}"

echo -e "\nStarting badblocks burn in procedure. This can take a long time..."
badblocks -ws -b "${BLOCK_SIZE}" "${DRIVE}"

echo -e "\nRunning final SMART tests..."
smartctl -Ct long "${DRIVE}"

echo -e "\nFinal SMART results:"
smartctl -A "${DRIVE}"
