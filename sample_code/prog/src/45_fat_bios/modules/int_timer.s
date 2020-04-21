;************************************************************************
;	��O:�^�C�}�[
;************************************************************************
int_timer:
		;---------------------------------------
		; �y���W�X�^�̕ۑ��z
		;---------------------------------------
		pusha
		push	ds
		push	es

		;---------------------------------------
		; �f�[�^�p�Z�O�����g�̐ݒ�
		;---------------------------------------
		mov		ax, 0x0010						; 
		mov		ds, ax							; 
		mov		es, ax							; 

		;---------------------------------------
		; TICK
		;---------------------------------------
		inc		dword [TIMER_COUNT]				; TIMER_COUNT++; // ���荞�݉񐔂̍X�V

		;---------------------------------------
		; ���荞�݃t���O���N���A(EOI)
		;---------------------------------------
		outp	0x20, 0x20						; // �}�X�^PIC:EOI�R�}���h

		;---------------------------------------
		; �^�X�N�̐؂�ւ�
		;---------------------------------------
		str		ax								; AX = TR; // ���݂̃^�X�N���W�X�^
		cmp		ax, SS_TASK_0					; case (AX)
		je		.11L							; {
		cmp		ax, SS_TASK_1					;   
		je		.12L							;   
		cmp		ax, SS_TASK_2					;   
		je		.13L							;   
		cmp		ax, SS_TASK_3					;   
		je		.14L							;   
		cmp		ax, SS_TASK_4					;   
		je		.15L							;   
		cmp		ax, SS_TASK_5					;   
		je		.16L							;   
												;   default:
		jmp		SS_TASK_0:0						;     // �^�X�N0�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.11L:											;   case SS_TASK_0:
		jmp		SS_TASK_1:0						;     // �^�X�N1�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.12L:											;   case SS_TASK_1:
		jmp		SS_TASK_2:0						;     // �^�X�N2�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.13L:											;   case SS_TASK_2:
		jmp		SS_TASK_3:0						;     // �^�X�N3�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.14L:											;   case SS_TASK_3:
		jmp		SS_TASK_4:0						;     // �^�X�N4�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.15L:											;   case SS_TASK_4:
		jmp		SS_TASK_5:0						;     // �^�X�N5�ɐ؂�ւ�
		jmp		.10E							;     break;
												;     
.16L:											;   case SS_TASK_5:
		jmp		SS_TASK_6:0						;     // �^�X�N6�ɐ؂�ւ�
		jmp		.10E							;     break;
.10E:											; }

		;---------------------------------------
		; �y���W�X�^�̕��A�z
		;---------------------------------------
		pop		es								; 
		pop		ds								; 
		popa

		iret

ALIGN 4, db 0
TIMER_COUNT:	dd	0

