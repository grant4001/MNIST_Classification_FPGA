timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 400 -prefix alu_conv_postRoute -outDir timingReports
clearClockDomains
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 400 -prefix alu_conv_postRoute -outDir timingReports
saveDesign controller_final_layout.enc

saveNetlist -phys -includePowerGround controller_phy.v -excludeLeafCell
saveNetlist controller_nophy.v -excludeLeafCell
write_sdf alu_conv.sdf

verify_drc -report cnn.drc.rpt -limit 1000
verifyConnectivity -type all -error 1000 -warning 50
verifyProcessAntenna -reportfile cnn.antenna.rpt -error 1000