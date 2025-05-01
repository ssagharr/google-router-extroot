#!/bin/sh         
set -e  # Exit immediately if a command exits with a non-zero status  
set -x
# Script Introduction
echo -e "\033[1;36mThis script is developed for the \033[1;34mGoogle Wifi AC-1304\033[1;36m \033[32mOpenWRT\033[1;36m devices.\033[0m"
echo -e "\033[1;36mIt will configure extroot to expand the storage by using the free space on the internal storage to create an extra partition for overlay data.\033[0m"
echo -e "\033[1;33mDo you want to continue? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" != "y" ]; then
  echo -e "\033[31mExiting the script.\033[0m"
  exit 0
fi

# Variables
DISK="/dev/mmcblk0"
DEVICE="${DISK}p3"

# 3-second delay before Step 1
sleep 3

# Step 1: Install required packages
echo -e "\033[34mUpdating and installing required packages...\033[0m"
opkg update
opkg install block-mount kmod-fs-ext4 e2fsprogs parted kmod-usb-storage luci-app-attendedsysupgrade luci cfdisk resize2fs ncat pv gzip coreutils-dd coreutils-mv openssh-sftp-server lsblk

# Step 2: Create new partition
echo -e "\033[1;33mDo you want to create a new partition for extroot? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" = "y" ]; then
  echo -e "\033[34mCreating a new partition for extroot...\033[0m"
  parted -s ${DISK} -- mkpart extroot 247808s -2048s
else
  echo -e "\033[35mSkipping partition creation.\033[0m"
fi

# Step 3: Format the new partition
echo -e "\033[1;33mDo you want to format the new partition? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" = "y" ]; then
  echo -e "\033[34mFormatting the new partition...\033[0m"
  mkfs.ext4 -L extroot ${DEVICE}
else
  echo -e "\033[31mSkipping partition formatting and exiting.\033[0m"
 # exit 0
fi

# 3-second delay before Step 4
sleep 3


# Step 4: Configure extroot
echo -e "\033[34mConfiguring extroot...\033[0m"
sleep 15
eval $(block info ${DEVICE} | grep -o -e 'UUID="\S*"')
echo -e "\033[35mOk .\033[0m"
sleep 15
eval $(block info | grep -o -e 'MOUNT="\S*/overlay"')
echo -e "\033[35mOk . .\033[0m"
sleep 15
uci -q delete fstab.extroot
echo -e "\033[35mOk . . .\033[0m"
sleep 15
uci set fstab.extroot="mount"
echo -e "\033[35mOk . . . .\033[0m"
sleep 15
uci set fstab.extroot.uuid="${UUID}"
echo -e "\033[35mOk . . . . .\033[0m"
sleep 15
uci set fstab.extroot.target="${MOUNT}"
echo -e "\033[35mOk . . . . . .\033[0m"

# Adding delay around uci commit fstab
echo -e "\033[1;36mCommitting changes to fstab...\033[0m"
sleep 15
uci commit fstab
echo -e "\033[1;36mChanges committed to fstab.\033[0m"
sleep 15

# Step 5: Configure rootfs_data
echo -e "\033[34mConfiguring rootfs_data...\033[0m"
ORIG="$(block info | sed -n -e '/MOUNT="\S*\/overlay"/s/:\s.*$//p')"
echo -e "\033[35mOk .\033[0m"
sleep 15
uci -q delete fstab.rwm
echo -e "\033[35mOk . .\033[0m"
sleep 15
uci set fstab.rwm="mount"
echo -e "\033[35mOk . . .\033[0m"
sleep 15
uci set fstab.rwm.device="${ORIG}"
echo -e "\033[35mOk . . . .\033[0m"
sleep 15
uci set fstab.rwm.target="/rwm"
echo -e "\033[35mOk . . . . .\033[0m"
# Adding delay around uci commit fstab
echo -e "\033[1;36mCommitting changes to fstab...\033[0m"
sleep 15
uci commit fstab
echo -e "\033[1;36mChanges committed to fstab.\033[0m"
sleep 15

# Step 7: mount
echo -e "\033[1;33mDo you want to mount? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" = "y" ]; then
  echo -e "\033[34mmount...\033[0m"
  sleep 2
  mount ${DEVICE} /mnt
  sleep 15
else
  echo -e "\033[31mSkipping mount.\033[0m"
fi
# Step 8: Transfer data
echo -e "\033[1;33mDo you want to transfer data? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" = "y" ]; then
  echo -e "\033[34mtransferring data...\033[0m"
  
  sleep 10
  tar -C ${MOUNT} -cvf - . | tar -C /mnt -xf -
  sleep 10
else
  echo -e "\033[31mSkipping transfer data and exiting.\033[0m"
  exit 0
fi

# Initial message
msg="Almost done"
exclamation="!"

# Loop for adding exclamation marks
for i in 1 2 3  4  5  6 ; do
  echo -ne "\r\033[35m$msg$exclamation\033[0m"
  exclamation="${exclamation}!"
  sleep 1
done
# Move to the next line after the loop
echo
sleep 2
echo -e "\033[32m>>>>>>>>>>>DONE!\033[0m"

# 2-second delay before Step 8
sleep 2

# Step 9: Reboot to apply changes
echo -e "\033[1;33mDo you want to reboot the device to apply changes? [\033[32my\033[0m/\033[31mn\033[0m]\033[0m"
read -r answer
if [ "$answer" = "y" ]; then
  echo -e "\033[34mRebooting the device to apply changes...\033[0m"
  reboot
else
  echo -e "\033[33mYou need to reboot the device manually to apply changes.\033[0m"
  exit 0
fi
