create_clock -name clk -period 8 -waveform { 0 4 } [get_ports {clk}]

# set clock uncertainty of the system clock (skew and jitter)
# set_clock_uncertainty -setup 0.03 [get_clocks clk]
# set_clock_uncertainty -hold 0.06 [get_clocks clk]

# ------------------------- Input constraints ----------------------------------

set_input_delay -clock clk -max 0.1 [all_inputs]
set_input_delay -clock clk -min -0.1 [all_inputs]

# ------------------------- Output constraints ---------------------------------

set_output_delay -clock clk -max 0.1 [all_outputs]
set_output_delay -clock clk -min -0.1 [all_outputs]

# Assume 50fF load capacitances everywhere:
set_load 0.050 [all_outputs]

# Set 10fF maximum capacitance on all inputs
set_max_capacitance 0.010 [all_inputs]

# set maximum transition at output ports
set_max_transition 0.07 [current_design]

# set_attr use_scan_seqs_for_non_dft false

# set attribute for input drivers
