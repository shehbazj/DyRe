if [ `id -g` != 0 ]; then
	echo "Usage SUDO: ./initLvmsetup [numDrives]"
	exit
fi


startDev=1
numDevs=${1-"3"}

if [ $# -eq 2 ]; then
startDev=$1
numDevs=$2
fi

echo "number of params is $#"

dmsetup remove raid4

for i in `seq $startDev $numDevs`; do 
	losetup -d /dev/loop$i
	rm -rf /tmp/$i
	dd if=/dev/zero of=/tmp/$i bs=4096 count=20000
	losetup /dev/loop$i /tmp/$i
done

echo "loop devices setup"
losetup

./createVolumes.sh $startDev $numDevs
echo $numDevs

## start gdb
#
##gdb lvcreate 
#
##./raidVolSetup.sh
#
##echo $numDevs
