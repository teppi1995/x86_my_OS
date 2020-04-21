	;; 【マクロ】
%include	"../include/define.s"
%include	"../include/macro.s"
	
	ORG		BOOT_LOAD

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

	mov [BOOT + drive.no], dl		;ブートドライブ

	;; 【文字列を表示】
	cdecl	puts, .s0

	;;残りのセクタをすべて読み込む
	mov		bx, BOOT_SECT - 1	;BX = 残りのブートセクタ数
	mov		cx, BOOT_LOAD + SECT_SIZE ;CX = 次のロードアドレス

	cdecl	read_chs, BOOT, bx, cx

	cmp		ax, bx
.10Q:
	jz		.10E
.10T:
	cdecl	puts, .e0
	call	reboot
.10E:

	;; 次のステージへ移行
	
	jmp		stage_2
	
	;; 【データ】
.s0		db "Now Booting...", 0x0A, 0x0D, 0
.e0		db "Error:sector read", 0

;; ブートドライブに関する情報
ALIGN	2, db 0
BOOT:
	istruc	drive
		at	drive.no,	dw	0
		at	drive.cyln,	dw	0
		at	drive.head,	dw	0
		at	drive.sect,	dw	2
	iend
	
;; 【モジュール】
%include "../modules/real/puts.s"
%include "../modules/real/itoa.s"	
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"
	
	;; 【ブートフラグ】 
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	
;;ブート処理第２ステージ
stage_2:
	cdecl 	puts, .s0

	jmp		$

.s0		db "2nd stage...", 0x0A, 0x0D, 0

;; パディング（このファイルは8kバイトとする）
	times BOOT_SIZE - ($ - $$)		db	0
