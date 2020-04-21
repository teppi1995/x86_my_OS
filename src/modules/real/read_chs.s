read_chs:
	;; スタックフレームの構築

	push	bp
	mov		bp, sp
	push	3
	push	0

	;; レジスタの保存
	push	bx
	push	cx
	push	dx
	push	es
	push	si

	;; 処理の開始
	mov		si, [bp + 4]		;SI = SRCバッファ

	;; CXレジスタの設定
	;; （BIOSコールの呼び出しに適した形に変換）
	mov		ch, [si + drive.cyln + 0]
	mov		cl, [si + drive.cyln + 1]
	shl		cl, 6
	or		cl, [si + drive.sect]

	;; セクタの読み込み
	mov		dh, [si + drive.head]
	mov		dl, [si + 0]
	mov		ax, 0x0000
	mov		es, ax
	mov		bx, [bp + 8]
.10L:

	mov		ah, 0x02
	mov		al, [bp + 6]

	int		0x13
	jnc		.11E

	mov		al, 0
	jmp		.10E
.11E:

	cmp		al, 0
	jne		.10E

	mov		ax, 0
	dec		word [bp - 2]
	jnz		.10L

.10E:
	mov		ah, 0

	pop		si
	pop		es
	pop		dx
	pop		cx
	pop		bx


	mov		sp, bp
	pop		bp


	ret
	
