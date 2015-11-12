#b main
#b _alloc_init
#b lvcreate
b lvm_run_command
#r --extents 100%FREE --stripes 3 --stripesize 256 --name root vol_vg
#r --type raid4 -i 3 -L 30M -n root vol_vg
r --type dyre -min 1 -max 3 -L 30M -n root vol_vg
#r --extents 100%FREE -name root vol_vg
