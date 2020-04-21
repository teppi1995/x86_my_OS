;************************************************************************
;
;	�J�[�l����
;
;************************************************************************

%define	USE_SYSTEM_CALL
%define	USE_TEST_AND_SET

;************************************************************************
;	�}�N��
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		KERNEL_LOAD						; �J�[�l���̃��[�h�A�h���X

[BITS 32]
;************************************************************************
;	�G���g���|�C���g
;************************************************************************
kernel:
		;---------------------------------------
		; �t�H���g�A�h���X���擾
		;---------------------------------------
		mov		esi, BOOT_LOAD + SECT_SIZE		; ESI   = 0x7C00 + 512
		movzx	eax, word [esi + 0]				; EAX   = [ESI + 0] // �Z�O�����g
		movzx	ebx, word [esi + 2]				; EBX   = [ESI + 2] // �I�t�Z�b�g
		shl		eax, 4							; EAX <<= 4;
		add		eax, ebx						; EAX  += EBX;
		mov		[FONT_ADR], eax					; FONT_ADR[0] = EAX;

		;---------------------------------------
		; TSS�f�B�X�N���v�^�̐ݒ�
		;---------------------------------------
		set_desc	GDT.tss_0, TSS_0			; // �^�X�N0�pTSS�̐ݒ�
		set_desc	GDT.tss_1, TSS_1			; // �^�X�N1�pTSS�̐ݒ�
		set_desc	GDT.tss_2, TSS_2			; // �^�X�N2�pTSS�̐ݒ�
		set_desc	GDT.tss_3, TSS_3			; // �^�X�N3�pTSS�̐ݒ�
		set_desc	GDT.tss_4, TSS_4			; // �^�X�N4�pTSS�̐ݒ�
		set_desc	GDT.tss_5, TSS_5			; // �^�X�N5�pTSS�̐ݒ�
		set_desc	GDT.tss_6, TSS_6			; // �^�X�N6�pTSS�̐ݒ�

		;---------------------------------------
		; �R�[���Q�[�g�̐ݒ�
		;---------------------------------------
		set_gate	GDT.call_gate, call_gate	; // �R�[���Q�[�g�̐ݒ�

		;---------------------------------------
		; LDT�̐ݒ�
		;---------------------------------------
		set_desc	GDT.ldt, LDT, word LDT_LIMIT

		;---------------------------------------
		; GDT�����[�h�i�Đݒ�j
		;---------------------------------------
		lgdt	[GDTR]							; // �O���[�o���f�B�X�N���v�^�e�[�u�������[�h

		;---------------------------------------
		; �X�^�b�N�̐ݒ�
		;---------------------------------------
		mov		esp, SP_TASK_0					; // �^�X�N0�p�̃X�^�b�N��ݒ�

		;---------------------------------------
		; �^�X�N���W�X�^�̏�����
		;---------------------------------------
		mov		ax, SS_TASK_0
		ltr		ax								; // �^�X�N���W�X�^�̐ݒ�

		;---------------------------------------
		; ������
		;---------------------------------------
		cdecl	init_int						; // ���荞�݃x�N�^�̏�����
		cdecl	init_pic						; // ���荞�݃R���g���[���̏�����
		cdecl	init_page						; // �y�[�W���O�̏�����

		set_vect	0x00, int_zero_div			; // ���荞�ݏ����̓o�^�F0���Z
		set_vect	0x07, int_nm				; // ���荞�ݏ����̓o�^�F�f�o�C�X�g�p�s��
		set_vect	0x0E, int_pf				; // ���荞�ݏ����̓o�^�F�y�[�W�t�H���g
		set_vect	0x20, int_timer				; // ���荞�ݏ����̓o�^�F�^�C�}�[
		set_vect	0x21, int_keyboard			; // ���荞�ݏ����̓o�^�FKBC
		set_vect	0x28, int_rtc				; // ���荞�ݏ����̓o�^�FRTC
		set_vect	0x81, trap_gate_81, word 0xEF00	; // �g���b�v�Q�[�g�̓o�^�F1�����o��
		set_vect	0x82, trap_gate_82, word 0xEF00	; // �g���b�v�Q�[�g�̓o�^�F�_�̕`��

		;---------------------------------------
		; �f�o�C�X�̊��荞�݋���
		;---------------------------------------
		cdecl	rtc_int_en, 0x10				; rtc_int_en(UIE); // �X�V�T�C�N���I�����荞�݋���
		cdecl	int_en_timer0					; // �^�C�}�[�i�J�E���^0�j���荞�݋���

		;---------------------------------------
		; IMR(���荞�݃}�X�N���W�X�^)�̐ݒ�
		;---------------------------------------
		outp	0x21, 0b_1111_1000				; // ���荞�ݗL���F�X���[�uPIC/KBC/�^�C�}�[
		outp	0xA1, 0b_1111_1110				; // ���荞�ݗL���FRTC

		;---------------------------------------
		; �y�[�W���O��L����
		;---------------------------------------
		mov		eax, CR3_BASE					;
		mov		cr3, eax						; // �y�[�W�e�[�u���̓o�^

		mov		eax, cr0						; // PG�r�b�g���Z�b�g
		or		eax, (1 << 31)					; CR0 |= PG;
		mov		cr0, eax						; 
		jmp		$ + 2							; FLUSH();

		;---------------------------------------
		; CPU�̊��荞�݋���
		;---------------------------------------
		sti										; // ���荞�݋���

		;---------------------------------------
		; �t�H���g�̈ꗗ�\��
		;---------------------------------------
		cdecl	draw_font, 63, 13				; // �t�H���g�̈ꗗ�\��
		cdecl	draw_color_bar, 63, 4			; // �J���[�o�[�̕\��

		;---------------------------------------
		; ������̕\��
		;---------------------------------------
		cdecl	draw_str, 25, 14, 0x010F, .s0	; draw_str();

.10L:											; while (;;)
												; {
		;---------------------------------------
		; ��]����_��\��
		;---------------------------------------
		cdecl	draw_rotation_bar				;   // ��]����_��\��

		;---------------------------------------
		; �L�[�R�[�h�̎擾
		;---------------------------------------
		cdecl	ring_rd, _KEY_BUFF, .int_key	;   EAX = ring_rd(buff, &int_key);
		cmp		eax, 0							;   if (EAX == 0)
		je		.10E							;   {
												;   
		;---------------------------------------
		; �L�[�R�[�h�̕\��
		;---------------------------------------
		cdecl	draw_key, 2, 29, _KEY_BUFF		;     ring_show(key_buff); // �S�v�f��\��

		;---------------------------------------
		; �L�[�������̏���
		;---------------------------------------
		mov		al, [.int_key]					;     AL = [.int_key]; // �L�[�R�[�h
		cmp		al, 0x02						;     if ('1' == AL)
		jne		.12E							;     {

		;---------------------------------------
		; �t�@�C���ǂݍ���
		;---------------------------------------
		call	[BOOT_LOAD + BOOT_SIZE - 16]	;       // �t�@�C���ǂݍ���

		;---------------------------------------
		; �t�@�C���̓��e��\��
		;---------------------------------------
		mov		esi, 0x7800						;       ESI       = �ǂݍ��ݐ�A�h���X;
		mov		[esi + 32], byte 0				;       [ESI +32] = 0; // �ő�32����
		cdecl	draw_str, 0, 0, 0x0F04, esi		;       draw_str();    // ������̕\��
.12E:											;     }

		;---------------------------------------
		; CTRL+ALD+END�L�[
		;---------------------------------------
		mov		al, [.int_key]					;     AL  = [.int_key]; // �L�[�R�[�h
		cdecl	ctrl_alt_end, eax				;     EAX = ctrl_alt_end(�L�[�R�[�h);
		cmp		eax, 0							;     if (0 != EAX)
		je		.14E							;     {
												;       
		mov		eax, 0							;       // �d�f�����͈�x�����s��
		bts		[.once], eax					;       if (0 == bts(.once))
		jc		.14E							;       {
		cdecl	power_off						;         power_off(); // �d�f����
												;       }
.14E:											;     }
.10E:											;   }
		jmp		.10L							; }

.s0:	db	" Hello, kernel! ", 0

ALIGN 4, db 0
.int_key:	dd	0
.once:		dd	0

ALIGN 4, db 0
FONT_ADR:	dd	0
RTC_TIME:	dd	0

;************************************************************************
;	�^�X�N
;************************************************************************
%include	"descriptor.s"
%include	"modules/paging.s"
%include	"modules/int_timer.s"
%include	"modules/int_pf.s"
%include	"tasks/task_1.s"
%include	"tasks/task_2.s"
%include	"tasks/task_3.s"

;************************************************************************
;	���W���[��
;************************************************************************
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/interrupt.s"
%include	"../modules/protect/pic.s"
%include	"../modules/protect/int_rtc.s"
%include	"../modules/protect/int_keyboard.s"
%include	"../modules/protect/ring_buff.s"
%include	"../modules/protect/timer.s"
%include	"../modules/protect/draw_rotation_bar.s"
%include	"../modules/protect/call_gate.s"
%include	"../modules/protect/trap_gate.s"
%include	"../modules/protect/test_and_set.s"
%include	"../modules/protect/int_nm.s"
%include	"../modules/protect/wait_tick.s"
%include	"../modules/protect/memcpy.s"
%include	"../modules/protect/ctrl_alt_end.s"
%include	"../modules/protect/power_off.s"
%include	"../modules/protect/acpi_find.s"
%include	"../modules/protect/find_rsdt_entry.s"
%include	"../modules/protect/acpi_package_value.s"

;************************************************************************
;	�p�f�B���O
;************************************************************************
		times KERNEL_SIZE - ($ - $$) db 0x00	; �p�f�B���O

;************************************************************************
;	FAT
;************************************************************************
%include	"fat.s"
