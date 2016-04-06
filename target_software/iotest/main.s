    processor 6502
        
    org $300


        
init:  
    LDX     #$FF                 ; Initialize stack pointer to $01FF
    TXS
    CLD                          ; Clear decimal mode

done:
    JMP done
        
helloText:
    .byte "Hello, world\0"