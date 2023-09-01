#path to project directory
prj_path = $(shell cd ..; pwd)

# set name of top module
top_module = rv_top_testbench

# output files for icarus and gtkwave
icarus_res_file = sim.out
wave_file = wave.vcd

# get list of include files
inc := $(shell find "$(prj_path)/include")
# get list of source files
src = $(shell find "$(prj_path)/rtl")
# get list of testbench files
tb = $(shell find "$(prj_path)/testbench")

sim: clean
# call make from another dir for compile program
	make -C $(prj_path)/program
	iverilog -g2005-sv -s $(top_module) -o $(icarus_res_file) -i $(inc)  $(src) $(tb)
	vvp $(icarus_res_file) $(wave_file)
	gtkwave -S scrypt.tcl $(wave_file)

clean: 
	rm -rf $(icarus_res_file)
	rm -rf $(wave_file)