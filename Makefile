
AUPAV  := 0x228
CLEAD1 := 0x234
UCONI  := 0x29d
MORPAT := 0x2cb

TARGETS := keyxlat.hex output_vt100.hex

all: $(TARGETS)

build-deps:
	sudo apt-get install -y binutils-z80

%.o: %.asm
	z80-unknown-coff-as $< -o $@ -g

%.hex: %.o
	z80-unknown-coff-objcopy $< -O ihex $@

%.bin: %.o
	z80-unknown-coff-objcopy $< -O binary $@

patch_uconi.bin: keyxlat.bin
	dd if=$< of=$@ bs=1 skip=$$(($(UCONI))) count=3

patch_main.bin: keyxlat.bin
	dd if=$< of=$@ bs=1 skip=$$(($(MORPAT)))

patch_configured.bin: output_vt100.bin
	dd if=$< of=$@ bs=1 skip=$$(($(AUPAV))) count=1

patch_output.bin: output_vt100.bin
	dd if=$< of=$@ bs=1 skip=$$(($(CLEAD1)))

ws.com: patch_uconi.bin patch_main.bin patch_output.bin patch_configured.bin wsu.com
	cp wsu.com ws.com
	dd if=patch_uconi.bin of=ws.com conv=notrunc bs=1 seek=$$(($(UCONI)-0x100))
	dd if=patch_main.bin of=ws.com conv=notrunc bs=1 seek=$$(($(MORPAT)-0x100))
	dd if=patch_output.bin of=ws.com conv=notrunc bs=1 seek=$$(($(CLEAD1)-0x100))
	dd if=patch_configured.bin of=ws.com conv=notrunc bs=1 seek=$$(($(AUPAV)-0x100))

# TODO:
# - if patch_main.bin size is > 128 error

clean:
	rm -f $(TARGETS) patch_uconi.bin patch_main.bin
