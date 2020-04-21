	BOOT_LOAD	equ	0x7C00

	ORG		BOOT_LOAD

;; 	【マクロ】
%include	"../include/macro.s"	


;;【エントリポイント】 
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

	mov [BOOT.DRIVE], dl		;ブートドライブ

	;; 【文字列を表示】
	cdecl	puts, .s0
	
	jmp	$

	;; 【データ】
.s0		db "Now Booting...", 0x0A, 0x0D, 0
	

ALIGN 2, db 0 
BOOT:							;ブートドライブに関する情報
.DRIVE:		dw	0				;ドライブ番号
;; 【モジュール】
%include "../modules/real/puts.s"

	
	;; 【ブートフラグ】 
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	
