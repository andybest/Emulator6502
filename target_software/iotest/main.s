; vim: set syntax=asm_ca65:
    processor 6502

DUART_BASE:     equ $0200
DUART_TX_A:     equ DUART_BASE + 3

    org $300
        
init:  
    LDX     #$FF                 ; Initialize stack pointer to $01FF
    TXS
    CLD                          ; Clear decimal mode

    jsr printString
    jmp done

printString:
    ldx #0
psLoop:
    lda helloText,x
    inx
    cmp #0
    beq printDone
    sta DUART_TX_A
    jmp psLoop
printDone:
    rts

done:
    JMP done
        
helloText:
    .byte "Hello, world", $0
