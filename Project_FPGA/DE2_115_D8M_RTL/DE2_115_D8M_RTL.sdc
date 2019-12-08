#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz"  -name CLOCK2_50 [get_ports CLOCK2_50]
create_clock -period "50.0 MHz"  -name CLOCK3_50 [get_ports CLOCK3_50]
create_clock -period "50.0 MHz"  -name CLOCK_50  [get_ports CLOCK_50 ]
create_clock -period "25.0 MHz"  -name MIPI_PIXEL_CLK [get_ports MIPI_PIXEL_CLK]



#**************************************************************
# Set Input Delay
#**************************************************************
# 25.0 MHz
set_input_delay 5.0 -clock "MIPI_PIXEL_CLK" [get_ports {MIPI_PIXEL_D[*]}]
set_input_delay 5.0 -clock "MIPI_PIXEL_CLK" [get_ports MIPI_PIXEL_VS]
set_input_delay 5.0 -clock "MIPI_PIXEL_CLK" [get_ports MIPI_PIXEL_HS]

create_clock -period "15 KHz"  -name VGA_HS [get_ports VGA_HS]
create_clock -period "60 Hz"  -name  VGA_VS [get_ports VGA_VS]

#**************************************************************
# Set Output Delay
#**************************************************************
# 25.0 MHz
#**************************************************************
# Set Output Delay
#**************************************************************
# 25.0 MHz
set_output_delay 5.0 -clock "VGA_CLK" [get_ports {VGA_R[*]}]
set_output_delay 5.0 -clock "VGA_CLK" [get_ports {VGA_G[*]}]
set_output_delay 5.0 -clock "VGA_CLK" [get_ports {VGA_B[*]}]
set_output_delay 5.0 -clock "VGA_CLK" [get_ports VGA_DE]
set_output_delay 5.0 -clock "VGA_CLK" [get_ports VGA_VS]
set_output_delay 5.0 -clock "VGA_CLK" [get_ports VGA_HS]



