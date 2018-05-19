;主引导程序 --- 改造MBR，引导读取硬盘
;mbr3_Loader.S

;---------------------
LOADER_BASE_ADDR	 equ 0x900
LOADER_START_SECTION equ 0x2

;vstart作用是告诉编译器，把我的起始地址编为0x7c00
SECTION MBR vstart=0x7c00 ;程序开始的地址
    mov ax, cs            ;使用cs初始化其他的寄存器
    mov ds, ax            ;因为是通过jmp 0:0x7c00到的MBR开始地址
    mov ss, ax            ;所以此时的cs为0,也就是用0初始化其他寄存器
    mov fs, ax			  ;此类的寄存器不同通过立即数赋值，采用ax中转
    mov sp, 0x7c00  	  ;初始化栈指针
    mov ax, 0xb800			;显存地址，中转入ax
    mov es, ax				;显存地址存入附加堆栈段es

;---------------------------
; 显示“Frank MBR”
;清屏利用0x10中断的0x6号功能
;清屏(向上滚动窗口)
;AH=06H,AL=上滚行数(0表示全部)
;BH=上卷行属性
;(CL,CH)=窗口左上角坐标，(DL,DH)=窗口右下角
;---------------------------
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0			;左上角(0,0)
    mov dx, 0x184f		;右下角(79,24),
                     	;VGA文本模式中一行80个字符，共25行

    int 0x10

;直接从(0,0)写入每个字符和对应色彩
;------------------------------
	mov byte[es: 0x00], 'F'
	mov byte[es: 0x01], 0xEE   ;黄色前景棕色背景+闪烁
	
	mov byte[es: 0x02], 'r'
	mov byte[es: 0x03], 0xEE
	
	mov byte[es: 0x04], 'a'
	mov byte[es: 0x05], 0xEE
	
	mov byte[es: 0x06], 'n'
	mov byte[es: 0x07], 0xEE
	
	mov byte[es: 0x08], 'k'
	mov byte[es: 0x09], 0xEE
	
	mov byte[es: 0x0A], '-'
	mov byte[es: 0x0B], 0xEE
	
	mov byte[es: 0x0C], 'M'
	mov byte[es: 0x0D], 0xEE
	
	mov byte[es: 0x0E], 'B'
	mov byte[es: 0x0F], 0xEE
	
	mov byte[es: 0x10], 'R'
	mov byte[es: 0x11], 0xEE

;设置参数，调用函数读取硬盘
;------------------------------
	mov eax, LOADER_START_SECTION	;起始扇区LBA地址
	mov bx, LOADER_BASE_ADDR		;写入的地址
	mov cx, 1						;待读入的扇区数
	call rd_disk_m_16				;调用读取硬盘

	jmp LOADER_BASE_ADDR			;跳转到Loader区

;------------------------
;读取硬盘n个扇区
;------------------------
rd_disk_m_16:
;step1:设置读取扇区数
	mov esi, eax					;eax=LBA起始扇区号,备份eax
									;bx=数据写入的内存地址
	mov di, cx						;cx=读入的扇区数,1；备份cx
	mov dx, 0x1F2					;使用0x1F2端口,Sector count
	mov al, cl						;访问8位端口时使用寄存器AL
	out dx, al						;将AL中的数据写入端口号为0x1F2的寄存器中
									;out的操作数可以位8位立即数或寄存器DX，源操作数必须为AL或AX
	mov eax, esi

;step2:将LBA地址写入0x1F3-0x1F6(在这里我们地址为2)
	;0x1F3放0-7位
	mov dx, 0x1F3
	out dx, al

	;0xF4放8-15位
	mov cl, 8
	shr eax, cl			;右移8位,AL置0
	mov dx, 0x1F4
	out dx, al

	;0xF5放16-23位
	shr eax, cl
	mov dx, 0x1F5
	out dx, al

	shr eax, cl
	and al, 0x0F
	or	al, 0xE0		;设置7-4位为1110,LBA模式,主盘
	mov dx, 0x1F6
	out dx, al

;step3:往Command寄存器写入读命令
	mov dx, 0x1F7
	mov al, 0x20
	out dx, al

;step4:检查硬盘状态
  .not_ready:
	nop
	in  al, dx
	and al, 0x88
	cmp al, 0x08
	jnz .not_ready

;step5:从0xF0端口读出数据
	mov ax, di			;DI为要读取的扇区数,data寄存器为16位,即每次读取2个字节,要读(DI*512/2)次
	mov dx, 256
	mul dx				;MUL指令的被乘数隐含在AX中,乘积的低16位在AX中,高16位在DX中
	mov cx, ax			;把AX的的值赋给CX,用作计数器
	
	mov dx, 0x1F0
  .go_on_read:
	in  ax, dx			;把0x1F0端口读出的数据放在AX寄存器中
	mov [bx], ax		;再把AX寄存器中的数据放在偏移地址为BX指向的内存空间
	add bx, 2			;一次读2个字节
	loop .go_on_read
	ret					;记得调用函数后要返回

;------------------------------
    times 510-($-$$) db 0
    db 0x55, 0xaa
