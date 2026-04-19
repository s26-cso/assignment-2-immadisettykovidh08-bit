
.section .data
filename: .asciz "input.txt"
yes_msg:  .asciz "Yes\n"
no_msg:   .asciz "No\n"

# ── Uninitialised data (two 1-byte scratch buffers) ──────────
.section .bss
c1: .space 1          # holds the left  character
c2: .space 1          # holds the right character


.section .text
.global _start

_start:
    # Initialise the global pointer (required for linker relaxation)
    .option push
    .option norelax
    la    gp, __global_pointer$
    .option pop

    # ── open("input.txt", O_RDONLY)
    # openat(AT_FDCWD=-100, filename, O_RDONLY=0, 0)
    li    a7, 56
    li    a0, -100          # AT_FDCWD
    la    a1, filename
    li    a2, 0             # O_RDONLY
    li    a3, 0             # mode (ignored for O_RDONLY)
    ecall
    mv    s0, a0            # s0 = file descriptor
    bltz  s0, exit          # open failed → quit

    # ── Get file size via lseek(fd, 0, SEEK_END) 
    li    a7, 62
    mv    a0, s0
    li    a1, 0             # offset = 0
    li    a2, 2             # SEEK_END
    ecall
    mv    s1, a0            # s1 = file size (bytes)

    # Empty file is a palindrome; also guards against size <= 0
    blez  s1, print_yes

    # ── Initialise two-pointer indices 
    li    s2, 0             # s2 = left  index (starts at 0)
    addi  s3, s1, -1        # s3 = right index (starts at size-1)

# ── Main loop: compare characters at s2 and s3 
loop:
    # When left >= right every pair has been matched → palindrome
    bge   s2, s3, print_yes

    # Read left character: lseek(fd, s2, SEEK_SET) then read 1 byte
    li    a7, 62
    mv    a0, s0
    mv    a1, s2            # seek to left index
    li    a2, 0             # SEEK_SET
    ecall

    li    a7, 63
    mv    a0, s0
    la    a1, c1
    li    a2, 1
    ecall

    # Read right character: lseek(fd, s3, SEEK_SET) then read 1 byte
    li    a7, 62
    mv    a0, s0
    mv    a1, s3            # seek to right index
    li    a2, 0             # SEEK_SET
    ecall

    li    a7, 63
    mv    a0, s0
    la    a1, c2
    li    a2, 1
    ecall

    # Compare the two bytes
    la    t0, c1
    lb    t1, 0(t0)
    la    t2, c2
    lb    t3, 0(t2)
    bne   t1, t3, print_no  # mismatch → not a palindrome

    # Advance pointers toward the centre
    addi  s2, s2, 1
    addi  s3, s3, -1
    j     loop


print_yes:
    li    a7, 64            # write
    li    a0, 1             # stdout
    la    a1, yes_msg
    li    a2, 4             # "Yes\n" = 4 bytes
    ecall
    j     exit

print_no:
    li    a7, 64            # write
    li    a0, 1             # stdout
    la    a1, no_msg
    li    a2, 3             # "No\n"  = 3 bytes
    ecall
    # fall through to exit

exit:
    # close(fd) — clean up before quitting
    li    a7, 57
    mv    a0, s0
    ecall

    li    a7, 93            # exit(0)
    li    a0, 0
    ecall
