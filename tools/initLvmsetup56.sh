# quick and dirty create a volume group on 2 physical volumes

if [ `id -g` != 0 ]; then
	echo "Usage SUDO: ./initLvmsetup56.sh"
	exit
fi

./initLvmsetup.sh 5 6

sudo lvcreate --type linear -L 20M -n linearvol vol_vg56
