🔽🔽 Tutorial for Partitioning the Free Space on a Google Router and Extroot Configuration to Preserve Installed Packages and Settings After Updating OpenWrt, Plus Backup and Restore Partition (Next Tutorial) 🔽🔽

⚠️ Note: To achieve the desired results, the Google router must be in its factory state, and the memory expansion process should not have been performed previously.

1. Install Prerequisite Packages:
shell
Copy
Edit
opkg update
opkg install block-mount kmod-fs-ext4 e2fsprogs parted kmod-usb-storage luci-app-attendedsysupgrade luci cfdisk resize2fs
2. Create a Partition from the Router's Free Space
Run the following command and follow the steps:

shell
Copy
Edit
cfdisk /dev/mmcblk0
Steps:

a: Navigate to the last line labeled Free space.

b: Select the option New.

c: The program will automatically calculate the remaining free space. Simply press Enter.

d: Choose the option Write, type yes to confirm, and press Enter.

⚡️ Exit the program and reboot the device.

3. Extroot the Created Partition
⚠️ Important:
All extroot commands must be copied and executed line by line.

a. Format the Created Partition:

shell
Copy
Edit
PARTITION="/dev/mmcblk0p3"
shell
Copy
Edit
mkfs.ext4 -L extroot ${PARTITION}
b. Configure Extroot:

shell
Copy
Edit
eval $(block info ${PARTITION} | grep -o -e 'UUID="\S*"')
shell
Copy
Edit
eval $(block info | grep -o -e 'MOUNT="\S*/overlay"')
shell
Copy
Edit
uci -q delete fstab.extroot
shell
Copy
Edit
uci set fstab.extroot="mount"
shell
Copy
Edit
uci set fstab.extroot.uuid="${UUID}"
shell
Copy
Edit
uci set fstab.extroot.target="${MOUNT}"
shell
Copy
Edit
uci commit fstab
c. Configure rootfs_data:

shell
Copy
Edit
ORIG="$(block info | sed -n -e '/MOUNT="\S*\/overlay"/s/:\s.*$//p')"
shell
Copy
Edit
uci -q delete fstab.rwm
shell
Copy
Edit
uci set fstab.rwm="mount"
shell
Copy
Edit
uci set fstab.rwm.device="${ORIG}"
shell
Copy
Edit
uci set fstab.rwm.target="/rwm"
shell
Copy
Edit
uci commit fstab
d. Transfer /overlay Data to the New Partition:

shell
Copy
Edit
mount ${PARTITION} /mnt
shell
Copy
Edit
tar -C ${MOUNT} -cvf - . | tar -C /mnt -xf -
⚡️ Reboot the router after completing these steps.

4. Configure Mount Points
a: Access the user interface via a browser and navigate to:
LuCI → System → Mount Points

b: In the Mount Points section, find the path /overlay and click Edit.

c: In the new page, open the UUID menu and select match by UUID. This will add the Label option.

d: Open the Label menu, select extroot (/dev/mmcblk0p3, 3... GiB), check Enabled, and save.

⚡️ Finally, reboot the device.

✔️ Final Steps
Once all steps are complete, you can proceed to install packages such as Passwall... Managers and make desired changes. From now on, whenever you update OpenWrt, simply reinstall the prerequisite packages (step 1) and reboot the router. All installed packages and their settings will remain intact, exactly as before the update.
