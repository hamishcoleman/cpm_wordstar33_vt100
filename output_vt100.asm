
IDTEX   EQU 0x18a
CLEAD1  EQU 0x234
CLEAD2  EQU 0x23d
CTRAIL  EQU 0x242
LINOFF  EQU 0x248
COLOFF  EQU 0x249
ASCUR   EQU 0x24a
UCRPOS  EQU 0x24b

    org IDTEX
    db "      VT-100/xterm           "

ORG CLEAD1
    db 2
    db 0x1b, "["

org CLEAD2
    db 1
    db ";"

org CTRAIL
    db 1
    db "H"

org LINOFF
    db 1
org COLOFF
    db 1
org ASCUR
    db 2

org UCRPOS
    nop
    nop
    ret
    db 6
    db 1
EAREOL:
    db 3
    db 0x1b, "[K"
    db 0,0,0
LINDEL:
    db 0,0,0,0,0,0,0
LININS:
    db 0,0,0,0,0,0,0

    db 0,0

IVON:
    db 4
    db 0x1b, "[7m"
    db 0,0
IVOFF:
    db 3
    db 0x1b, "[m"
    db 0,0,0
TRMINI:
    db 0
    db 0,0,0,0,0,0,0,0
TRMUNI:
    db 0
    db 0,0,0,0,0,0,0,0
INISUB:
    nop
    nop
    ret
UNISUB:
    nop
    nop
    ret
USELST: db 0xff
