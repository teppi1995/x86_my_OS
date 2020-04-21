	BOOT_LOAD	equ	0x7C00

	ORG		BOOT_LOAD

;; 	【マクロ】
%include	"../include/macro.s"	


;;【エントリポイント】 
entry:
	jmp	ipl						;IPLへジャンプ
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

	;;次の512バイトを読み込む
	mov		ah, 0x02			;AH = 読み込みセクタ
	mov		al, 1				;AL = 読み込みセクタ数
	mov		cx, 0x0002			;CX = シリンダ/セクタ
	mov		dh, 0x00			;DH = ヘッド位置
	mov		dl, [BOOT.DRIVE]	;DL = ドライブ番号
	mov		bx, 0x7C00 + 512	;BX = オフセット
	int		0x13
.10Q:
	jnc		.10E
.10T:
	cdecl	puts, .e0
	call	reboot
.10E:
	
	jmp		stage_2				;次のステージへ以降

	;; 【データ】
.s0		db "Now Booting...", 0x0A, 0x0D, 0
.e0		db "Error:sector read", 0
.s1		db "--------", 0x0A, 0x0D, 0
	

ALIGN 2, db 0 
BOOT:							;ブートドライブに関する情報
.DRIVE:		dw	0				;ドライブ番号
;; 【モジュール】
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"	
%include "../modules/real/reboot.s"
	
	;; 【ブートフラグ】 
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	
;;ブート処理第２ステージ
stage_2:
	cdecl 	puts, .s0

	jmp		$

.s0		db "2nd stage...", 0x0A, 0x0D, 0

;; パディング（このファイルは8kバイトとする）
	times (1024 * 8) - ($ - $$)		db	0
