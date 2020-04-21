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

	;; 【数値を表示】
	cdecl	itoa,	8086, .s1, 8, 10, 0b0001
	cdecl	puts, .s1

	cdecl	itoa,	8086, .s1, 8, 10, 0b0011
	cdecl	puts, .s1

	cdecl	itoa,	-8086, .s1, 8, 10, 0b0001
	cdecl	puts, .s1

	cdecl	itoa,	-1, .s1, 8, 10, 0b0001
	cdecl	puts, .s1

	cdecl	itoa,	-1, .s1, 8, 10, 0b0000
	cdecl	puts, .s1

	cdecl	itoa,	-1, .s1, 8, 16, 0b0000
	cdecl	puts, .s1

	cdecl	itoa,	12, .s1, 8, 2, 0b0100
	cdecl	puts, .s1

	;; 処理の終了
	jmp	$

	;; 【データ】
.s0		db "Now Booting...", 0x0A, 0x0D, 0
.s1		db "--------", 0x0A, 0x0D, 0
	

ALIGN 2, db 0 
BOOT:							;ブートドライブに関する情報
.DRIVE:		dw	0				;ドライブ番号
;; 【モジュール】
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"	

	
	;; 【ブートフラグ】 
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	
