.align 0

UCNSTA  EQU 0x029a
UCONI   EQU 0x029d
MORPAT  EQU 0x02cb
WSCONST EQU 0x1d55
WSCONI  EQU 0x1d6c  ; original CONIN function

CH_BS   EQU 0x08
CH_ESC  EQU 0x1b
CH_DEL  EQU 0x7f

; FIXME:
; - hook UCNSTA with a check for our nextchar

; jump to our patches
;     ORG UCNSTA
;     jp patch_CONST

    ORG UCONI
    jp patch_CONI

; our patch function
    ORG MORPAT
; patch_CONST:
;     ; do we have a saved char?
;     ld hl, nextch
;     ld A, (hl)
;     or A
;     jp z, WSCONST
;     ld A, 255
;     ret

patch_CONI:
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
    ; TODO: saving A in nexch and returning ESC costs 5 bytes

    call WSCONI

    ; Which table to use?
    cp '2'
    jr c, below_2
    cp 'A'
    jr c, below_A
    cp 'E'
    jr c, below_E

    ; above E
    ; needs a ^Q prefix
    sub 'F'
    ld ix, table4
    call xlat
    ld (hl), a
    ld a, CTRL_Q
    ret

below_E:
    sub 'A'
    ld ix, table1
    ; fall through

xlat:
    ; a is offset
    ; ix is address of xlat table
    ld b,0
    ld c,a
    add ix,bc
    ld a, (ix)  ; simple one char xlat
    ret

below_A:
    ; TODO: F9 - F12 end up here too
    push af
    call WSCONI ; swallow the tilde
    pop af
    sub '2'
    ld ix, table2
    jr xlat

below_2:
    ; TODO: F5 - F8 end up here too
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

table2:
    ; ends with a tilde, FFS: ^[[2~
    ;   2       3       4      5       6
    db  WS_INS, WS_DEL, '4',   WS_PGU, WS_PGD

table3:
    ; ctrl + Up, Down, Right, Left (codes are like ^[[1;5A)
    ;  A        B        C        D
    db WS_UPLN, WS_DNLN, WS_NXWD, WS_PVWD

table4:
    db WS_END   ; F
nextch:
    db  0   ; Stash a variable in an unused spot in the xlat table
    db WS_HOME  ; H
