.align 0

UCONI   EQU 0x029d
MORPAT  EQU 0x02cb
WSCONI  EQU 0x1d6c  ; original CONIN function

CH_BS   EQU 0x08
CH_ESC  EQU 0x1b
CH_DEL  EQU 0x7f

WS_UP   EQU 'E'-'@'
WS_DN   EQU 'X'-'@'
WS_LT   EQU 'S'-'@'
WS_RT   EQU 'D'-'@'

; patch the routine
    ORG UCONI
    jp MORPAT

; our patch function
    ORG MORPAT
    call WSCONI
    cp CH_ESC
    jr z, 1f
    cp CH_BS
    jr z, 2f
    cp CH_DEL
    ret nz      ; not for us, hand it back
    ld A, CH_BS ; switch DEL with BS
    ret
2:
    ld A, CH_DEL ; switch BS with DEL
    ret

1:
    call WSCONI
    cp '['
    ret nz      ; not a CSI, eat the escape and hand the rest back

    call WSCONI

    ; is this a simple cursor move?
    cp 'A'
    ret c
    cp 'E'
    ret nc

    ld b,0
    ld c,a
    ld hl, to1-'A'
    add hl,bc
    ld a, (hl)
    ret

    ; the simple cursor diamond is ^[[A through ^[[D
to1:
    db  WS_UP, WS_DN, WS_RT, WS_LT
