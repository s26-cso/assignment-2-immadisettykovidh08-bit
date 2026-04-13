.section .text

.global make_node
make_node: #arguments ==(value =a0)
    addi sp,sp,-16 #add stack
    sd ra,8(sp)  #store return address  
    sd a0,0(sp)  #store val

    li  a0,24   
    call malloc   #allocate memory for 24 bytes

    ld t0,0(sp)   #load val in temp
    sw t0,0(a0)   # store in 0(a0) ,node->val
    sd x0,8(a0)   #node->left=NULL ,x0=0
    sd x0,16(a0)  #node->right=NULL

    ld ra ,8(sp)  #load return address
    addi sp,sp,16 #remove stack pointer
    ret  #return root(a0)

.global insert
insert: #arguments(root=a0,value=a1)
   addi sp,sp,-32 #add stack
   sd ra,16(sp)  #store return address
   sd a1,8(sp)  #store inerst value
   sd a0,0(sp)  #store root

   beq a0,x0,create_node #if(root==NULL) create new node

   lw t0,0(a0) #else load root->val 

   blt a1,t0,left #if(value<root->val) then go left(root->left)
right:
  ld t1,16(a0)  #load roo->right (16(a0))
  mv a0,t1   # root=root->right
  ld a1,8(sp) #load value
  call insert # again call insert with a0=(root->right,value)

  ld t2,0(sp)  #load original root
  sd a0,16(t2) # store a0(returned node) at root->right(original root)
  mv a0,t2  # store original root in a0 to return 
  j done
left:
  ld t1,8(a0) #load root->left
  mv a0,t1   #root=root->ledt
  ld a1,8(sp) #load value
  call insert # again call insert with a0=(root->left,value)

  ld t2,0(sp) #load original root
  sd a0,8(t2) #store a0(returned root after call) at root->left(original root)
  mv a0,t2 #store original root in a0 to return
  j done
create_node:
  ld a0,8(sp) #load value in a0(need value to call male_node)
  call make_node 
done:
   ld ra,16(sp) #load return address from stack again
   addi sp,sp,32 #remove stack
   ret #return root

.global getAtMost 
getAtMost:  #arguments are (value,root) value=a0,root=a1
    mv t0,a0 #move value to t0
    mv a0,a1 #store root in a0
    li t1,-1 #ans=-1 
loop:
    beq a0,x0,exit #if(root==null) exit
    lw t2,0(a0) #load root->val
    ble t2,t0,getright #if(root->val<=value) go right

    ld a0 ,8(a0) #else root=root->left
    j loop #loop again
getright:
    mv t1,t2  #store root->val in t1
    ld a0,16(a0) #root=root->right
    j loop #loop again
exit:
    mv a0,t1 #move t1 to a0(to return val)
    ret

.global get
get: #arguments are(a0=root,a1=value) 
   beq a0,x0,not_found #if(root==null) exit

   lw t1,0(a0)  #load root->val in t1
   beq a1,t1,found #if(root->val==value) found

   blt a1,t1,go_left #if(value<root->val) go left 
   ld a0,16(a0) #else root=root->right
   j get #jump to get 
found:
   ret 
go_left:
   ld a0,8(a0) #root=root->left
   j get  #jump to get
not_found:
   mv a0,x0  #if not found store 0 or null in a0 
   ret