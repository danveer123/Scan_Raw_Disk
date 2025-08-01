#!/bin/bash
## This is a user-interactive LVM extension script ##
# Display available disks
echo -e "\033[0;32mAvailable disks:\033[0m"
lsblk | egrep -Ev 'boot|swap|home|sr0'
# Get the disk name from user
read -p "Please enter your raw disk name (e.g., sdb): " raw_disk
if [ -z "$raw_disk" ]; then
    echo "No disk name entered. Exiting."
    exit 1
fi
echo "User selected disk: /dev/$raw_disk"

# Show existing physical volumes
pvs
# Create physical volume
echo "Creating physical volume on /dev/$raw_disk..."
pvcreate /dev/$raw_disk || { echo "Failed to create PV on /dev/$raw_disk"; exit 1; }

# Show volume groups
vgs
# Get VG name from user
read -p "Enter VG name to extend: " vg_name
if [ -z "$vg_name" ]; then
    echo "No VG name entered. Exiting."
    exit 1
fi
echo -e "\033[0;32mExtending VG: $vg_name\033[0m"
vgextend "$vg_name" /dev/$raw_disk || { echo "VG extend failed"; exit 1; }

# Display partitions (LVMs)
echo -e "\033[0;32mSelect which partition (LV) you want to extend:\033[0m\n"
df -Th | egrep -Ev 'tmpfs|Filesystem|efivarfs|boot' | awk '{print $1 "   " $6}'

# Get LV name
read -p "Enter full LV path (e.g., /dev/mapper/rhel-root): " lv_name
if [ -z "$lv_name" ]; then
    echo "No LV name entered. Exiting."
    exit 1
fi
echo "You selected: $lv_name"
# Extend LV
echo -e "\033[0;32mExtending LVM...\033[0m"
lvextend -r -l +100%FREE "$lv_name" || { echo "LV extend failed"; exit 1; }

echo "$lv_name successfully extended."
