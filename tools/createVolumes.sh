startDev=$1
numDevs=$2

if [ "$#" -ne 2 ]; then 
	echo "Usage sudo ./createVolumes.sh <startDrive> <numDrives>"
	exit
fi

# show physical volumes.
echo "display physical volumes."

pvdisplay

echo "creating physical volumes"

deviceArray='['
for i in `seq $startDev $numDevs`; do
	deviceArray=$deviceArray$i
done

deviceArray=$deviceArray']'
echo "Device Array $deviceArray"

./cleanupLvm.sh $startDev $numDevs $deviceArray

pvcreate /dev/loop$deviceArray

echo "Display physical volumes"
pvdisplay

echo "creating virtual volume groups"

vgcreate vol_vg$startDev$numDevs /dev/loop$deviceArray

echo "Display Virtual Groups"

vgdisplay

#sudo lvremove 

#echo "Create A logical Volume"

#lvcreate --extents 100%FREE --name root vol_vg

#echo "DIsplay the Logical Volume"

#lvdisplay
