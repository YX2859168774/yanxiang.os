;setup 已经由MBR，即boot.asm中载入进来了
; 0柱面0磁道2扇區
[ORG  0x500]        ;伪代码 代码执行的起始地址

[SECTION .text]     ;声明代码段，用来存放可执行代码的
[BITS 16]           ;声明代码是16位模式的
global _start       ;声明“_start”是全局的，（以便于后期在C语言的环境中直接调用汇编的程序）
_start:             ;程序的入口位置

    ;段寄存器和SI寄存器的初始化
    ;SS, DS, ES, FS, GS 是段寄存器
    ;SI 是索引寄存器 比如说之前的字符串存入在si寄存器当中
    mov     ax, 0   ;类似与ax flags 用于给段寄存器初始化为0用的
    mov     ss, ax
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     si, ax
    ;第一个程序，打印msg->hello在屏幕上
    mov     si, msg
    call    print

    jmp     $  ;一直循环

    ;yanxiang说明如果这边代码往下看不懂的，去boot.asm有超详细的分析
print:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x01
.loop:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10

    inc si
    jmp .loop
.done:
    ret

msg:
    db "hello", 10, 13, 0

