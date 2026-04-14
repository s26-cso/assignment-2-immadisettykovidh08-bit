.section .data
filename: .asciz "input.txt"
yes_msg: .asciz "Yes\n"
no_msg: .asciz "No\n"

.section .bss
c1: .space 1
c2: .space 1

.section .text
.global _start

.option push
.option norelax
la gp, __global_pointer$
.option pop

_start:
    #  FIX: initialize global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    # openat
    li a7, 56
    li a0, -100
    la a1, filename
    li a2, 0
    li a3, 0
    ecall

    mv s0, a0
    bltz s0, exit

    # lseek end
    li a7, 62
    mv a0, s0
    li a1, 0
    li a2, 2
    ecall

    mv s1, a0
    blez s1, is_palindrome

    li s2, 0
    addi s3, s1, -1

loop:
    bge s2, s3, is_palindrome

    # left
    li a7, 62
    mv a0, s0
    mv a1, s2
    li a2, 0
    ecall

    li a7, 63
    mv a0, s0
    la a1, c1
    li a2, 1
    ecall

    # right
    li a7, 62
    mv a0, s0
    mv a1, s3
    li a2, 0
    ecall

    li a7, 63
    mv a0, s0
    la a1, c2
    li a2, 1
    ecall

    # compare
    la t0, c1
    lb t1, 0(t0)

    la t2, c2
    lb t3, 0(t2)

    bne t1, t3, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop

is_palindrome:
    li a7, 64
    li a0, 1
    la a1, yes_msg
    li a2, 4
    ecall
    j exit

not_palindrome:
    li a7, 64
    li a0, 1
    la a1, no_msg
    li a2, 3
    ecall

exit:
    li a7, 93
    li a0, 0
    ecall
