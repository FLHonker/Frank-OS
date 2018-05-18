;主引导程序 --- 直接操作显存显示多彩“Hello MBR”
;mbr.S 调用BIOS 10H号中断
;显示Frank MBR
;---------------------

;vstart作用是告诉编译器，把我的起始地址编为0x7c00
SECTION MBR vstart=0x7c00 ;程序开始的地址
    mov ax, cs            ;使用cs初始化其他的寄存器
    mov ds, ax            ;因为是通过jmp 0:0x7c00到的MBR开始地址
    mov ss, ax            ;所以此时的cs为0,也就是用0初始化其他寄存器
    mov fs, ax			  ;此类的寄存器不同通过立即数赋值，采用ax中转
    mov sp, 0x7c00  	  ;初始化栈指针
    mov ax, 0xb800			;显存地址，中转入ax
    mov es, ax				;显存地址存入附加堆栈段es

;清屏利用0x10中断的0x6号功能
;清屏(向上滚动窗口)
;AH=06H,AL=上滚行数(0表示全部)
;BH=上卷行属性
;(CL,CH)=窗口左上角坐标，(DL,DH)=窗口右下角
;------------------------
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0			;左上角(0,0)
    mov dx, 0x184f		;右下角(79,24),
                     	;VGA文本模式中一行80个字符，共25行

    int 0x10

;直接从(0,0)写入每个字符和对应色彩
;------------------------------
	mov byte[es: 0x00], 'H'
	mov byte[es: 0x01], 0xEE   ;黄色前景棕色背景+闪烁
	
	mov byte[es: 0x02], 'e'
	mov byte[es: 0x03], 0x33
	
	mov byte[es: 0x04], 'l'
	mov byte[es: 0x05], 0xDD
	
	mov byte[es: 0x06], 'l'
	mov byte[es: 0x07], 0x02
	
	mov byte[es: 0x08], 'o'
	mov byte[es: 0x09], 0xA2
	
	mov byte[es: 0x0A], ' '
	mov byte[es: 0x0B], 0x39
	
	mov byte[es: 0x0C], 'M'
	mov byte[es: 0x0D], 0x88
	
	mov byte[es: 0x0E], 'B'
	mov byte[es: 0x0F], 0x0C
	
	mov byte[es: 0x10], 'R'
	mov byte[es: 0x11], 0x1F

;------------------------------
    jmp $
    times 510-($-$$) db 0	;$表示当前指令的地址，$$表示程序的起始地址(也就是最开始的7c00)，
    ;所以$-$$就等于本条指令之前的所有字节数。
    ;510-($-$$)的效果就是，填充了这些0之后，从程序开始到最后一个0，一共是510个字节。
    db 0x55, 0xaa			;再加2个字节，刚好512B，占满一个扇区
