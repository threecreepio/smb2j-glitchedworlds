AS = ca65
CC = cc65
LD = ld65
IPS = flips.exe

.PHONY: clean

%.o: %.asm
	$(AS) -g --debug-info $< -o $@

%.o.bin: %.asm
	$(AS) -g --debug-info $< -o $@.o
	$(LD) $@.o -C layoutbin -o $@

smb2j-glitchedworlds.zip: patch.ips patch-fdsheader.ips
	zip $@ patch.ips patch-fdsheader.ips README.md

patch.ips: main.fds
	$(IPS) --create --ips "original.fds" "main.fds" $@

patch-fdsheader.ips: main.fds
	cat fds-header.bin main.fds > main-header.fds
	$(IPS) --create --ips "original.fds" "main-header.fds" $@

main.fds: layout sm2data2.o.bin sm2data3.o.bin sm2data4.o.bin fdswrap.o
	$(LD) --dbgfile $@.dbg -C layout fdswrap.o -o $@

clean:
	rm -f smb2j-glitchedworlds.zip main*.fds patch.ips patch-fdsheader *.o *.o.bin
