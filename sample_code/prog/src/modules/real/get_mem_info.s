;************************************************************************
;	���������̕\��
;------------------------------------------------------------------------
;	ACPI�f�[�^�̃A�h���X�ƒ������O���[�o���ϐ��ɕۑ�����
;========================================================================
;������		: void get_mem_info(void);
;
;������		: ����
;
;���߂�l;	: ����
;************************************************************************
get_mem_info:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	si
		push	di
		push	bp

		;---------------------------------------
		; �y�����̊J�n�z
		;---------------------------------------
		cdecl	puts, .s0						; // �w�b�_��\��

		mov		bp, 0							; lines = 0; // �s��
		mov		ebx, 0							; index = 0; // �C���f�b�N�X��������
.10L:											; do
												; {
		mov		eax, 0x0000E820					;   EAX   = 0xE820
												;   EBX   = �C���f�b�N�X
		mov		ecx, E820_RECORD_SIZE			;   ECX   = �v���o�C�g��
		mov 	edx, 'PAMS'						;   EDX   = 'SMAP';
		mov		di, .b0							;   ES:DI = �o�b�t�@
		int		0x15							;   BIOS(0x15, 0xE820);

		; �R�}���h�ɑΉ����H
		cmp		eax, 'PAMS'						;   if ('SMAP' != EAX)
		je		.12E							;   {
		jmp		.10E							;     break; // �R�}���h���Ή�
.12E:											;   }

		; �G���[�����H							;   if (CF)
		jnc		.14E							;   {
		jmp		.10E							;     break; // �G���[����
.14E:											;   }

		; 1���R�[�h���̃���������\��
		cdecl	put_mem_info, di				;   1���R�[�h���̃���������\��

		; ACPI data�̃A�h���X���擾
		mov		eax, [di + 16]					;   EAX = ���R�[�h�^�C�v;
		cmp		eax, 3							;   if (3 == EAX) // ACPI data
		jne		.15E							;   {
												;     
		mov		eax, [di +  0]					;     EAX   = BASE�A�h���X;
		mov		[ACPI_DATA.adr], eax			;     ACPI_DATA.adr = EAX;
												;     
		mov		eax, [di +  8]					;     EAX   = Length;
		mov		[ACPI_DATA.len], eax			;     ACPI_DATA.len = EAX;
.15E:											;   }

		cmp		ebx, 0							;   if (0 != EBX)
		jz		.16E							;   {
												;     
		inc		bp								;     lines++;
		and		bp, 0x07						;     lines &= 0x07;
		jnz		.16E							;     if (0 == lines)
												;     {
		cdecl	puts, .s2						;       // ���f���b�Z�[�W��\��
												;       
		mov		ah, 0x10						;       // �L�[���͑҂�
		int		0x16							;       AL = BIOS(0x16, 0x10);
												;       
		cdecl	puts, .s3						;       // ���f���b�Z�[�W������
												;     }
.16E:											;   }
												;   
		cmp		ebx, 0							;   
		jne		.10L							; }
.10E:											; while (0 == EBX);

		cdecl	puts, .s1						; // �t�b�_��\��

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		bp
		pop		di
		pop		si
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		ret

.s0:	db " E820 Memory Map:", 0x0A, 0x0D
		db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db " <more...>", 0
.s3:	db 0x0D, "          ", 0x0D, 0

ALIGN 4, db 0
.b0:	times E820_RECORD_SIZE db 0

;************************************************************************
;	���������̕\��
;========================================================================
;������		: void put_mem_info(adr);
;
;������
;	adr		: �����������Q�Ƃ���A�h���X
;
;���߂�l;	: ����
;************************************************************************
put_mem_info:
		;---------------------------------------
		; �y�X�^�b�N�t���[���̍\�z�z
		;---------------------------------------
												;    + 4| �o�b�t�@�A�h���X
												;    + 2| IP�i�߂�Ԓn�j
		push	bp								;  BP+ 0| BP�i���̒l�j
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	bx
		push	si

		;---------------------------------------
		; �������擾
		;---------------------------------------
		mov		si, [bp + 4]					; SI = �o�b�t�@�A�h���X;

		;---------------------------------------
		; ���R�[�h�̕\��
		;---------------------------------------

		; Base(64bit)
		cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

		; Length(64bit)
		cdecl	itoa, word [si +14], .p4 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +12], .p4 + 4, 4, 16, 0b0100
		cdecl	itoa, word [si +10], .p5 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

		; Type(32bit)
		cdecl	itoa, word [si +18], .p6 + 0, 4, 16, 0b0100
		cdecl	itoa, word [si +16], .p6 + 4, 4, 16, 0b0100

		cdecl	puts, .s1						;   // ���R�[�h����\��

		mov		bx, [si +16]					;   // �^�C�v�𕶎���ŕ\��
		and		bx, 0x07						;   BX  = Type(0�`5)
		shl		bx, 1							;   BX *= 2;   // �v�f�T�C�Y�ɕϊ�
		add		bx, .t0							;   BX += .t0; // �e�[�u���̐擪�A�h���X�����Z
		cdecl	puts, word [bx]					;   puts(*BX);

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		si
		pop		bx

		;---------------------------------------
		; �y�X�^�b�N�t���[���̔j���z
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret;

.s1:	db " "
.p2:	db "ZZZZZZZZ_"
.p3:	db "ZZZZZZZZ "
.p4:	db "ZZZZZZZZ_"
.p5:	db "ZZZZZZZZ "
.p6:	db "ZZZZZZZZ", 0

.s4:	db " (Unknown)", 0x0A, 0x0D, 0
.s5:	db " (usable)", 0x0A, 0x0D, 0
.s6:	db " (reserved)", 0x0A, 0x0D, 0
.s7:	db " (ACPI data)", 0x0A, 0x0D, 0
.s8:	db " (ACPI NVS)", 0x0A, 0x0D, 0
.s9:	db " (bad memory)", 0x0A, 0x0D, 0

.t0:	dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4

