#生成随机数的功能在64HZ的CPU下运行，以保证1s刷新一次
.text  
main:
   li   sp, 0x10000            # Initialize stack pointer
   csrrwi zero, 0x300, 0x8     # enable externel interrupt
   lui  s1, 0xFFFFF
   li   a0, 0x12345678
   ecall                       # Test ecall   
TEST:
   addi s10,x0,0               #s10是是否正在生成随机数的标志位，1表示正在生成，0则反之
MAINLOOP:
   lw   s0, 0x70(s1)           #从拨码开关读数据
   andi s2,s0,0XFF             #获得操作数AB和操作码并将它们整数部分和小数部分分隔开来
   srai s0,s0,8
   andi s1,s0,0XFF
   srai s0,s0,13
   andi s3,s0,7
   andi t2,s1,15
   andi t4,s2,15
   srai t1,s1,4
   andi t1,t1,15
   srai t3,s2,4
   andi t3,t3,15
   addi a1,x0,0                #根据操作码执行相应的操作
   beq s3,a1,ZERO
   addi a1,a1,1
   beq s3,a1,ADD
   addi a1,a1,1
   beq s3,a1,SUB
   addi a1,a1,1
   beq s3,a1,MUL
   addi a1,a1,1
   beq s3,a1,DIV
   addi a1,a1,1
   beq s3,a1,RAM
  
END:
   lui  s1, 0xFFFFF
   sw   a0, 0x00(s1)           #将结果写入数码管
   jal  x0,TEST
    
ENDL:
   addi a6,x0,10               #把结果转化为10进制表示，转化思路：低位减十，高位加一，直至所有位小于10
   addi a2,t6,0
   addi a3,x0,0
   addi a4,x0,0
   addi a5,x0,0
ENDLOOP1:
   blt a2,a6,ENDLOOP2
   sub a2,a2,a6
   addi a3,a3,1
   jal x0,ENDLOOP1
ENDLOOP2:
   blt a3,a6,ENDLOOP3
   sub a3,a3,a6
   addi a4,a4,1
   jal x0,ENDLOOP2
ENDLOOP3:
   blt a4,a6,ENDCHU
   sub a4,a4,a6
   addi a5,a5,1
   jal x0,ENDLOOP3
ENDCHU:
   slli a3,a3,4
   slli a4,a4,8
   slli a5,a5,12
   add t6,a2,a3
   add t6,t6,a4
   add t6,t6,a5
   slli t6,t6,16
   add a0,t6,t5              #结果储存在a0里
   jal x0,END
   
   
#零操作  
ZERO:
    addi a0,x0,0
    jal x0,END

    
#加法操作，考虑进位        
ADD:
    add t5,t2,t4
    addi a6,x0,10
    addi t6,x0,0
    bge t5,a6,JINWEI
ADDS:
    add t6,t6,t1
    add t6,t6,t3
    jal x0,ENDL   
JINWEI:
   addi t6,t6,1
   addi a6,x0,10
   sub t5,t5,a6
   jal x0,ADDS
 
   
#减法操作，分类讨论大小以保证绝对值      
SUB:
   blt s1,s2,BZ
   blt t2,t4,AZBX
   jal x0,AGC
BZ:
   blt t4,t2,BZAX
   jal x0,BGC  
AZBX:
   addi t2,t2,10
   addi a6,x0,1
   sub t1,t1,a6
   jal x0,AGC   
BZAX:
   addi t4,t4,10
   addi a6,x0,1
   sub t3,t3,a6
   jal x0,BGC    
AGC:
   sub t5,t2,t4
   sub t6,t1,t3
   jal x0,ENDL   
BGC:
   sub t5,t4,t2
   sub t6,t3,t1
   jal x0,ENDL
   

#乘法操作，整数小数均移位后合并        
MUL:
   sll a6,t1,s2
   sll a7,t2,s2
   addi a5,x0,10   
MLOOP:
   blt a7,a5,MULEND
   sub a7,a7,a5
   addi a6,a6,1
   jal x0,MLOOP
MULEND:
   addi t5,a7,0
   addi t6,a6,0
   jal x0,ENDL
   
   
#除法操作：整数部分移位余数*1010加小数部分后移位得到小数部分
DIV:
   addi a6,x0,4
   bge s2,a6,FM
   sub a6,a6,s2
   sll a7,t1,a6
   andi a5,a7,15
   srl a5,a5,a6
   slli a4,a5,3
   slli a3,a5,1
   add a5,a3,a4
   add a5,a5,t2
   sra t6,t1,s2
   sra t5,a5,s2
   jal x0,ENDL
FM:
   addi t6,x0,0
   slli a4,t1,3
   slli a3,t1,1
   add a5,a3,a4
   add a5,a5,t2
   sra t5,a5,s2
   jal x0,ENDL
   

#随机数生成：种子+移位
RAM:
    bne s10,x0,RAMLOOP
    slli a7,s1,24
    addi a6,x0,0
    add a6,a6,a7
    slli a7,s1,8
    add a6,a6,a7
    slli a7,s2,16
    add a6,a6,a7
    add a6,a6,s2
RAMLOOP:
    srli a2,a6,31
    andi a2,a2,1
    srli a3,a6,21
    andi a3,a3,1
    srli a4,a6,1
    andi a4,a4,1
    andi a5,a6,1
    xor a2,a2,a3
    xor a2,a2,a4
    xor a2,a2,a5
    addi a5,x0,0XFFFFFFFF
    slli a6,a6,1
    add a6,a6,a2
    and a6,a6,a5
    addi a0,a6,0
    lui  s1, 0xFFFFF
    sw   a0, 0x00(s1)           #这里写数码管
    bne a0,x0,RAMEND            #这一步避免先设置操作码后设置操作数导致问题
    jal x0,MAINLOOP  
RAMEND:
    addi s10,x0,1
    jal x0,MAINLOOP
    

    
   
    
    
   
