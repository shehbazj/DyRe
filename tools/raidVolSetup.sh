if [ `id -g` != 0 ]; then
	echo "Please run as sudo user\nsudo ./raidVolSetup.sh"
	exit
fi

#remove if already exists
file="/dev/mapper/vol_vg-raid4"

if mount | grep /mnt > /dev/null; then
	umount /mnt
	lvremove vol_vg raid4
else
 echo "mount directory clean"
fi

#create a raid Volume

lvcreate --type raid4 -L 80M -i3 -n raid4 vol_vg

## create fs on volume
#
#mkfs.xfs /dev/mapper/vol_vg-raid4
#
## mount it on /mnt
#
#mount /dev/mapper/vol_vg-raid4 /mnt
#
## start bonnie
#
##bonnie++ -d /mnt/ -c 3 -s 60 -r 30 -u root
