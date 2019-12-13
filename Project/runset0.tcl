setDesignMode -process 45
fit
setDrawView fplan
getIoFlowFlag

floorPlan -s 5000 5000 2 2 2 2

uiSetTool select
getIoFlowFlag

globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo

saveDesign alu_conv_fl.enc