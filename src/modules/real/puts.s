puts:
	push	bp
	mov		bp, sp

	;; 【レジスタの保存】
	push	ax
	push	bx
	push	si

	;; 【引数を取得】
	mov		si,	[bp + 4]


	;; 【処理の開始】
	mov		ah, 0x0E
	mov		bx, 0x0000
	cld							;DF = 0アドレス加算

.10L:
	lodsb

	cmp		al, 0
	je		.10E

	int		0x10
	jmp		.10L
.10E:

	pop		si
	pop		bx
	pop		ax

	mov 	sp, bp
	pop		bp

	ret
