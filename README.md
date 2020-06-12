While playing with a reproduction Altair 8800, the need for a useful editor
was noticed.  The editor from that era is Wordstar, but while there are some
simple patches to make it output the vt100 terminal control characters (and
some more complex ones to add some colors), it still needed the wordstar
key combinations.

The translation from vt100 (or xterm) cursor movement keycodes to wordstar
ones is pretty simple, so could it fit within the available patch space?
