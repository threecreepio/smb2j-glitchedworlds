AS = ca65
CC = cc65
LD = ld65

.PHONY: clean

%.o: %.asm
	$(AS) -g --debug-info $< -o $@

%.o.bin: %.asm
	$(AS) -g --debug-info $< -o $@.o
	$(LD) $@.o -C layoutbin -o $@

main.fds: layout sm2main.o.bin sm2data2.o.bin sm2data3.o.bin sm2data4.o.bin fdswrap.o
	$(LD) --dbgfile $@.dbg -C layout fdswrap.o -o $@

clean:
	rm -f main*.nes *.o *.o.bin
