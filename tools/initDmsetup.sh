if [ `id -g` != 0 ]; then
	echo "Run the script as sudo user"
	exit
fi

numDevs=${1-"1"}


dmsetup remove mydev

for i in [[ `seq 1 $numDevs` ]]; do 
	losetup -d /dev/loop$i
	rm -rf /tmp/$i
	dd if=/dev/zero of=/tmp/$i bs=4096 count=1000
	losetup /dev/loop$i /tmp/$i
done

# start gdb

gdb ./dmsetup


#echo $numDevs
