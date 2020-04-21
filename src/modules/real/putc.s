putc:
	;; 【スタックフレームの構築】

	push	bp
	mov		bp, sp

	;; 【レジスタの保存】

	push	ax
	push	bx

	;; 【処理の開始】

	mov		al, [bp + 4]		;出力文字を取得
	mov		ah, 0x0E
	mov		bx, 0x0000
	int		0x10

	;; 【レジスタの復帰】

	pop		bx
	pop		ax

	;; 【スタックフレームの破棄】

	mov		sp, bp
	pop		bp

	ret
