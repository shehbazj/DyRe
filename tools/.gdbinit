#b main
#b  _lvconvert_raid
#b _lvconvert_raid 
#b _alloc_rmeta_for_lv
#b _alloc_image_component
#b _alloc_init

b _init_alloc_parms
# FOR RAID4 TO RAID2P 

#r -x raid2p vol_vg14/raid4vol

# FOR LINEAR TO MIRROR

#r -m +1 vol_vg56/linearvol
