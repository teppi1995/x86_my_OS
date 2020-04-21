;************************************************************************
;	�������C���[�W
;************************************************************************

		;---------------------------------------
		;           |            | 
		;           |____________| 
		; 0000_7A00 |            | ( 512) �X�^�b�N
		;           |____________| 
		; 0000_7C00 |            | (  8K) �u�[�g
		;           =            = 
		;           |____________| 
		; 0000_9C00 |            | (  8K) �J�[�l���i�ꎞ�W�J�j
		;           =            = 
		;           |____________| 
		; 0000_BC00 |////////////| 
		;           =            = 
		;           |____________| 
		; 0010_0000 |       (2K) | ���荞�݃f�B�X�N���v�^�e�[�u��
		;           |____________| 
		; 0010_0800 |       (2K) | �J�[�l���X�^�b�N
		;           |____________| 
		; 0010_1000 |       (8K) | �J�[�l���v���O����
		;           |            | 
		;           =            = 
		;           |____________| 
		; 0010_3000 |       (8K) | �^�X�N�p�X�^�b�N
		;           |            | �i�e�^�X�N1K�j
		;           =            = 
		;           |____________| 
		; 0010_5000 |            | Dir
		;      6000 |____________| Page
		; 0010_7000 |            | Dir
		;      8000 |____________| Page
		; 0010_9000 |////////////| 
		;           |            | 

		BOOT_SIZE			equ		(1024 * 8)		; �u�[�g�T�C�Y
		KERNEL_SIZE			equ		(1024 * 8)		; �J�[�l���T�C�Y

		BOOT_LOAD			equ		0x7C00			; �u�[�g�v���O�����̃��[�h�ʒu
		BOOT_END			equ		(BOOT_LOAD + BOOT_SIZE)

		KERNEL_LOAD			equ		0x0010_1000

		SECT_SIZE			equ		(512)			; �Z�N�^�T�C�Y

		BOOT_SECT			equ		(BOOT_SIZE   / SECT_SIZE)	; �u�[�g�v���O�����̃Z�N�^��
		KERNEL_SECT			equ		(KERNEL_SIZE / SECT_SIZE)	; �J�[�l���̃Z�N�^��

		E820_RECORD_SIZE	equ		20

		VECT_BASE			equ		0x0010_0000		;	0010_0000:0010_07FF


		STACK_BASE			equ		0x0010_3000		; �^�X�N�p�X�^�b�N�G���A
		STACK_SIZE			equ		1024			; �X�^�b�N�T�C�Y

		SP_TASK_0			equ		STACK_BASE + (STACK_SIZE * 1)
		SP_TASK_1			equ		STACK_BASE + (STACK_SIZE * 2)
		SP_TASK_2			equ		STACK_BASE + (STACK_SIZE * 3)
		SP_TASK_3			equ		STACK_BASE + (STACK_SIZE * 4)
		SP_TASK_4			equ		STACK_BASE + (STACK_SIZE * 5)
		SP_TASK_5			equ		STACK_BASE + (STACK_SIZE * 6)
		SP_TASK_6			equ		STACK_BASE + (STACK_SIZE * 7)

		CR3_BASE			equ		0x0010_5000		; �y�[�W�ϊ��e�[�u���F�^�X�N3�p

		PARAM_TASK_4		equ		0x0010_8000		; �`��p�����[�^�F�^�X�N4�p
		PARAM_TASK_5		equ		0x0010_9000		; �`��p�����[�^�F�^�X�N5�p
		PARAM_TASK_6		equ		0x0010_A000		; �`��p�����[�^�F�^�X�N6�p

		CR3_TASK_4			equ		0x0020_0000		; �y�[�W�ϊ��e�[�u���F�^�X�N4�p
		CR3_TASK_5			equ		0x0020_2000		; �y�[�W�ϊ��e�[�u���F�^�X�N5�p
		CR3_TASK_6			equ		0x0020_4000		; �y�[�W�ϊ��e�[�u���F�^�X�N6�p


;************************************************************************
;	�f�B�X�N�C���[�W
;************************************************************************
		;(SECT/SUM)  file img                 
		;                       ____________  
		;( 16/  0)   0000_0000 |       (8K) | �u�[�g
		;                      =            = 
		;                      |____________| 
		;( 16/ 16)   0000_2000 |       (8K) | �J�[�l��
		;                      =            = 
		;                      |____________| 
		;(256/ 32)   0000_4000 |     (128K) | FAT-1
		;                      |            | 
		;                      |            | 
		;                      =            = 
		;                      |____________| 
		;(256/288)   0002_4000 |     (128K) | FAT-2
		;                      |            | 
		;                      |            | 
		;                      =            = 
		;                      |____________| 
		;( 32/544)   0004_4000 |      (16K) | ���[�g�f�B���N�g���̈�
		;                      |            | (32�Z�N�^/512�G���g��)
		;                      =            = 
		;                      |____________| 
		;(   /576)   0004_8000 |            | �f�[�^�̈�
		;                      |            | 
		;                      =            = 
		;                      |            | 
		;                      |____________| 
		;(   /640)   0005_0000 |////////////| 
		;                      |            | 

		FAT_SIZE			equ		(1024 * 128)	; FAT-1/2
		ROOT_SIZE			equ		(1024 *  16)	; ���[�g�f�B���N�g���̈�

		ENTRY_SIZE			equ		32				; �G���g���T�C�Y

		; BOOT �C���[�W�͈قȂ�t�@�C���Ȃ̂ŁAFAT �A�h���X�̒�`�ɂ͉��Z���Ȃ�
		FAT_OFFSET			equ		(BOOT_SIZE + KERNEL_SIZE)
		FAT1_START			equ		(KERNEL_SIZE)
		FAT2_START			equ		(FAT1_START + FAT_SIZE)
		ROOT_START			equ		(FAT2_START + FAT_SIZE)
		FILE_START			equ		(ROOT_START + ROOT_SIZE)

		; �t�@�C������
		ATTR_READ_ONLY		equ		0x01
		ATTR_HIDDEN			equ		0x02
		ATTR_SYSTEM			equ		0x04
		ATTR_VOLUME_ID		equ		0x08
		ATTR_DIRECTORY		equ		0x10
		ATTR_ARCHIVE		equ		0x20

