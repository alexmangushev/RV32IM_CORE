#path to project directory
prj_path = $(shell cd ..; pwd)

# set name of top module
top_module = rv_core_testbench

# output files for icarus and gtkwave
icarus_res_file = sim.out
wave_file = wave.vcd

# get list of include files
export inc = $(shell find "$(prj_path)/include")
# get list of source files
export src = $(shell find "$(prj_path)/rtl")
# get list of testbench files
export tb = $(shell find "$(prj_path)/testbench")

icarus: clean
# call make from another dir for compile program
	make -C $(prj_path)/program
	iverilog -g2005-sv -s $(top_module) -o $(icarus_res_file) -i $(inc)  $(src) $(tb)
	vvp $(icarus_res_file) $(wave_file)
	gtkwave -S gtkwave.tcl $(wave_file)

modelsim: clean
	make -C $(prj_path)/program
	cmd.exe /c modelsim.bat
	python3 compare.py

clean: 
	rm -rf $(icarus_res_file)
	rm -rf $(wave_file)