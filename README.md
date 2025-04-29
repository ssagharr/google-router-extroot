# google-router-extroot
google router extroot script
check the tutorial on Telegram : https://t.me/iranwrt/43382/97058


🔽🔽 Tutorial for Partitioning the Free Space on a Google Router and Extroot Configuration to Preserve Installed Packages and Settings After Updating OpenWrt, Plus Backup and Restore Partition (Next Tutorial) 🔽🔽

⚠️ Note: To achieve the desired results, the Google router must be in its factory state, and the memory expansion process should not have been performed previously.

1. Install Prerequisite Packages:
opkg update
opkg install block-mount kmod-fs-ext4 e2fsprogs parted kmod-usb-storage luci-app-attendedsysupgrade luci cfdisk resize2fs

2. Create a Partition from the Router's Free Space:
cfdisk /dev/mmcblk0

Navigate to the last line labeled Free space.

Select the option "New".

The program will calculate the remaining free space automatically. Press Enter.

Choose the option "Write", type yes to confirm, and press Enter.

⚡ Exit the program and reboot the device.

3. Extroot the Created Partition:
a. Format the Created Partition:
PARTITION="/dev/mmcblk0p3"
mkfs.ext4 -L extroot ${PARTITION}

b. Configure Extroot:
eval $(block info ${PARTITION} | grep -o -e 'UUID="\S*"')
eval $(block info | grep -o -e 'MOUNT="\S*/overlay"')
uci -q delete fstab.extroot
uci set fstab.extroot="mount"
uci set fstab.extroot.uuid="${UUID}"
uci set fstab.extroot.target="${MOUNT}"
uci commit fstab

c. Configure rootfs_data:
ORIG="$(block info | sed -n -e '/MOUNT="\S*/overlay"/s/:\s.*$//p')"
uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${ORIG}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

d. Transfer Data from /overlay to the New Partition:
mount ${PARTITION} /mnt
tar -C ${MOUNT} -cvf - . | tar -C /mnt -xf -

⚡ Reboot the router after completing these steps.

4. Configure Mount Points:
Access the user interface via a browser and navigate to: LuCI → System → Mount Points.

In the Mount Points section, find the path /overlay and click "Edit".

Open the UUID menu and select "match by UUID". This will add the Label option.

Open the Label menu, select extroot (/dev/mmcblk0p3, 3... GiB), check "Enabled", and save.

⚡ Finally, reboot the device.

✔️Once all steps are complete, you can proceed to install packages such as Passwall... and make desired changes. From now on, whenever you update OpenWrt, simply reinstall the prerequisite packages (step 1) and reboot the router. All installed packages and their settings will remain intact, exactly as before the update.
