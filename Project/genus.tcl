######################################################
# Script for Cadence RTL Compiler synthesis
######################################################

# Set the search paths to the libraries and the HDL files
# Remember that "." means your current directory

#set_attribute hdl_search_path {./} ;# Search path for Verilog files
#set_attribute lib_search_path {/export/cadence/UofU_SYNS_v1_2/UTFSM_libraries/MW_UTAH} ;# Search path for library files
#set_attribute library [list UofU_Digital_v1_2.lib] ;# Target Library
#set_attribute information_level 6 ;# See a lot of warnings.
set myFiles [list ../mac.sv ../mac_array.sv ../cnn_sender.sv ../cnn_receiver.sv ../controller.sv];
set basename controller;# name of top level module
#set myClk clk ;# clock name
#set myPeriod_ps  100000 ;# Clock period in ps - 10MHz
#set myInDelay_ps   5000 ;# delay from clock to inputs valid - 5 ns
#set myOutDelay_ps  5000 ;# delay from clock to output valid - 5 ns
set runname _post_synth ;# name appended to output files

#*********************************************************
#* below here shouldn't need to be changed... *
#*********************************************************

# Analyze and Elaborate the HDL files
read_hdl -sv ${myFiles}
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef

#*********************************************************
#* Avoid these flip-flops - two outputs not always using both causing DRCs in ICC 
#*********************************************************
#set_attribute avoid true [find / -libcell DCBX1]
#set_attribute avoid true [find / -libcell DCBNX1]

elaborate ${basename}
current_design controller
# Apply Constraints and generate clocks
#set clock [define_clock -period ${myPeriod_ps} -name ${myClk} [clock_ports]]
#external_delay -input $myInDelay_ps -clock ${myClk} [find / -port ports_in/*]
#external_delay -output $myOutDelay_ps -clock ${myClk} [find / -port ports_out/*]
read_sdc ../cnn.sdc

# Sets transition to default values for Synopsys SDC format,
# fall/rise 400ps
#########################################################################
#dc::set_clock_transition .4 $myClk

# check that the design is OK so far
check_design -unresolved
report timing -lint

puts "Continue to synthesize? (Y/N)"

set data ""
set valid 0 
while {!$valid} {
    gets stdin data
    set valid [expr {($data == Y) || ($data == N)}]
    if {!$valid} {
        puts "Choose either Y or N"
    }
}

if {$data == Y} {
    puts "YES!"
} elseif {$data == N} {
    puts "NO!"
    exit
}

# Synthesize the design to the target library
syn_generic
report timing
syn_map
report timing
syn_opt

# Write out the reports
report timing > ${basename}_${runname}_timing.rep
report gates > ${basename}_${runname}_cell.rep
report power > ${basename}_${runname}_power.rep
report area > ${basename}_${runname}_area.rep
report qor > my_qor.rep

# Write out the structural Verilog and sdc files
write_hdl -mapped > ${basename}.${runname}.sv
write_sdc > ${basename}.${runname}.sdc
