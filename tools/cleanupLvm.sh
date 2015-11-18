echo -e "\e[1;31m Cleanup Start \e[0m"

if [ "$#" -ne 2 ]; then 
	echo "Usage sudo ./cleanupLvm.sh <numDrives> <deviceArray>"
	exit
fi

numDrives=$1
deviceArray=$2

echo "Delete volume if it exsits"

umount /dev/vol_vg/root
lvremove /dev/vol_vg/root

echo "Delete Volume Group if it exists"

vgchange -a n vol_vg
vgremove vol_vg

echo "Delete Physical Volume if that exists"

pvremove /dev/loop$deviceArray

echo -e "\e[1;31m Cleanup End \e[0m"
