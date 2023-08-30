#path to project directory
prj_path = $(shell cd ..; pwd)

# set name of top module
top_module = rv_alu_testbench

# output files for icarus and gtkwave
icarus_res_file = sim.out
wave_file = wave.vcd

# get list of include files
inc := $(shell find "$(prj_path)/include")
# get list of source files
src = $(shell find "$(prj_path)/rtl")
# get list of testbench files
tb = $(shell find "$(prj_path)/testbench")

sim: clear
	echo $(src)
	iverilog -g2005-sv -s $(top_module) -o $(icarus_res_file) -i $(inc)  $(src) $(tb)
	vvp $(icarus_res_file) $(wave_file)
	gtkwave -S scrypt.tcl $(wave_file)

clear: 
	rm -rf $(icarus_res_file)
	rm -rf $(wave_file)