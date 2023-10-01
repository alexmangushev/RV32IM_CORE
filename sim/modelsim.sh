# recreate a temp folder for all the simulation files
rm -rf sim
mkdir sim
cd sim

# start the simulation
vsim -do ../modelsim.tcl

cd ..