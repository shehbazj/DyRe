echo -e "Cleanup Start"

if [ "$#" -ne 3 ]; then 
	echo "Usage sudo ./cleanupLvm.sh <startDev> <numDevs> <deviceArray>"
	exit 
fi

startDev=$1
numDevs=$2
deviceArray=$3

echo "Delete volume if it exsits"

umount /dev/vol_vg/root
lvremove /dev/vol_vg/root

echo "Delete Volume Group if it exists"

vgchange -a n vol_vg
vgremove vol_vg

echo "Delete Physical Volume if that exists"

pvremove /dev/loop$deviceArray

echo -e "Cleanup End"
