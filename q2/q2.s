.section .data
fmt: .asciz "%lld "
nl:  .asciz "\n"

.section .text
.global main
.extern printf
.extern atoi
.extern malloc
.extern free

main:
    addi sp, sp, -64
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)
    sd s4, 40(sp)
    sd s5, 48(sp)
    sd s6, 56(sp)

    addi s0, a0, -1      # n
    mv s1, a1            # argv

#allocate arrays
    li t0, 8
    mul a0, s0, t0
    call malloc
    mv s2, a0            # arr

    mul a0, s0, t0
    call malloc
    mv s3, a0            # ans

    mul a0, s0, t0
    call malloc
    mv s4, a0            # stack

#read input
    li t1, 0
read:
    bge t1, s0, init_ans

    slli t2, t1, 3
    add t3, s1, t2
    ld a0, 8(t3)
    call atoi

    slli t4, t1, 3
    add t5, s2, t4
    sd a0, 0(t5)

    addi t1, t1, 1
    j read

#initialize ans
init_ans:
    li t1, 0
init_loop:
    bge t1, s0, start_nge

    slli t2, t1, 3
    add t3, s3, t2
    li t4, -1
    sd t4, 0(t3)

    addi t1, t1, 1
    j init_loop

#NGE logic
start_nge:
    li s5, -1            # top = -1
    addi t0, s0, -1      # i = n-1

outer:
    blt t0, x0, print

inner:
    blt s5, x0, assign

    # get stack[top]
    slli t1, s5, 3
    add t2, s4, t1
    ld t3, 0(t2)

    # arr[stack[top]]
    slli t4, t3, 3
    add t5, s2, t4
    ld t6, 0(t5)

    # arr[i]
    slli t1, t0, 3
    add t2, s2, t1
    ld t3, 0(t2)
    ble t6, t3, pop_stack
    j assign

pop_stack:
    addi s5, s5, -1
    j inner

assign:
    blt s5, x0, push_idx

    # ans[i] = stack[top]
    slli t1, t0, 3
    add t2, s3, t1

    slli t3, s5, 3
    add t4, s4, t3
    ld t5, 0(t4)

    sd t5, 0(t2)

push_idx:
    addi s5, s5, 1
    slli t1, s5, 3
    add t2, s4, t1
    sd t0, 0(t2)

    addi t0, t0, -1
    j outer

#print
print:
    li t0, 0

print_loop:
    bge t0, s0, cleanup

    slli t1, t0, 3
    add t2, s3, t1
    ld a1, 0(t2)

    la a0, fmt
    call printf

    addi t0, t0, 1
    j print_loop

#cleanup
cleanup:
    la a0, nl
    call printf

    mv a0, s2
    call free
    mv a0, s3
    call free
    mv a0, s4
    call free

    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    ld s5, 48(sp)
    ld s6, 56(sp)
    addi sp, sp, 64

    li a0, 0
    ret
    