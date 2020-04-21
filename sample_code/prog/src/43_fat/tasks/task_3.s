;************************************************************************
;	TASK
;************************************************************************
task_3:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ---------------
		push	dword 0							;    - 4| x0 = 0; // X���W���_
		push	dword 0							;    - 8| y0 = 0; // Y���W���_
		push	dword 0							;    -12| x  = 0; // X���W�`��
		push	dword 0							;    -16| y  = 0; // Y���W�`��
		push	dword 0							;    -20| r  = 0; // �p�x

		;---------------------------------------
		; ������
		;---------------------------------------
		mov		esi, 0x0010_7000				; ESI = �`��p�����[�^

		;---------------------------------------
		; �^�C�g���\��
		;---------------------------------------
		mov		eax, [esi + rose.x0]			; X0���W
		mov		ebx, [esi + rose.y0]			; Y0���W

		shr		eax, 3							; EAX = EAX /  8; // X���W�𕶎��ʒu�ɕϊ�
		shr		ebx, 4							; EBX = EBX / 16; // Y���W�𕶎��ʒu�ɕϊ�
		dec		ebx								; // 1��������Ɉړ�
		mov		ecx, [esi + rose.color_s]		; �����F
		lea		edx, [esi + rose.title]			; �^�C�g��

		cdecl	draw_str, eax, ebx, ecx, edx	; draw_str();

		;---------------------------------------
		; X���̒��_
		;---------------------------------------
		mov		eax, [esi + rose.x0]			; EAX  = X0���W
		mov		ebx, [esi + rose.x1]			; EBX  = X1���W
		sub		ebx, eax						; EBX  = (X1 - X0);
		shr		ebx, 1							; EBX /= 2;
		add		ebx, eax						; EBX += X0
		mov		[ebp - 4], ebx					; x0 = EBX; // X���W���_;

		;---------------------------------------
		; Y���̒��_
		;---------------------------------------
		mov		eax, [esi + rose.y0]			; EAX  = Y0���W
		mov		ebx, [esi + rose.y1]			; EBX  = Y1���W
		sub		ebx, eax						; EBX  = (Y1 - Y0);
		shr		ebx, 1							; EBX /= 2;
		add		ebx, eax						; EBX += Y0
		mov		[ebp - 8], ebx					; y0 = EBX; // Y���W���_;

		;---------------------------------------
		; X���̕`��
		;---------------------------------------
		mov		eax, [esi + rose.x0]			; EAX = X0���W;
		mov		ebx, [ebp - 8]					; EBX = Y���̒��_;
		mov		ecx, [esi + rose.x1]			; ECX = X1���W;

		cdecl	draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]	; X��

		;---------------------------------------
		; Y���̕`��
		;---------------------------------------
		mov		eax, [esi + rose.y0]			; Y0���W
		mov		ebx, [ebp - 4]					; EBX = X���̒��_;
		mov		ecx, [esi + rose.y1]			; Y1���W

		cdecl	draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]	; Y��

		;---------------------------------------
		; �g�̕`��
		;---------------------------------------
		mov		eax, [esi + rose.x0]			; X0���W
		mov		ebx, [esi + rose.y0]			; Y0���W
		mov		ecx, [esi + rose.x1]			; X1���W
		mov		edx, [esi + rose.y1]			; Y1���W

		cdecl	draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]	; �g

		;---------------------------------------
		; �U����X���̖�95%�Ƃ���
		;---------------------------------------
		mov		eax, [esi + rose.x1]			; EAX  = X1���W;
		sub		eax, [esi + rose.x0]			; EAX -= X0���W;
		shr		eax, 1							; EAX /= 2;      // ����
		mov		ebx, eax						; EBX  = EAX;
		shr		ebx, 4							; EBX /= 16;
		sub		eax, ebx						; EAX -= EBX;

		;---------------------------------------
		; FPU�̏�����(�o���Ȑ��̏�����)
		;---------------------------------------
		cdecl	fpu_rose_init					\
					, eax						\
					, dword [esi + rose.n]		\
					, dword [esi + rose.d]

		;---------------------------------------
		; ���C�����[�v
		;---------------------------------------
.10L:											; for ( ; ; )
												; {
		;---------------------------------------
		; ���W�v�Z
		;---------------------------------------
		lea		ebx, [ebp -12]					;   EBX = &x;
		lea		ecx, [ebp -16]					;   ECX = &y;
		mov		eax, [ebp -20]					;   EAX = r;

		cdecl	fpu_rose_update					\
					, ebx						\
					, ecx						\
					, eax

		;---------------------------------------
		; �p�x�X�V(r = r % 36000)
		;---------------------------------------
		mov		edx, 0							;   EDX = 0;
		inc		eax								;   EAX++;
		mov		ebx, 360 * 100					;   DBX = 36000
		div		ebx								;   EDX = EDX:EAX % EBX;
		mov		[ebp -20], edx

		;---------------------------------------
		; �h�b�g�`��
		;---------------------------------------
		mov		ecx, [ebp -12]					;   ECX = X���W
		mov		edx, [ebp -16]					;   ECX = Y���W

		add		ecx, [ebp - 4]					;   ECX += X���W���_;
		add		edx, [ebp - 8]					;   EDX += Y���W���_;

		mov		ebx, [esi + rose.color_f]		;   EBX = �\���F;
		int		0x82							;   sys_call_82(�\���F, X, Y);

		;---------------------------------------
		; �E�F�C�g
		;---------------------------------------
		cdecl	wait_tick, 2					;   wait_tick(2);

		;---------------------------------------
		; �h�b�g�`��(����)
		;---------------------------------------
		mov		ebx, [esi + rose.color_b]		;   EBX = �w�i�F;
		int		0x82							;   sys_call_82(�w�i�F, X, Y);


        jmp     .10L                            ; }


ALIGN 4, db 0
DRAW_PARAM:										; �`��p�����[�^
.t3:
	istruc	rose
		at	rose.x0,		dd		 32			; ������W�FX0
		at	rose.y0,		dd		 32			; ������W�FY0
		at	rose.x1,		dd		208			; �E�����W�FX1
		at	rose.y1,		dd		208			; �E�����W�FY1

		at	rose.n,			dd		2			; �ϐ��Fn
		at	rose.d,			dd		1			; �ϐ��Fd

		at	rose.color_x,	dd		0x0007		; �`��F�FX��
		at	rose.color_y,	dd		0x0007		; �`��F�FY��
		at	rose.color_z,	dd		0x000F		; �`��F�F�g
		at	rose.color_s,	dd		0x030F		; �`��F�F����
		at	rose.color_f,	dd		0x000F		; �`��F�F�O���t�`��F
		at	rose.color_b,	dd		0x0003		; �`��F�F�O���t�����F

		at	rose.title,		db		"Task-3", 0	; �^�C�g��
	iend

.t4:
	istruc	rose
		at	rose.x0,		dd		248			; ������W�FX0
		at	rose.y0,		dd		 32			; ������W�FY0
		at	rose.x1,		dd		424			; �E�����W�FX1
		at	rose.y1,		dd		208			; �E�����W�FY1

		at	rose.n,			dd		3			; �ϐ��Fn
		at	rose.d,			dd		1			; �ϐ��Fd

		at	rose.color_x,	dd		0x0007		; �`��F�FX��
		at	rose.color_y,	dd		0x0007		; �`��F�FY��
		at	rose.color_z,	dd		0x000F		; �`��F�F�g
		at	rose.color_s,	dd		0x040F		; �`��F�F����
		at	rose.color_f,	dd		0x000F		; �`��F�F�O���t�`��F
		at	rose.color_b,	dd		0x0004		; �`��F�F�O���t�����F

		at	rose.title,		db		"Task-4", 0	; �^�C�g��
	iend

.t5:
	istruc	rose
		at	rose.x0,		dd		 32			; ������W�FX0
		at	rose.y0,		dd		272			; ������W�FY0
		at	rose.x1,		dd		208			; �E�����W�FX1
		at	rose.y1,		dd		448			; �E�����W�FY1

		at	rose.n,			dd		2			; �ϐ��Fn
		at	rose.d,			dd		6			; �ϐ��Fd

		at	rose.color_x,	dd		0x0007		; �`��F�FX��
		at	rose.color_y,	dd		0x0007		; �`��F�FY��
		at	rose.color_z,	dd		0x000F		; �`��F�F�g
		at	rose.color_s,	dd		0x050F		; �`��F�F����
		at	rose.color_f,	dd		0x000F		; �`��F�F�O���t�`��F
		at	rose.color_b,	dd		0x0005		; �`��F�F�O���t�����F

		at	rose.title,		db		"Task-5", 0	; �^�C�g��
	iend

.t6:
	istruc	rose
		at	rose.x0,		dd		248			; ������W�FX0
		at	rose.y0,		dd		272			; ������W�FY0
		at	rose.x1,		dd		424			; �E�����W�FX1
		at	rose.y1,		dd		448			; �E�����W�FY1

		at	rose.n,			dd		4			; �ϐ��Fn
		at	rose.d,			dd		6			; �ϐ��Fd

		at	rose.color_x,	dd		0x0007		; �`��F�FX��
		at	rose.color_y,	dd		0x0007		; �`��F�FY��
		at	rose.color_z,	dd		0x000F		; �`��F�F�g
		at	rose.color_s,	dd		0x060F		; �`��F�F����
		at	rose.color_f,	dd		0x000F		; �`��F�F�O���t�`��F
		at	rose.color_b,	dd		0x0006		; �`��F�F�O���t�����F

		at	rose.title,		db		"Task-6", 0	; �^�C�g��
	iend




;************************************************************************
;	�o���Ȑ��F������
;------------------------------------------------------------------------
;	�o���Ȑ���`�悷�邽�߂�FPU�̃��W�X�^������������
;
;	Z = A * sin(n��)
;	  = A * sin( (n/d) * ((��/180) * t) )
;
;	���̃O���t��`�悷�邽�߂ɁAX/Y���W�����̗l�Ɍv�Z����
;
;	x = A * sin(n��) * cos(��)
;	y = A * sin(n��) * sin(��)
;
;	���̎��Ak��(n / d)�Ŏw�肷��B�܂��A���f�B�A�� = �x * (�� / 180)
;	�ł��鎖����Ar = �� / 180���Ɍv�Z���Ă���
;========================================================================
;������		: void fpu_rose_init(A, n, d);
;
;������
;	DWORD	: A
;	DWORD	: n
;	DWORD	: d
;
;���߂�l	: ����
;************************************************************************
fpu_rose_init:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												; ------|--------
												;    +16| d
												;    +12| n
												;    + 8| A
												; ---------------
		push	ebp								; EBP+ 4| EIP�i�߂�Ԓn�j
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ---------------
		push	dword 180						;    - 4| dword i = 180;

		;---------------------------------------
		; FPU���g��������
		;
		; A(�U��), k(n/d),r(�x�����f�B�A��)��
		; FPU���̃��W�X�^�ɃX�^�b�N���Ă���
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
		fldpi									;   pi     |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fidiv	dword [ebp - 4]					;   pi/180 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fild	dword [ebp +12]					;        n |  pi/180 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fidiv	dword [ebp +16]					;      n/d |         |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
		fild	dword [ebp + 8]					;        A |     n/d |  pi/180 |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
												;        A |       k |       r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		;---------------------------------------
		; �X�^�b�N�t���[���̔j��
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

;************************************************************************
;	�o���Ȑ��F�v�Z
;------------------------------------------------------------------------
;	�p�x�������Ƃ��Ď󂯎��A���W���v�Z����B
;	�i���̃p�����[�^��FPU���W�X�^�ɐݒ�ς݂Ɖ���j
;========================================================================
;������		: void fpu_rose_update(t, X, Y);
;
;������
;	DWORD	: �p�x[�x]
;	DWORD	: Y���W�ւ̃|�C���^
;	DWORD	: X���W�ւ̃|�C���^
;
;���߂�l	: ����
;************************************************************************
fpu_rose_update:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												; ---------------
												; EBP+16| t(�p�x)
												; EBP+12| Y(float)
												; EBP+ 8| X(float)
												; ---------------
		push	ebp								; EBP+ 4| EIP�i�߂�Ԓn�j
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ------|--------

		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax
		push	ebx

		;---------------------------------------
		; X/Y�̕ۑ����ݒ�
		;---------------------------------------
		mov		eax, [ebp +  8]					; EAX = pX; // X���W�ւ̃|�C���^
		mov		ebx, [ebp + 12]					; EBX = pY; // Y���W�ւ̃|�C���^

		;---------------------------------------
		; FPU���g��������
		; 
		; ���ɃX�^�b�N���Ă���l������
		; t(�p�x)������W���v�Z����
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
		fild	dword [ebp +16]					;        t |       A |       k |       r |xxxxxxxxx|xxxxxxxxx|
		fmul	st0, st3						;       rt |         |         |         |         |         |
		fld		st0								;       rt |      rt |       A |       k |       r |xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		; rt �� �Ƃƒu��������					;       �� |      �� |       A |       k |       r |         |
												; ---------+---------+---------|---------|---------|---------|
		fsincos									;   cos(��)|  sin(��)|      �� |       A |       k |       r |
		fxch	st2								;       �� |         |  cos(��)|         |         |         |
		fmul	st0, st4						;      k�� |         |         |         |         |         |
		fsin									;  sin(k��)|         |         |         |         |         |
		fmul	st0, st3						; Asin(k��)|         |         |         |         |         |
												; ---------+---------+---------|---------|---------|---------|
												; Asin(k��)|  sin(��)|  cos(��)|       A |       k |       r |
												; ---------+---------+---------|---------|---------|---------|
		;---------------------------------------
		; x =  A * sin(k��) * cos(��);
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
												; Asin(k��)|  sin(��)|  cos(��)|       A |       k |       r |
		fxch	st2								;   cos(��)|         |Asin(k��)|         |         |         |
		fmul	st0, st2						;        x |         |         |         |         |         |
		fistp	dword [eax]						;   sin(��)|Asin(k��)|       A |       k |       r |xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		;---------------------------------------
		; y = -A * sin(k��) * sin(��);
		;---------------------------------------
												; ---------+---------+---------|---------|---------|---------|
												;       ST0|      ST1|      ST2|      ST3|      ST4|      ST5|
												; ---------+---------+---------|---------|---------|---------|
												;   sin(��)|Asin(k��)|       A |       k |       r |xxxxxxxxx|
		fmulp	st1, st0						;        y |       A |       k |       r |xxxxxxxxx|xxxxxxxxx|
		fchs									;       -y |         |         |         |xxxxxxxxx|xxxxxxxxx|
		fistp	dword [ebx]						;        A |       k |       r |xxxxxxxxx|xxxxxxxxx|xxxxxxxxx|
												; ---------+---------+---------|---------|---------|---------|
		;---------------------------------------
		; ���W�X�^�̕��A
		;---------------------------------------
		pop		ebx
		pop		eax

		;---------------------------------------
		; �X�^�b�N�t���[���̔j��
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

