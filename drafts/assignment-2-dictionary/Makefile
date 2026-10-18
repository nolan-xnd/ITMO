NASM := nasm
LD := ld
PYTHON := python3
NASMFLAGS := -f elf64 -g -F dwarf

.DEFAULT_GOAL := all
.PHONY: all test clean
all: main

main: main.o dict.o lib.o
	$(LD) -o $@ $^

main.o: main.asm words.inc colon.inc dict.inc lib.inc
	$(NASM) $(NASMFLAGS) -o $@ $<

dict.o: dict.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

lib.o: lib.asm
	$(NASM) $(NASMFLAGS) -o $@ $<

test: main
	$(PYTHON) test.py -v

clean:
	rm -f main *.o
