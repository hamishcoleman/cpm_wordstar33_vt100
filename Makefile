
TARGETS := keyxlat.hex

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
	dd if=$< of=$@ bs=1 skip=$$((0x29d)) count=3

patch_main.bin: keyxlat.bin
	dd if=$< of=$@ bs=1 skip=$$((0x2cb))

ws.com: patch_uconi.bin patch_main.bin wsu.com
	cp wsu.com ws.com
	dd if=patch_uconi.bin of=ws.com conv=notrunc bs=1 seek=$$((0x19d))
	dd if=patch_main.bin of=ws.com conv=notrunc bs=1 seek=$$((0x1cb))
