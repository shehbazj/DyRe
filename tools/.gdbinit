#b main
#b _alloc_init
b lvcreate
#b lvm_register_segtype
#b lvm_run_command
#b lvm2_main
#b _lvcreate_params
#b _process_command_line
#b segtype_arg
#b init_dyre_segtypes
#b init_raid_segtypes
#b init_multiple_segtypes
#r --extents 100%FREE --stripes 3 --stripesize 256 --name root vol_vg
#r --type raid4 -i 3 -L 30M -n root vol_vg
r --type dyre1 --minredundancy 1 --maxredundancy 3 -L 30M -n root vol_vg
#r --extents 100%FREE -name root vol_vg
