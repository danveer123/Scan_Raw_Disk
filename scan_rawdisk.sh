#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

echo "Scanning for new added disks..."
for i in host{0..50};do
	echo "- - -" > /sys/class/scsi_host/$i/scan
done > /dev/null 2>&1
## Once disk scan below script find Raw disk ##

echo "======================================"
echo -e  "${GREEN}Scanning New Raw disk\n"
found_raw_disk=false

# List all disks using lsblk, skip the NAME line, and check if it has no mountpoint and no partitions
lsblk -dn -o NAME,TYPE | while read disk type; do
    if [ "$type" = "disk" ]; then
        # Check if disk has any partitions
        if ! lsblk /dev/$disk | grep -q part; then
            # Check if disk has filesystem or is mounted
            if ! blkid /dev/$disk &>/dev/null && ! mount | grep -q "/dev/$disk"; then
                raw_disk="/dev/$disk"
                echo "$raw_disk is a RAW disk"
                found_raw_disk=true
            fi
        fi
    fi
done

# Exit with code 1 if no raw disk was found
if [ "$found_raw_disk" = false ]; then
    echo -e "${RED}No RAW disks found.\n${NC}"
    echo -e "${YELLOW}Please ask database team to add new hard disk\n${NC}"
    exit 1
fi

## Lets find the size of raw disk

disk=`lsblk | grep disk | tail -1 | awk '{print $4}'`
echo " Your raw disk size is: $disk"
#===================================#
## Lets extend the Root partation
## This is user interactive script, needs user input 
