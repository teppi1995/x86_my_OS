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
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

	;; 【ブートフラグ】 
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

	;; リアルモード時に取得した情報
FONT:							;フォント
	.seg:	dw	0
	.off:	dw	0

ACPI_DATA:
	.adr:	dd	0
	.len:	dd	0
	
;;【モジュール（512バイト移行に配置）】 
%include "../modules/real/itoa.s"	
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"	
%include "../modules/real/get_mem_info.s"
%include "../modules/real/kbc.s"
%include "../modules/real/read_lba.s"


;;ブート処理第２ステージ
stage_2:
	cdecl 	puts, .s0

	;; ドライブ情報を取得
	cdecl	get_drive_param, BOOT
	cmp		ax, 0
.10Q:
	jne		.10E
.10T:
	cdecl	puts, .e0
	call	reboot
.10E:

	;; ドライブ情報を表示
	mov		ax, [BOOT + drive.no]
	cdecl	itoa, ax, .p1, 2, 16, 0b0100
	mov		ax, [BOOT + drive.cyln]
	cdecl	itoa, ax, .p2, 4, 16, 0b0100
	mov		ax, [BOOT + drive.head]
	cdecl	itoa, ax, .p3, 2, 16, 0b0100
	mov		ax, [BOOT + drive.sect]
	cdecl	itoa, ax, .p4, 2, 16, 0b0100
	cdecl	puts, .s1

	;; 【次のステージへ移行】
	jmp		stage_3rd

	;; データ
.s0		db "2nd stage...", 0x0A, 0x0D, 0
.s1		db "Drive:0x"
.p1		db "  , C:0x"
.p2		db "    , H:0x"
.p3		db "  , S:0x"
.p4		db "  ", 0x0A, 0x0D, 0

.e0		db "Can't get drive parameter.", 0

stage_3rd:
	;; 文字を表示
	cdecl	puts, .s0

	;; プロテクトモードで使用するフォントは、BIOSのものを流用

	cdecl	get_font_adr, FONT

	;; フォントアドレスの表示

	cdecl	itoa, word	[FONT.seg], .p1, 4, 16, 0b0100
	cdecl	itoa, word	[FONT.off], .p2, 4, 16, 0b0100
	cdecl	puts, .s1

	;; メモリ情報の取得と表示

	cdecl	get_mem_info

	mov		eax, [ACPI_DATA.adr]
	cmp		eax, 0
	je		.10E

	cdecl	itoa, ax, .p4, 4, 16, 0b0100
	shr		eax, 16
	cdecl	itoa, ax, .p3, 4, 16, 0x0100
	cdecl	puts, .s2

.10E:
	
	;; 処理の終了
	jmp		stage_4				;while(1)

	;; データ
	.s0		db	"3rd stage...", 0x0A, 0x0D, 0

	.s1:	db 	"Font Address = "
	.p1:	db	"ZZZZ:"
	.p2:	db	"ZZZZ", 0x0A, 0x0D, 0
			db	0x0A, 0x0D, 0

	.s2		db " ACPI data = "
	.p3		db "ZZZZ:"
	.p4		db "ZZZZ", 0x0A, 0x0D, 0

stage_4:
	;; 文字列を表示
	cdecl 	puts, .s0

	;; A20 ゲートの有効化
	cli
	cdecl	KBC_Cmd_Write, 0xAD

	cdecl	KBC_Data_Read, .key

	mov		bl, [.key]
	or		bl, 0x02

	cdecl	KBC_Cmd_Write, 0xD1
	cdecl	KBC_Data_Write,bx

	cdecl	KBC_Cmd_Write, 0xAE

	sti

	;; 文字列を表示
	cdecl	puts, .s1

	;; キーボードLEDのテスト
	mov		bx, 0				;cx = LEDの初期値

.10L:

	mov 	ah, 0x00
	int		0x16				;AL = BIOS(0x16, 0x00)

	cmp		al, '1'
	jb		.10E

	cmp		al, '3'
	ja		.10E

	mov		cl, al
	dec		cl
	and		cl, 0x03
	mov		ax, 0x0001
	shl		ax, cl
	xor		bx, ax

	;; LEDコマンドの送信
	cli

	cdecl	KBC_Cmd_Write, 0xAD

	cdecl	KBC_Data_Write, 0xED
	cdecl	KBC_Data_Read, .key

	cmp		[.key], byte 0xFA
	jne		.11F

	cdecl	KBC_Data_Write, bx

	jmp		.11E
.11F:
	cdecl	itoa, word [.key], .e1, 2, 16, 0b0100
	cdecl	puts, .e0
.11E:

	cdecl	KBC_Cmd_Write, 0xAE

	sti

	jmp		.10L
.10E:
	
	;; 文字列を表示
	cdecl 	puts, .s3
	
	;; 処理の終了
	jmp		stage_5

.s0:		db	"4th stage...", 0x0A, 0x0D, 0 
.s1:		db	" A20 Gate Enabled.", 0x0A, 0x0D, 0	
.s2:		db	"Keyboard LED Test...", 0
.s3:		db 	"(done)", 0x0A, 0x0D, 0
.e0:		db	"["
.e1:		db 	"ZZ]", 0
	
.key:	dw	0

;;第５ステージ（カーネルのロード)
stage_5:
	;; 文字列を表示
	cdecl	puts, .s0

	;; カーネルを読み込む
	cdecl	read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

	cmp		ax, KERNEL_SECT
.10Q:
	jz		.10E
.10T:
	cdecl	puts, .e0
	call	reboot
.10E:

	;; 処理の終了
	jmp		stage_6

.s0			db 	"5th stage...", 0x0A, 0x0D, 0
.e0			db 	" Failure load kernel...", 0x0A, 0x0D, 0

;;第６ステージ
stage_6:
	;; 文字列を表示
	cdecl	puts, .s0

	;; ユーザからの入力町
.10L:

	mov		ah, 0x00
	int		0x16
	cmp		al, ' '
	jne		.10L

	;; ビデオモードの設定
	mov		ax, 0x0012			;VGA 640 x 480
	int		0x10				;BIOS(0x10, 0x12)

	;; 処理の終了
	jmp		stage_7

.s0			db	"6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
			db	" [Push SPACE key to protect mode ...]", 0x0A, 0x0D, 0

;; ***********************************
;;GLOBAL DESCRIPTOR TABLE
;;（セグメントディスクリプタのテーブル） 
;; ***********************************
	
ALIGN 4, db 0
GDT:		dq	0x00_0_0_0_0_000000_0000 ;NULL
.cs:		dq	0x00_C_F_9_A_000000_FFFF ;CODE 4G
.ds:		dq	0x00_C_F_9_2_000000_FFFF ;DATA 4G
.gdt_end:

;; セレクタ

SEL_CODE	equ	.cs - GDT
SEL_DATA	equ	.ds - GDT


;;GDT 
GDTR:	dw	GDT.gdt_end - GDT - 1
		dd	GDT

;;IDT 
IDTR:	dw	0
		dd	0

;;ブート処理の第７ステージ
	
stage_7:
	cli

	;; GDTのロード
	lgdt	[GDTR]
	lidt	[IDTR]

	;; プロテクトモードへ移行
	mov		eax, cr0
	or		ax, 1
	mov		cr0, eax			;CR0 |= 1;

	jmp		$ + 2
	
	;; セグメント間ジャンプ
[BITS 32]
	DB		0x66
	jmp		SEL_CODE:CODE_32	;オペランドサイズオーバーライドプレフィックス

;;**************
;;32bitコード開始
;;************** 	
CODE_32:

	;; セレクタの初期化
	mov		ax,	SEL_DATA
	mov		ds, ax
	mov		es,	ax
	mov		fs, ax
	mov		gs, ax
	mov		ss, ax

	;; 	カーネル部をコピー
	mov		ecx, (KERNEL_SIZE) / 4 ;4biteずつ
	mov		esi, BOOT_END		   ;src = 0x0000_9C00　カーネル部
	mov		edi, KERNEL_LOAD	   ;dest = 0x0010_1000 上位アドレス
	cld
	rep		movsd				;while(--ECX) * EDI++ = *ESI++

	;; カーネル処理に移行
	jmp		KERNEL_LOAD

	
;; パディング（このファイルは8kバイトとする）
	times BOOT_SIZE - ($ - $$)		db	0
