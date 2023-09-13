# create modelsim working library
vlib work

set inc ../../include/*.sv
set src ../../rtl/*.sv
set tb  ../../testbench/*.sv

# compile all the Verilog sources
vlog $inc $src $tb

# open the testbench module for simulation
vsim work.rv_core_testbench

add wave -color orange -hex -group tb /rv_core_testbench/*
add wave -hex -group top /rv_core_testbench/dut/*
add wave -hex -group fetch /rv_core_testbench/dut/i_fetch_stage/*
add wave -hex -group fetch /rv_core_testbench/dut/i_fetch_stage/i_fetch_unit/*
add wave -hex -group decode /rv_core_testbench/dut/i_decode_stage/*
add wave -hex -group decode /rv_core_testbench/dut/i_decode_stage/i_gpr/rf_reg
add wave -hex -group execute /rv_core_testbench/dut/i_execute_stage/*
add wave -hex -group memory /rv_core_testbench/dut/i_memory_stage/*
add wave -hex -group control_unit /rv_core_testbench/dut/i_control_unit/*


#set all_signals [find signals -ports -internal * -recursive]
#set all_nets [find nets * -recursive]
#foreach i $all_nets {
#    puts $i
#}

#add wave -recursive /rv_core_testbench/dut/*
#add wave /rv_core_testbench/dut/*
# add wave -recursive *

# run the simulation
run -all

# expand the signals time diagram
wave zoom full