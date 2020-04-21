;************************************************************************
;	�d�f�������s��
;------------------------------------------------------------------------
;	�d�f�����ɐ��������ꍇ�A���̊֐��͖߂��Ă��Ȃ�
;========================================================================
;������		: void power_off(void);
;
;������		: ����
;
;���߂�l	: ����
;************************************************************************
power_off:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi

		;---------------------------------------
		; �d�f�J�n���b�Z�[�W
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x020F, .s0	; draw_str();  // �d�f�J�n���b�Z�[�W

		;---------------------------------------
		; �y�[�W���O�𖳌���
		;---------------------------------------
		mov		eax, cr0						; // PG�r�b�g���N���A
		and		eax, 0x7FFF_FFFF				; CR0 &= ~PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

												; do
												; {
		;---------------------------------------
		; ACPI�f�[�^�̊m�F
		;---------------------------------------
		mov		eax, [0x7C00 + 512 + 4]			;   EAX = ACPI�A�h���X;
		mov		ebx, [0x7C00 + 512 + 8]			;   EBX = ����;
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; RSDT�e�[�u���̌���
		;---------------------------------------
		cdecl	acpi_find, eax, ebx, 'RSDT'		;	EAX = acpi_find('RSDT');
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; FACP�e�[�u���̌���
		;---------------------------------------
		cdecl	find_rsdt_entry, eax, 'FACP'	;   EAX = find_rsdt_entry('FACP')
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		mov		ebx, [eax + 40]					;   // DSDT�A�h���X�̎擾
		cmp		ebx, 0							;   if (0 == DSDT)
		je		.10E							;     break;

		;---------------------------------------
		; ACPI���W�X�^�̕ۑ�
		;---------------------------------------
		mov		ecx, [eax + 64]					;   // ACPI���W�X�^�̎擾
		mov		[PM1a_CNT_BLK], ecx				;   PM1a_CNT_BLK = FACP.PM1a_CNT_BLK;

		mov		ecx, [eax + 68]					;   // ACPI���W�X�^�̎擾
		mov		[PM1b_CNT_BLK], ecx				;   PM1b_CNT_BLK = FACP.PM1b_CNT_BLK;

		;---------------------------------------
		; S5���O��Ԃ̌���
		;---------------------------------------
		mov		ecx, [ebx + 4]					;   ECX  = DSDT.Length; // �f�[�^��;
		sub		ecx, 36							;   ECX -= 36;          // �e�[�u���w�b�_�����Z
		add		ebx, 36							;   EBX += 36;          // �e�[�u���w�b�_�����Z
		cdecl	acpi_find, ebx, ecx, '_S5_'		;   EAX = acpi_find('_S5_');
		cmp		eax, 0							;   if (0 == EAX)
		je		.10E							;     break;

		;---------------------------------------
		; �p�b�P�[�W�f�[�^�̎擾
		;---------------------------------------
		add		eax, 4							;   EAX  = �擪�̗v�f;
		cdecl	acpi_package_value, eax			;   EAX = �p�b�P�[�W�f�[�^;
		mov		[S5_PACKAGE], eax				;   S5_PACKAGE = EAX;

.10E:											; } while (0);

		;---------------------------------------
		; �y�[�W���O��L����
		;---------------------------------------
		mov		eax, cr0						; // PG�r�b�g���Z�b�g
		or		eax, (1 << 31)					; CR0 |= PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

												; do
												; {
		;---------------------------------------
		; ACPI���W�X�^�̎擾
		;---------------------------------------
		mov		edx, [PM1a_CNT_BLK]				;   EDX = FACP.PM1a_CNT_BLK
		cmp		edx, 0							;   if (0 == EDX)
		je		.20E							;     break;

		;---------------------------------------
		; �J�E���g�_�E���̕\��
		;---------------------------------------
		cdecl	draw_str, 38, 14, 0x020F, .s3	;   draw_str();  // �J�E���g�_�E��...3
		cdecl	wait_tick, 100
		cdecl	draw_str, 38, 14, 0x020F, .s2	;   draw_str();  // �J�E���g�_�E��...2
		cdecl	wait_tick, 100
		cdecl	draw_str, 38, 14, 0x020F, .s1	;   draw_str();  // �J�E���g�_�E��...1
		cdecl	wait_tick, 100

		;---------------------------------------
		; PM1a_CNT_BLK�̐ݒ�
		;---------------------------------------
		movzx	ax, [S5_PACKAGE.0]				;   // PM1a_CNT_BLK
		shl		ax, 10							;   AX  = SLP_TYPx;
		or		ax, 1 << 13						;   AX |= SLP_EN;
		out		dx, ax							;   out(PM1a_CNT_BLK, AX);

		;---------------------------------------
		; PM1b_CNT_BLK�̊m�F
		;---------------------------------------
		mov		edx, [PM1b_CNT_BLK]				;   EDX = FACP.PM1b_CNT_BLK
		cmp		edx, 0							;   if (0 == EDX)
		je		.20E							;     break;

		;---------------------------------------
		; PM1b_CNT_BLK�̐ݒ�
		;---------------------------------------
		movzx	ax, [S5_PACKAGE.1]				;   // PM1b_CNT_BLK
		shl		ax, 10							;   AX  = SLP_TYPx;
		or		ax, 1 << 13						;   AX |= SLP_EN;
		out		dx, ax							;   out(PM1b_CNT_BLK, AX);

.20E:											; } while (0);

		;---------------------------------------
		; �d�f�҂�
		;---------------------------------------
		cdecl	wait_tick, 100					; // 100[ms]�E�F�C�g

		;---------------------------------------
		; �d�f���s���b�Z�[�W
		;---------------------------------------
		cdecl	draw_str, 38, 14, 0x020F, .s4	;         draw_str();  // �d�f���s���b�Z�[�W

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

		ret

.s0:	db	" Power off...   ", 0
.s1:	db	" 1", 0
.s2:	db	" 2", 0
.s3:	db	" 3", 0
.s4:	db	"NG", 0

ALIGN 4, db 0
PM1a_CNT_BLK:	dd	0
PM1b_CNT_BLK:	dd	0
S5_PACKAGE:
.0:				db	0
.1:				db	0
.2:				db	0
.3:				db	0

