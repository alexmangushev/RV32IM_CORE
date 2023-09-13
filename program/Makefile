asm_log = asm.log
spike_log = spike.log

all: clean
# compile
	riscv32-unknown-elf-gcc -march=rv32i main.c lib.c -O0 -o main.o
# save disasm
	riscv32-unknown-elf-objdump -d -S main.o >> $(asm_log)
# save program for verilog
	riscv32-unknown-elf-objcopy -O verilog --verilog-data-width 4 main.o mem.v
# call spike
#	spike -l --log=$(spike_log) pk main.o
	./getlogspike.sh

clean:
	rm -rf $(asm_log)
	rm -rf $(spike_log)
	rm -rf main.o