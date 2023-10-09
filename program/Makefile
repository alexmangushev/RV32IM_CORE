asm_log = asm.log
spike_log = spike.log

all: clean
# compile
	riscv32-unknown-elf-gcc -march=rv32im main.c -g -O0 -o main
# save disasm
	riscv32-unknown-elf-objdump -D -S main > $(asm_log)
#	riscv32-unknown-elf-objdump --disassembler-color=color --visualize-jumps=extended-color -d -S main
# save program for verilog
	riscv32-unknown-elf-objcopy -O verilog --verilog-data-width 4 --change-addresses -0x10094 main mem.v
# call spike
	./getlogspike.sh

clean:
	rm -rf $(asm_log)
	rm -rf $(spike_log)
	rm -rf main.o