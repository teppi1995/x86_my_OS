;************************************************************************
;	�����̕\��
;------------------------------------------------------------------------
;	�O���t�B�b�N�X���[�h�Ńe�L�X�g��\��
;========================================================================
;������		: void draw_char(col, row, color, ch);
;
;������
;	col		: ��i0�`79�j
;	row		: �s�i0�`29�j
;	color	: �`��F
;	ch		: ����
;
;���߂�l	: ����
;************************************************************************
draw_char:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												; ------|--------
												; EBP+20| ����
												; EBP+16| �F
												; EBP+12| Y�i�s�j
												; EBP+ 8| X�i��j
												; ------+----------------
		push	ebp								; EBP+ 4| EIP�i�߂�Ԓn�j
		mov		ebp, esp						; EBP+ 0| EBP�i���̒l�j
												; ------+----------------

		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		;---------------------------------------
		; �e�X�g�A���h�Z�b�g
		;---------------------------------------
%ifdef	USE_TEST_AND_SET
		cdecl	test_and_set, IN_USE			; TEST_AND_SET(IN_USE); // ���\�[�X�̋󂫑҂�
%endif

		;---------------------------------------
		; �R�s�[���t�H���g�A�h���X��ݒ�
		;---------------------------------------
		movzx	esi, byte [ebp +20]				; CL  = �����R�[�h;
		shl		esi, 4							; CL *= 16; // 1����16�o�C�g
		add		esi, [FONT_ADR]					; ESI = �t�H���g�A�h���X;

		;---------------------------------------
		; �R�s�[��A�h���X���擾
		; Adr = 0xA0000 + (640 / 8 * 16) * y + x
		;---------------------------------------
		mov		edi, [ebp +12]					; Y�i�s�j
		shl		edi, 8							; EDI = Y * 256;
		lea		edi, [edi * 4 + edi + 0xA0000]	; EDI = Y *   4 + Y;
		add		edi, [ebp + 8]					; X�i��j

		;---------------------------------------
		; 1�������̃t�H���g���o��
		;---------------------------------------
		movzx	ebx, word [ebp +16]				; // �\���F

		cdecl	vga_set_read_plane, 0x03		; // �������݃v���[���F�P�x(I)
		cdecl	vga_set_write_plane, 0x08		; // �ǂݍ��݃v���[���F�P�x(I)
		cdecl	vram_font_copy, esi, edi, 0x08, ebx

		cdecl	vga_set_read_plane, 0x02		; // �������݃v���[���F��(R)
		cdecl	vga_set_write_plane, 0x04		; // �ǂݍ��݃v���[���F��(R)
		cdecl	vram_font_copy, esi, edi, 0x04, ebx

		cdecl	vga_set_read_plane, 0x01		; // �������݃v���[���F��(G)
		cdecl	vga_set_write_plane, 0x02		; // �ǂݍ��݃v���[���F��(G)
		cdecl	vram_font_copy, esi, edi, 0x02, ebx

		cdecl	vga_set_read_plane, 0x00		; // �������݃v���[���F��(B)
		cdecl	vga_set_write_plane, 0x01		; // �ǂݍ��݃v���[���F��(B)
		cdecl	vram_font_copy, esi, edi, 0x01, ebx

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
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		;---------------------------------------
		; �y�X�^�b�N�t���[���̔j���z
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

%ifdef USE_TEST_AND_SET
ALIGN 4, db 0
IN_USE:	dd	0
%endif

