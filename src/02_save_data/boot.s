	BOOT_LOAD	equ	0x7C00


entry:
	jmp	ipl


	;; BPB(Bios Parameter Block)

	times 90 - ($ - $$) db 0x90

	;; IPL(Initial Program Loader)

ipl:
	cli							;割り込み禁止

	mov	ax, 0x000				;AX = 0x0000
	mov ds, ax					;DS = 0x0000
	mov es, ax					;ES = 0x0000
	mov ss, ax					;SS = 0x0000
	mov sp, BOOT_LOAD			;SP = 0x7C00

	sti							;割り込み許可

	mov [BOOT.DRIVE], dl		;ブートドライブを保存

	mov	al, 'A'
	mov	ah, 0x0E				;テレタイプ式１文字出力
	mov	bx, 0x0000				;ページ番号と文字色を0に設定
	int	0x10					;ビデオBIOSコール

	jmp	$

ALIGN 2, db 0 
BOOT:							;ブートドライブに関する情報
.DRIVE:		dw	0				;ドライブ番号
	
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	
