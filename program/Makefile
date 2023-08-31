all: clean
# compile
	riscv32-unknown-elf-gcc -march=rv32i main.c lib.c -O0 -o main.o
# save disasm
	riscv32-unknown-elf-objdump -d -S main.o >> asm.log
# save program for verilog
	riscv32-unknown-elf-objcopy -O verilog main.o mem.v
# call spike
	spike -l --log=spike.log pk main.o

clean:
	rm -rf asm.log
	rm -rf spike.log
	rm -rf main.o