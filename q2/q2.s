.section .data
newline:.asciz "\n"
fmt: .asciz "%lld "

.section .text
.global main
.extern printf
.extern atoi
.extern malloc
.extern free

main:
  addi sp,sp,-64 #add stack 
  sd ra,0(sp)  #store return address
  sd s0,8(sp)  #store all saved registers in stack 
  sd s1,16(sp)
  sd s2,24(sp)
  sd s3,32(sp)
  sd s4,40(sp)
  sd s5,48(sp)
  sd s6,56(sp)
  
  addi s0,a0,-1 #s0=n
  mv s1,a1     #s1=a1=argv
  li t0,8

#allocate arr (s4)

  mul a0,s0,t0    #n*8bytes
  call malloc
  mv s4,a0         #s4=base address of arr

# Allocate ans (s5)

  li t0,8         #n*8bytes
  mul a0,s0,t0  
  call malloc
  mv s5,a0         #s5=base address of ans

# Allocate stack (s6)

  li t0,8         #n*8bytes
  mul a0,s0,t0    
  call malloc
  mv s6,a0         #s6=base address of stack
  li s2,0      #s2 is the pointer == i
scan_loop:
  bge s2,s0,scan_done #if s2>=n done

  slli t1,s2,3  #i*8
  add t2,s1,t1  #argv+(i*8)  gives address of &argv[i]
  ld a0,8(t2)   #load argv[i+1],,since argv[0] is ./a or ./prog
  call atoi    #converts string(a0) to int
  
  slli t4,s2,3 #i*8
  add t5,s4,t4 #arr+(i*8) s4=arr pointer
  sd a0,0(t5)  #store a0 at arr[i]

  addi s2,s2,1 #i++
  j scan_loop  

scan_done:
  li t0,0  #pointer j=0

ans_loop:
  bge t0,s0,ans_done #if(j>=n) done

  slli t2,t0,3  #j*8
  add t3,s5,t2  #ans+(j*8)
  li t4,-1   
  sd t4,0(t3)  #ans[j]=-1

  addi t0,t0,1 #j++
  j ans_loop

ans_done:
  li s3,-1       #stack top pointer top=-1
  addi s2,s0,-1  #i=n-1

loop:
  blt s2,x0,print #if(i<0) print everything

loop2:
  blt s3,x0,loop3 #if(s3<0) go to loop3

  slli t2,s3,3 #top*8
  add t3,s6,t2 #stack+(top*8)
  ld t4,0(t3) #t4 has stack[top] i.e arr index

  slli t2,t4,3 #t4*8  to get arr[stack[top]]
  add t3,s4,t2 #arr+(t4*8) 
  ld t6,0(t3) #t6 now has arr[stack[top]];

  slli t2,s2,3 #i*8
  add t3,s4,t2 #arr+(i*8)
  ld t5,0(t3)  #t5 has arr[i];

  ble t6,t5,pop  #if( arr[stack[top]] <= arr[i] ) pop
  j loop3

pop:
  addi s3,s3,-1  #top--;
  j loop2

loop3:
  blt s3,x0,push  # if(top<0) push

  slli t2,s2,3    # i*8
  add t3,s5,t2   #ans+(i*8)

  slli t5,s3,3  #top*8
  add t6,s6,t5  #stack + top*8
  ld t1,0(t6)  #t1=stack[top]
  sd t1,0(t3)  #(t3)==>ans[i]=t1

push:
  addi s3,s3,1 #top++

  slli t2,s3,3 #top*8
  add t3,s6,t2 #stack + top*8
  sd s2,0(t3)  #stack[top]=s2 (arr index)

  addi s2,s2,-1 #i--
  j loop

print:
  li s2,0   #s2 is a pointer
print_loop:
  bge s2,s0,free_all  #if (s2>=n) exit

  slli t2,s2,3  #s2*8
  add t3,s5,t2  #ans+s2*8
  ld a1,0(t3)   #a1=ans[i]

  la a0,fmt    #a0 = "%lld"
  call printf  #print

  addi s2,s2,1  #s2++
  j print_loop

free_all:
  la a0,newline #a0 = "\n"
  call printf  #prints newline
  mv a0,s4
  call free
  mv a0,s5
  call free
  mv a0,s6
  call free
exit:
  ld ra,0(sp)  #reload return address
  ld s0,8(sp)  #return saved registers from stack
  ld s1,16(sp)
  ld s2,24(sp)
  ld s3,32(sp)
  ld s4,40(sp)
  ld s5,48(sp)
  ld s6,56(sp)
  add sp,sp,64 #remove stack pointer
  li a0,0  # return 0
  ret