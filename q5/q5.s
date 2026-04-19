.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

.section .bss
c1: .space 1
c2: .space 1

.section .text
.global _start

_start:
    # openat(AT_FDCWD, "input.txt", O_RDONLY, 0)
    li    a7, 56
    li    a0, -100
    la    a1, filename
    li    a2, 0
    li    a3, 0
    ecall
    mv    s0, a0
    bltz  s0, exit

    # lseek(fd, 0, SEEK_END) -> file size in s1
    li    a7, 62
    mv    a0, s0
    li    a1, 0
    li    a2, 2
    ecall
    mv    s1, a0

    # empty file is a palindrome
    blez  s1, print_yes

    # left = 0, right = size - 1
    li    s2, 0
    addi  s3, s1, -1

loop:
    bge   s2, s3, print_yes

    # read char at left index
    li    a7, 62
    mv    a0, s0
    mv    a1, s2
    li    a2, 0
    ecall
    li    a7, 63
    mv    a0, s0
    la    a1, c1
    li    a2, 1
    ecall

    # read char at right index
    li    a7, 62
    mv    a0, s0
    mv    a1, s3
    li    a2, 0
    ecall
    li    a7, 63
    mv    a0, s0
    la    a1, c2
    li    a2, 1
    ecall

    # compare
    la    t0, c1
    lb    t1, 0(t0)
    la    t2, c2
    lb    t3, 0(t2)
    bne   t1, t3, print_no

    addi  s2, s2, 1
    addi  s3, s3, -1
    j     loop

print_yes:
    li    a7, 64
    li    a0, 1
    la    a1, yes_msg
    li    a2, 4
    ecall
    j     exit

print_no:
    li    a7, 64
    li    a0, 1
    la    a1, no_msg
    li    a2, 3
    ecall

exit:
    li    a7, 93
    li    a0, 0
    ecall

