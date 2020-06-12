
TARGETS := keyxlat.hex

all: $(TARGETS)

build-deps:
	sudo apt-get install -y binutils-z80

%.o: %.asm
	z80-unknown-coff-as $< -o $@ -g

%.hex: %.o
	z80-unknown-coff-objcopy $< -O ihex $@
