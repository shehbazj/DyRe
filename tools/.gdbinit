#b main
#b  _lvconvert_raid
b _lvconvert_raid 
#b _alloc_image_components
#r -x raid2p vol_vg14/raid4vol
#r --type raid4 -m 1 vol_vg56/linearvol
#r -m +1 vol_vg56/linearvol
