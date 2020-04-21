	BOOT_LOAD	equ		0x7C00	;ブートプログラムのロード位置
	BOOT_SIZE	equ		(1024 * 8) ;ブートコードサイズ
	SECT_SIZE	equ		(512)	   ;セクタサイズ
	BOOT_SECT	equ		(BOOT_SIZE / SECT_SIZE) ;ブートプログラムのセクタ数

	BOOT_END	equ		(BOOT_LOAD + BOOT_SIZE)
	
	E820_RECORD_SIZE	equ		20


	;; KERNEL
	;; add 15_load_kernel
	KERNEL_LOAD		equ		0x0010_1000
	KERNEL_SIZE		equ		(1024 * 8) ;カーネルサイズ
	KERNEL_SECT		equ		(KERNEL_SIZE / SECT_SIZE)
	
	
