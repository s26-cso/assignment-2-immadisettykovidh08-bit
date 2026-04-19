.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

.section .bss
c1: .space 1
c2: .space 1

.section .text
.global main

main:
    # save ra and s0-s4 (5 regs + ra = 6 * 8 = 48 bytes, round to 48)
    addi  sp, sp, -48
    sd    ra,  0(sp)
    sd    s0,  8(sp)
    sd    s1, 16(sp)
    sd    s2, 24(sp)
    sd    s3, 32(sp)
    sd    s4, 40(sp)

    # openat(AT_FDCWD, "input.txt", O_RDONLY, 0)
    li    a7, 56
    li    a0, -100
    la    a1, filename
    li    a2, 0
    li    a3, 0
    ecall
    mv    s0, a0            # s0 = fd
    bltz  s0, print_no      # open failed

    # lseek(fd, 0, SEEK_END) -> file size in s1
    li    a7, 62
    mv    a0, s0
    li    a1, 0
    li    a2, 2
    ecall
    mv    s1, a0            # s1 = size

    blez  s1, print_yes     # empty file is a palindrome

    li    s2, 0             # s2 = left index
    addi  s3, s1, -1        # s3 = right index

loop:
    bge   s2, s3, print_yes

    # seek to left, read one byte into c1
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

    # seek to right, read one byte into c2
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

    # compare c1 and c2
    la    t0, c1
    lb    t1, 0(t0)
    la    t2, c2
    lb    t3, 0(t2)
    bne   t1, t3, print_no

    addi  s2, s2, 1
    addi  s3, s3, -1
    j     loop

print_yes:
    la    a0, yes_msg
    call  printf
    j     done

print_no:
    la    a0, no_msg
    call  printf

done:
    ld    ra,  0(sp)
    ld    s0,  8(sp)
    ld    s1, 16(sp)
    ld    s2, 24(sp)
    ld    s3, 32(sp)
    ld    s4, 40(sp)
    addi  sp, sp, 48
    li    a0, 0
    ret
