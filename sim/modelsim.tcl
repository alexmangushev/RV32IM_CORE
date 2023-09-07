# create modelsim working library
vlib work

#set inc [glob ../../include/*]
#set src [glob ../../rtl/*]
#set tb [glob ../../testbench/*]

#set all_files ""
#append $all_files "$inc $src $tb"

# compile all the Verilog sources
#vlog  ../TOP_testbench.sv ../../modules/*.*v
vlog ../../include/*.sv ../../rtl/*.sv ../../testbench/*.sv

# open the testbench module for simulation
vsim work.rv_core_testbench

add wave -hex -group tb /rv_core_testbench/*
add wave -hex -group top /rv_core_testbench/dut/*
add wave -hex -group fetch /rv_core_testbench/dut/i_fetch_stage/*
add wave -hex -group decode /rv_core_testbench/dut/i_decode_stage/*
add wave -hex -group decode /rv_core_testbench/dut/i_decode_stage/i_gpr/rf_reg
add wave -hex -group execute /rv_core_testbench/dut/i_execute_stage/*
add wave -hex -group memory /rv_core_testbench/dut/i_memory_stage/*


#set all_signals [find signals -ports -internal * -recursive]
#set all_nets [find nets * -recursive]
#foreach i $all_nets {
#    puts $i
#}

#add wave -recursive /rv_core_testbench/dut/*
#add wave /rv_core_testbench/dut/*

# add all testbench signals to time diagram
#add wave sim:/TOP_testbench/mii_en
#add wave -hex sim:/TOP_testbench/mii_data_tx
#add wave -hex sim:/TOP_testbench/mii_clk_tx
#add wave sim:/TOP_testbench/mii_dv
#add wave -hex sim:/TOP_testbench/mii_data_rx
#add wave -hex sim:/TOP_testbench/mii_clk_rx
#add wave sim:/TOP_testbench/finish_w
#add wave sim:/TOP_testbench/finish_s
#add wave sim:/TOP_testbench/finish_h
#add wave sim:/TOP_testbench/rst_w
#add wave sim:/TOP_testbench/rst_s
#add wave sim:/TOP_testbench/rst_h
#add wave -radix unsigned sim:/TOP_testbench/top/mem_ptr_w
#add wave -radix unsigned sim:/TOP_testbench/top/mem_ptr_s
#add wave -radix unsigned sim:/TOP_testbench/top/mem_ptr_h
#add wave -hex sim:/TOP_testbench/top/state_q
#add wave -hex sim:/TOP_testbench/clk

# add wave -recursive *
#add wave -hex sim:/TOP_testbench/mem
#add wave -hex sim:/TOP_testbench/mem_wr

#add wave -color orange -hex sim:/TOP_testbench/top/write_to_memory/*

# run the simulation
run -all

# expand the signals time diagram
wave zoom full