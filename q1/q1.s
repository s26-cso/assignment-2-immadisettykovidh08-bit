.section .text


# make_node(int val)

.global make_node
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd a0, 0(sp)

    li a0, 24
    call malloc

    ld t0, 0(sp)
    sw t0, 0(a0)      # val
    sd x0, 8(a0)      # left = NULL
    sd x0, 16(a0)     # right = NULL

    ld ra, 8(sp)
    addi sp, sp, 16
    ret



# insert(Node* root, int val)

.global insert
insert:
    addi sp, sp, -24
    sd ra, 16(sp)
    sd a0, 0(sp)     # root
    sd a1, 8(sp)     # val

    beq a0, x0, create_node

    lw t0, 0(a0)

    blt a1, t0, go_left

#go right 
go_right:
    ld t1, 16(a0)
    mv a0, t1
    ld a1, 8(sp)
    call insert

    ld t2, 0(sp)
    sd a0, 16(t2)
    mv a0, t2
    j done_insert

#go left
go_left:
    ld t1, 8(a0)
    mv a0, t1
    ld a1, 8(sp)
    call insert

    ld t2, 0(sp)
    sd a0, 8(t2)
    mv a0, t2
    j done_insert

create_node:
    ld a0, 8(sp)
    call make_node

done_insert:
    ld ra, 16(sp)
    addi sp, sp, 24
    ret



# get(Node* root, int val)

.global get
get:
    beq a0, x0, not_found

    lw t0, 0(a0)
    beq a1, t0, found

    blt a1, t0, go_left_get

    ld a0, 16(a0)
    j get

go_left_get:
    ld a0, 8(a0)
    j get

found:
    ret

not_found:
    mv a0, x0
    ret



# getAtMost(int val, Node* root)

.global getAtMost
getAtMost:
    mv t0, a0      # val
    mv a0, a1      # root
    li t1, -1      # answer

loop:
    beq a0, x0, done

    lw t2, 0(a0)

    ble t2, t0, go_right_atmost

    ld a0, 8(a0)
    j loop

go_right_atmost:
    mv t1, t2
    ld a0, 16(a0)
    j loop

done:
    mv a0, t1
    ret
    