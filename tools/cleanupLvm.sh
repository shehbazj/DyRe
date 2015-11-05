echo -e "\e[1;31m Cleanup Start \e[0m"

if [ "$#" -ne 2 ]; then 
	echo "Usage sudo ./cleanupVolumes.sh <numDrives> <deviceArray>"
	exit
fi

numDrives=$1
deviceArray=$2

echo "Delete Volume Group if it exists"

vgremove vol_vg

echo "Delete Physical Volume if that exists"

pvremove /dev/loop$deviceArray

echo -e "\e[1;31m Cleanup End \e[0m"
