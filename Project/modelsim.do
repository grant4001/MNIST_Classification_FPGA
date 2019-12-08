vlib work
vmap work work
vlog -work work "sram.sv"
vlog -work work "wt_mem0.sv"
vlog -work work "wt_mem1.sv"
vlog -work work "wt_mem2.sv"
vlog -work work "wt_mem3.sv"
vlog -work work "wt_mem4.sv"
vlog -work work "wt_mem5.sv"
vlog -work work "wt_mem6.sv"
vlog -work work "wt_mem7.sv"
vlog -work work "bi_mem0.sv"
vlog -work work "line_buffer_group.sv"
vlog -work work "ff_line_buffer_groups.sv"
vlog -work work "fmap_I.sv"
vlog -work work "fmap_II.sv"
vlog -work work "fmap_III.sv"
vlog -work work "mac.sv"
vlog -work work "mac_array.sv"
vlog -work work "controller.sv"
vlog -work work "top.sv"
vlog -work work "testbench.sv"
vsim +notimingchecks -L work work.testbench

add wave -noupdate -group testbench
add wave -noupdate -group testbench -radix hexadecimal /testbench/*

add wave -noupdate -group testbench/top_u
add wave -noupdate -group testbench/top_u -radix hexadecimal /testbench/top_u/*

add wave -noupdate -group testbench/top_u/controller_u
add wave -noupdate -group testbench/top_u/controller_u -radix hexadecimal /testbench/top_u/controller_u/*

add wave -noupdate -group testbench/top_u/ff_line_buffer_groups_u
add wave -noupdate -group testbench/top_u/ff_line_buffer_groups_u -radix hexadecimal /testbench/top_u/ff_line_buffer_groups_u/*

add wave -noupdate -group testbench/top_u/fmap_I_u
add wave -noupdate -group testbench/top_u/fmap_I_u -radix hexadecimal /testbench/top_u/fmap_I_u/*

add wave -noupdate -group testbench/top_u/fmap_II_u
add wave -noupdate -group testbench/top_u/fmap_II_u -radix hexadecimal /testbench/top_u/fmap_II_u/*

add wave -noupdate -group testbench/top_u/fmap_III_u
add wave -noupdate -group testbench/top_u/fmap_III_u -radix hexadecimal /testbench/top_u/fmap_III_u/*

add wave -noupdate -group testbench/top_u/bi_mem0_u
add wave -noupdate -group testbench/top_u/bi_mem0_u -radix hexadecimal /testbench/top_u/bi_mem0_u/*

add wave -noupdate -group testbench/top_u/wt_mem0_u
add wave -noupdate -group testbench/top_u/wt_mem0_u -radix hexadecimal /testbench/top_u/wt_mem0_u/*

add wave -noupdate -group testbench/top_u/wt_mem1_u
add wave -noupdate -group testbench/top_u/wt_mem1_u -radix hexadecimal /testbench/top_u/wt_mem1_u/*

add wave -noupdate -group testbench/top_u/wt_mem2_u
add wave -noupdate -group testbench/top_u/wt_mem2_u -radix hexadecimal /testbench/top_u/wt_mem2_u/*

add wave -noupdate -group testbench/top_u/wt_mem3_u
add wave -noupdate -group testbench/top_u/wt_mem3_u -radix hexadecimal /testbench/top_u/wt_mem3_u/*

add wave -noupdate -group testbench/top_u/wt_mem4_u
add wave -noupdate -group testbench/top_u/wt_mem4_u -radix hexadecimal /testbench/top_u/wt_mem4_u/*

add wave -noupdate -group testbench/top_u/wt_mem5_u
add wave -noupdate -group testbench/top_u/wt_mem5_u -radix hexadecimal /testbench/top_u/wt_mem5_u/*

add wave -noupdate -group testbench/top_u/wt_mem6_u
add wave -noupdate -group testbench/top_u/wt_mem6_u -radix hexadecimal /testbench/top_u/wt_mem6_u/*

add wave -noupdate -group testbench/top_u/wt_mem7_u
add wave -noupdate -group testbench/top_u/wt_mem7_u -radix hexadecimal /testbench/top_u/wt_mem7_u/*

run 200000
