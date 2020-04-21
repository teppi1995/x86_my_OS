;************************************************************************
;	¼üÌ`æ
;========================================================================
;¡®		: void draw_line(X0, Y0, X1, Y1, color);
;
;¡ø
;	X0		: n_ÌXÀW
;	Y0		: n_ÌYÀW
;	X1		: I_ÌXÀW
;	Y1		: I_ÌYÀW
;	color	: `æF
;
;¡ßèl	: ³µ
;************************************************************************
draw_line:
		;---------------------------------------
		; yX^bNt[Ì\zz
		;---------------------------------------
												; ---------------
												;    +24| F
												;    +20| Y1
												;    +16| X1
												;    +12| Y0
												;    + 8| X0
												; ---------------
		push	ebp								; EBP+ 4| EIPißèÔnj
		mov		ebp, esp						; EBP+ 0| EBPi³Ìlj
												; ---------------
		push	dword 0							;    - 4| sum   = 0; // Î²ÌÏZl
		push	dword 0							;    - 8| x0    = 0; // XÀW
		push	dword 0							;    -12| dx    = 0; // Xª
		push	dword 0							;    -16| inc_x = 0; // XÀWª(1 or -1)
		push	dword 0							;    -20| x0    = 0; // YÀW
		push	dword 0							;    -24| dx    = 0; // Yª
		push	dword 0							;    -28| inc_x = 0; // YÀWª(1 or -1)
												; ------|--------

		;---------------------------------------
		; yWX^ÌÛ¶z
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		;---------------------------------------
		; ðvZiX²j
		;---------------------------------------
		mov		eax, [ebp + 8]					; EAX = X0;
		mov		ebx, [ebp +16]					; EBX = X1;
		sub		ebx, eax						; EBX = X1 - X0; // 
		jge		.10F							; if ( < 0)
												; {
		neg		ebx								;      *= -1;
		mov		esi, -1							;   // XÀWÌª
		jmp		.10E							; }
.10F:											; else
												; {
		mov		esi, 1							;   // XÀWÌª
.10E:											; }

		;---------------------------------------
		; ³ðvZiY²j
		;---------------------------------------
		mov		ecx, [ebp +12]					; ECX = Y0
		mov		edx, [ebp +20]					; EDX = Y1
		sub		edx, ecx						; EDX = Y1 - Y0; // ³
		jge		.20F							; if (³ < 0)
												; {
		neg		edx								;   ³ *= -1;
		mov		edi, -1							;   // YÀWÌª
		jmp		.20E							; }
.20F:											; else
												; {
		mov		edi, 1							;   // YÀWÌª
.20E:											; }

		;---------------------------------------
		; X²
		;---------------------------------------
		mov		[ebp - 8], eax					;   // X²:JnÀW
		mov		[ebp -12], ebx					;   // X²:`æ
		mov		[ebp -16], esi					;   // X²:ª(î²F1 or -1)

		;---------------------------------------
		; Y²
		;---------------------------------------
		mov		[ebp -20], ecx					;   // Y²:JnÀW
		mov		[ebp -24], edx					;   // Y²:`æ
		mov		[ebp -28], edi					;   // Y²:ª(î²F1 or -1)

		;---------------------------------------
		; î²ðßé
		;---------------------------------------
		cmp		ebx, edx						; if ( <= ³)
		jg		.22F							; {
												;   
		lea		esi, [ebp -20]					;   // X²ªî²
		lea		edi, [ebp - 8]					;   // Y²ªÎ²
												;   
		jmp		.22E							; }
.22F:											; else
												; {
		lea		esi, [ebp - 8]					;   // Y²ªî²
		lea		edi, [ebp -20]					;   // X²ªÎ²
.22E:											; }

		;---------------------------------------
		; JèÔµñ(î²Ìhbg)
		;---------------------------------------
		mov		ecx, [esi - 4]					; ECX = î²`æ;
		cmp		ecx, 0							; if (0 == ECX)
		jnz		.30E							; {
		mov		ecx, 1							;   ECX = 1;
.30E:											; }

		;---------------------------------------
		; üð`æ
		;---------------------------------------
.50L:											; do
												; {
%ifdef	USE_SYSTEM_CALL
		mov		eax, ecx						;   // JèÔµñðÛ¶

		mov		ebx, [ebp +24]					;   EBX = \¦F;
		mov		ecx, [ebp - 8]					;   ECX = XÀW;
		mov		edx, [ebp -20]					;   EDX = YÀW;
		int		0x82							;   sys_call(1, X, Y, F, ¶); BX(C), CX(X), DX(Y)

		mov		ecx, eax
%else
		cdecl	draw_pixel, dword [ebp - 8], \
							dword [ebp -20], \
							dword [ebp +24]		;   // _Ì`æ
%endif
												;   // î²ðXV(1hbgª)
		mov		eax, [esi - 8]					;   EAX = î²ª(1 or -1);
		add		[esi - 0], eax					;   

												;   // Î²ðXV
		mov		eax, [ebp - 4]					;   EAX  = sum; // Î²ÌÏZl;
		add		eax, [edi - 4]					;   EAX += dy;  // ª(Î²Ì`æ)
		mov		ebx, [esi - 4]					;   EBX  = dx;  // ª(î²Ì`æ)

		cmp		eax, ebx						;   if (ÏZl <= Î²Ìª)
		jl		.52E							;   {
		sub		eax, ebx						;     EAX -= EBX; // ÏZl©çÎ²Ìªð¸Z
												;     
												;     // Î²ÌÀWðXV(1hbgª)
		mov		ebx, [edi - 8]					;     EBX =  Î²ª;
		add		[edi - 0], ebx					;     
.52E:											;   }
		mov		[ebp - 4], eax					;   // ÏZlðXV
												;   
		loop	.50L							;   
.50E:											; } while ([vñ--);

		;---------------------------------------
		; yWX^ÌAz
		;---------------------------------------
		pop		edi
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		;---------------------------------------
		; yX^bNt[Ìjüz
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

