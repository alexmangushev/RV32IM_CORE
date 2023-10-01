asm_log = asm.log
spike_log = spike.log

all: clean
# compile
	riscv32-unknown-elf-gcc -march=rv32im main.c lib.c -O0 -o main.o
#	riscv32-unknown-linux-gnu-gcc -fopenmp main.c lib.c -o main.o
#	riscv32-unknown-elf-gcc -march=rv32im main.s -o main.o
# save disasm
	riscv32-unknown-elf-objdump -D -S main.o > $(asm_log)
#	riscv32-unknown-elf-objdump --disassembler-color=color --visualize-jumps=extended-color -d -S main.o > $(asm_log)
# save program for verilog
	riscv32-unknown-elf-objcopy -O verilog --verilog-data-width 4 --change-addresses -0x10094 main.o mem.v
# call spike
#	spike -l --log=$(spike_log) pk main.o
	./getlogspike.sh

clean:
	rm -rf $(asm_log)
	rm -rf $(spike_log)
	rm -rf main.o