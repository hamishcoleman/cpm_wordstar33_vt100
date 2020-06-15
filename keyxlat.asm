.align 0

UCONI   EQU 0x029d
MORPAT  EQU 0x02cb
WSCONST EQU 0x1d55
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
    or A
    jr z, 1f
    ld B, 0
    ld (hl), B
    ret

1:
    call WSCONI
    cp CH_ESC
    jr z, handle_esc
    cp CH_BS
    ret nz      ; not for us, hand it back
    ld A, CH_DEL ; switch BS with DEL
    ret

    ; TODO: can we reliably confirm that there is not another char available
    ; and return a single ESC if not?
handle_esc:
    call WSCONI
    cp '['
    ret nz
    ; TODO: can we save A in nextch and return Esc?

    call WSCONI

    ; is this a table1 xlat?
    cp 'A'
    jr c, below_A
    cp 'I'
    ret nc

    sub 'A'
    ld ix, table1
    ; fall through

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
    ; FIXME:
    ; - wordstar calls the WSCONST() to check if there is a char waiting,
    ;   which means our ^Q command gets paused for a timeout.  It stll works
    ;   but it is not ideal.

below_A:
    cp '2'
    jr c, below_2
    ; we know it is between '2' and '?', dont do errorchecks for >'6'

    ; it is a number
    push af
    call WSCONI ; swallow the tilde
    pop af
    sub '2'
    ld ix, table2
    jr xlat

below_2:
    ; is it a ctrl+ left or right
    cp '1'
    ret nz
    ; No checks done on the swallowed chars!
    call WSCONI ; swallow the semicolon
    call WSCONI ; swallow the '5'
    call WSCONI
    sub 'A'
    ld ix, table3
    jr xlat

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

WS_NXWD EQU 'F'-'@'
WS_PVWD EQU 'A'-'@'
WS_UPLN EQU 'W'-'@'
WS_DNLN EQU 'Z'-'@'

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

table3:
    ; the first two chars are ctrl+up and ctrl+down, if there is a reasonable
    ; ctrl + Up, Down, Right, Left (codes are like ^[[1;5A)
    ;  A        B        C        D
    db WS_UPLN, WS_DNLN, WS_NXWD, WS_PVWD
