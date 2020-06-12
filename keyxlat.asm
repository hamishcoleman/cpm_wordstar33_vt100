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

    ; is this a table1 xlat?
    cp 'A'
    jr c, 2f
    cp 'I'
    ret nc

    ; table1
    sub 'A'
    ld ix, table1

xlat:
    ld b,0
    ld c,a
    add ix,bc
    cp 5        ; table size
    jr nc, 1f
    ld a, (ix)  ; simple one char xlat
    ret
1:
    ; needs a ^Q prefix
    ld a, (ix)
    ld (hl), a
    ld a, CTRL_Q
    ret

2:
    cp '2'
    jr c, 1f
    cp '7'
    jr nc, 1f

    ; it is a number
    push af
    call WSCONI ; swallow the tilde
    pop af
    sub '2'
    ld ix, table2
    jr xlat

1:
    ret

CTRL_Q  EQU 'Q'-'@'

WS_UP   EQU 'E'-'@'
WS_DN   EQU 'X'-'@'
WS_LT   EQU 'S'-'@'
WS_RT   EQU 'D'-'@'

WS_HOME EQU 's'
WS_END  EQU 'd'

WS_INS  EQU 'V'-'@'
WS_DEL  EQU 'G'-'@'
WS_PGU  EQU 'R'-'@'
WS_PGD  EQU 'C'-'@'

    ; the simple cursor diamond is ^[[A through ^[[D
    ; home and end are ^[[H and ^[[F
table1:
    ;   A      B      C      D
    db  WS_UP, WS_DN, WS_RT, WS_LT
nextch:
    db  0   ; Stash a variable in an unused spot in the xlat table
    db WS_END, 'G', WS_HOME

table2:
    ; ends with a tilde, FFS: ^[[2~
    ;   2       3       4      5       6
    db  WS_INS, WS_DEL, '4',   WS_PGU, WS_PGD
