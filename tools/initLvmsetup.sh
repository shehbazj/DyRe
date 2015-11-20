if [ `id -g` != 0 ]; then
	echo "Usage SUDO: ./initLvmsetup [numDrives]"
	exit
fi

numDevs=${1-"3"}


dmsetup remove mydev

for i in `seq 1 $numDevs`; do 
	losetup -d /dev/loop$i
	rm -rf /tmp/$i
	dd if=/dev/zero of=/tmp/$i bs=4096 count=10000
	losetup /dev/loop$i /tmp/$i
done

echo "loop devices setup"
losetup

./createVolumes.sh $numDevs
echo $numDevs

# start gdb

#gdb lvcreate 


#echo $numDevs
