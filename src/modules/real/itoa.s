itoa:
	;; 【スタックフレームの構築】


	push	bp
	mov		bp, sp


	;; 【レジスタの保存】
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di

	;; 引数を取得
	mov		ax, [bp + 4]		;val = 数値
	mov		si, [bp + 6]		;dst = バッファアドレス
	mov		cx, [bp + 8]		;size = 残りバッファアサイズ

	mov		di, si
	add		di, cx
	dec		di

	mov		bx, word [bp + 12]

	;; 符号付き判定
	test	bx, 0b0001
.10Q:
	je		.10E
	cmp		ax, 0
.12Q:
	jge		.12E
	or		bx, 0b0010
.12E:
.10E:	

	;; 符号出力判定
	test	bx, 0b0010
.20Q:
	je		.20E
	cmp		ax, 0
.22Q:
	jge		.22F
	neg		ax
	mov		[si], byte '-'
	jmp		.22E
.22F:
	mov		[si], byte '+'
.22E:
	dec		cx
.20E:

	;; ASCII変換

	mov		bx, [bp + 10]
.30L:
	mov		dx, 0
	div		bx

	mov		si, dx
	mov		dl, byte [.ascii + si] ;dl = Ascii[dx]

	mov 	[di], dl
	dec		di

	cmp		ax, 0
	loopnz	.30L

.30E:

	;; 空欄を埋める
	cmp		cx, 0
.40Q:
	je		.40E
	mov		al, ' '
	cmp		[bp + 12], word 0b0100
.42Q:
	jne		.42E
	mov		al, '0'
.42E:
	std
	rep	stosb

.40E:


	;; 【レジウスタの復帰】

	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax


	;; 【スタックフレームのは木】
	mov		sp, bp
	pop		bp

	ret

.ascii	db	"0123456789ABCDEF"
	
	
