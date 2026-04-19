# ============================================================
#  q2.s  —  Next Greater Element (0-based position)
#
#  For each arr[i], print the index of the first element to
#  its right that is strictly greater. Print -1 if none.
#
#  Algorithm  : right-to-left monotonic stack sweep  O(n) / O(n)
#
#  KEY FIX over original: loop counters and pointers that cross
#  a `call` instruction are kept in s-registers (callee-saved).
#  t-registers are only used within straight-line blocks that
#  contain no calls, so they are never clobbered unexpectedly.
#
#  Register map:
#    s0 = n              number of array elements (argc - 1)
#    s1 = argv           pointer to argv[]
#    s2 = arr            heap array of n int64 values
#    s3 = ans            heap array of n int64 results (init -1)
#    s4 = stk            heap array used as index stack
#    s5 = top            stack top index (-1 = empty)
#    s6 = i              loop variable
# ============================================================

.section .data
fmt_d:  .asciz "%lld"
spc:    .asciz " "
nl:     .asciz "\n"

.section .text
.global main
.extern printf
.extern atoi
.extern malloc
.extern free

main:
    # ── Prologue ─────────────────────────────────────────────
    addi  sp, sp, -64
    sd    ra,  0(sp)
    sd    s0,  8(sp)
    sd    s1, 16(sp)
    sd    s2, 24(sp)
    sd    s3, 32(sp)
    sd    s4, 40(sp)
    sd    s5, 48(sp)
    sd    s6, 56(sp)

    addi  s0, a0, -1        # s0 = n  (argc minus the program name)
    mv    s1, a1            # s1 = argv

    # ── Allocate three arrays of n * 8 bytes ─────────────────
    slli  a0, s0, 3         # a0 = n * 8
    call  malloc
    mv    s2, a0            # s2 = arr[]

    slli  a0, s0, 3
    call  malloc
    mv    s3, a0            # s3 = ans[]

    slli  a0, s0, 3
    call  malloc
    mv    s4, a0            # s4 = stk[]

    # ── Read argv[1..n] → arr[0..n-1] ────────────────────────
    # argv[i+1] is the string for arr[i].
    # atoi is called each iteration; s6=i survives because it
    # is an s-register. t-regs are only used after the call
    # returns (no calls follow until the next iteration's call).
    li    s6, 0
read_loop:
    bge   s6, s0, init_ans

    addi  t0, s6, 1         # t0 = i + 1
    slli  t0, t0, 3         # t0 = (i+1) * 8
    add   t0, s1, t0        # t0 = &argv[i+1]
    ld    a0, 0(t0)         # a0 = argv[i+1]  (char*)
    call  atoi              # a0 = integer value

    slli  t0, s6, 3         # t0 = i * 8  (s6 still valid)
    add   t0, s2, t0        # t0 = &arr[i]
    sd    a0, 0(t0)         # arr[i] = value

    addi  s6, s6, 1
    j     read_loop

    # ── Initialise ans[0..n-1] = -1 ──────────────────────────
    # No calls in this block, so t-regs are fine.
init_ans:
    li    s6, 0
init_loop:
    bge   s6, s0, nge_start
    slli  t0, s6, 3
    add   t0, s3, t0
    li    t1, -1
    sd    t1, 0(t0)
    addi  s6, s6, 1
    j     init_loop

    # ── NGE sweep (right to left, monotonic stack) ────────────
    #
    # Pseudocode:
    #   top = -1
    #   for i = n-1 downto 0:
    #     while top >= 0 AND arr[stk[top]] <= arr[i]:
    #       top--
    #     if top >= 0:
    #       ans[i] = stk[top]
    #     stk[++top] = i
    #
    # No calls in this block — t-regs safe throughout.
nge_start:
    li    s5, -1            # top = -1
    addi  s6, s0, -1        # i   = n - 1

outer:
    blt   s6, x0, print_ans    # i < 0 → all done

    # Load arr[i] into t6 (used only inside this iteration,
    # no calls between here and the end of the iteration).
    slli  t0, s6, 3
    add   t0, s2, t0
    ld    t6, 0(t0)             # t6 = arr[i]

while_top:
    # Exit while-loop if stack empty
    blt   s5, x0, record_ans

    # Load arr[stk[top]]
    slli  t0, s5, 3
    add   t0, s4, t0
    ld    t1, 0(t0)             # t1 = stk[top]  (an index)
    slli  t2, t1, 3
    add   t2, s2, t2
    ld    t3, 0(t2)             # t3 = arr[stk[top]]

    # Pop if arr[stk[top]] <= arr[i]  (we want strictly greater)
    ble   t3, t6, pop_and_retry
    j     record_ans            # arr[stk[top]] > arr[i] → stop

pop_and_retry:
    addi  s5, s5, -1            # top--
    j     while_top

record_ans:
    # If stack not empty, ans[i] = stk[top]
    blt   s5, x0, push_i       # stack empty → ans[i] stays -1

    slli  t0, s5, 3
    add   t0, s4, t0
    ld    t1, 0(t0)             # t1 = stk[top]
    slli  t2, s6, 3
    add   t2, s3, t2
    sd    t1, 0(t2)             # ans[i] = stk[top]

push_i:
    # stk[++top] = i
    addi  s5, s5, 1
    slli  t0, s5, 3
    add   t0, s4, t0
    sd    s6, 0(t0)             # stk[top] = i

    addi  s6, s6, -1            # i--
    j     outer

    # ── Print ans[0..n-1] space-separated ────────────────────
    # Format: "v0 v1 v2 ... vn-1\n"  (space between, not trailing)
print_ans:
    li    s6, 0
print_loop:
    bge   s6, s0, print_nl

    # Print a separating space before every element except the first
    beqz  s6, do_print_val
    la    a0, spc
    call  printf

do_print_val:
    slli  t0, s6, 3
    add   t0, s3, t0
    ld    a1, 0(t0)             # a1 = ans[i]
    la    a0, fmt_d
    call  printf

    addi  s6, s6, 1
    j     print_loop

print_nl:
    la    a0, nl
    call  printf

    # ── Free heap memory ─────────────────────────────────────
    mv    a0, s2
    call  free
    mv    a0, s3
    call  free
    mv    a0, s4
    call  free

    # ── Epilogue ──────────────────────────────────────────────
    ld    ra,  0(sp)
    ld    s0,  8(sp)
    ld    s1, 16(sp)
    ld    s2, 24(sp)
    ld    s3, 32(sp)
    ld    s4, 40(sp)
    ld    s5, 48(sp)
    ld    s6, 56(sp)
    addi  sp, sp, 64
    li    a0, 0
    ret
    