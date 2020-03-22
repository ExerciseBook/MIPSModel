INTRO :
    j MAIN

INIT :
    ori $8, $0, 0           # Array
    ori $1, 0x10001008      # Mars will split it into a sequence of instructions.
    sw  $1, 0($8)           # a[0]
    ori $1, 0x10001002      
    sw  $1, 4($8)           # a[1]
    ori $1, 0x80001001      
    sw  $1, 8($8)           # a[2]
    ori $1, 0x10001005      
    sw  $1, 12($8)          # a[3]
    ori $1, 0x80001000      
    sw  $1, 16($8)          # a[4]
    ori $1, 0xffff8000      
    sw  $1, 20($8)          # a[5]
    jr $31              
                        
SORT :

    # $4 i
    # $5 j
    # $8+$4 = $6 @(a[i])
    # $8+$5 = $7 @(a[j])
    # $12 a[i]
    # $13 a[j]

    ori $4, $0, 0           # i := 0
    or  $6, $0, $8          # 
    LOOPI :                 # while i <= 4 ------------------------\
                                            #                      |
                                            #                      |
    add $6, $8, $4          # fetch a[i]                           |
    lw $12, 0($6)                           #                      |
                                            #                      |
                                            #                      |
    addi $5, $4, 4          # j := i + 1                           |
    LOOPJ :                 # while j <= 5 --------------------\   |
                                            #                  |   |
                                            #                  |   |
    add $7, $8, $5          # fetch a[j]                       |   |
    lw $13, 0($7)                           #                  |   |
                                            #                  |   |
                                            #                  |   |
    slt $9, $12, $13        # comparison                       |   |
    beq $9, $0, LOOPJEND    # if a[i] >= a[j] then continue    |   |
                                            #                  |   |
    or $10, $0, $12         #  Swap                            |   |
    or $12, $0, $13         #  the Register                    |   |
    or $13, $0, $10         #  and                             |   |
    sw $12, 0($6)           #  Write to                        |   |
    sw $13, 0($7)           #  Memory                          |   |
                                            #                  |   |
    LOOPJEND :                              #                  |   |
    addi $5, $5, 4          # j := j + 1                       |   |
    slti $2, $5, 21         # <--------------------------------/   |
    bne $2, $0, LOOPJ       # <-/                                  |
                                            #                      |
    addi $4, $4, 4          # i := i + 1                           |
    slti $3, $4, 17         # <------------------------------------/
    bne $3, $0, LOOPI       # <-/

    jr $31

MAIN :
    jal INIT
    jal SORT