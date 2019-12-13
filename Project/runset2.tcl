setCTSMode -engine ck
set_ccopt_property update_io_latency false
clockDesign -specFile Clock.ctstch -outDir clock_report -unfixedInstBeforeCTS

checkPlace alu.checkPlace
timeDesign -postCTS -numPaths 200
timeDesign -postCTS -hold -numPaths 200
optDesign -postCTS -numPaths 200
optDesign -postCTS -hold -numPaths 200
timeDesign -postCTS -hold -numPaths 200
timeDesign -postCTS -numPaths 200
saveDesign alu_clk.enc

getFillerMode -quiet
addFillerGap 0.6
addFiller -cell FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 -prefix FILLER -markFixed
saveDesign alu_powerroute_clk_filler.enc

setAnalysisMode -cppr none -clockGatingCheck true -timeBorrowing true -useOutputPinCap true -sequentialConstProp false -timingSelfLoopsNoSkew false -enableMultipleDriveNet true -clkSrcPath true -warn true -usefulSkew false -analysisType onChipVariation -log true

setNanoRouteMode -quiet -drouteFixAntenna false
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
setNanoRouteMode -quiet -routeTopRoutingLayer 6
routeDesign -globalDetail
saveDesign alu_conv _powerroute_clk_filler.enc