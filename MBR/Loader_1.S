;Loader_!.S, 暂时什么有用工作也不做，只显示“Loader...”
;-----------------------------------
LOADER_BASE_ADDR 	equ 0x900
LOADER_START_SECTOR equ 0x2

SECTION LOADER vstart=LOADER_BASE_ADDR
	mov byte[es: 0x00], 'L'
	mov byte[es: 0x01], 0xEE   ;黄色前景棕色背景+闪烁
	
	mov byte[es: 0x02], 'o'
	mov byte[es: 0x03], 0xEE
	
	mov byte[es: 0x04], 'a'
	mov byte[es: 0x05], 0xEE
	
	mov byte[es: 0x06], 'd'
	mov byte[es: 0x07], 0xEE
	
	mov byte[es: 0x08], 'e'
	mov byte[es: 0x09], 0xEE
	
	mov byte[es: 0x0A], 'r'
	mov byte[es: 0x0B], 0xEE
	
	mov byte[es: 0x0C], '.'
	mov byte[es: 0x0D], 0xEE
	
	mov byte[es: 0x0E], '.'
	mov byte[es: 0x0F], 0xEE
	
	mov byte[es: 0x10], '.'
	mov byte[es: 0x11], 0xEE

	jmp $
