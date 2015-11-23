numDrives=$1

if [ "$#" -ne 1 ]; then 
	echo "Usage sudo ./createVolumes.sh <numDrives>"
	exit
fi

# show physical volumes.
echo "display physical volumes."

pvdisplay

echo "creating physical volumes"

deviceArray='['
for i in `seq 1 $numDrives`; do
	deviceArray=$deviceArray$i
done

deviceArray=$deviceArray']'
echo "Device Array $deviceArray"

./cleanupLvm.sh $numDrives $deviceArray

pvcreate /dev/loop$deviceArray

echo "Display physical volumes"
pvdisplay

echo "creating virtual volume groups"

vgcreate vol_vg /dev/loop$deviceArray

echo "Display Virtual Groups"

vgdisplay

sudo lvremove vol_vg root

#echo "Create A logical Volume"

#lvcreate --extents 100%FREE --name root vol_vg

#echo "DIsplay the Logical Volume"

#lvdisplay
