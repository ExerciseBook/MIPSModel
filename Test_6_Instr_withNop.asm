# Test File for 7 Instruction, include:
# ADDU/SUBU/LW/SW/ORI/BEQ/JAL
################################################################
### Make sure following Settings :
# Settings -> Memory Configuration -> Compact, Data at address 0

.text
L0: ori $29, $0, 12
    ori $2, $0, 0x1234
    ori $3, $0, 0x3456
    addu $4, $2, $3
    subu $6, $3, $4
    sw $2, 0($0)
    sw $3, 4($0)
    sw $4, 4($29)
    lw $5, 0($0)
    # nop
    # nop
    beq $2, $5, L2
    nop
L1: lw $3, 4($29)
L2: lw $5, 4($0)
    # nop
    # nop
    beq $3, $5, L1
    nop
    subu $6, $6, $2
    sw $6, -4($29)
    beq $3, $3, L0
    nop

