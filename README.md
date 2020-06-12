While playing with a reproduction Altair 8800, the need for a useful editor
was noticed.  The editor from that era is Wordstar, but while there are some
simple patches to make it output the vt100 terminal control characters (and
some more complex ones to add some colors), it still needed the wordstar
key combinations.

The translation from vt100 (or xterm) cursor movement keycodes to wordstar
ones is pretty simple, so could it fit within the available patch space?

# Useful references

- [z80 instruction set](ttp://z80-heaven.wikidot.com/instructions-set)
- [CPM zero page](https://en.wikipedia.org/wiki/Zero_page_(CP/M))
- [CPM BIOS calls](https://www.seasip.info/Cpm/bios.html)
