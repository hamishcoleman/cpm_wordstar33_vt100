
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

uconi.raw: keyxlat.bin
	dd if=$< of=$@ bs=1 skip=$$(($(UCONI))) count=3

keyxlat.raw: keyxlat.bin
	dd if=$< of=$@ bs=1 skip=$$(($(MORPAT)))

configured.raw: output_vt100.bin
	dd if=$< of=$@ bs=1 skip=$$(($(AUPAV))) count=1

output_vt100.raw: output_vt100.bin
	dd if=$< of=$@ bs=1 skip=$$(($(CLEAD1)))

ws.com: uconi.raw keyxlat.raw output_vt100.raw configured.raw wsu.com
	cp wsu.com $@
	dd if=uconi.raw of=$@ conv=notrunc bs=1 seek=$$(($(UCONI)-0x100))
	dd if=keyxlat.raw of=$@ conv=notrunc bs=1 seek=$$(($(MORPAT)-0x100))
	dd if=output_vt100.raw of=$@ conv=notrunc bs=1 seek=$$(($(CLEAD1)-0x100))
	dd if=configured.raw of=$@ conv=notrunc bs=1 seek=$$(($(AUPAV)-0x100))

# TODO:
# - if patch_main.bin size is > 128 error
# - if output_vt100.raw size means it overlaps with uconi.raw, error

clean:
	rm -f $(TARGETS) *.bin *.raw ws.com
