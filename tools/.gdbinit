b main
#b _alloc_init
#b lvcreate
#b lvm_register_segtype
#b lvm_run_command
#b lvm2_main
#b vg_commit
#b wipe_lv
#b unlink
#b readlink
#b _nodes_are_linked
#b _link
#b _file_lock_resource
#b _link_nodes
#b _link_tree_nodes
#b sync_local_dev_names
#b dev_cache_get
#b _lvcreate_params
#b _should_wipe_lv
#b _lv_create_an_lv
#b _process_command_line
#b segtype_arg
#b init_dyre_segtypes
#b init_raid_segtypes
#b init_multiple_segtypes
#r --extents 100%FREE --stripes 3 --stripesize 256 --name root vol_vg
#r --type raid4 -i 3 -L 30M -n root vol_vg
#b target_version
b add_dev_node
b _create_and_load_v4
b _create_node
#b _lvcreate_params
r -vv -i 2 -I 8 -L 30M -n root vol_vg
#r -vv --type dyre1 --minredundancy 1 --maxredundancy 3 --stripes 3 --stripesize 256 -L 30M -n root vol_vg
#r --extents 100%FREE -name root vol_vg
