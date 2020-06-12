.align 0

UCONI   EQU 0x029d
MORPAT  EQU 0x02cb
WSCONI  EQU 0x1d6c  ; original CONIN function

CH_BS   EQU 0x08
CH_ESC  EQU 0x1b
CH_DEL  EQU 0x7f

; patch the routine
    ORG UCONI
    jp patch

; our patch function
    ORG MORPAT
patch:
    ; do we have a saved char?
    ld hl, nextch
    ld A, (hl)
    cp 0
    jr z, 1f
    ld B, 0
    ld (hl), B
    ret

1:
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
    cp 'I'
    ret nc

    ld b,0
    ld c,a
    ld ix, to1-'A'
    add ix,bc
    cp 'E'
    jr c, 1f

CTRL_Q  EQU 'Q'-'@'

    ; needs a ^Q prefix
    ld a, (ix)
    ld (hl), a
    ld a, CTRL_Q
    ret

    ; simple one char xlat
1:
    ld a, (ix)
    ret


WS_UP   EQU 'E'-'@'
WS_DN   EQU 'X'-'@'
WS_LT   EQU 'S'-'@'
WS_RT   EQU 'D'-'@'

WS_HOME EQU 's'
WS_END  EQU 'd'

    ; the simple cursor diamond is ^[[A through ^[[D
    ; home and end are ^[[H and ^[[F
to1:
    ;   A      B      C      D           F            H
    db  WS_UP, WS_DN, WS_RT, WS_LT
nextch:
    db  0   ; Stash a variable in an unused spot in the xlat table
    db WS_END, 'G', WS_HOME
