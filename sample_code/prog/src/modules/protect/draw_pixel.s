;************************************************************************
;	�s�N�Z���̕`��
;========================================================================
;������		: void draw_pixel(X, Y, color);
;
;������
;	X		: X���W
;	Y		: Y���W
;	color	: �`��F
;
;���߂�l	: ����
;************************************************************************
draw_pixel:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												; ------|--------
												; EBP+16| �F
												; EBP+12| Y
												; EBP+ 8| X
												; ------|--------
		push	ebp								; EBP+ 4| EIP�i�߂�Ԓn�j
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ------+--------
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edi

		;---------------------------------------
		; Y���W��80�{����i640/8�j
		;---------------------------------------
		mov		edi, [ebp +12]					; EDI  = Y���W
		shl		edi, 4							; EDI *= 16;
		lea		edi, [edi * 4 + edi + 0xA_0000]	; EDI  = 0xA00000[EDI * 4 + EDI];

		;---------------------------------------
		; X���W��1/8���ĉ��Z
		;---------------------------------------
		mov		ebx, [ebp + 8]					; EBX  = X���W;
		mov		ecx, ebx						; ECX  = X���W;�i�ꎞ�ۑ��j
		shr		ebx, 3							; EBX /= 8;
		add		edi, ebx						; EDI += EBX;

		;---------------------------------------
		; X���W��8�Ŋ������]�肩��r�b�g�ʒu���v�Z
		; (0=0x80, 1=0x40,... 7=0x01)
		;---------------------------------------
		and		ecx, 0x07						; ECX = X & 0x07;
		mov		ebx, 0x80						; EBX = 0x80;
		shr		ebx, cl							; EBX >>= ECX;

		;---------------------------------------
		; �F�w��
		;---------------------------------------
		mov		ecx, [ebp +16]					; // �\���F

%ifdef	USE_TEST_AND_SET
		cdecl	test_and_set, IN_USE			; TEST_AND_SET(IN_USE); // ���\�[�X�̋󂫑҂�
%endif

		;---------------------------------------
		; �v���[�����ɏo��
		;---------------------------------------
		cdecl	vga_set_read_plane, 0x03		; // �P�x(I)�v���[����I��
		cdecl	vga_set_write_plane, 0x08		; // �P�x(I)�v���[����I��
		cdecl	vram_bit_copy, ebx, edi, 0x08, ecx

		cdecl	vga_set_read_plane, 0x02		; // ��(R)�v���[����I��
		cdecl	vga_set_write_plane, 0x04		; // ��(R)�v���[����I��
		cdecl	vram_bit_copy, ebx, edi, 0x04, ecx

		cdecl	vga_set_read_plane, 0x01		; // ��(G)�v���[����I��
		cdecl	vga_set_write_plane, 0x02		; // ��(G)�v���[����I��
		cdecl	vram_bit_copy, ebx, edi, 0x02, ecx

		cdecl	vga_set_read_plane, 0x00		; // ��(B)�v���[����I��
		cdecl	vga_set_write_plane, 0x01		; // ��(B)�v���[����I��
		cdecl	vram_bit_copy, ebx, edi, 0x01, ecx


%ifdef	USE_TEST_AND_SET
		;---------------------------------------
		; �e�X�g�A���h�Z�b�g
		;---------------------------------------
		mov		[IN_USE], dword 0				; �ϐ��̃N���A
%endif

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		edi
		pop		ecx
		pop		ebx
		pop		eax

		;---------------------------------------
		; �y�X�^�b�N�t���[���̔j���z
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

