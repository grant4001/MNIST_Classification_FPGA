addRing -nets {VSS VDD} -type core_rings -follow io -layer {top metal5 bottom metal5 left metal4 right metal4} -width {top 1 bottom 1 left 1 right 1} -spacing {top 1 bottom 1 left 1 right 1} -offset {top 0 bottom 0 left 0 right 0} -center 0 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
addStripe -block_ring_top_layer_limit metal5 -max_same_layer_jog_length 1.6 -padcore_ring_bottom_layer_limit metal3 -set_to_set_distance 5 -stacked_via_top_layer metal10 -padcore_ring_top_layer_limit metal5 -spacing 1 -xleft_offset 1 -merge_stripes_value 0.095 -layer metal4 -block_ring_bottom_layer_limit metal3 -width 1 -nets {VSS VDD } -stacked_via_bottom_layer metal1
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { 1 10 } -blockPinTarget { nearestRingStripe nearestTarget } -padPinPortConnect { allPort oneGeom } -checkAlignedSecondaryPin 1 -blockPin useLef -allowJogging 1 -crossoverViaBottomLayer 1 -allowLayerChange 1 -targetViaTopLayer 10 -crossoverViaTopLayer 10 -targetViaBottomLayer 1 -nets { VDD VSS }

saveDesign alu_conv_power.enc

editPowerVia -skip_via_on_pin Standardcell -bottom_layer metal1 -add_vias 1 -top_layer metal8
saveDesign alu_power.enc
setEndCapMode -reset
setEndCapMode -boundary_tap false
setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -modulePlan 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 0 -moduleAwareSpare 0 -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false
placeDesign

timeDesign -preCTS -numPaths 200
optDesign -preCTS -numPaths 200
setDrawView place
saveDesign alu_conv_pl.enc