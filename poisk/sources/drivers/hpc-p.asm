;  * Debug Version For Home Computer POISK  - 2.0 *
;ver 26.02.90
;****** ������� ������ (96�) ******
INCLUDE EQU.ASM       ;����⠭�� � ��६����
;--------------------------------------------------------------------------
; ����⠭��
;-----------------------------------------------------------------------------
;  ���४樨:
;     14.02.89 - ��६����� SCAN_CODE_OLD
;-----------------------------------------------------------------------------
FALSE           EQU        0
TRUE            EQU        NOT FALSE
FIRST_TIME      EQU        8
SECOND_TIME     EQU        2
DATA_ORG        EQU        80H
KEY_INT         EQU        9
CURSOR_TIME     EQU        4
PORT_A          EQU        60H         ;���� ���� � 8255
PORT_B          EQU        61H         ;���� ���� B 8255
PORT_C		EQU        62H	       ;���� ���� C 8255
INTA00          EQU        20H         ;���� 8259
INTA01          EQU        21H         ;���� 8259
EOI             EQU        20H
TIMER           EQU        40H
TIM_CTL         EQU        43H         ;���� ���� �ࠢ����� ⠩��஬ 8253
TIMER0          EQU        40H         ;���� ���� ���稪�/⠩��� 0  8253
TMINT           EQU        01          ;��᪠ ���뢠��� ⠩��� 0
MOTOR_TURN_BIT  EQU	   04H
KBD_IN          EQU        60H         ;���� ���� ����� ������ ����������
BDINT           EQU        02          ;��᪠ ���뢠��� ����������
KB_DATA         EQU        60H         ;���� ᪠������ ����������
KB_CTL          EQU        61H         ;��ࠢ���騥 ���� ����������
;----------------------------------------------------------------------------
; ��।������ ���� 8255 ��� PPI_TRAP ��� PPI_KBD
;----------------------------------------------------------------------------
TRAP_A		EQU	28H		;
TRAP_D		EQU	2AH		;
SCR_MODE        EQU     68H             ;���� ०���
P61		EQU	61H
P6A             EQU     6AH             ;PORT SET COLOR!!!!!!!!!!!!!!!!!!!!!!!!
P62             EQU     62H
PPIC		EQU	63H		;���� ०��� PPI_TRAP
;
LINE_SEL	EQU	60H		;�롮� ��ப� ��� ��࠭���� ᪠����
COL_READ	EQU	69H		;�⥭�� ������� KBD
KEY_SERV_MODE	EQU	6BH		;���� ०��� PPI_KBD
;----------------------------------------------------------------------------
; ���� ���뢠��� �1810 ��88
;----------------------------------------------------------------------------
ABS0   SEGMENT         AT 0
STG_LOC0               LABEL     BYTE
       ORG             2*4
NMI_PTR                LABEL     WORD
       ORG             5*4
INT5_PTR               LABEL     WORD
       ORG             8*4
INT_ADDR               LABEL     WORD
INT_PTR                LABEL     DWORD
       ORG             10H*4
VIDEO_INT              LABEL     WORD
       ORG             1DH*4
PARM_PTR               LABEL     DWORD       ;�����⥫� ��ࠬ��஢ �����
       ORG             01EH*4                ;�����⥫� ��ࠬ��஢ ��᪠
DISK_POINTER           LABEL     DWORD
       ORG             01FH*4                ;��ᯮ������� ������������
EXT_PTR                LABEL     DWORD       ;��� ����᪮�� ०���
       ORG             7C00H
BOOT_LOCN              LABEL     FAR
ABS0   ENDS
;-----------------------------------------------------------------------------
; �⥪ - �ᯮ������ ⮫쪮 �� �६� ���樠����樨
;------------------------------------------------------------------------------
STOCK  SEGMENT         AT  30H
       DW              128 DUP(?)
TOS    LABEL           WORD
STOCK  ENDS
;-----------------------------------------------------------------------------
; ������ ������ ��� ��� BIOS
;------------------------------------------------------------------------------
DATA   SEGMENT         AT  40H
RS232_BASE             DW     4 DUP(?)     ;���� ���⮢ �����஢ RS232
PRINTER_BASE           DW     4 DUP(?)     ;���� ���⮢ �ਭ�஢
EQUIP_FLAG             DW     ?            ;��⠭�������� ����㤮�����
                                           ;              (��������)
MFG_TST                DB     ?            ;���� ���樠����樨
MEMORY_SIZE            DW     ?            ;������ ����� � ������
IO_RAM_SIZE            DW     ?            ;������ ����� ������ �����-�뢮��
;-----------------------------------------------------------------------------
; ������� ������ ����������
;------------------------------------------------------------------------------
KB_FLAG                DB     ?
;------��ᯮ������� 䫠��� SHIFT ����� ��६����� KB_FLAG
INS_STATE              EQU    80H          ;����ﭨ� ��⠢�� (INS)
CAPS_STATE             EQU    40H          ;����� ������ ����.���� (CAPS)
NUM_STATE              EQU    20H          ;����� ������ ����� (NUM)
SCROLL_STATE           EQU    10H          ;����� ������ ᢥ�⪨
ALT_SHIFT              EQU    08H          ;����� ������ ���(ALT)
CTL_SHIFT              EQU    04H          ;����� ������ ��� (CTL)
LEFT_SHIFT             EQU    02H          ;����� ������ ���� (᫥��)
RIGHT_SHIFT            EQU    01H          ;����� ������ ���� (�ࠢ�)
KB_FLAG_1              DB     ?            ;��ன ���� ���ﭨ� ����������
INS_SHIFT              EQU    80H          ;����� ������ ��⠢�� (INS)
CAPS_SHIFT             EQU    40H          ;����� ������ ����.���� (CAPS)
NUM_SHIFT              EQU    20H          ;����� ������ ����� (NUM)
SCROLL_SHIFT           EQU    10H          ;����� ������ ᢥ�⪨
HOLD_STATE             EQU    08H          ;����প� ������ ������
ALT_INPUT              DB     ?            ;�祩�� ��� ����� ALT
BUFFER_HEAD            DW     ?            ;�����⥫� ���設� ���� ����������
BUFFER_TAIL            DW     ?            ;�����⥫� ��砫� ���� ����������
KB_BUFFER              DW     16 DUP(?)    ;������� ��� 15-� ������ � ����
KB_BUFFER_END          LABEL  WORD         ;����� ���� ����������
;-----���設�=��砫� �����뢠��, �� ���� ����
NUM_KEY                EQU    69           ;��� ᪠��஢���� ������ �����
SCROLL_KEY             EQU    70           ;��� ᪠��஢���� ������ ᢥ�⪨
ALT_KEY                EQU    56           ;��� ᪠��஢���� ������ ���
CTL_KEY                EQU    29           ;��� ᪠��஢���� ������ ���
CAPS_KEY               EQU    58           ;��� ᪠��஢���� ������ ���.����
LEFT_KEY               EQU    42           ;SCAN-��� ����� ������ ����
RIGHT_KEY              EQU    54           ;SCAN-��� �ࠢ�� ������ ����
INS_KEY                EQU    82           ;SCAN-��� ������ ��⠢��
DEL_KEY                EQU    83           ;SCAN-��� ������ 㤠�����
RUS_KEY                EQU    91           ;SCAN-��� ������ ���/���
SHIFT2_KEY             EQU    92           ;SCAN-��� ������ SHIFT2
;----------------------------------------------------------------------------
; ������ ������ ����
;----------------------------------------------------------------------------
SEEK_STATUS            DB     ?             ;����ﭨ� ��४����஢��
;                                           ���� 3-0= ���ன�⢮ �㦤�����
;                                           � ��४����஢�� ��। ᫥���饩
;                                           鯥�樥� ���᪠, �᫨ ���=0
INT_FLAG               EQU    080H          ;���� �����㦥��� ���뢠���
MOTOR_STATUS           DB     ?             ;����ﭨ� �����⥫�
;                             ���� 3-0 = ���ன�⢮ 3-0 ࠡ�⠥�
;                             ��� 7 = ⥪��� ������ - ������,
;                             ����প� �⢥� ����
MOTOR_WAIT             EQU    37            ;���稪 ����প� (2ᥪ) ���
;                                            ����᪠ �����⥫�
MOTOR_COUNT     	DB	?           ;���稪 �६��� ����᪠
;
DISKETTE_STATUS        DB     ?             ;���� ���� ������
;                                      ����� ���ﭨ� ����஫��� ���� (7����)
NEC_STATUS		LABEL BYTE      	;7 BYTE
TRACK_PTR              DB     2 DUP(?)
STEP_MULT              DB     ?
			DB	4 DUP (?)	;�����
;-----------------------------------------------------------------------
;--------------------------
; ���⠪�� ��� �����
;--------------------------
;                    !/��᮪�� ࠧ�襭��
;                    !!/��⨢��� ��࠭�� �����
;                    !!!/���⮢�� ������
;                    !!!!/��� �������
;                    !!!!!/��� ࠧ�襭�� NMI
CHAR_40_MODE   EQU   01000000B
CHAR_80_MODE   EQU   11000000B
MED_RES_MODE   EQU   00101000B
HIGH_RES_MODE  EQU   10001000B
CRT_MODE_PORT  EQU   3DEH              ;���� ⥪�饣� ०��� �⮡ࠦ����
START_BUFFER   EQU   0B800H            ;��砫� ����
EXTRA_BUFFER   EQU   START_BUFFER+400h ;����� ���� (16�)
REG3D4         EQU   3D4H
REG3D5         EQU   3D5H
REG3D8         EQU   3D8H
REG3D9         EQU   3D9h
REG3DA         EQU   3DAH
REG3DE         EQU   3DEH
DSEGMENT       EQU   40h
INT_VIDEO      EQU   10H
;---------------------------------------------------------------------------
;  ������� ������ �����
;--------------------------------------------------------------------------
CRT_MODE      DB      ?       ;����騩 ०�� �⮡ࠦ����
CRT_COLS      DW      ?       ;��᫮ ������� �࠭�
CRT_LEN       DW      ?       ;����� ���������� � �����
CRT_START     DW      ?       ;��砫�� ���� ���������
CURSOR_POSN   DW      8 DUP(?);����� ��� ������ �� 8-�� ��࠭��
CURSOR_MODE   DW      ?       ;����騩 ०�� �����
ACTIVE_PAGE   DB      ?       ;������ �⮡ࠦ����� ��࠭��
ADDR_6845     DW      ?
CRT_MODE_SET  DB      ?       ;����饥 �����祭�� ��� 3x8 ॣ���஢
CRT_PALLETTE  DB      ?       ;������ ������ ��� 梥⭮� ��䨪�
;----------------------------------------------------------------------------
;  ������� ������ ����⭮�� ������䮭�
;----------------------------------------------------------------------------
EDGE_CNT               DW      ?             ;���稪 ���⥫쭮�� ���� ������
CRC_REG                DW      ?             ;������� CRC
;----------------------------------------------------------------------------
INTR_FLAG              DB      ?             ;���� ���뢠���
;----------------------------------------------------------------------------
;  ������� ������ ⠩���
;----------------------------------------------------------------------------
TIMER_LOW              DW       ?            ;��. ᫮�� ���稪� ⠩���
TIMER_HIGH             DW       ?            ;��. ᫮�� ���稪� ⠩���
TIMER_OFL              DB       ?            ;�ਧ��� 横�� ⠩���
                                             ;��᫥ ��᫥����� �⥭��
;COUNTS_SEC            EQU      18
;COUNTS_MIN            EQU      1092
;COUNTS_HOUR           EQU      65543
;COUNTS_DAY            EQU      1573040=1800B0H
;-----------------------------------------------------------------------------
; ������� ��⥬��� ������
;-----------------------------------------------------------------------------
BIOS_BREAK             DB        ?            ;��� 7=1 �᫨ ������
;                                              ���᪠����
RESET_FLAG             DW        ?            ;�����=1234H �᫨ ���
;                                              �� ����������
;------------ ��६����� INT15H ----------------------------------------------
LOWLIM		DW	?		;MIN ����. ������� "1"
;
ORG DATA_ORG
;
;--------�������⥫쭠� ������� �����-----------------------------------------
;
CURSOR_COUNT           DB        ?
;                                             ����
CRT_MODE_SAFE DB      ?       ;����騩 ०�� �⮡ࠦ����
CURSOR_ON     DB      ?       ;���� ��⠭���� �����
CRT_STATUS    DB      ?
REG_6845      DB      ?
CURSOR_POS_L  DB      ?
CURSOR_POS_H  DB      ?
;
;--------������� ������ ���樨 ����������-----------------------------------
;
KB_STAT_L     EQU     8     ; ������⢮ ����� � ����� ����������
KB_STAT_C     EQU     800H  ; ��� ���襩 ������� (������ � �����)
KB_STAT_S     EQU     80H   ; ��� ���襩 �����
KB_KEY        EQU     96    ; ������⢮ ������
KB_L_KEY      EQU     12    ; ������⢮ �����
KB_STAT       DW      KB_STAT_L DUP (?) ; ���ﭨ� ���������� �� ����� )
RUSS          DB      ?     ; �ਧ��� ������ TRUE ��� FALSE
FBEEP         DB      ?     ; �ਧ��� ������ TRUE ��� FALSE
TIME          DB      ?     ; ������⢮ ⨪�� �� ����७�� ���� ������
LAST          DW      ?     ; ���� ��᫥���� ����⮩ ������
                            ; 00 - ��� ������ ��� ����७��
EMPTY	      DW      ?     ; ���ﭨ� ���������� ��᫥ ��᫥�����
                            ; ���� (��⥣ࠫ쭠� �業��: �����/ �� �����)
                            ; 00 - ����� ���������
                            ; ��㣮� ��� - �� ����� ���������
W_SCAN        DB      ?     ; ࠡ�⠥� ᪠��஢���� ���������
; SHIFT1        DB      ?
SHIFT2        DB      ?
MEM_KEY       DB      15 DUP (?)  ; ������ ����⨩ �ᮡ�� ������
                            ;   ( � �६� ᪠�-������ )
SCAN_CODE_OLD DB      ?     ; ��᫥���� ᪠�_��� �� ���� 60H
;------------- ��� 䠩�� ��� ����⭮�� ������䮭� -----------------------
LOAD_ADDR               DW       ?
BUFFERM         DB      8 DUP (?)
LAST_VAL        DB      ?        ;��᫥���� ��������� ���祭��
K_CICL          DB      ?
T_CURSOR        DB      ?
DATA   ENDS
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;  ������� �������⥫��� ������
;----------------------------------------------------------------------------
XXDATA  SEGMENT         AT       50H
STATUS_BYTE             DB       ?
                        ORG      6
;ADDR_MON                DW       ?
XXDATA ENDS
;-----------------------------------------------------------------------------
; ���������
;-----------------------------------------------------------------------------
VIDEO_RAM               SEGMENT AT 0B800H
REGEN   LABEL           BYTE
REGENW  LABEL           WORD
        DB              16384 DUP(?)
VIDEO_RAM   ENDS
VECTOR  SEGMENT AT 0F000H
        ASSUME CS:VECTOR
        ORG    0E016H
RESETV  LABEL   FAR
VECTOR  ENDS
hard    segment at 5400h
	assume cs:hard
	org    0h
hd	label    far
hard    ends
INT13   SEGMENT AT 0E000H
        ASSUME CS:INT13
        ORG    40H
INT13_SERVICE	LABEL	FAR
INT13   ENDS
KARTR   SEGMENT AT 0C000H           ;������� ����� ����ਤ��
        ASSUME CS:KARTR
        ORG    0000H
KARTRIDJ	LABEL	FAR
KARTR   ENDS
BOOTM   SEGMENT AT 60H
        ASSUME CS:BOOTM
        ORG    0000H
BOOT_SM LABEL	FAR
BOOTM   ENDS
;----------------------------------------------------------------------------
;  ���� ���
;----------------------------------------------------------------------------
CODE    SEGMENT
        ORG    0E000H
DB             'POISK (C) 1989 UkSSR  '  ;��⪠ ���
INCLUDE TEST.ASM      ;��砫�� ��� � ���樠������
;---------------------------------------------------------------------------
; ��砫�� ���-�ணࠬ��, ���樠������
;---------------------------------------------------------------------------
        ASSUME  CS:CODE, DS:DATA
RESET   LABEL   NEAR
START:  CLI                          ;��窠 �室� � BIOS (�� ����,
                                     ;�� ����祭�� ��⠭��)
        IN      AL,TRAP_A            ;���� �ਣ��� NMI
        MOV     AL,89H               ;��⠭���� ०��� 8255 (TRAP)
        OUT     PPIC,AL
        MOV     AL,88H               ;��⠭���� ०���
        OUT     SCR_MODE,AL
        IN      AL,TRAP_A            ;���� �ਣ��� NMI
        MOV     AL,83H               ;��⠭���� ०��� 8255 (KBD)
        OUT     KEY_SERV_MODE,AL     ;��⠭���� ०��� ����������
; ��।�� �ࠢ����� �ਢ�����஢������ ���, �᫨ ��� ����
        MOV     AX,0C000H
        SUB     BX,BX
        MOV     DS,AX
        CMP     DS:[BX],055AAH
        JNZ     ST0
        JMP     KARTRIDJ+3
ST0:    SUB     AX,AX
        MOV     ES,AX                ;�������=0
        XOR     DI,DI
        MOV     CX,0FFFFH
        CLD                          ;���⪠ ������ �����=64�
        REP     STOSB
        MOV     CX,0800H
        MOV     ES,CX
        MOV     DI,8000H
        MOV     CX,DI
        CLD
        REP     STOSB
        MOV     ES,AX                ;�������=0
        XOR     DI,DI
        MOV     CX,0FFFFH
        CLD                          ;���⪠ ������ �����=64�
        REP     SCASB
        CMP     CX,0
        JZ      CLR1
        HLT
CLR1:   MOV     CX,0800H
        MOV     ES,CX
        MOV     DI,8000H
        MOV     CX,DI
        CLD
        REP     SCASB
        CMP     CX,0
        JZ      CLR2
	MOV	DX,04
	CALL	BEEP_ERROR
        HLT
CLR2:
        MOV     ES,AX
	MOV	SS,AX
	MOV	SP,03FFH
        PUSH    CS                   ;��⠭���� ⠡���� ���뢠���:
        PUSH    CS
        POP     BX
        POP     DS
        MOV     CX,1EH               ;��⠭���� ���稪� ����஢
        MOV     SI,OFFSET VECTOR_TABLE      ;���饭�� ⠡���� ����஢
        MOV     DI,OFFSET INT5_PTR
SM0:    LODSW                        ;����뫪� ⠡���� ����஢
        STOSW                        ;(���� ���㦨����� ���뢠���)
        MOV     AX,BX
        STOSW
        LOOP    SM0
        MOV     DI,8
        MOV     AX,OFFSET NMI_SERVICE ;���뫪� ����� NMI
        STOSW
        MOV     AX,BX
        STOSW
        MOV     AX,DATA
        MOV     ES,AX
        MOV     CX,10H               ;������ TEST_TABLIC
        MOV     SI,OFFSET TEST_TABLIC ;(������ ���䨣��樨)
        MOV     DI,OFFSET RS232_BASE
        REP     MOVSW
	SUB	AX,AX
IX0:    ADD     AX,4000H
	PUSH	AX
	MOV	DS,AX
	SUB	BX,BX
	MOV	AX,5AA5H
	MOV	[BX],AX
	NOT	AX
	NOT	WORD PTR [BX]
	CMP	WORD PTR [BX],AX
	POP	AX
	PUSH	ES
	POP	DS
	JNZ	IX1
	ADD	MEMORY_SIZE+1,1
	JMP	IX0
IX1:    MOV     MOTOR_STATUS,1
    ;;; MOV     EMPTY,0            ; ��������� �����
        MOV     FBEEP,TRUE
    ;;;	MOV	RUSS,FALSE
    ;;; MOV     SHIFT1,LEFT_KEY    ; ������ �⦠�
        MOV     AL,13H                ;��⠭����� ०�� 8259
        OUT     INTA00,AL             ;����஫��� ���뢠���
        MOV     AL,8
        OUT     INTA01,AL
        MOV     AL,9
        OUT     INTA01,AL
        MOV     AL,36H               ;��⠭����� ०�� 8253
        OUT     TIM_CTL,AL           ;������
        XOR     AL,AL
        OUT     TIMER0,AL            ;����� 0
        OUT     TIMER0,AL
        MOV     AL,76H
        OUT     TIM_CTL,AL
        XOR     AL,AL
        OUT     TIMER0+1,AL          ;����� 1
        OUT     TIMER0+1,AL
; ��⠭���� ०��� VIDEO
        MOV     AX,0003H
        INT     10H
; ���� BIOS
        PUSH    DS
        PUSH    CS
        POP     DS
        MOV     BX,0E000H
        MOV     CX,2000H
        CALL    ROS_CHECKSUM         ;�஢�ઠ ����஫쭮� �㬬�
        JZ      IX2
        MOV     DX,3
        CALL    BEEP_ERROR
        HLT
; ��⠭���� ��砫��� ���祭�� ��᪮��� ��६�����
IX2:    POP     DS
        MOV     BYTE PTR TRACK_PTR,0H
        MOV     BYTE PTR TRACK_PTR+1,0H
;���������� ��砫쭮�� ���祭�� ���� ����㧪�
        MOV     WORD PTR LOAD_ADDR,0060H
        STI                          ;������� ���뢠���
; �뤠�� ���⠢��
; �஢�ઠ � ���樠������ ��� � ����।���
        MOV     DX,0C000H
ROM_CH0:
        MOV     DS,DX
        SUB     BX,BX
        CMP     [BX],0AA55H
        JNE     ROM_CH1
        CALL    ROM_INIT
ROM_CH1:
        ADD     DX,20H
        CMP     DX,0FE00H
        JL      ROM_CH0
SYS_BOOT:
        PUSH    DS
        INT     19H                  ;����㧪� ��⥬�
        POP     DS
        INT     18H                  ;��।�� �ࠢ����� ���
                                     ;��� ࠡ�� � ����⮩
INCLUDE MONN.ASM      ;������
MONITOR      PROC    FAR
        JMP    M0
MONITOR      ENDP
;
;---------------------------------------------
;   ��������� ������ - 40*25 �������
;---------------------------------------------
M0:
        SUB     AX,AX
	MOV	SS,AX
	MOV	SP,03FFH
        mov    ax,01
        int    10h
;---------------------------------------------
;        �뢮� ������� ����
;---------------------------------------------
MX0:    lea    si,s0
	mov	cx,LS0
        call   P_MSG
mX1:    call   read_char   ;����� ������
        cmp    AH,3BH      ;������ � ��������?
        JZ     READ_CAS    ;��
        cmp    AH,3CH      ;������ � ���
        JNZ    MX1         ;���
        PUSH   DS
        MOV    AX,KARTR    ;(DS) - ������� ���������
        MOV    BX,0
        MOV    DS,AX
;�������� ����� (������ ���� = E9�)
        MOV    AL,BYTE PTR DS:[BX]
        CMP    AL,0E9H
        POP    DS
        JNZ    MX0          ;����� ���
	MOV	AX,2
	INT	10H
        JMP     KARTRIDJ
;---------------------------------------------
;      ����㧪� 䠩�� � ������
;---------------------------------------------
READ_CAS:
        ASSUME DS:DATA
        MOV    AX,DATA
        MOV    DS,AX
	mov    AX,LOAD_ADDR   ;��������� ������� ��������
        mov    es,ax
        CALL   READ_NAME   ;����� ����� �����
        LEA    si,SW5
        MOV    cx,LSW5
          CALL    P_MSG       ;����������� ����������
RC4:      CALL    READ_CHAR   ;����� ������
          CMP     AL,13       ;�����?
          JNZ     RC4         ;���
          PUSH    ES
          LEA     BX,BUFFERM
          MOV     AH,4
          INT     15H
          JC      RCERROR
          lea     si,sX12
          MOV     cx,LSX12
          call    P_MSG      ;����᪠��?
          call    read_char
          call    wr_1_char
          cmp     al,'N'
          jz      RC5
          cmp     al,'n'
          jz      RC5
          cmp     al,'�'
	  jz	  rc5
	  cmp	  al,'�'
          jz      rc5
          MOV     AX,0
          PUSH    AX
          DB      0CBH         ;(RETF) �������� ���������� ����������� ���������
RC5:      JMP     M0           ;������ � ������
rcerror:
          lea     si,sX2
          mov     cx,LSX2   ;---------------------
          call    P_MSG
          call    read_char
	  JMP	  MX0
;        �/� ����� ����� �����
;---------------------------------------------
READ_NAME:
       LEA   si,SW2
       MOV   cx,LSW2
       CALL  P_MSG
       MOV   SI,0
RN1:   MOV   BUFFERM[SI],' '
       INC   SI
       CMP   SI,8
       JNZ   RN1
       MOV   SI,0
RN2:   CALL  READ_CHAR
       CMP   AL,13
       JZ    RN3
       CMP   AL,1BH
       JZ    READ_NAME
       CMP   AL,20H
       JB    RN2
       CALL  WR_1_CHAR
       MOV   BUFFERM[SI],AL
       INC   SI
       CMP   SI,8
       JNZ   RN2
RN3:   RET
wr_1_char    proc
        push   cx
        PUSH   BX
        PUSH   DX
        MOV    AH,14
        INT    10H
        POP    DX
        POP    BX
        pop    cx
        ret
wr_1_char    endp
;�⥭�� ���������� ᨬ����
read_char    proc   near
        mov    ah,0
        int    16h
r_ret:  ret
read_char    endp
;����饭�� ������
s0:     db    13,10,0F6H,' "�����" ',0F7H,13,10
        db    13,10
s01:    db    'F1 - ����� � ����⮩',13,10,13,10
s03:    db    'F2 - ����� � ���',13,10,13,10
S05:    DB    '�롥�� �����'
LS05	= $ - OFFSET S05
LS0     = $ - OFFSET S0
sX12:   db    13,10,'����᪠��?'
LSX12	= $ - OFFSET SX12
sX2:    db    13,10,'�訡�� �⥭�� ***',13,10
LSX2	= $ - OFFSET SX2
SW2:    DB    13,10,'������ ��� 䠩��:'
LSW2	= $ - OFFSET SW2
SW5:    DB    13,10,'���.  ������䮭, ������ (BK)'
LSW5	= $ - OFFSET SW5
fn:     db    13,10,'���� ������!',13,10
LFN	= $ - OFFSET FN
INCLUDE ALTTAB.ASM    ; ������ ����ୠ⨢��� ����� 128 - 256
; ������ ����ୠ⨢��� ����� 128 - 256
ALTC:   DB      007H,00FH,01BH,033H,07FH,063H,063H,000H ;�
        DB      07EH,060H,060H,07EH,063H,063H,07EH,000H ;�
        DB      07CH,066H,066H,07EH,063H,063H,07EH,000H ;�
        DB      07EH,060H,060H,060H,060H,060H,060H,000H ;�
        DB      03EH,036H,036H,036H,036H,036H,07FH,063H ;�
        DB      07EH,060H,060H,07CH,060H,060H,07FH,000H ;�
        DB      06BH,06BH,03EH,008H,03EH,06BH,06BH,000H ;�
        DB      01EH,033H,003H,01EH,003H,063H,03EH,000H ;�
        DB      063H,063H,067H,06FH,07BH,073H,063H,000H ;�
        DB      06BH,063H,067H,06FH,07BH,073H,063H,000H ;�
        DB      063H,066H,06CH,07CH,066H,063H,063H,000H ;�
        DB      003H,007H,00FH,01BH,033H,063H,063H,000H ;�
        DB      063H,077H,07FH,06BH,063H,063H,063H,000H ;�
        DB      063H,063H,063H,07FH,063H,063H,063H,000H ;�
        DB      03EH,063H,063H,063H,063H,063H,03EH,000H ;�
        DB      07FH,063H,063H,063H,063H,063H,063H,000H ;�
        DB      07EH,063H,063H,07EH,060H,060H,060H,000H ;�
        DB      03EH,063H,060H,060H,060H,063H,03EH,000H ;�
        DB      07EH,018H,018H,018H,018H,018H,018H,000H ;�
        DB      063H,063H,063H,03FH,003H,063H,03EH,000H ;�
        DB      008H,03EH,06BH,06BH,06BH,03EH,008H,000H ;�
        DB      063H,036H,01CH,008H,01CH,036H,063H,000H ;�
        DB      066H,066H,066H,066H,066H,066H,07FH,003H ;�
        DB      063H,063H,063H,03FH,003H,003H,003H,000H ;�
        DB      06BH,06BH,06BH,06BH,06BH,06BH,07FH,000H ;�
        DB      06BH,06BH,06BH,06BH,06BH,06BH,07FH,001H ;�
        DB      078H,018H,018H,01EH,01BH,01BH,01EH,000H ;�
        DB      061H,061H,061H,079H,06DH,06DH,079H,000H ;�
        DB      060H,060H,060H,07EH,063H,063H,07EH,000H ;�
        DB      03EH,063H,003H,00FH,003H,063H,03EH,000H ;�
        DB      04EH,05BH,05BH,07BH,05BH,05BH,04EH,000H ;�
        DB      03FH,063H,063H,03FH,01BH,033H,063H,000H ;�
        DB      000H,000H,03CH,006H,03EH,066H,03FH,000H ;�
        DB      002H,03CH,060H,07CH,066H,066H,03CH,000H ;�
        DB      000H,000H,07CH,066H,07CH,063H,07EH,000H ;�
        DB      000H,000H,07EH,060H,060H,060H,060H,000H ;�
        DB      000H,000H,03EH,036H,036H,036H,07FH,063H ;�
        DB      000H,000H,03CH,066H,07EH,060H,03EH,000H ;�
        DB      000H,000H,06BH,03EH,008H,03EH,06BH,000H ;�
        DB      000H,000H,03CH,066H,00CH,066H,03CH,000H ;�
        DB      000H,000H,066H,066H,06EH,076H,066H,000H ;�
        DB      018H,000H,066H,066H,06EH,076H,066H,000H ;�
        DB      000H,000H,066H,06CH,078H,066H,066H,000H ;�
        DB      000H,000H,007H,00FH,01BH,033H,063H,000H ;�
        DB      000H,000H,063H,077H,06BH,063H,063H,000H ;�
        DB      000H,000H,066H,066H,07EH,066H,066H,000H ;�
        DB      000H,000H,03CH,066H,066H,066H,03CH,000H ;�
        DB      000H,000H,07EH,066H,066H,066H,066H,000H ;�
        DB      022H,088H,022H,088H,022H,088H,022H,088H ;�
        DB      055H,0AAH,055H,0AAH,055H,0AAH,055H,0AAH ;�
        DB      0DBH,077H,0DBH,0EEH,0DBH,077H,0DBH,0EEH ;�
        DB      018H,018H,018H,018H,018H,018H,018H,018H ;�
        DB      010H,010H,010H,010H,0F0H,010H,010H,010H ;�
        DB      010H,010H,0F0H,010H,0F0H,010H,010H,010H ;�
        DB      014H,014H,014H,014H,0F4H,014H,014H,014H ;�
        DB      000H,000H,000H,000H,0FCH,014H,014H,014H ;�
        DB      000H,000H,0F0H,010H,0F0H,010H,010H,010H ;�
        DB      014H,014H,0F4H,004H,0F4H,014H,014H,014H ;�
        DB      036H,036H,036H,036H,036H,036H,036H,036H ;�
        DB      000H,000H,0FEH,006H,0F6H,036H,036H,036H ;�
        DB      036H,036H,0F6H,006H,0FEH,000H,000H,000H ;�
        DB      014H,014H,014H,014H,0FCH,000H,000H,000H ;�
        DB      010H,010H,0F0H,010H,0F0H,000H,000H,000H ;�
        DB      000H,000H,000H,000H,0F8H,018H,018H,018H ;�
        DB      018H,018H,018H,018H,01FH,000H,000H,000H ;�
        DB      018H,018H,018H,018H,0FFH,000H,000H,000H ;�
        DB      000H,000H,000H,000H,0FFH,018H,018H,018H ;�
        DB      018H,018H,018H,018H,01FH,018H,018H,018H ;�
        DB      000H,000H,000H,000H,0FFH,000H,000H,000H ;�
        DB      018H,018H,018H,018H,0FFH,018H,018H,018H ;�
        DB      010H,010H,01FH,010H,01FH,010H,010H,010H ;�
        DB      014H,014H,014H,014H,017H,014H,014H,014H ;�
        DB      036H,036H,037H,030H,03FH,000H,000H,000H ;�
        DB      000H,000H,03FH,030H,037H,036H,036H,036H ;�
        DB      036H,036H,0F7H,000H,0FFH,000H,000H,000H ;�
        DB      000H,000H,0FFH,000H,0F7H,036H,036H,036H ;�
        DB      036H,036H,037H,030H,037H,036H,036H,036H ;�
        DB      000H,000H,0FFH,000H,0FFH,000H,000H,000H ;�
        DB      036H,036H,0F7H,000H,0F7H,036H,036H,036H ;�
        DB      010H,010H,0FFH,000H,0FFH,000H,000H,000H ;�
        DB      014H,014H,014H,014H,0FFH,000H,000H,000H ;�
        DB      000H,000H,0FFH,000H,0FFH,010H,010H,010H ;�
        DB      000H,000H,000H,000H,0FFH,014H,014H,014H ;�
        DB      014H,014H,014H,014H,01FH,000H,000H,000H ;�
        DB      010H,010H,01FH,010H,01FH,000H,000H,000H ;�
        DB      000H,000H,01FH,010H,01FH,010H,010H,010H ;�
        DB      000H,000H,000H,000H,01FH,014H,014H,014H ;�
        DB      014H,014H,014H,014H,0FFH,014H,014H,014H ;�
        DB      010H,010H,0FFH,010H,0FFH,010H,010H,010H ;�
        DB      018H,018H,018H,018H,0F8H,000H,000H,000H ;�
        DB      000H,000H,000H,000H,01FH,018H,018H,018H ;�
        DB      0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH,0FFH ;�
        DB      000H,000H,000H,000H,0FFH,0FFH,0FFH,0FFH ;�
        DB      0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H,0F0H ;�
        DB      00FH,00FH,00FH,00FH,00FH,00FH,00FH,00FH ;�
        DB      0FFH,0FFH,0FFH,0FFH,000H,000H,000H,000H ;�
        DB      000H,000H,07CH,066H,066H,07CH,060H,060H ;�
        DB      000H,000H,03CH,066H,060H,066H,03CH,000H ;�
        DB      000H,000H,07EH,018H,018H,018H,018H,000H ;�
        DB      000H,000H,066H,066H,03EH,006H,066H,03CH ;�
        DB      000H,008H,03EH,06BH,06BH,03EH,008H,008H ;�
        DB      000H,000H,063H,036H,01CH,036H,063H,000H ;�
        DB      000H,000H,066H,066H,066H,066H,07FH,003H ;�
        DB      000H,000H,066H,066H,03EH,006H,006H,000H ;�
        DB      000H,000H,06BH,06BH,06BH,06BH,07FH,000H ;�
        DB      000H,000H,06BH,06BH,06BH,06BH,07FH,001H ;�
        DB      000H,000H,078H,018H,01EH,01BH,01EH,000H ;�
        DB      000H,000H,061H,061H,079H,06DH,079H,000H ;�
        DB      000H,000H,060H,060H,07CH,066H,07CH,000H ;�
        DB      000H,000H,03EH,063H,00FH,063H,03EH,000H ;�
        DB      000H,000H,04EH,05BH,07BH,05BH,04EH,000H ;�
        DB      000H,000H,03EH,066H,03EH,036H,066H,000H ;�
        DB      014H,07EH,060H,07CH,060H,060H,07FH,000H ;�
        DB      014H,000H,03CH,066H,07EH,060H,03EH,000H ;�
        DB      000H,000H,000H,000H,001H,003H,006H,00CH ;�
        DB      000H,000H,000H,000H,060H,030H,018H,00CH ;�
        DB      00CH,018H,030H,060H,000H,000H,000H,000H ;�
        DB      00CH,006H,003H,001H,000H,000H,000H,000H ;�
        DB      000H,006H,003H,07FH,003H,006H,000H,000H ;�
        DB      000H,018H,030H,07FH,030H,018H,000H,000H ;�
        DB      00CH,00CH,00CH,00CH,03FH,01EH,00CH,000H ;�
        DB      000H,00CH,01EH,03FH,00CH,00CH,00CH,00CH ;�
        DB      00CH,00CH,000H,03FH,000H,00CH,00CH,000H ;�
        DB      018H,018H,07EH,018H,018H,000H,07EH,000H ;�
        DB      045H,064H,054H,04CH,044H,044H,044H,000H ;�
        DB      000H,061H,01EH,033H,033H,01EH,061H,000H ;�
        DB      000H,000H,01EH,01EH,01EH,01EH,000H,000H ;�
        DB      000H,000H,000H,000H,000H,000H,000H,000H ;
        ORG 0E6F2H
INCLUDE INT19.ASM     ;INT19 - ����㧪� ��⥬�
;---INT 19------------------------------------------------
;�ணࠬ�� ����㧪� ��⥬�
;     �᫨ ���ன�⢮ � - ��᪥�� 5 1/4", � ����㧪� ��������
;     ��஦�� 0, ᥪ�� 1���뢠���� �� ����� BOOT(0:7C00)
;     � �� ���� ��।����� �ࠢ�����.
;     �᫨ ��᪥�� ��������� ��� �ந��諠 �����⭠� �訡��,
;     � �ࠢ����� ��।����� � ��� CASSETE-BASIC.
;
; �᫨ ����㧪� ���� � ��᪥���, � ��� 0=1 ��� ���� 60H
;----------------------------------------------------------
        ASSUME CS:CODE,DS:DATA
BOOT_STRAP     PROC    NEAR
      STI                      ;������� ���뢠���
      MOV      AX,DATA         ;��⠭���� ���樨 ������
      MOV      DS,AX
      MOV      AX,EQUIP_FLAG   ;������� ���ﭨ� ��४���⥫��
      TEST     AL,1H           ;�뤥���� ���ﭨ� ��४���⥫� IPL
      JZ       H3              ;��३� �� �室 CASSETTE BASIC
;-------------���⥬� ����㦠���� � ��᪥���
                             ;CX-���稪 ����஢
      MOV       AX,0
      MOV       DS,AX
      MOV       CX,4         ;��⠭����� ���稪 ����஢
H1:
      PUSH      CX           ;���࠭��� ���稪 ����஢
      MOV       DX,0         ;���ன�⢮ 0, ������� 0
      MOV       AH,0         ;���� ����
      INT       13H          ;����/�뢮� ��᪥���
      JC        H2           ;�᫨ �訡��, �������
      MOV       AH,2         ;�⥭�� ������ ᥪ��
      MOV       BX,0         ;�� ���� BOOT
      MOV       ES,BX
      MOV       BX,OFFSET BOOT_LOCN
      MOV       DX,0         ;���ன�⢮ 0, ������� 0
      MOV       CX,1         ;����� 1, ��஦�� 0
      MOV       AL,1         ;���뢠��� ᥪ��
      INT       13H
H2:   POP       CX           ;����⠭����� ���稪 ����஢
      JNC       H4           ;��⠭����� CF �� �訡�� �⥭��
      LOOP      H1           ;�� �����
;---------����㧪� � ��᪥��� ����������
H3:
      IRET
;---------����㧪� �����訫��� �ᯥ譮
H4:
      JMP       BOOT_LOCN    ;��।�� �ࠢ����� ��⥬�
BOOT_STRAP   ENDP
INCLUDE INT10_B2.ASM    ;Write_TTY � ᢥ⮢�� ���
;-----------------------------------------------------
; WRITE_TTY
;  �� �ணࠬ�� ���ᯥ稢��� ࠡ��� � ����� � ०��� ⥫�⠩��. �뢮����
;  ᨬ��� �����뢠���� � ⥪���� ������ �����, � ����� ��६�頥�� �
;  ᫥������ ������. ��᫥ ����� ᨬ���� � ��᫥���� ������ ��ப�
;  �믮������ ��⮬���᪨� ���室 �� ����� ��ப�. �᫨ ��⨢��� ��࠭��
;  �࠭� ���������, �믮������ ��६�饭�� �࠭� �� ���� ��ப� �����
;  (ᢥ�⪠). �᢮��������� ��ப� ���������� 梥⮬ ��ਡ�� �� ��᫥����
;  ����樨 ����� ��। ᢥ�⪮� (� ᨬ���쭮� ०���). � ����᪮� ०���
;  �ᯮ������ 梥� 0.
;�室:
;  (AH) - ⥪�騩 ०�� �࠭�
;  (AL) - �뮤��� ᨬ���
;  (BL) - 梥� ��।���� ����� ��� ᨬ���� � ����᪮� ०���
;����砭��: ������ �� 蠣, ������ ���⪨, ��ॢ�� ��ப� � ������
;           ��ࠡ��뢠���� ��� �������.
;��室:
;  �� ॣ����� ��࠭�����
;---------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
WRITE_TTY       PROC   NEAR
        PUSH    AX            ;���࠭��� ॣ�����
        PUSH    AX            ;���࠭��� ᨬ��� ��� �����
        MOV     BH,ACTIVE_PAGE ;������� ⥪���� ��⨢��� ��࠭���
        MOV     AH,3
        INT     INT_VIDEO     ;������ ���祭�� ⥪�饩 ����樨 �����
        POP     AX            ;����⠭����� ᨬ���
;
;------ DX ᮤ�ন� ⥪���� ������ �����
;
        CMP     AL,8          ;�� ������ �� 蠣?
        JE      U8            ;��, ���室
        CMP     AL,0DH        ;�� ������ ���⪨?
        JE      U9            ;��, ���室
        CMP     AL,0AH        ;�� ��ॢ�� ��ப�?
        JE      U10           ;��, ���室
        CMP     AL,07H        ;�� ������?
        JE      U11           ;��, ���室
;
;------ ������ ᨬ���� �� �࠭
;
        MOV     AH,10         ;������ ⮫쪮 ᨬ����
        MOV     CX,1          ;���쪮 ���� ᨬ���
        INT     INT_VIDEO     ;������ ᨬ����
;
;------ ������ ����� ��� ᫥���饣� ᨬ����
;
        INC     DL
        CMP     DL,BYTE PTR CRT_COLS   ;�஢�ઠ ��९������� �������
        JNZ     U7            ;��⠭����� �����
        MOV     DL,0          ;������� ��� �����
        CMP     DH,24
        JNZ     U6            ;��⠭����� �����
;
;------ �ॡ���� ᢥ�⪠ (�ப��⪠)
U1:
        MOV     AH,2
        MOV     BH,ACTIVE_PAGE ;������� ⥪���� ��⨢��� ��࠭���
        INT     INT_VIDEO      ;��⠭����� �����
;
;------ ��।������ ���祭�� �������⥫� �� �६� ᢥ�⪨
;
        CMP     CRT_MODE,4
        JC      U2            ;���뢠��� �����
        MOV     BH,0          ;���������� 䮭�
        JMP SHORT  U3         ;��⠭����� �ப����
U2:                           ;���뢠��� �����
        MOV     BH,ACTIVE_PAGE ;������� ⥪���� ��⨢��� ��࠭���
        MOV     AH,8
        INT     INT_VIDEO     ;������ ᨬ���/��ਡ�� ⥪�饣� �����
        MOV     BH,AH         ;��������� � BH
U3:                           ;�ப��⪠
        MOV     AX,601H       ;�ப��⪠ ����� ��ப�
        MOV     CX,0          ;���孨� ���� 㣮�
        MOV     DH,24         ;������ �ࠢ�� ��ப�
        MOV     DL,BYTE PTR CRT_COLS   ;������ �ࠢ�� �������
        DEC     DL
U4:
        INT     INT_VIDEO     ;�ப��⪠ �࠭�
U5:                           ;������ �� TTY
        POP     AX            ;����⠭����� ᨬ���
        JMP     VIDEO_RETURN  ;������
U6:                           ;��⠭����� �����
        INC     DH            ;�������� ��ப�
U7:                           ;��⠭����� �����
        MOV     BH,ACTIVE_PAGE ;������� ⥪���� ��⨢��� ��࠭���
        MOV     AH,2
        JMP     U4            ;��⠭����� ���� �����
;
;------ ��।���� ������ �� 蠣
U8:
        CMP     DL,0          ;��� ����� ��ப�?
        JE      U7            ;��⠭�����  �����
        DEC     DL            ;���- ������ ��� �� 蠣
        JMP     U7            ;��⠭�����  �����
;
;------ ��।���� ������ ���⪨
U9:
        MOV     DL,0          ;��।������ �� ����� �������
        JMP     U7            ;��⠭�����  �����
;
;------ ��।���� ��ॢ�� ��ப�
U10:
        CMP     DH,24         ;��᫥���� ��ப� �࠭�?
        JNE     U6            ;��, �ப��⪠ �࠭�
        JMP     U1            ;���, ��⠭����� ����� ᭮��
;
;------ ��।���� ������
U11:
        MOV     BX,0602H      ;��⠭����� ���稪 ��� ᨣ����
        CALL    BEEP          ;������� ��� BELL
        JMP     U5            ;������ �� TTY
WRITE_TTY       ENDP
;---------------------------------------------------------------------------
;LIGHT PEN
;       � �� ��� ᢥ⮢�� ��� ���������, � ०�� ���뢠��� ���������
;       ᢥ⮢��� ��� �� �����ন������.
;----------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
READ_LPEN       PROC   NEAR
        MOV     AH,0
        JMP     VIDEO_RETURN     ;��� ᢥ⮢��� ���, ������
READ_LPEN       ENDP
INCLUDE TBL_KBDP.ASM
;----------------------------------------------------------------------------
;   ⠡��� ��� �������� "�����"
;----------------------------------------------------------------------------
;  12.02.88   ���쪮�᪨�  �.�.
;----------------------------------------------------------------------------
;          ⠡��� ���ᠭ�� ������ ���������� (12*8)
;      ����⥫�� ��� (-1..-0FH) --  ��뫪� �� ��ப� ⠡���� LN_KEY1
;- �������--1----2----3----4----5----6----7----8----9----10---11--12-
LINE1  DB  55H, 4CH, 00H, 56H, 35H, 1CH, 48H, 50H,-0CH, 18H,-0BH,57H
LINE2  DB -0FH, 4BH, 52H, 41H,-0DH, 0EH, 47H, 4FH, -2H, -3H, 19H,54H
LINE3  DB  21H, 49H, 51H, 31H, 20H, 1FH, 2CH, 00H, 32H, 25H, 30H,22H
LINE4  DB  3DH, 00H, 00H, 40H, 3CH, 3BH, -1H, 01H, -9H,-0AH, 3FH,3EH
LINE5  DB  12H, 00H, 9DH, 23H, 11H, 10H, 1EH, 3AH, 24H, 17H, 14H,13H
LINE6  DB 0AAH, 37H,0B8H, 2EH, 2DH,0DCH,0DBH,0AAH, 58H, 59H, 2FH,39H
LINE7  DB  00H, 45H, 53H, 00H, 27H, 44H, 4EH, 4DH, 26H, 42H, 5AH,43H
LINE8  DB -06H, 4AH, 0FH, 15H, -7H, 46H, -4H, 2BH, 00H, 16H, -5H,-8H
;----------------------------------------------------------------------------
;  03.02.88 - �-54,�-55,�-56,�-57,�-58,�-59,�-5A/  ���� ᪠� ����
         ORG    0E82DH
DB       8FH          ;�� �����
INCLUDE INT16N.ASM
;--------------------------------------------------------------
;
;                � � � � � � � � � �
;
;___int 16_________________
;
;   �ணࠬ�� �����প� ����������
;
;   �� �ணࠬ�� ���뢠�� � ॣ����
; AX ��� ᪠��஢���� ������ � ���
; ASCII �� ���� ����������.
;
;   �ணࠬ�� �믮���� �� �㭪樨, ���
; ������ �������� � ॣ���� AH:
;
;    AH=0 - ����� ᫥���騩 ᨬ���
;            �� ����.�� ��室� ���
;            ᪠��஢���� � AH,���
;            ASCII � AL.
;
;   AH=1 - ��⠭����� ZF, �᫨ ���
;            ASCII ���⠭:
;            ZF=0 - ���� ��������,
;            ZF=1 - ���� ���⮩.
;         �� ��室� � AX ����饭� ᮤ�ন��� ���設� ���� ����������.
;
;   AH=2 - ������ ⥪�饣� ���ﭨ� � ॣ���� AL
;          �� ����ﭭ� ��।������� ������ ����� �
;          ���ᮬ 00417H.
;
;   �� �믮������ �ணࠬ� ���������� �ᯮ������� 䫠���,
; ����� ��⠭���������� � ����ﭭ� ��।������� ������
; ����� �� ���ᠬ 00417H � 00418H � ����� ���祭��:
;   00417H
;         0 - �ࠢ�� ��४��祭�� ॣ���� SHIFT;
;         1 - ����� ��४��祭�� ॣ����  SHIFT;
;         2 - ���  (CTRL);
;         3 - ���  (ALT) ;
;         4 - ���  (ScrollLock) ;
;         5 - ���  (NumLock);
;         6 - ���  (CapsLock) ;
;         7 - ���  (Ins) ;
;   00418H
;         0 - ���ﭨ� ������ ��� ����� ����⨥� � �⦠⨥� (�� �ᯮ��);
;         1 - ��� (�� �ᯮ��);
;         2 - �/� (�� �ᯮ��);
;         3 - ��㧠 (HOLD_STATE);
;         4 - ���;
;         5 - ���;
;         6 - ���;
;         7 - ���.
;
;   ������, ᮮ⢥�����騥 ࠧ�鸞� 4-7 ����ﭭ� ��।�������
; ������ ����� � ���ᮬ 00417H, ��⠭���������� �� ������
; ������ ���, ���, ���, ��� � ��࠭��� ᢮� ���祭�� �� ᫥-
; ���饣� ������ ᮮ⢥�����饩 ������.
; ���������� 䫠���, ᮮ⢥�����騥 ࠧ�鸞� 4-7 ����ﭭ�
; ��।������� ������ ����� � ���ᮬ 00418H, � 䫠���
; ���, ���, ����� ��४��祭�� ॣ����, �ࠢ�� ��४��祭��
; ॣ����, �/� ��⠭���������� �� ������ ������ � ���뢠����
; �� �⦠��.
;
;--------------------------------------------------------------.
        ASSUME CS:CODE,DS:DATA
KEYBOARD_IO     PROC   FAR
        STI                   ;ࠧ�襭�� ���뢭��
        PUSH    DS
        PUSH    BX
        MOV     BX,DATA
        MOV     DS,BX         ;��⠭���� 㪠��⥫� �� ᥣ���� ������
	MOV	BX,BUFFER_HEAD;�����⥫� ���設� ���� ����� INT9
        OR      AH,AH         ;AH=0
        JZ      K1            ;�⥭�� ᨬ���� ASCII
        DEC     AH            ;AH=1
        JZ      K2            ;���� ���ﭨ� ����
        DEC     AH            ;AH=2
;        JNZ     KBRET
        MOV	AL,KB_FLAG    ;SHIFT_STATUS
KBRET:  POP     BX
        POP     DS
        IRET
;------ �⥭�� ���� ᨬ���� ASCII �� ��������
K1:
	MOV	AH,1
	INT	16H	      ;�����ᨢ�� ���� ����������
        JZ      K1            ;�᫨ ��� ��⮢����
        CALL    K4            ;���騢���� 㪠��⥫� �⥭�� ����
        MOV     BUFFER_HEAD,BX ;������ ������ ���祭�� 㪠��⥫�
	JMP	KBRET	      ;��室
;-------ASCII STATUS
K2:
        CLI                   ;����� ���뢠���
        CMP     BX,BUFFER_TAIL ;�᫨ 㪠��⥫� ࠢ�� (ZF=1), � ���� ����
        MOV     AX,[BX]
        STI                   ;ࠧ�襭�� ���뢠���
        POP     BX
        POP     DS
        RET     2             ;������ ��� ��࠭���� 䫠���
KEYBOARD_IO     ENDP
INCLUDE TBL_INT9.ASM
;-------------------------------------------------------------
;             � � � � � � �   � � �   I N T 9
;-------------------------------------------------------------
;      ⠡��� ᮮ⢥��⢨� ���᪨� ᨬ����� ᪠�-�����
LR      LABEL    BYTE
        DB       '��������'
        DB       '��������'
        DB       '��������'
        DB       '��������'
        DB       0f0h           ;
;--------------------------
;------- ᪠�-���� �ࠢ����� ������
K6      LABEL   BYTE
        DB      RIGHT_KEY
        DB      LEFT_KEY
        DB      CTL_KEY
        DB      ALT_KEY
        DB      SCROLL_KEY
        DB      NUM_KEY
        DB      CAPS_KEY
        DB      INS_KEY
K6L     EQU     $-K6
;------- ��४���஢�� ��� CTRL, ᪠�-���� 00-??
K8      DB      01,55  ;�࠭��� ���ࢠ��
        DB      27, -1,  0, -1, -1, -1, 30, -1
        DB      -1, -1, -1, 31, -1,127, -1, 17
        DB      23,  5, 18, 20, 25, 21,  9, 15
        DB      16, 27, 29, 10, -1,  1, 19,  4
        DB       6,  7,  8, 10, 11, 12, -1, -1
        DB      -1, -1, 28, 26, 24,  3, 22,  2
        DB      14, 13, -1, -1, -1, -1, 114+80H
;--------------------------
;------- ��४���஢�� ��� CTRL, �������⥫쭠� ���������
;            ( ᪠�-���� ??-?? )
K9      LABEL   BYTE
        DB      71,81 ;�࠭��� ���ࢠ��
        DB      119+80H,-1,     -2,-1,115+80H,-1
        DB      116+80H,-1,117+80H,-1,118+80H
;-------- ��४���஢�� ��� ���孥�� ॣ����, ᪠�-���� 00-??  (��� SHIFT)
K10     LABEL   BYTE
        DB      1,55
        DB      01BH,'1234567890-=',08H,09H
        DB      'qwertyuiop[]',0DH,-1,'asdfghjkl;',027H
        DB      60H,-1,5CH,'zxcvbnm,./',-1,'*'
;--------------------------
;-------- ��४���஢�� ��� ������� ॣ����, ᪠�-���� 00-??   (c SHIFT)
K11     LABEL   BYTE
        DB      1,55  ;�࠭��� ���ࢠ��
        DB      27,'!@#$',37,05EH,'&*()_+',08H,15+80H
        DB      'qwertyuiop',7BH,7DH,0DH,-1,'asdfghjkl:"'
        DB      07EH,-1,7CH,'zxcvbnm<>?',-1,114+80H
;--------------------------
;-------��४���஢�� ᨬ����� �������⥫쭮� ����������
;       (��஢�� ०��, ᪠�-���� ??-??)
K14     LABEL   BYTE
        DB      71,83 ;�࠭��� ���ࢠ��
        DB      '789-456+1230.'
;-------��४���஢�� ᨬ����� �������⥫쭮� ����������
;       (�ࠢ����� ����஬, ᪠�-���� ??-??)
K15     LABEL   BYTE
        DB      71,83  ;�࠭��� ���ࢠ��
        DB      71+80H, 72+80H, 73+80H, '-',    75+80H,    -1, 77+80H
        DB      '+',     79+80H, 80+80H, 81+80H, 82+80H, 83+80H
;--------------------------
;------ ⠡��� �����⨬�� ���ࢠ��� ᪠�-����� ��� ALT � RUS
KT_ALT  DB      2, 13  ; 1..+
KT_RUS0 DB     16, 25  ; Q..P
        DB     30, 38  ; A..L
        DB     44, 50  ; Z..M
KT_RUS  DB     84, 90  ; X..�,� � ���� �窠�� � �����
         ORG    0E987H
INCLUDE INT9.ASM
;---------------------------------------------------------------
;
;              � � � � � � � � � �       I N T 9
;
;---------------------------------------------------------------
;         ���쪮�᪨� �.                    06.01.89
;---------------------------------------------------------------
;    �ணࠬ�� ��ࠡ�⪨ ���뢠��� ����������
;
; �ணࠬ�� ���뢠�� ��� ᪠��஢���� ������ � ॣ���� AL.
; �����筮� ���ﭨ� ࠧ�鸞 7 � ���� ᪠��஢���� ����砥�,
; �� ������ �⦠�.
;   � १���� �믮������ �ணࠬ�� � ॣ���� AX �ନ�����
; ᫮��, ���訩 ���� ���ண� (AH) ᮤ�ন� ��� ᪠��஢����,
; � ����訩 (AL) - ��� ASCII. �� ���ଠ�� ����頥��� � ����
; ����������. ��᫥ ���������� ���� �������� ��㪮��� ᨣ���.
; ������������ ����� 0:417 � 0:418
;  �஢������� � ��ࠡ��뢠���� ���樨:
;        - SHIFT + PrintScreen
;        - CTRL  + NumLock
;        - ALT   + CTRL + DEL
;-------------------------------------------------------------
;----------------------- I N T 9 -----------------------------------
KB_INT  PROC    FAR
        STI                   ;ࠧ���� ���뢠���
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES
        CLD                   ;���ࠢ����� ���।
;------ ��⠭���� ॣ���஢
        PUSH    CS
        POP     ES            ;ES=CS
        MOV     AX,DATA
        MOV     DS,AX         ;㪠��⥫� �� ᥣ���� �������
        IN      AL,KB_DATA    ;�⥭�� ᪠�_����
        MOV     AH,AL         ; (AH) - ᪠�-���
;        CALL    DISP_HEX     ;  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        AND     AL,7FH       ;��� ��� �����-�⦠�
        MOV     SI,OFFSET ALT_INPUT ; 㪠��⥫� �� ������⥫� ���� ᨬ����
        MOV     DX,word ptr KB_FLAG    ; ���ﭨ� �ࠢ����� ������:
                              ;           DL - KB_FLAG,  DH - KB_FLAG1
;------ �஢�ઠ �� ᪠�_��� �ࠢ���饩 ������
K16:
        MOV     DI,OFFSET K6   ;⠡��� SHIFT KEY
        MOV     CX,K6L         ;����� ⠡����
        REPNE   SCASB          ;����
	JNE	K25	       ;�� ��ࠢ����� ������
;------ ��ࠢ����� ������
K17:                           ;(CL) - ������⢮ ᤢ����
        MOV     BH,80H
        SHR     BH,CL          ;(BH) - ��᪠ ������ ��� KB_FLAG
        CMP     AH,AL          ;�஢�ઠ �� �⦠⨥
        JNZ     K23            ;�᫨ ������ �⦠�
;------ ��ࠢ����� ������ �����
        CMP     BH,SCROLL_SHIFT
        JAE     K18            ;�᫨ ������ �� ������⢠
                               ; { Scroll,Num,Caps,Ins }
;------ ����� ������ �� ������⢠  { Alt,Ctl,ShiftLeft,ShiftRigth }
        OR      DL,BH           ;��⠭���� 䫠��� � KB_FLAG
        JMP     SHORT K26       ;� ��室� �� ���뢠���
;------ ����� ������ �� ������⢠  { Scroll,Num,Caps,Ins }
K18:
        TEST    DL,CTL_SHIFT+ALT_SHIFT;
        JNZ     K25                ; ��ࠡ�⪠ �� ���筮� ������
        CMP     AL,INS_KEY         ; �஢�ઠ �� ��� INS
        JNZ     K22
;------ ����� ������ INS
K19:    CALL    CALC_NUMKEY_SHIFT  ; ��।������ ����� ������. ����������
        JZ      K22  ; �������⥫쭠� ��������� � �ࠢ���饬 ���ﭨ�
        ; �������⥫쭠� ��������� � ��஢�� ���ﭨ�
        MOV     AL,'0'             ; ������ � ���� ���� '0'
        JMP     SHORT K23E
;------ ��������� KB_FLAG ��� ������ �� ������⢠  { Scroll,Num,Caps,Ins }
K22:
        TEST    BH,DH              ; ����ୠ� ������� �� ����� ����⨨?
        JNZ     K26                ; �᫨ �������
        OR      DH,BH              ; ��⠭���� ��� - ������ �����
        XOR     DL,BH              ; ������� ०���
        CMP     AL,INS_KEY         ; �஢�ઠ INSERT KEY
        JNE     K26                ; �᫨ ���
        JMP     KW0_BUF            ; ������ � ���� ���� ������ INS
;------ ��ࠢ����� ������ �⦠�
K23:
        CMP     BH,SCROLL_SHIFT
        JAE     K24
;------ �⦠� ������ �� ������⢠  { Alt,Ctl,ShiftLeft,ShiftRigth }
        NOT     BH                 ; ������஢���� ��᪨
        AND     DL,BH              ; c��� ��� �ਧ���� � KB_FLAG
        CMP     AH,ALT_KEY+80H     ; �⦠� ������ ALT
        JNE     K26                ; � ��室� �� ���뢭��
;------ �⦠� ������ ALT, ������ ᨬ���� � ����
;       ( ᨬ��� �� ������ � ��஢�� ���� )
        MOV     AL,[SI]
        SUB     AH,AH              ; ᪠�_���=0
        MOV     [SI],AH            ; ��� ����-������⥫�
        OR      AL,AL              ; ��� ᨬ���� = 0 ?
        JE      K26                ; � ��室� �� ���뢠���
K23E:   JMP     KW_BUF             ; ������ ��������� ���� ᨬ���� � ����
;------ �⦠� ������ �� ������⢠  { Scroll,Num,Caps,Ins }
K24:
        NOT     BH                 ; ������஢���� ��᪨
        AND     DH,BH              ; ��� ���-�ਧ���� � KB_FLAG1
        JMP     SHORT K26          ; � ��室� �� ���뢠���
;------ ����-��� ������� ������� -----------------------------------------
K25:
        CMP     AH,AL             ; �஢�ઠ ��� ������/�⦠��
        JNE     K26A               ; ������ �⦠�
        TEST    DH,HOLD_STATE      ; �஢�ઠ ०���-��㧠
        JZ      K28                ; ०�� ��㧠 ���������
        ;०��_��㧠
        CMP     AL,NUM_KEY
        JE      K26A               ; �᫨ ०�� ��㧠 �த��������
        AND     DH,NOT HOLD_STATE  ; ��� ०��� ��㧠
;------ ������� �� ����������
K26:
        MOV     word ptr KB_FLAG,DX      ; ��࠭���� 䫠��� ������ �ࠢ�����
K26A:
        MOV     SCAN_CODE_OLD,AH; ����������� ᪠�-����
        CLI                     ; ����� ���뢠���
        MOV     AL,EOI          ; ������� - ����� ���뢠���
        OUT     020H,AL         ; ������ ������� � ����஫��� ���뢠���
K27:
        POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        IRET
;--------------------------------------------------------------
;           ������� ����-��� ������� �������
;  ( ��४���஢�� ᪠�-����� � ����ୠ⨢��� ����஢�� )
;--------------------------------------------------------------
K28:    ;�஢�ઠ �� �������⥫�� ᪠�-���
        CMP      SCAN_CODE_OLD,0E0H
        JZ       K65AA        ; �᫨ �������⥫�� ᪠�-���
       ;�஢�ઠ ���ﭨ� �ࠢ����� ������
       TEST    DL,ALT_SHIFT+CTL_SHIFT
       JNZ     K70             ; �᫨ ���� ��� ��� ������ ������
;--------------------------------------------------------------
;    �஢�ઠ � ���㦨����� ᨬ����� ��� ALT � CTRL
;--------------------------------------------------------------
K60:   CMP     RUSS,TRUE
       JNE     K61
;----- SERVICE RUSS  -  �஢�ઠ � ���㦨����� ���᪨� ᨬ�����
SERVICE_RUSS:
        MOV     BX,offset KT_RUS0
        CALL    CONTR_TABLE
        JNZ     K61                     ; �᫨ �� ���᪠� �㪢�
SR2:
        MOV     BX,offset LR
        XLAT    CS:LR            ; ����祭�� ���� ᨬ����
        ;
        MOV     CL,DL
        AND     CL,LEFT_SHIFT+RIGHT_SHIFT+CAPS_STATE
        JZ      SR3                     ; ������ �ࠢ����� �� ������
        CMP     CL,CAPS_STATE+1
        JC      SR4                     ; ����� ⮫쪮 ���� �� ������
                                        ; SHIFT1 ��� CAPS_STATE
SR3:    ; �����쪨� �㪢�
        CMP     AL,0F0h
        JNZ     SR0
        INC     AL
        JMP     short SR4
SR0:    ADD     AL,20H
        CMP     AL,0B0H
        JC      SR4
        ADD     AL,30H
SR4:
        JMP     KW_BUF                  ; � ����� � ����
;-----------------------------------------------------------------
;----- �஢�ઠ � ���㦨����� �� ���᪨� �㪢
K61:
       CMP      AL,71         ; �������⥫쭠� ��������� ?
       JAE      K65           ; ��
;----- �������� ����������
       TEST     DL,LEFT_SHIFT+RIGHT_SHIFT
       JNZ      K62
       ; �᭮���� ���������, ������ SHIFT �� �����
       MOV      BX, offset K10
       CALL     CONTR_CODE
       SUB      CL,CL
       JMP      CONTR_FK
       ; �᭮���� ���������, ������ SHIFT �����
K62:
K63:   ; �஢�ઠ SHIFT + PrintScreen
        CMP     AL,55           ; PRINT SCREEN KEY
        JNE     K64
        ; �ᯥ�⪠ ᮤ�ন���� �࠭�
        MOV     AL,EOI
        OUT     020H,AL
        INT     5H              ;
        JMP     K27             ;  ������ ��� ��. ����஫��஬ ���뢠���
K64:    MOV     BX,offset K11
        CALL     CONTR_CODE
        MOV     CL,84-59
        JMP      CONTR_FK
;------ �������������� ����������
K65:   CALL    CALC_NUMKEY_SHIFT  ; ��।������ ����� ������. ����������
       MOV     BX, offset K14     ; ���. ��������� � ��஢�� ���ﭨ�
       JNZ     K65A
K65AA: MOV     BX, offset K15     ; ���. ��������� � �ࠢ���饬 ���ﭨ�
K65A:  CALL    CONTR_CODE
       JMP     K26
;-----------------------------------------------------------------
;----- ����� ALT �/��� CTL --------------------------------------
;-----------------------------------------------------------------
K70:    TEST    DL,ALT_SHIFT
        JZ      K80            ; �᫨ ALT �� ����� (����� CTRL)
;----- �஢�ઠ �� ��������� ALT + CTL + DEL
        CMP     AL,DEL_KEY
        JNE     K71             ; ��� ���
        MOV     RESET_FLAG,1234H ; ��⠭���� ��ࠬ��஢ ��� �㭪樨 ���
        JMP     RESET           ; ���室 �� ���
;--------------------------------------------------------------
;    �஢�ઠ � ���㦨�����  ᨬ�����  � ALT
;--------------------------------------------------------------
K71:    ; �஢�ઠ �� ���� �������⥫쭮� ����������
        CMP     AL,71
        JB      K72
        CMP     AL,82
        JA      K72
        MOV     BX,offset  K14+2-71
        XLAT    CS:K14
        SUB     AL,'0'
        JC      K72
        ;���������� ���� ᨬ����
        XCHG    [SI],AL
        MOV     AH,10
        MUL     AH
        ADD     [SI],AL
        JMP     K26             ; ��室 �� ���뢠���
 K72:
        MOV     AL,AH
        MOV      byte ptr[SI],0        ; ��� ������������ ����
        MOV     BX,offset KT_ALT ;A..Z, 0..9, -, +
        CALL    CONTR_TABLE     ; �஢�ઠ � ��४���஢�� ᪠� �����
        CMP     CL,84
        JZ      K72A            ; �᫨ ��� ��������� KT_ALT
        CMP     CL,2            ; �஢�ઠ �� ᪠�-���� 0..9-+
        JNZ     K72AA
        ADD     AH,118          ; �᫨ � ���������  0..9-+
K72AA:  JMP     KW0_BUF
K72A:   MOV     CL,104-59       ; ���饭�� ��� ����祭�� �ᥢ�� ᪠�-����
        JMP     CONTR_FK        ; �஢�ઠ �� �㭪樮����� ������
;--------------------------------------------------------------
;    �஢�ઠ � ���㦨�����  ᨬ�����  � CTRL
;--------------------------------------------------------------
K80:
        MOV     BX, offset K8   ; �᭮���� ��������� + CTRL
        CALL    CONTR_CODE
        MOV     BX, offset K9  ; �������⥫쭠� ��������� + CTRL
        CALL    CONTR_CODE
;       �஢�ઠ �ᯮ���⥫��� ������
        CMP     AL,SCROLL_KEY   ; �஢�ઠ ������ "BREAK"
        JNE     K81             ; �� "BREAK"
        ;"BREAK"
        ;���⪠ ���� �����
        MOV     AX,BUFFER_HEAD
        MOV     BUFFER_TAIL,AX
        MOV     BIOS_BREAK,80H  ; �ਧ��� BREAK �� ����������
        INT     1BH             ; ����� ���뢠��� ��ࠡ�⪨ BREAK
        SUB     AX,AX           ; ���⮩ ᨬ���
        JMP     KW_BUF          ; � ����� � ����
K81:
        CMP     AL,NUM_KEY      ; �஢�ઠ ������ "PAUSE"
        JNE     K82             ; NO-PAUSE
        ;"PAUSE"
        OR      KB_FLAG_1,HOLD_STATE ; ��⠭����� 䫠� "PAUSE"
        MOV     W_SCAN,FALSE   ; ࠧ�襭�� ����୮�� �室� � SCANINT
        MOV     AL,EOI
        OUT     020H,AL
        ;
;        CMP     CRT_MODE,7     ; IS THIS BLACK AND WHITE CARD
;        JE      K81A           ; YES,NOTHING TO DO
;        MOV     DX,03D8H       ; PORT FOR COLOR CARD
;        MOV     AL,CRT_MODE_SET        ; GET THE VALUE OF THE CURRENT MODE
;        OUT     DX,AL          ; SET THE CRT MODE,SO THAT CRT IS ON
K81A:   ; 横� �������� ����砭�� ����
        TEST    KB_FLAG_1,HOLD_STATE
        JNZ     K81A
        JMP     K27            ; � ��室� �� ���뢠���
K82:
       ; �஢�ઠ CTRL+PrintScreen
        CMP     AL,55
        JNE     K83
        MOV     AH,114     ; START/STOP PRINTING SWITCH
        JMP     KW0_BUF         ; � ����� � ����
 K83:
        MOV     CL,94-59        ; ���饭�� ��� ����祭�� �ᥢ�� ᪠�-����
;-----------------------------------------------------------------------
;     �������� �������������� ������ � �������
;      (CL) - ���饭�� ��� ����祭�� �ᥢ�� ᪠�_����
CONTR_FK:
         ; �஢�ઠ �� �஡��
         CMP     AL,57
         JNE     C_FK1
         MOV     AL,' '
         JMP     SHORT KW_BUF
C_FK1:   ; �஢�ઠ �� �㭪樮����� ������
         CMP     AL,59
         JB      K90A
         CMP     AL,68
         JA      K90A
         ADD     AH,CL
;----------------------------------------------------------------------
;------- ������ � �����
KW0_BUF: SUB    AL,AL
KW_BUF:
;        CALL    DISP_AX     ;  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        ; ����ᥭ�� ᪠�_���� (AH) � ���� ᨬ���� � ���� (AL)
        MOV     BX,BUFFER_TAIL ; GET THE END POINTER TO THE BUFFER
        MOV     SI,BX         ; SAVE THE VALUE
        CALL    K4            ; ADVANCE THE TAIL
        CMP     BX,BUFFER_HEAD ; HAS THE BUFFER WRAPPED AROUND
        JE      K90           ; BUFFER_FULL_BEEP
        MOV     [SI],AX        ; STORE THE VALUE
        MOV     BUFFER_TAIL,BX ; MOVE THE POINTER UP
        JMP     K90A           ; INTERRUPT RETURN
;------ BUFFER IS FULL,SOUND THE BEEPER
K90:                          ; BUFFER-FULL-BEEP
;        MOV     AL,EOI
;        OUT     20H,AL
        MOV     BX,0504H       ;
        CALL    BEEP
K90A:   JMP     K26           ; INTERRUPT_RETURN
KB_INT ENDP
;=========================================================================
;      ��।������ ����� ������. ����������
;      ��室:
;        Z=TRUE   -   �ࠢ����� ���������
;        Z=FALSE  -   ��஢�� ���������
 CALC_NUMKEY_SHIFT  PROC NEAR
       MOV     BL,DL
       AND     BL,NUM_SHIFT+LEFT_SHIFT+RIGHT_SHIFT
       JZ      CALC_END
       CMP     BL,NUM_SHIFT+1
       JB      CALC_END
       CMP     AL,AL    ;��⠭���� 䫠�� Z
CALC_END: RET
CALC_NUMKEY_SHIFT  ENDP
;=========================================================================
;      ������������� �������� � ��������� ������ ����������
;      (BX) - 㪠��⥫� �� ��������
;              <���><����><���饭��>
;       ��室: 䫠� Z=0  - ��㤠�� ����
;              䫠� Z=1  - 㤠�� ����, (AL)- ���浪��� �����
CONTR_TABLE PROC  NEAR
       PUSH    DX
       SUB     DL,DL       ; �㬬��� ��������
CT0:   MOV     CX,CS:[BX]
       CMP     AL,CL
       JB      CTE
       CMP     AL,CH
       JBE     CT00
       ;��� ��� ���ࢠ��
       SUB     CH,CL
       ADD     DL,CH         ;���������� �㬬�୮� ����� ����������
       INC     DL
       ADD     BX,2
       CMP     CL,83
       JB      CT0
       JMP     SHORT CTE
       ;��� ����� ���ࢠ��
CT00:  SUB     AL,CL
       ADD     AL,DL
       CMP     AL,AL   ; ��⠭���� 䫠�� Z
CTE:   POP     DX
       RET                   ;��室 - 㤠�� ����
CONTR_TABLE ENDP
;=========================================================================
;      ������������� �������� � ��������� ���������
;      (BX) - 㪠��⥫� �� ��������
;             <���><����><⠡���>
;
CONTR_CODE PROC  NEAR
       MOV     CX,CS:[BX]
;       PUSH    AX          ;  !!!!!!!!!!!!!!!!!
;       MOV     AL,'='
;       CALL    DISP_CHAR
;       MOV     AX,CX
;       CALL    DISP_AX
;       POP     AX
       CMP     AL,CL
       JB      CC_END
       CMP     AL,CH
       JA      CC_END
       ; ᪠�-��� ��室���� � �����⨬�� ���������
       SUB     AL,CL ; ��।������ ᬥ饭�� �⭮�⥫쭮 �������쭮�� ����
       ADD     AL,2
       XLAT    CS:K10
       POP     CX    ; 㤠����� �� �⥪� ���� ������
       TEST    AL,80H; �஢�ઠ �ନ஢���� �ᥢ�� ᪠�_����
       JNZ     CC_C1; �᫨ �ᮡ� ���
       ; �஢�ઠ �� ��⨭᪨� �㪢�
       CMP     AL,'a'
       JB      CC_C0
       CMP     AL,'z'
       JA      CC_C0
       ; ��⨭᪨� �㪢� - ������ ���ﭨ� ��. ������
       MOV     CL,DL
       AND     CL,LEFT_SHIFT+RIGHT_SHIFT+CAPS_STATE
       JZ      CC_C0                    ; ������ �ࠢ����� �� ������
       CMP     CL,CAPS_STATE+1
       JAE     CC_C0                     ; ����� ⮫쪮 ���� �� ������
       SUB     AL,'a'-'A'
CC_C0: JMP     KW_BUF
CC_C1: ; �஢�ઠ ����饭���� ᪠�_����
       CMP     AL,0FFH
       JZ      K90A   ;����饭�� ᪠�_���
       CMP     AL,0FEH
       JNZ     CC_C2;
       MOV     AH,132
       JMP     KW0_BUF
CC_C2: ; �ᥢ�� ᪠�_���
       AND     AL,7FH
       MOV     AH,AL
       JMP     KW0_BUF
CC_END: RET
CONTR_CODE ENDP
;=======================================================================
;      ���������� ��������� ���������� ������ �����
;      (BX) - 㪠��⥫�
K4      PROC    NEAR
        ADD     BX,2          ;���室 � ᫥���饬� ᫮��
        CMP     BX,OFFSET KB_BUFFER_END ; ����� ���� ?
        JNE     K5            ;����� ���� �� ���⨣���
        MOV     BX,OFFSET KB_BUFFER ;� ��砫� ���� (�� ������)
K5:     RET
K4      ENDP
;=========================================================================
INCLUDE INT_TIME.ASM
;---------------------------------------------------------------------------
; �� �ணࠬ�� ��ࠡ��뢥� ���뢠��� ⠩��� 8253 �� ������ 0. �室���
; ���� 1.19318���, ����⥫� 65536, १���� - 18.2 ���뢠��� � ᥪ㭤�.
;
; ��ࠡ�⪠ ���뢠��� ᮤ�ন� ���稪 ���뢠���, ����� �����
; �ᯮ�짮������ ��� ��⠭���� �६��� ��⮪. ��ࠡ�⪠ ���뢠��� ⠪��
; ���⠥� ���稪 �ࠢ����� �����⥫�� ������⥫�� ���, � ����� ���稪
; ���௠�, �����⥫� �⪫�砥��� � ���뢠���� 䫠���. ��ࠡ�⪠ ���뢠���
; ����� �������⢮���� �� �ணࠬ�� ���짮��⥫� �१ ���뢠��� 1CH �����
; ⠪� ⠩���. ���짮��⥫� �����⠢������ �ணࠬ�� � ����頥� �� ���� �
; ⠡���� ����஢.
;--------------------------------------------------------------------------
TIMER_INT        PROC  FAR
        STI                          ;������� ���뢠���
        PUSH    DS
        PUSH    AX
        PUSH    DX                   ;���࠭��� ���ﭨ�
        MOV     AX,DATA
        MOV     DS,AX                ;��⠭����� ������
        INC     TIMER_LOW            ;���६��� ⠩���
        JNZ     T4                   ;��९�������?
        INC     TIMER_HIGH           ;���६��� ���襩 ��� ⠩���
T4:                                  ;��९�������
        CMP     TIMER_HIGH,018H      ;�஢�ઠ: ࠢ�� ���稪 24 �ᠬ?
        JNZ     T5                   ;��ࠢ����� ��᪥�⮩
        CMP     TIMER_LOW,0B0H
        JNZ     T5                   ;��ࠢ����� ��᪥⮩
;
;------������ ���௠� 24 ��
;
        MOV     TIMER_HIGH,0
        MOV     TIMER_LOW,0
        MOV     TIMER_OFL,1
;
;------���� �६��� �������� ��� ��᪥��
;
T5:                                  ;��ࠢ����� ��᪥⮩
        DEC     CURSOR_COUNT
        JNZ     T6
        MOV     CURSOR_COUNT,CURSOR_TIME
        CMP     CURSOR_MODE,0         ;������ �� �㫥��� ࠧ��� �����
        JZ      T6
        CMP     CURSOR_MODE,2000H     ;15.01.90�
        JZ      T6                    ;15.01.90�
T51:    MOV     AX,8
        INT     10h
        NOP
T6:                                  ;������ �� �ணࠬ��
        INT     1CH                ;��।�� �ࠢ����� �ணࠬ�� ���짮��⥫�
        MOV     AL,EOI
        OUT     020H,AL              ;����� ���뢠��� ��� 8259
        POP     DX
        POP     AX
        POP     DS                   ;����⠭����� ���ﭨ�
        IRET                         ;������ �� ���뢠���
TIMER_INT       ENDP
        ORG     0EC59H
INCLUDE INT13.ASM
;----------------------------------------------------------
;     ����/����� � ������� (INT 13H)
;----------------------------------------------------------
;DISKETTE_IO    PROC    NEAR
;         JMP     INT13_SERVICE
;DISKETTE_IO    ENDP
TEST_TABLIC     LABEL    WORD        ;������ ���न��樨 ���������
        DW      0,0,0,0              ;���� �����஢ RS232
        DW      0378H,0,0,0          ;���� �ਭ�஢
        DW      40ECH                ;��⠭����� '4 ���ன�⢠'
        DB      0                    ;���� ���樠����樨
        DW      96                   ;������ ����� � ������
        DW      40H                  ;������ ������ �����/�뢮��
        DB      0
        DB      0
        DB      0
        DW      1EH                  ;�����⥫� ���設� ����
        DW      1EH                  ;�����⥫� ��砫� ����
INCLUDE SCANINT2.ASM
;----------------------------------------------------------------------------
;  24.10.88   ���쪮�᪨�  �.�.
;----------------------------------------------------------------------------
;  29.10.88 - �஢�ઠ ����୮�� �宦�����
;  14.02.89 - �������⥫�� ᪠�_���� (��稭����� �� 0E0H:c8,cb,cd,d0)
;----------------------------------------------------------------------------
; --  ⠡��� ������ ��� ����� ( �� ������  ����� )
;             ��� 7 - �ਧ��� ����室����� ������஢���� SHIFT
;----------------------------------------------------------------------------
; ------------��� ᯥ�ᨬ�����--- SHIFT1 ----SHIFT2-----������ � �����--
;                                                      �����              �����
LN_KEY1 DB        80H+09H,           04H,   80H+29H    ; 1/12       1      4/7
        DB            34H,       80H+08H,   80H+33H    ; 4/1        2      2/9
        DB        80H+0CH,       80H+09H,   80H+34H    ; 4/2        3      2/10
        DB        80H+0AH,           0DH,       28H    ; 4/6        4  .   8/7
        DB        80H+28H,       80H+05H,   80H+1AH    ; 4/10       5      8/11
        DB            0CH,       80H+03H,   80H+03H    ; 5/4        6      8/1
        DB        80H+0BH,       80H+02H,   80H+08H    ; 5/5        7      8/5
        DB            35H,       80H+04H,   80H+07H    ; 5/9        8      8/12
        DB        80H+27H,       80H+06H,   80H+1BH    ; 5/11       9      4/9
        DB            33H,       80H+07H,       2BH    ; 5/12      10  .   4/10
        DB        80H+06H,       80H+0BH,       1AH    ; 8/1       11  .   1/11
        DB        80H+35H,       80H+0AH,   80H+2BH    ; 8/2       12      1/9
        DB            27H,           05H,       29H    ; 8/10      12  .   2/5
        DB            35H,           37H,       00     ; 8/11      14
        DB        80H+02H,       80H+0DH,       1BH    ; 8/12      15  .   2/1
;----------------------------------------------------------------------
;       ���� ������ ����������, �ନ஢���� ���� ᪠��஢����
;       � ������ ᪠� - ���� � ���� 60H
;-----------------------------------------------------------------------
SCANINT PROC	NEAR
        STI
	PUSH	AX
	PUSH	DS
	MOV	AX,DATA
	MOV	DS,AX
;------ �஢�ઠ ���ﭨ� ���������� � 楫��
	MOV	AL,0FFH	       ;�롮� ��� ����� ������
	OUT	LINE_SEL,AL
	IN	AX,COL_READ	;�⥭�� ���ﭨ� �������
        OR      AH,0F0H         ;��⠭���� ������ � 4-� ����� ���
        INC     AX              ;�஢�ઠ �� �� ������� (����)
        JNZ     SC1            ;�᫨ �� ����
;       ����� ���ﭨ� ����  AX=0
        MOV     LAST,AX         ;�� �ࢥ���� �� ����७��
        CMP     AX,EMPTY        ;
        JNZ      SC1
SC0:    JMP      SC_RET1        ;�᫨ ��஥ ���ﭨ� "����"
SC1:
;--------   ��ࠡ�⪠ ������, ��������� ���������
        ;   AX - ����� ��⥣ࠫ쭮� ���ﭨ� ����������
        ;        00     -    ����
        ;        ��㣮� - �� ����
;------ �஢�ઠ �� ����୮� �妤���� � ���뢠���
        CMP     W_SCAN,TRUE
        JZ      SC0
        MOV     W_SCAN,TRUE       ; ��⠭���� �ਧ���� "ࠡ��"
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI
        MOV     EMPTY,AX        ; ������ ������ ���ﭨ� ����������
        MOV     BX,offset KB_STAT ; ���� �।���饣� ���ﭨ� ����������
        MOV     DI,offset LINE1+KB_KEY-1   ; ���� ��������㥬�� ������
        MOV     DL,KB_STAT_S          ; ��� ��� ���� �����
        ;------------------- ��砫� 横�� SC2 / SC2E
SC2:    MOV     AL,DL           ; ��⠭���� ��������� ���� ���� �����
        OUT     LINE_SEL,AL     ; ���� �����
        IN      AX,COL_READ
        OR      AH,0F0H
        NOT     AX              ; ��ॢ�� �� �����᭮�� ����
        CMP     AX,[BX]         ; �ࠢ����� ������ ���ﭨ� � ����
        JNZ     SC21            ; �᫨ ���ﭨ� �� ᮢ����
        ;------ ���ﭨ� ����� ����������
        SUB     DI,KB_L_KEY     ; ���室 � ����� ����� � ⠡� ᪠� �����
        JMP     SC2E
        ;------ ��䨪�஢��� ��������� ���ﭨ� ������ � �����
        ;------ ��।������ ������ ��������� ���ﭨ�
        ;       �஢�ઠ � 横��
SC21:
        MOV     SI,AX
        XOR     SI,[BX]         ; SI ᮤ�ন� ������� � �⫨������ ����
        MOV     [BX],AX         ; ����������� ⥪�饣� ���ﭨ� �����
        MOV     CX,KB_STAT_C    ; ����� ��砫쭮� ������� � �������� ����
        ;       AX - ����� ���ﭨ� ⥪�饩 �����
        ;       BX - ���� ����� � ���ᨢ� KB_STAT
        ;       CX - ����� �������
        ;       DL - ����� �����
        ;       DI - ���� ᪠�-���� �஢��塞�� ������
        ;       SI - ᮤ�ন� ������� � ���� ����������� ������
        ;------------------- ��砫� 横�� SC22 / SC22E
SC22:
        TEST    SI,CX            ; �뤥����� �������
        JZ      SC22E            ; �᫨ ������� �� �⫨�����
        ;------- ������ �������� ᢮� ��ﭨ�
        TEST    [BX],CX
        JZ      SC222           ; ����� ���ﭨ� "����"?
        ;-------- ����� ������ �����
        MOV     LAST,DI         ; ����� ����⮩ ������
        MOV     TIME,FIRST_TIME ; ����� ��⠢�� �६��� ��������
        CALL    SEND_CODE       ; ��ࠡ�⪠  ����⮩ ������
        JMP     SC22E
        ;-------  ����� ������ �⦠�
SC222:  CMP     DI,LAST
        JNZ     SC2221          ; �᫨ �⦠� �� ����������� ������
        MOV     LAST,0          ; ��� ������ ����७��
SC2221: MOV     AL,CS:[DI]      ; ����祭�� ᪠� ���� ������
        CMP     AL,SHIFT2_KEY+80H
        JNZ     NO_SH2
        ;SHIFT2
        NOT     SHIFT2
        NOT     RUSS
NO_SH2:
        MOV     AH,80H          ; �ਧ��� �⦠⮩ ������
        CALL    C_OUT60         ; �뢮� � 60 ���� + INT9
        ;----------------- ����� 横�� SC22/ SC22E
SC22E:
        DEC     DI               ; ���� ������ ᪠�-����
        SHR     CX,1             ; ���室 � ᫥���饩 �������
        JNC     SC22
SC2E:   ADD     BX,2            ; ���室 � ᫥���饩 �����
        SHR     DL,1            ; ����䨪��� ��������� ����
                                ;(���稪 横��)
        JNC     SC2
        ;-----------------------------------����� 横�� SC2/ SC2E
;------�஢�ઠ ������⢨� ����� ����⮩ ������
        MOV     DI,LAST
        OR      DI,DI
        JZ      SC_RET
;------�஢�ઠ ���⥫쭮�� ������ ������
        MOV     BX, offset TIME
        DEC     byte ptr [BX]   ; �஢�ઠ ����砭�� ���ࢠ�� ⯮��७��
        JNZ     SC_RET
        MOV     [BX],byte ptr SECOND_TIME ; ����ୠ� ��⠭���� ���ࢠ��
        CALL    SEND_CODE      ; �ନ஢���� ᪠�-����
SC_RET:
        MOV     W_SCAN,FALSE   ; ���� �ਧ���� ࠡ��
        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
SC_RET1:
        CLI
        MOV     AL,20H         ; ����஫��� ���뢠���
        OUT     20H,AL
        POP     DS
        POP     AX
        IRET
SCANINT ENDP
;-------------------------------------------------
;       �ନ஢���� ���� ����⮩ ᪠��஢����
;-------------------------------------------------
;       DI - ���� ᪠�-���� ������
;-------------------------------------------------
SEND_CODE      PROC	NEAR
        MOV     AL,CS:[DI]     ; ��ࢨ�� ᪠�-���
	CMP	AL,62		;SCODE - F4
	JNZ	NO_FBEEP
	NOT	FBEEP
NO_FBEEP:
;------ �஢�ઠ �� �ᮡ� ������ ( �� ������ ����� )
        CMP     AL,255-16
        JNC     SEND1          ; �᫨ �ᮡ�� ������
;------ �஢�ઠ �� ��� ���⥫쭮 ������ ������
;       AND     AL,7FH
;       TEST    byte ptr CS:[DI],80H
        CMP     AL,80H         ; ������ �� �ᮡ� ������
        JB      SEND1          ; �᫨ ���筠� ������
        CMP     AL,48H+80H     ; ������ ��������� ������ 0C8..0D0
        JB      SEND01
        CMP     AL,50H+80H
        JBE     SEND1
SEND01: CMP     TIME,SECOND_TIME
        JZ      SEND2
SEND1:
        CMP     FBEEP,TRUE
	JNZ	SEND1A             ; �᫨ ��� ��������
;-------- ��㪮��� ᨣ��� �� ������ ������
        PUSH    BX
        MOV     BX,0101H
        CALL    BEEP
        POP     BX
;---------------------
SEND1A:
        ; �஢�ઠ ������ ������ RUS
        CMP	AL,RUS_KEY+80H
        JZ      YES_RUS                 ; ������� ०��� ���/���
        CMP     AL,SHIFT2_KEY+80H
        JNZ     NO_SHIFT2
        ;SHIFT2
        NOT     SHIFT2
YES_RUS:NOT     RUSS
        RET
NO_SHIFT2:
SEND2:
        XOR     AH,AH                ; �ਧ��� ������ ������
        CALL    C_OUT60              ; �뢮� � 60 ���� + INT9
SEND_E:
	RET
SEND_CODE ENDP
;-------------------------------------------------------------------
;         �뢮� � ���� 60 � �맮� INT9
;             AL - ��� ᪠��஢���� (��ࢨ��) ������
;                  255-250  - ��뫪� �� ����� ⠡����
;             AH - 00  - ������ �����
;                  80H - ������ �⦠�
;-------------------------------------------------------------------
C_OUT60 PROC NEAR
;------ �஢�ઠ �� �ᮡ� ������ ( �� ������ ����� )
        CMP     AL,255-16
        JNC     C_OUT1
;------ �஢�ઠ �� ������ �⫨�� �� ���������� IBM
        CMP      AL,RUS_KEY+80H
        JNC      NO_INT9
;------ �஢�ઠ �� �������⥫�� ᪠�_����       ; 14.02.89
        CMP      AL,48H+80H
        JC       C_OUT60A
        PUSH     AX         ; �������⥫�� ᪠�_����
        MOV      AL,0E0H
        CALL     C_INT9
        POP      AX
;------ ����� ᪠� ����
C_OUT60A:
        AND     AL,7FH
        OR      AL,AH
        CALL    C_INT9;
NO_INT9:
        RET
;------ �ᮡ� ������ ( �� ������ ����� )
C_OUT1: PUSH    DI
        PUSH    SI
        PUSH    BX
        MOV     BX,AX
        XOR     AH,AH
        NOT     AL         ; AX - ����� ��ப� � ⠡��� LN_KEY1
        MOV     SI,AX
;------ �஢�ઠ �� ����⨥ �⦠⨥
        TEST    BH,80H
        JZ      C_OUT1A     ; �᫨ �����
;------- ������  �⦠�
        MOV     AL,MEM_KEY[SI]  ; ��� ᪠��஢���� ����⮩ ������
        OR      AL,BH           ; ���������� �ਧ���� " �⦠�"
        CALL    C_INT9
        JMP     C_OUT32
;------- ������ �����
C_OUT1A:
        MOV     DI,AX
        ADD     DI,AX
        ADD     DI,AX      ; DI - ᬥ饭��  � ⠡��� LN_KEY1
        MOV     AH,LEFT_KEY+80H ; ���ﭨ� SHIFT1
        TEST    KB_FLAG,3H  ; �஢�ઠ  ������ SHIFT1
        JNZ     C_OUT2
        CMP     SHIFT2,FALSE  ; �஢�ઠ  ������ SHIFT1
        JZ      C_OUT3      ; ������ SHIFT1 � SHIFT2 �� ������
        ; ������ SHIFT2 �����
        INC     DI
        INC     DI
        JMP     C_OUT3
C_OUT2: ; ������ SHIFT1 �����
        AND     AH,7FH
        INC     DI
;------- �뢮� ������஢������ ᪠�-����
C_OUT3:
        MOV     BL,CS:LN_KEY1[DI]
        TEST    BL,80H         ; �஢�ઠ ����室����� ᬥ�� SHIFT1
        JZ      C_OUT31
        ;  ��४��祭�� SHIFT1
        MOV     AL,AH
        XOR     AL,80H          ; ������஢���� ���襣� ���
        CALL    C_INT9          ; �뤠� ���⭮�� ���� ��� SHIFT1
C_OUT31:; ᪠� ��� ����⮩ ������
        MOV     AL,BL
        AND     AL,7FH
        MOV     MEM_KEY[SI],AL ; ����������� ᪠�-���� ����⮩ ������
        CALL    C_INT9
        ;  ����⠭������� SHIFT1
        TEST    BL,80H
        JZ      C_OUT32
        MOV     AL,AH
        CALL    C_INT9          ;  ����⠭������� ���ﭨ� SHIFT
C_OUT32:POP      BX
        POP      SI
        POP      DI
        RET
C_OUT60 ENDP
;--------------------------------------------------------------
C_INT9  PROC NEAR
;       AX - ��� ᪠��஢����
;       CALL   DISP_AX     ; !!!!!!!!
        OUT    LINE_SEL,AL
        INT    KEY_INT
        RET
C_INT9  ENDP
;---------------------------------------------------------------
INCLUDE NMISER.ASM
;------------------------------------------------------------------------
;                                                                       ;
;     *******          �ணࠬ�� ���㦨����� NMI            *******    ;
;                                                                       ;
;------------------------------------------------------------------------
NMI_SERVICE:
        CLD
        PUSH    ES
        PUSH    DS
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    SI
        PUSH    DI
        PUSH    AX
        MOV     AX,DSEGMENT
        MOV     DS,AX
        MOV     AX,START_BUFFER   ;���� ��砫� ����
        MOV     ES,AX
        IN      AX,TRAP_A
        MOV     BX,AX
        TEST    AH,40h
        JNZ     IO_ROUTINES
MWTC_ROUTINE:                     ;����ணࠬ�� ���㦨����� �����
                                  ; (������ ⥪��)
        CLI                       ;����� ���뢠���
        MOV     DI,BX
        AND     DI,3FFEh          ;�롮� ��� ����
        MOV     DX,ES:[DI]        ;�⥭�� ᨬ����/��ਡ��
        SAR     DI,1
        MOV     AX,DI
        MOV     CL,AH
        SAR     CL,1
        SAR     CL,1
        TEST    CRT_MODE,2        ;80x25 ?
        JZ      MW4               ;���, 40x25
        SAR     CL,1              ;CL = PageNo
        MOV     CH,80             ;CH = 80
        AND     AH,7
MW2:
        DIV     CH
        XCHG    AH,AL
        PUSH    AX
        CBW
        SUB     DI,AX
        SAL     DI,1
        SAL     DI,1
        ADD     DI,AX
        POP     AX
        CMP     CL,ACTIVE_PAGE    ;��⨢��� ��࠭��?
        JNE     AX_NMI
        XOR     CH,CH
        MOV     SI,CX
        SAL     SI,1
        CMP     AX,[SI+OFFSET CURSOR_POSN]
        MOV     BX,EXTRA_BUFFER
        MOV     ES,BX
        PUSHF
        JNE     MW3
        CALL    REMOVE_CURSOR
MW3:
        PUSH    AX
        MOV     AX,DX
        MOV     BL,AH
        XOR     AH,AH
        MOV     CL,1
        TEST    CRT_MODE,2        ;\80x25 ?
        JNZ     MW31              ;\��
        and     di,0fffh          ;\
        JMP     MW32              ;\
MW31:   AND     DI,1FFFH          ;\
MW32:   CALL    S1B
        POP     AX
        POPF
AX_NMI:
        POP     AX
NMI_RET:
        JMP     VIDEO_RETURN      ;���室 �� ������ �� �����
MW4:
        MOV     CH,40
        AND     AH,3
        JMP     MW2
IO_ROUTINES:                      ;������� ��⠫��� NMI
                                  ;  (���饭�� � ���⠬ �����)
        TEST    AH,80h
        JNZ     IOWC_ROUTINE
IORC_ROUTINE:
        POP     AX
        MOV     AL,0FFh
        JMP     VIDEO_RETURN
IOWC_ROUTINE:
        IN      AL,TRAP_D
        MOV     SI,AX
        CMP     BL,0D4h ;         ;���� 3D4 ?
        JE      PORT_3D4
        CMP     BL,0D5h           ;���� 3D5 ?
        JE      PORT_3D5
        CMP     BL,0D8h           ;���� 3D8 ?
        JE      PORT_3D8
        CMP     BL,0D9h           ;���� 3D9 ?
        JNE     AX_NMI
PORT_3D9:
        XCHG    AL,AH             ;���࠭��� ��ࢮ��砫�� �����
        IN      AL,SCR_MODE       ;����� ���� ⥪�饣� ०���
        AND     AX,37C8H          ;��᪠ D7,D6 � D3
                                  ;�롮� D4,D5 � D2..D0
        OR      AL,AH             ;���⠢��� ���� ����
        OUT     SCR_MODE,AL       ;������ ���� ०�� �࠭�
        JMP     AX_NMI
PORT_3D4:                         ;������ � ���� 3D4 (�᫮ 6845)
        MOV     REG_6845,AL       ;���࠭��� �� � �����
        JMP     AX_NMI            ;�� ᤥ����
PORT_3D5:
        MOV     CL,REG_6845       ;����⠭����� �᫮
        CMP     CL,11
        JNZ     REG10
        MOV     BYTE PTR CURSOR_MODE,AL
REG10:  CMP     CL,10
        JNZ     REG14
        MOV     BYTE PTR CURSOR_MODE+1,AL
REG14:
        CMP     CL,15             ;�������=15?
        JE      REG_15
        CMP     CL,14             ;�������=14?
        JNE     AX_NMI            ;�᫨ ॣ���� �� 14 � �� 15, ��祣� �� ������
        MOV     CURSOR_POS_H,AL   ;���࠭��� ������ ������ �����
        JMP     AX_NMI            ;�� ᤥ����
REG_15:                           ;������� 15
        MOV     CURSOR_POS_L,AL   ;���࠭��� ������ ������ �����
        MOV     AH,CURSOR_POS_H
        TEST    CRT_MODE,2
        JZ      R_15_2
        MOV     CL,80
R_15_1:
        and     ax,07ffh
        DIV     CL
        XCHG    AL,AH
        MOV     DX,AX
        POP     AX
        MOV     BH,ACTIVE_PAGE
        JMP     SET_CPOS
R_15_2:
        MOV     CL,40
        JMP     R_15_1
PORT_3D8:                         ;���� 3D8 (���� ०���)
        AND     AL,1Fh            ;***
        JE      P_D8_RET
        TEST    AL,8
        JNZ     P_D8_RET
        TEST    AL,12h               ;��䨪�?
        JNZ     P_D8_3               ;��
        XOR     AH,AH
        TEST    AL,1                 ; 80X25 ?
        JZ      P_D8_1               ;���
        MOV     AH,2
P_D8_1:
        TEST    AL,4                 ;���⭮�?
        JNZ     P_D8_2               ;���
        INC     AH
P_D8_2:
        XCHG    AL,AH
        XOR     AH,AH
        CMP     AL,CRT_MODE
        JE      P_D8_RET          ;�맮� ��ࠡ�⪨ �㭪権 �����
        INT     10h
P_D8_RET:
        JMP     AX_NMI
P_D8_3:
        MOV     AH,6
        TEST    AL,10h                ; 640X200 ?
        JNZ     P_D8_2                ; ��
        DEC     AH
        TEST    AL,4                  ;���⭮�?
        JNZ     P_D8_2                ;���
        DEC     AH
        JMP     P_D8_2
INCLUDE INT15_B.ASM
;--------------------------------------------------------------------------
WRITE_BYTE	PROC	NEAR
; ������ ����� �� �������
; ����� ��� ������ ���������� � �������� AL.
;---------------------------------------------------------------------------
	PUSH	CX			;��������� CX,AX
	PUSH	AX
	MOV	CH,AL			;CH <--- ������������ ����
					;(������� ��� ������� ������)
	MOV	CL,8			;��� 8 ��� ������ � �����.
					;��� ������ ��� �������� �������
W27:					;���������� ���� ���
	RCL	CH,1			;CY <--- ������� ���
	PUSHF				;��������� �����
					;��� ������ ��� ���������� � CY
	CALL	WRITE_BIT		;�������� ��� ������
	POPF				;������������ CY ��� ���������� CRC
	CALL	CRC_GEN	                ;��������� CRC ��� ������������� ����
	DEC	CL			;DEC ������� ���
	JNZ	W27			;���������, ���� �� ��� ���� ��������
	POP	AX			;������������ AX,CX
	POP	CX
	RET				;��������� ������ �����
WRITE_BYTE	ENDP
;--------------------------------------------------------------------------
WRITE_BIT       PROC    NEAR
; ����:
;
; �������� ��� ������ �� �������
; ������������ ��� ���������� � CY
; �.�. ���� CY=1, ������������ ��� "1",
;      ���� CY=0, ������������ ��� "0"
;
; ����������: ��� ������������ ���� ���������� �������(1 ������)
;       ��� "1" ����� ������������ ����������� 500 �����������
;        ( ������ - 1000 ����������� )
;
;       ��� "0" ����� ������������ ����������� 250 �����������
;        ( ������ - 500 ����������� )
;
;--------------------------------------------------------------------------
                                        ;�����������, ��� '1'
        MOV     AX,1184                 ;������ ������ "1"
        JC      W28                     ;�������, ���� ������������ ��� "1"
        MOV     AX,592                  ;����� ���������� ������ "0"
W28:
        PUSH    AX                      ;��������� AX
W29:
        IN      AL,PORT_C               ;������ ����� ������ 2 �������
        AND     AL,020H
        JZ      W29                     ;����� ��������� �������� ������
W30:
        IN      AL,PORT_C               ;������ ����� ���� ������ ������������
					;������� � ������ �������
        AND     AL,020H
        JNZ     W30
                                        ;������������� ����� 2 �������
                                        ;��� ��������� ������� ���������� ����
        POP     AX                      ;������������� ����������� �������
W31:                                    ;���������������� �������
        OUT     042H,AL                 ;�������� ������� ���� � ����� 2
        MOV     AL,AH
        OUT     042H,AL                 ;�������� ������� ���� � ����� 2
        RET
WRITE_BIT       ENDP
;------------------------------------------------------------------------
CRC_GEN PROC    NEAR
; ���������� CRC ��� ������������� ����
;
; CRC ������������ ��� ����������� ������ ������
;
; � CY ���������� ��� �� ������� ������������ CRC
;
; ������������ AX � �����
;
;-------------------------------------------------------------------------
        MOV     AX,CRC_REG
                                        ;����������� ����������
                                        ;������������� ���� ���� ������������,
                                        ;���� CY � ������� ��� CRC �� �����
        RCR     AX,1
        RCL     AX,1
        CLC                             ;�������� CY
        JNO     W32                     ;�������, ���� �����������
                                        ;���� ��� ������ XOR � 15 ��������
                                        ;CRC �������� = 1,
        XOR     AX,0810H                ;�� ��������� XOR CRC �������� �
                                        ;0810H
        STC                             ;���������� CY
W32:
        RCL     AX,1                    ;�������� CY (��� ������)
                                        ;� CRC �������
        MOV     CRC_REG,AX              ;��������� CRC
        RET                             ;���������
CRC_GEN ENDP
INCLUDE RWCAS.ASM     ;INT15 - ������ � �������
;------------------------------------------------06-04-89----------
;  ��������� ������������ ������ ����� � �������
;------------------------------------------------------------------
;
;     1.3. ��������� 䠩��
;     ���������  䠩��  �� �����⭮� ���� ����� ᫥���騩 �ଠ�
;(ᬥ饭�� ������ � ����� �  ��⭠����筮�  ��⥬�  ��᫥-
;���):
; 0   ����ন� ���祭�� 0A5h, �ਧ��� ��������� 䠩��.
;
;1-8  ��� 䠩��. ����� ����� 䠩�� �� 1 �� 8 ᨬ�����. �஬� ᨬ-
;     �����, ����᫥���� � ���ᠭ�� �몠 ��� �����⨬� � ���-
;     �� 䠩�� ᨬ����, ������ ���ᨪ � ����� 䠩��  ����᪠��
;     ⠪�� � ���᪨� �㪢�.
;
; 9   ��� 䠩��.  ��।���� ⨯ ᮤ�ঠ饩�� � 䠩�� ���ଠ樨,
;     ᯮᮡ �� �।�⠢����� � 䠩��, �������, � ������� ������
;     ���ଠ�� �뫠 ����ᠭ� � 䠩�. ��� 䠩�� ���������  ᫥-
;     ���騬� ���祭�ﬨ:
;
;     00 - 䠩�, ᮤ�ঠ騩 ���ᨪ-�ணࠬ�� � ᨬ���쭮�  �ଠ-
;          �,  ����ᠭ�� �� �������� ����� � ������� ������
;          SAVE, ���ᠭ���� � ����㭪� 3.51  �������  ���㬥��,
;          ���  䠩�  ������,  ����ᠭ�� ���ᨪ-�ணࠬ��� � ��-
;          ����� �����஢ PRINT# � WRITE#, ���ᠭ��� � ����㭪-
;          �� 3.43 � 3.59 ������� ���㬥��. �� ��ᨪ-�ணࠬ��
;          ⠪�� 䠩� ���뢠���� � ����뢠���� � �������  ����-
;          �஢  OPEN � CLOSE, ���ᠭ��� � ����㭪�� 3.37 � 3.4
;          ������� ���㬥��. � ��砥  �ᯮ�짮�����  ����⭮��
;          ���ᨪ�  ������  OPEN (�.�.3.37) �����뢠�� �� ���-
;          ����� ����� ��������� 䠩��. �㭪�� ������  CLOSE
;          (�.�.3.4)  �����砥��� � �����뢠��� � 䠩� ���������
;          �������������� ���� 䠩�� ��᫥ �����襭��  ����権
;          �����  �  䠩�.  ������� PRINT# (�.�.3.43), WRITE#
;          (�.�.3.59) �����।�⢥��� �����뢠�� �뢮����  ���-
;          �� � 256-����� ���� 䠩��. ����� ��� ���� �����-
;          ����� ���������, �� 楫���� ��९��뢠���� �� ������-
;          ��� ����� � �᢮��������� ��� �ਥ�� ����� ������.
;     01  - 䠩� � ᮤ�ন�� ������ ����⨢��� �����; ������-
;          ������ � ������� ������ BSAVE (�.�.3.51).
;     40 - 䠩�, ᮤ�ঠ騩 ���ᨪ-�ணࠬ�� � ᨬ���쭮�  �ଠ-
;          �. �����뢠���� �� �������� ����� � ������� �����-
;          ஢ SAVE (�.�.3.51) � ��樥� � � ��४⨢� LIST, ���-
;          ᠭ�� � ����㭪�� 3.27, 5.7.
;     80  -  䠩�,  ᮤ�ঠ騩 ���ᨪ-�ணࠬ�� � ᦠ⮬ �ଠ�.
;          �����뢠���� �� �������� �����  �  �������  ������
;          SAVE (�.�.3.51) ��� ��樨.
;     A0 - 䠩�, ᮤ�ঠ騩 ���ᨪ-�ணࠬ�� � ���饭��� �ଠ�.
;          �����뢠���� �� �������� ����� � ������� �����஢
;          SAVE (�.�.3.51) � ��樥� P.
;
;A-B  �����  ����ᠭ���  � 䠩� ���ଠ樨.
;C-D  ���祭�� ᥣ���� ���� �  ����⨢���  �����  ���ଠ樨,
;     ����� �뫠 ��९�ᠭ� � 䠩�.
;E-F  ���祭��  ᬥ饭��  ���� � ����⨢��� ����� ���ଠ樨,
;     ����� �뫠 ��९�ᠭ� � 䠩�.
;10   ����ন� ���祭�� 00, �ਧ��� ���� ��������� 䠩��.
;
;     �ਬ�砭��. ����� ����ᠭ��� �  䠩�  ���ଠ樨,  ���祭��
;ᥣ����  �  ᬥ饭�� ���� (���� ��������� A-F) ������������ �
;��������� ⮫쪮 ��� 䠩��� ⨯�� 01, 80 � �0.
FILE_READ  PROC    NEAR
rc2:
          MOV     BP,SP
          MOV     AX,SS:[BP+2]
          MOV     DS,AX          ;(DS:BX) - ��� �����
          PUSH    BX
RC3:      mov     bx,0
          mov     cx,12
          mov     ah,2
          int     15h        ;����㧪� ���������
          JC      FREND      ;���� ������
          mov     di,0       ;��������� ���������
          cmp     byte ptr es:[di],0a5h
          jnz     rc3
          INC     DI
          POP     BX
          mov     si,0
rc6:      mov     al,byte ptr es:[di]
          CMP     DS:[BX+SI],AL
          jnz     rc2         ;��������� �� ᮢ���
          inc     di
          inc     si
          cmp     si,8
          jnz     rc6
          LEA	  si,fn       ;"���� ������"
	  mov	  cx,LFN
	  call	  P_MSG
          mov     di,10
          mov     cx,es:[di]
          mov     bx,0
          mov     ah,2
          int     15h         ;����㧨�� 䠩�
	  ret
FREND:
	  pop     bx
          RET
FILE_READ  ENDP
;----------------------------------------------06-04-89------------
;   ��������� ������������ ������ ����� �� �������
;------------------------------------------------------------------
FILE_WRITE   PROC     NEAR
          MOV     BP,SP
          MOV     AX,SS:[BP+2]
          MOV     DS,AX          ;(DS:BX) - ��� �����
       PUSH  ES
       PUSH  DS
       POP   ES
       MOV   CX,17
       MOV   AH,3
       push  bx
       INT   15H
       pop   bx
       MOV   CX,DS:[BX+10]
       MOV   BX,0
       POP   ES
       MOV   AH,3
       INT   15H
       PUSH  DS
       RET
FILE_WRITE   ENDP
INCLUDE STP2.ASM
AN_STR  PROC    NEAR
        PUSH    AX
        PUSH    DS
        MOV     AX,DATA
        MOV     DS,AX
        MOV     AL,T_CURSOR
        INC     K_CICL
        ADD     AL,K_CICL
        MOV     AH,80
        TEST    CRT_MODE,2
        JNZ     AN0
        MOV     AH,40
AN0:
        CMP     AL,AH
        JNZ     AN180
        MOV     K_CICL,0
        MOV     T_CURSOR,0
        ADD     DI,80*3
AN180:
        POP     DS
        POP     AX
        RET
AN_STR  ENDP
;AN_STR40  PROC    NEAR
;        PUSH    AX
;        MOV     AL,T_CURSOR
;        INC     K_CICL
;        ADD     AL,K_CICL
;        CMP     AL,40
;        JNZ     AN140
;        MOV     K_CICL,0
;        MOV     T_CURSOR,0
;        ADD     DI,80*4
;
;AN140:
;        POP     AX
;        RET
;AN_STR40  ENDP
        ORG    0F065H
INCLUDE INT10_A.ASM
;----INT 10---------------------------------------------------
;VIDED_IO
;       �� �ணࠬ�� ���ᯥ稢��� ����䥩� �����०����.
;       ������騥 �㭪樨 ॠ��������:
;       (AH)=0 ��⠭���� ०��� (AL) ����ন� ���祭�� ०���.
;               (AL)=0 40*25 ��୮/���� (BW)
;               (AL)=1 40*25 ���⭮�
;               (AL)=2 80*25 ��୮ /����
;               (AL)=3 80*25 ���⭮�
;               ����᪨� ०���
;               (�L)=4 320*200 ���⭮�
;               (AL)=5 320*200 ��୮/����
;               (AL)=6 640*200 ��୮/����
;               CRT MODE=7 80*25 ��୮/���� (०�� CRT)
;               ***NOTE BW MODES OPERATE SAME AS COLOR MODES,BUT COLOR
;               BURST IS NOT ENABLED
;       (AH)=1 ��⠭���� ⨯� �����
;               (CH)= ���� 4-0= ��ப� ��砫� �����
;                      ** �����⭮ �ᥣ�� ��뢠���� ���栭��
;                      ** ���� 5 � 6 ��뢠�� ��ࠢ����୮� ���栭��
;                         ��� ��祧������� �����
;               (CL)= ���� 4-0= ��ப� ��祧������� �����
;       (AH)=2 ��⠭���� ����樨 �����
;               (DH,DL)= ��ப�, ������� (0,0) ���� ���孨� 㣮�
;               (BH)= ����� ��࠭�� (0 ��� ����᪮�� ०���)
;       (AH)=3 �⥭�� ����樨 �����
;               (BH)= ����� ��࠭�� (0 ��� ����᪮�� ०���)
;               �� ��室� (DH,DL)= ��ப�, ������� ⥪�饩 ����樨 �����
;                         (CH,CL)= ����騩 ०�� �����
;       (AH)=4 �⥭�� ����樨 ᢥ⮢��� ���
;              (� �� ��� ��ॠ��������,ᢥ⮢�� ��� ��������)
;               (AH)=0-- LIGHT REN SWITCH NOT DOWN/NOT TRIGGERED
;               (AH)=1-- VALID LIGHT REN VALUE IN REGISTERS
;                      (DH,DL)= ROW,COLUMN OF CHARACTER LP POSN
;                      (CH)= RASTER LINE(0-199)
;                      (BX)=PIXEL COLUMN(0-319,639)
;       (AH)=5 �롮� ��⨢��� ��࠭��� (⮫쪮 ��� ⥪�⮢�� ०����)
;               (AL)= ���祭�� ����� ��࠭��� (0-7 ��� ०���� 0 ��� 1,
;                      0-3 ��� ०���� 2 ��� 3)
;       (AH)=6 �ப��⪠ ��⨢��� ��࠭��� �����
;               (AL)= ��᫮ ��ப �ப���⪨ (�᢮������騥�� ��ப�
;                     ����� ���� ����������� �஡�����)
;                     AL=0 ���⪠ �ᥣ� ����
;               (CH,CL)= ��ப�, ������� ���孥�� ������ 㣫� ����
;               (DH,DL)= ��ப�, ������� �ࠢ��� ������� 㣫� ����
;               (BH)= ��ਡ�� ��� ��ப ���������� ����
;       (AH)=7 �ப��⪠ ��⨢��� ��࠭��� ����
;               (AL) = ��᫮ ��ப�ப��⪨ (�᢮������騥�� ��ப�
;                      ������ ���� ����������� �஡�����)
;                      AL = 0 ���⪠ �ᥣ� ���� (�஡�����)
;               (CH,CL)= ��ப�, ������� ���孥�� ������ 㣫� ����
;               (DH,DL)= ��ப�, ������� ������� �ࠢ��� 㣫� ����
;               (BH)= ��ਡ�� ��� ��ப ����������
;
;       ����� ��ࠡ�⪨ ᨬ�����
;
;       (AH)=8 �⥭�� ��ਡ��/ᨬ���� �⥪�饩 ����樨 �����
;               (BH)= ����� ��࠭��� (⮫쪮 ��� ⥪�⮢��� ०���)
;               �� ��室�:
;               (AL)= ���⠭�� ᨬ���
;               (AH)= ��ਡ�� ���⠭���� ᨬ���� (⮫쪮 ���
;                     ⥪�⮢��� ०���)
;        (AH)=9 ������ ��ਡ��/ᨬ���� � ⥪���� ������ �����
;               (BH)= ����� ��࠭��� (⮫쪮 ��� ⥪�⮢�� ०����)
;               (CX)= ���稪 ᨬ����� (����७��) ��� �����
;               (AL)= ������ ��� �����
;               (BL)= ��ਡ�� ᨬ���� (⥪��) ��� 梥� (��䨪�)
;
;       (AH)=10 ������ ⮫쪮 ᨬ���� � ⥪���� ������ �����
;               (BH)= ����� ��࠭��� (⮫쪮 ��� ⥪�⮢�� ०����)
;               (CX)= ���稪 ᨬ����� (����७��) ��� �����
;               (AL)= ������ ��� �����
;       ��� �����/�⥭�� ᨬ����� � ����᪮� ०��� �����
;               �ନ������ � ������������, ����� ��室���� � ���
;               (⮫쪮 ���� 128 ������). ��� ���뢠���/����� �����
;               128 ������ ���짮��⥫� ������ �१ ���뢠��� 1FH
;               (�祩�� 0007�) ���樠����஢��� 㪠��⥫� �� 1� ⠡����,
;               ᮤ�ঠ��� ���� ����� 128 ������.
;
;       �� ����� ᨬ����� � ����᪨� ०���� ���稪 �� �㤥� �����-
;               ������ ⮫쪮 ��� ⥪�饩 ��ப�. ���室 � ᫥������
;               ��ப� �㤥� �����४��.
;
;
;       ������ ��ࠡ�⪨ ��䨪�
;       (AH)=11 ��⠭���� 梥⮢�� �������
;               (BH)= ���⮢�� ������ (0-127)
;               (BL)= ��ࠢ����� 梥⮬ (��� ⥪�饩 梥⮢��
;                  �������, ⮫쪮 ��� ��䨪� 320*200
;                      ��=0 �롮� 梥� 䮭�, BL (0-15)
;                      BH=1 �롮� �������:
;                           BL=0 - ������ (1), ���� (2), ����� (3)
;                           BL=1 - 樠� (1), ������ (2), ���� (3)
;
;
;       (AH)=12 ������ �窨
;               (DX)= ����� ��ப�
;               (CX)= ����� �������
;               (AL)= ���祭�� 梥�
;                      �᫨ ��� 7 AL=1, ⮣�� ���祭�� 梥� ��ࠧ����
;                      ����樥� �OR ��������� ���祭�� � ⥪�饣�
;       (AH)=13 �⥭�� �窨
;               (DX)= ����� ��ப�
;               (CX)= ����� �������
;               (AL)= �����頥��� ���⠭��� �窠
;
;�뢮� � ०��� ⥫�⠩�� ���� ASCIL
;
;       (AH)=14 ������ � ०��� ⥫�⠩��
;               (AL)= ������ ��� �����
;               (BL)= ���� ��������� � ����᪮� ०���
;               (BH)= ����� ��࠭��� � ⥪⮢�� ०���
;               ����砭��: ࠧ��� �࠭� ��।������ �।���⥫쭮
;                          ������� ०����
;       (AH)=15 ����騩 �����०��
;               �����頥� ⥪�饥 ���ﭨ�
;               (AL)= ����騩 ��⠭������� ०��
;               (AH)= ����� ������� ᨬ���� �� �࠭�
;               (BH)= ������ ��⨢��� ��࠭��
;
;       CS,SS,DS,ES,BX,CX,DX C��࠭����� �ணࠬ���,
;       ��⠫�� ��������
;--------------------------------------------------------
        ASSUME CS:CODE,DS:DATA,ES:VIDEO_RAM
M1      LABEL   WORD   ; ������ �ணࠬ� ����� ����/�뢮�
        DW      OFFSET SET_MODE         ; ��⠭���� ०���
        DW      OFFSET SET_CTYPE        ; ��⠭���� ࠧ��� �����
        DW      OFFSET SET_CPOS         ; ��⠭���� ⥪�饩 ����樨 �����
        DW      OFFSET READ_CURSOR      ; �⥭�� ⥪�饩 ����樨 �����
        DW      OFFSET READ_LPEN        ; �⥭�� ⥪�饩 ����樨 ᢥ⮢��� ���
        DW      OFFSET ACT_DISP_PAGE    ; ��⠭���� ��⨢��� ��࠭��� �����
        DW      OFFSET SCROLL_UP        ; ��६�饭�� ����� ����� �� �࠭�
        DW      OFFSET SCROLL_DOWN      ; ��६�饭�� ����� ���� �� �࠭�
        DW      OFFSET READ_AC_CURRENT  ; �⥭�� ᨬ���� � ��ਡ�� � ����樨 �����
        DW      OFFSET WRITE_AC_CURRENT ; ������ ᨬ���� � ��ਡ�� � ������ �����
        DW      OFFSET WRITE_C_CURRENT  ; ������ ⮫쪮 ᨬ���� � ⥪���� ������ �����
        DW      OFFSET SET_COLOR        ; ��⠭���� 梥⮢�� �������
        DW      OFFSET WRITE_DOT        ; ������ �窨 (���ᥫ�)
        DW      OFFSET READ_DOT         ; �⥭�� �窨 (���ᥫ�)
        DW      OFFSET WRITE_TTY        ; ��ᯫ�� � ०��� ⥫�⠩��
        DW      OFFSET VIDEO_STATE      ; ���ﭨ� �����
M1L     EQU     $-M1
VIDEO_IO        PROC   NEAR
        STI                   ; ࠧ���� ���뢠���
        CLD                   ; 㪠��⥫� ���ࠢ����� - ���।
        PUSH    ES
        PUSH    DS            ; ��࠭���� ॣ���஢
        PUSH    DX
        PUSH    CX
        PUSH    BX
        PUSH    SI
        PUSH    DI
        PUSH    AX            ; ��࠭��� ��
        MOV     AL,AH         ; ��࠭��� ���訩 ���� � AL
        XOR     AH,AH         ; ������ ��
        SAL     AX,1          ; 㬭����� �� 2 ��� ��ᬮ�� ⠡����
        MOV     SI,AX         ; �������� � SI ��� ��⢫����
        CMP     AX,M1L        ; �஢�ઠ �� �� <= 15 (�࠭�� ����)
        JB      M2            ; ���室 �� �����⨬��� ���祭��
        POP     AX            ; ������ ��ࠬ���
        JMP     VIDEO_RETURN  ; ��室, �� ����୮
M2:     MOV     AX,DATA
        MOV     DS,AX
        MOV     AX,START_BUFFER   ; ᥣ���� ��� 梥⭮�� ������
        MOV     ES,AX         ; ��⠭����� ��砫� ������ ����� �����
        POP     AX            ; ����⠭����� ���祭��
        MOV     AH,CRT_MODE          ; ������� ⥪�騩 ०�� � ��
        JMP     WORD PTR CS:[SI+OFFSET M1]
VIDEO_IO        ENDP
;--------------------------------------------------------
;SET_MODE
;       �� �ணࠬ�� ���樠������� ��ࠬ����
;       �롮� ०���. ��࠭ ��頥���.
;�室
;       (AL)= ᮤ�ন� ������� ०�� (0-7)
;��室��� ������ ���
;
;-------------------------------------------------------
;-------- COLUMNS
; T������ ��ࠬ��஢ ��࠭��� ०����
VIDEO_PARMS     LABEL        BYTE
M8      LABEL   BYTE
        DB      CHAR_40_MODE, CHAR_40_MODE, CHAR_80_MODE, CHAR_80_MODE
        DB      MED_RES_MODE, MED_RES_MODE, HIGH_RES_MODE, HIGH_RES_MODE
M9      LABEL   WORD    ; ⠡��� ॣ����樨 ࠧ��஢
        DW      2048    ; 40x25
        DW      4096    ; 80x25
        DW      16384   ; ��䨪�
        DW      16384   ;
SET_MODE        PROC   NEAR
        PUSH    AX           ; ��࠭��� ॣ���� AX
        CMP     AL, 8        ; �஢�ઠ �࠭��� ��ࠬ���
        JB      MM3          ; ���室, �᫨ <
CURSOR_BLINK:
        CMP     CURSOR_ON,0FH   ; �஢�ઠ 䫠�� ��⠭���� �����
        JZ      MMM15
;        TEST    CURSOR_ON,0FFH
;        JNZ     CUR1
;        TEST    CURSOR_MODE,0FFH
;        JZ      MMM15
CUR1:   MOV     AX,EXTRA_BUFFER ; ����� ᥣ���� �����-���� (16�)
        MOV     ES,AX
        CALL    M21
        NOT     CURSOR_ON
        POP     AX           ; ���⠭����� ॣ���� AX
MMM15:  JMP     VIDEO_RETURN  ; ������ �� �����
MM3:
        CLI
        MOV     AH,AL
        IN      AL,TRAP_A     ; ������� ���뢠���
        MOV     AL,AH         ; ��� ⨣��� HMI (����誠)
        MOV     SI,AX         ; ��࠭��� ०�� � AL
        MOV     CRT_MODE,AL   ; ��࠭��� ०�� � SL
        MOV     BX, OFFSET M8
        XLAT    CS:M8
        OUT     SCR_MODE,AL   ; ��⢫����
        MOV     ADDR_6845,REG3D4  ; ��⠭����� ०��
;
;-------����襭��/����� 梥� (��� D7)
;
        CMP     AH,3
        JNZ     ED1
        MOV     AL,40H       ; ���⭮�
        JMP     ED3
ED1:    CMP     AH,2
        JNZ     ED2
        MOV     AL,40H
        JMP     ED3
ED2:    MOV     AL,80H       ; ��୮/����
ED3:    OUT     P6A,AL
;
;-------���������� � ���⪠ ������ ॣ���樨
;
        XOR DI,DI             ; ��⠭����� ०�� ��� ॣ����樨
        MOV  CRT_START,DI     ; ��砫�� ����
        MOV     CX,8192       ; ��᫮ ᫮� � ���� ॣ����樨
        CMP     AH,4          ; �஢�ઠ �� ��䨪�
        JAE     M12           ; �� ����᪨� ०���
        CALL    NMI_DISABLE   ; ����� NMI �� �६� ���⪨
        MOV     AX,0720H      ; ������ ���������� ��� ⥪�⮢�� ०����
        PUSH    CX
        REP     STOSW         ; ���⪠ ���� ��� ⥪�⮢�� ०����
        POP     CX
        CALL    NMI_ENABLE    ; ������� NMI
M12:                          ; ���⪠ ���� ॣ����樨
        XOR     AX,AX         ; ���������� ��� ����᪨� ०����
        REP     STOSW         ; ���⪠ ������ ॣ����樨
        MOV     ACTIVE_PAGE,AL         ; ��⠭����� ��⨢��� ��࠭��� 0
;
;------����襭�� �����
;
        MOV     CURSOR_MODE,607H       ; ��⠭����� ⥪�騩 ०�� �����
        MOV     CRT_MODE_SET,29H       ; ���࠭��� ���祭��
        MOV     AL, 80
        MOV     BX,SI
;
;------��।����� �᫮ ������� ��� ��� �����
;      � �᫮, �ᯮ��㥬�� ��� TTY ����䥩�
;
        TEST    BL,2
        JNE     M13
        SAR     AX,1
M13:
        MOV     CRT_COLS,AX          ; ��᫮������� �� �࠭� (40 ��� 80)
;
;-------��⠭����� ������ ����� (������ ����� ��� ����᪮�� ०���)
;
        AND     SI,06H        ; ���饭�� ������ �� ⠡��� ࠧ��஢
        MOV     CX,CS:[SI+OFFSET M9]   ; ������ ��� ���⪨
        MOV     CRT_LEN,CX    ; ���࠭��� ࠧ��� (�� �ᯮ������ ��� �/�)
        MOV     CX,8          ; ������ �� ����樨 �����
        MOV     DI,OFFSET CURSOR_POSN
        PUSH    DS            ; ��⠭����� ᥣ����
        POP     ES            ; ������ ��� 1� ���� ⠡����
        XOR     AX,AX
        REP     STOSW         ; ��������� ��ﬨ
        MOV     CURSOR_ON,AL  ; �������, �� ����� �� ��⠭�����
;
;------��⠭���� ॣ���� ᪠��஢����------
;
        MOV     AL,3DH        ; ���祭�� 3DN ��� ��� ०����, �஬� 640*200
        CMP     BL,6          ; ����� 640*200 �/�
        JNZ     M14           ; �᫨ ���, � ������
        MOV     AL,3FH        ; �᫨ ��, � ��⠭����� 3FH
M14:                          ; �뤠�� ᪮४�஢���� ���祭�� � ���� 3D9
        MOV     CRT_PALLETTE,AL ; ���࠭��� ���祭�� ��� ���襣� �ᯮ�짮�����
;
;------���樠������ ����� NMI
;
        XOR     AX,AX
        MOV     ES,AX
        MOV     AX,OFFSET NMI_SERVICE
        MOV     DI,8
        STOSW
        PUSH    CS
        POP     AX
        STOSW
        POP     AX         ;���⠭������� ॣ���� AX
;
;------��ଠ��� ������ �� ��� �����-�����⮢
;
VIDEO_RETURN:
        POP     DI
        POP     SI
        POP     BX
M15:                          ; ������ �����
        POP     CX
        POP     DX
        POP     DS
        POP     ES            ; ����⠭������� ॣ���஢
        IRET                  ; �� ᤥ����, ������
SET_MODE        ENDP
;-------------------------------------------------------------------------
; SET_CTYPE
;       �� �ணࠬ�� ��⠭�������� ࠧ��� �����
; �室
;       (CX)-����ন� ࠧ��� ����� CH-������ �࠭�� CL-������ �࠭��
;---------------------------------------------------------------------------
SET_CTYPE       PROC   NEAR
        MOV     CURSOR_MODE,CX       ; ���࠭��� � ������ ������
        JMP     VIDEO_RETURN
SET_CTYPE       ENDP
;---------------------------------------------------------------------------
; SET_CPOS
;       �� ���ࠬ�� ��⠭�������� ⥪���� ������ �����
;       �� ������� X-Y ����業⠬
; �室
;       DX-��ப�, ������� ������ ���������
;       BH-��࠭�� �࠭� ��� �����
;--------------------------------------------------------------------------
SET_CPOS        PROC   NEAR
        PUSH    AX           ; ��࠭��� ॣ���� AX
        CMP     DH,25
        JNB     MM171
        MOV     CL,BH                ; ��࠭��
        XOR     CH,CH                ; ��⠭����� ���稪 横��
        SAL     CX,1                 ; ���饭�� ᫮��
        MOV     SI,CX                ; �ᯮ��㥬 ������� ॣ����
        CMP     ACTIVE_PAGE,BH       ; ��⨢��� ��࠭��
        JNE     MM17
                                     ; �� ������
M17:
        CMP     CRT_MODE,4           ; ����᪨� ०��
        JAE     MM17                 ; ��, ���室
        MOV     AX,EXTRA_BUFFER
        MOV     ES,AX
        MOV     AX,DATA
        MOV     DS,AX
;        PUSHF                        ; ���࠭��� 䫠��
        CLI                          ; ������� ���뢠���
        CMP     CURSOR_ON,0FFh        ; �᫨ ����� ��襭 ��祣� �� ������
        JNE     M125                   ; ���室, �᫨ ��⠭�����
        CALL    M21                   ; ������஢��� �����
M125:   MOV     CURSOR_ON,00          ; ������ 䫠� �����
;        POPF                         ; ����⠭����� 䫠��
        mov     cursor_count,2
MM17:
        MOV     [SI+OFFSET CURSOR_POSN],DX     ; ���࠭��� 㪠��⥫�
        STI                                    ; ������
MM171:
        POP     AX         ;���⠭������� ॣ���� AX
        JMP     VIDEO_RETURN
SET_CPOS        ENDP
;
;-----�������/ࠧ���� ���栭�� �����
;
BLINK_DISABLE  PROC    NEAR
        CLI
        PUSH   AX
        MOV    AX,DATA
        MOV    DS,AX
        MOV    CURSOR_ON,0Fh         ; ������� ���栭�� �����
        POP    AX
        RET
BLINK_DISABLE  ENDP
BLINK_ENABLE  PROC    NEAR
        CLI
        PUSH   AX
        MOV    AX,DATA
        MOV    DS,AX
        MOV    CURSOR_ON,0           ; ������� ���栭�� �����
        POP     AX
        RET
BLINK_ENABLE  ENDP
;
;-----������� ������ �����, AX ᮤ�ন� ���/�������
;
REMOVE_CURSOR  PROC    NEAR          ;AX ᮤ�ঠ� ��ப�/������� ��� �����
        PUSH   AX
        MOV    AX,DATA
        MOV    DS,AX
;        PUSHF                        ; ���࠭��� 䫠��
        CLI                          ; ������� ���뢠���
        CMP    CURSOR_ON,0FFh        ; �᫨ ����� ��襭 ��祣� �� ������
        JNE    M25                   ; ���室, �᫨ ��⠭�����
        CALL   M21                   ; ������஢��� �����
M25:    MOV    CURSOR_ON,00          ; ������ 䫠� �����
;        POPF                         ; ����⠭����� 䫠��
        POP    AX
        RET
REMOVE_CURSOR  ENDP
M21:    ; ������஢��� ����� �� �࠭�
        PUSH   SI                    ; ��࠭��� SI
        CALL   S26                   ; ���᫨�� ���� �����
        ADD    AX,050H               ;
        MOV    SI,AX                 ; ��᫠�� ���� ����� � SI
        TEST   CRT_MODE,2            ; ����� 80x25 ?
        JNZ    M24
        SHL    SI,1                  ; ��� 40x25, 㬭���� ���� �� 2
        ADD    SI,050H
        NOT    ES: BYTE PTR [SI]     ; ������஢��� 4 ���� �����
        INC    SI
        NOT    ES: BYTE PTR [SI]
        ADD    SI,2000H
        NOT    ES: BYTE PTR [SI]
        DEC    SI
M21A:   NOT    ES: BYTE PTR [SI]
        POP    SI                    ; ���⠭����� SI
        RET
M24:    ADD    SI,0A0H
        NOT    ES: BYTE PTR [SI]     ; ��� ०��� 80x25,
        AND    ES: BYTE PTR [SI],07FH  ;\
        ADD    SI,2000H              ; �������㥬 2 ���� �����
        OR     ES: BYTE PTR [SI],80H  ;\
        JMP    M21A
;-------------------------------------------------------------------------
; READ_CURSOR
; ������ ⥪�饥 ��������� �����
;        � �ணࠬ�� �⠥� ⥪�饥 ���祭�� ��������� �����
;       �ଠ���� � �����頥� ��뢠�饩 �ணࠬ��
; �室:
;       BH-����� ��࠭��� ��� �����
; ��室:
;       DX-��ப�/������� ⥪�饩 ����樨 �����
;       CX-����騩 ०�� �����
;--------------------------------------------------------------------------
READ_CURSOR     PROC   NEAR
        MOV     BL,BH
        XOR     BH,BH
        SAL     BX,1                 ; ���饭�� ᫮��
        MOV     DX,[BX+OFFSET CURSOR_POSN]  ; ������ ����� ��� ��࠭��� ��
        MOV     CX,CURSOR_MODE
        POP     DI
        POP     SI
        POP     BX
        POP     DS                   ; CX � DX �� ����ࠨ������
        POP     DS
        POP     DS
        POP     ES
        IRET
READ_CURSOR     ENDP
;-------------------------------------------------------------------------
; ACT_DISP_PAGE
;       �� �ணࠬ�� ��⠭�������� ��⨢��� ��࠭��� �����,
;       �ᯮ���� ���������� ��������� ��� �ࠢ����� �����
; �室
;       AL-H���� ����� ��࠭���
; ��室
;       ����஫��� ���뢠���� ��� ��⠭���� ����� ��࠭���
;--------------------------------------------------------------------------
ACT_DISP_PAGE   PROC   NEAR
        PUSH    AX
        TEST    CRT_MODE,4       ; ��䨪� 320�200
        JNZ     A_D_RET
        MOV     BP,ES            ; ���࠭��� ����稭� 0B800h
        MOV     BX,EXTRA_BUFFER
        MOV     ES,BX
        CALL    REMOVE_CURSOR    ; ����� ����� � �࠭�
        MOV     ACTIVE_PAGE,AL   ; ��⠭����� ����� ��࠭���
;
;-------���᫨�� ���� ��砫�� ���� ���������
;
        CBW                      ; �८�ࠧ����� ���� � ᫮��
        MUL     CRT_LEN          ; �������� �� ࠧ��� �࠭�
        MOV     CRT_START,AX     ; ��砫�� ���� ��࠭���
;
;-------��⠭����� 㪠��⥫�
;
        MOV     SI,AX            ; �����⥫� ���筨�� (����ࠦ����)
        XOR     DI,DI            ; �����⥫� �ਥ�����
;
;-------����஢��� ����� ��࠭���
;
        MOV     CL,25            ; ��� 25 ��ப
BEG:
        MOV     CH,BYTE PTR [CRT_COLS] ;��� 40 ��� 80 �������
        PUSH    DS               ; ���࠭��� ᥣ���� ������
COL:
        MOV     DS,BP            ; ��⠭����� 0B800h � DS
        LODSW                    ; �⥭�� ᨬ����/��ਡ��
        MOV     BL,AH            ; �����஢��� ��ਡ��
        XOR     AH,AH
        POP     DS               ; ���⠭����� ᥣ���� ������
        PUSH    DS               ; ����� ��࠭��� DATA
        PUSH    CX               ; ���࠭��� ���稪
        PUSH    SI               ; ���࠭��� 㪠��⥫�
        PUSH    DI
        MOV     CX,1             ; ���쪮 ��� 1 ᨬ����
        CALL    S1B              ; ���ᮢ��� ����ࠦ����
        POP     DI
        INC     DI
        POP     SI               ; ���⠭����� 㪠��⥫�
        POP     CX               ; ���⠭����� ���稪
        DEC     CH               ; ᫥����� �������
        JNZ     COL
        ADD     DI,120           ; ��⠭����� 㪠��⥫� �� ᫥������ ��ப�
        POP     DS               ; ���⠭����� ᥣ���� ������
        TEST    CRT_MODE,2       ; 40X25 ?
        JZ      A_D_NEXT         ; ��,
        ADD     DI,120           ; �ਡ�����
A_D_NEXT:
        LOOP    BEG              ; �� ᫥������ ��ப�
A_D_RET:
        POP     AX
        JMP     VIDEO_RETURN
ACT_DISP_PAGE   ENDP
;-------------------------------------------------------------------------
;SET COLOR
;       �� �ணࠬ�� ��⠭�������� 梥��� ������� ��� ०����
;       �।���� ࠧ�襭��
;�室
;       (BH) HAS COLOR ID
;                  BH=0-���� 䮭� ��⠭����������
;                       ��� 梥� 0 �� ��. 5 ��⠬ BL (0-31),
;                  BH=1-�롮� ������� �� �᭮��
;                       ��. ��� BL:
;                             0=������, ����, ����� ��� 梥⮢ 1,2,3
;                             1=���㡮�, 樠�, 䨮��⮢� ��� 梥⮢ 1,2,3
;       (BL) HAS THE COLOR VALUE TO BE USED
; ��室
;       ��⠭���� 梥⮢�� �������
;---------------------------------------------------------------------------
SET_COLOR       PROC   NEAR
        PUSH    AX
        MOV     AH,CRT_PALLETTE      ; ���祭�� ⥪�饩 �������
        IN      AL,SCR_MODE          ; ����� �࠭�
        OR      BH,BH                ; ���� 0 (��=0)
        JNZ     M20                  ; ���室 �� 梥� 1 (��=1)
;
;------��ࠡ�⪠ 梥� 0-��⠭���� 梥� 䮭�
;
        MOV     BH,BL
        AND     AX,0E0C8H            ; ������� ⥪�騥 ��. 5 ��⮢
        AND     BX,01F37H            ; ���訥 3 ��� �室���� ��祭��
        OR      AX,BX                ; ������� ���祭�� � ०���
M19:                                 ; �뢮� �������
        MOV     CRT_PALLETTE,AH      ; ���࠭��� ���祭�� 梥�
        OUT     SCR_MODE,AL
        POP     AX
        JMP     VIDEO_RETURN
;
;------��ࠡ�⪠ 梥� 1-��⠭���� �ॡ㥬�� �������
;
M20:
        AND     AX,0EFEFH            ; ������ ��� �롮� �������
        SHR     BL,1                 ; �஢���� ����訩 ��� BL
        JNC     M19                  ; ��� ᤥ����
        OR      AX,1010H             ; ��⠭����� ��� �롮� �������
        JMP     M19
SET_COLOR       ENDP
;--------------------------------------------------------------------------
;VIDEO STATE
; �ணࠬ�� �����頥� ⥪�饥 ���ﭨ� ����� � AX
; AH = ������⢮ �������
; AL = ����騩 ०�� �����
; BH = ����� ⥪�饩 ��⨢��� ��࠭���
;----------------------------------------------------------------------------
VIDEO_STATE     PROC   NEAR
        MOV     AH,BYTE PTR CRT_COLS ; ������� �᫮ �������
        MOV     AL,CRT_MODE          ; ����騩 ०��
        MOV     BH,ACTIVE_PAGE       ; ������� ⥪���� ��⨢��� ��࠭��
        POP     DI                   ; ���⠭����� ०��
        POP     SI
        POP     CX
        JMP     M15                  ; ������ � ��뢠�饩 �ணࠬ��
VIDEO_STATE     ENDP
;----------------------------------------------------------------------------
; POSITION
;       �� �ணࠬ�� ������ ���� ����
;       ॣ����樨 ᨬ����� � ⥪�⮢�� ०���
;�室
;       AX = ��ப�, ������� ����樨
;��室
;       AX = ���饭�� ����樨 ᨬ���� � ���� ॣ����樨
;----------------------------------------------------------------------------
POSITION        PROC   NEAR
        PUSH    BX                   ; ���࠭��� ॣ����
        MOV     BX,AX
        MOV     AL,AH                ; ��ப� � AL
        MUL     BYTE PTR CRT_COLS    ; ��।����� �᫮ ���� ��� ��ப�
        XOR     BH,BH
        ADD     AX,BX                ; �������� ���祭�� �������
        SAL     AX,1                 ;* 2 ��� ���⮢ ��ਡ�⮢
        POP     BX
        RET
POSITION        ENDP
NMI_DISABLE PROC NEAR
        PUSH    AX
        IN      AL,SCR_MODE
        OR      AL,8                 ; ��⠭����� ��� ࠧ�襭�� NMI
        OUT     SCR_MODE,AL
        POP     AX
        RET
NMI_DISABLE ENDP
NMI_ENABLE PROC NEAR
        PUSH    AX
        IN      AL,SCR_MODE
        AND     AL,0F7H              ; ������ ��� ࠧ�襭�� NMI
        OUT     SCR_MODE,AL
        POP     AX
        RET
NMI_ENABLE ENDP
;------------------------------------------------------------------------------
;SCROLL UP
;       �� �ணࠬ�� ��६�頥� ���� ᨬ�����
;       ����� �� �࠭� (�ப��⪠)
;�室
;       (AH)= ����訩 ०��
;       (AL)= ������⢮ ᤢ������� ��ப
;       (CX)= ��ப�/�������-��न���� ������ 㣫� ����
;       (DX)= ��ப�/�������-��न���� ������� �ࠢ��� 㣫� ����
;       (BH)= ��ਡ��� ᨬ���� �஡��� (��� �᢮��������� ��ப)
;       (DS)= ������� ������
;       (ES)= ������� ���� ॣ����樨
;��室
;       NONE-�������஢��� ���� ॣ����樨
;------------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA,ES:DATA
SCROLL_UP       PROC   NEAR
        MOV     BL,AL                ; ���࠭��� ���稪 ��ப
        CMP     AH,4                 ; �஢�ઠ �� ����᪨� ०��
        JC      N1                   ; ��ࠡ��뢠���� �⤥�쭮
        JMP     GRAPHICS_UP          ; �� ����᪨� ०���
N1:                                  ; �த������ ⥪��
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        CALL    NMI_DISABLE          ; ������� NMI
        PUSH    BX                   ; ���࠭��� ��ॡ�� ����������
        MOV     AX,CX                ; ���孨� ���� 㣮� ����
        CALL    SCROLL_POSITION      ; ��⠭����� ��� �ப��⪨
        JZ      N7                   ; ���� �஡��� (����������)
        ADD     SI,AX                ; � ���� (��砫�)
        MOV     AH,DH                ; ��᫮ ��ப � ����
        SUB     AH,BL                ; ��᫮ ��।�������� ��ப (����)
N2:                                  ; ���� �� ��ப��
        CALL    N10                  ; �������� ���� ��ப�
        ADD     SI,BP
        ADD     DI,BP                ; �����⥫� �� ᫥������ ��ப� � �����
        DEC     AH                   ; ���稪 ��ப ᤢ���
        JNZ     N2                   ; ���� �� ��ப��
N3:                                  ; �室 ���⪨
        POP     AX                   ; ���⠭������� ��ਡ�� � AH
        MOV     AL,' '               ; ���������� �஡�����
N4:                                  ; ���� ���⪨
        CALL    N11
        ADD     DI,BP                ; �����⥫� �� ᫥������ ��ப�
        DEC     BL                   ; ���稪 ��ப �ப��⪨
        JNZ     N4                   ; ���� ���⪨
N5:                                  ; ����� �ப��⪨
        POP     DS
N6:                                  ; ������ �� �����
        CALL    NMI_ENABLE           ; �����饭�� NMI
        POP     DX
        POP     CX
        POP     BX
        MOV     AX,EXTRA_BUFFER
        MOV     ES,AX
        POP     AX
        MOV     BH,0                 ; ���� ����������
        PUSH    AX
        CALL    REMOVE_CURSOR        ; ��६����� �����
        CALL    BLINK_DISABLE        ; ������� ���栭��
        CALL    UP_GRAPHICS
SCROLL_RET:
        CALL    BLINK_ENABLE         ; ������� ���栭��
        POP     AX
        JMP     VIDEO_RETURN         ; ������ �� �����
N7:                                  ; ���� ����������
        MOV     BL,DH                ; ������� ���稪 ��ப
        JMP     N3                   ; �� ����� �⮩ ������
SCROLL_UP       ENDP
;------���� ���� ��ࠡ�⪨ �������� �ப��⪨
SCROLL_POSITION PROC NEAR
N9:     CALL    POSITION             ; �८�ࠧ����� 㪠��⥫� ������ ॣ����樨
        ADD     AX,CRT_START         ; ���饭�� ��⨢��� ��࠭���
        MOV     DI,AX                ; �ப��⪠ �� ���� (�����)
        MOV     SI,AX                ; �ப��⪠ � ���� (��砫�)
        SUB     DX,CX                ; DX=��ப�/������� � �����
        INC     DH
        INC     DL                   ; ���६��� �� 0
        XOR     CH,CH                ; ������ ���訩 ���� ���稪�
        MOV     BP,CRT_COLS          ; ������� �᫮ ������� �࠭�
        ADD     BP,BP                ; ������� ��� ���� ��ਡ��
        MOV     AL,BL                ; ������� ���稪 ��ப
        MUL     BYTE PTR CRT_COLS    ; ��।����� ᬥ饭�� ��砫쭮�� ����
        ADD     AX,AX                ; ������� ��� ���� ��ਡ��
        PUSH    ES                   ; ��⠭����� ������ ���� ॣ����樨
        POP     DS                   ; ��� ����� 㪠��⥫��
        CMP     BL,0                 ; 0-����� �ப��⪨ ������ ����������
        RET                          ; ������ � ��⠭������묨 䫠����
SCROLL_POSITION ENDP
;-----�������� ��ப� (�ப��⪠)
N10     PROC    NEAR
        MOV     CL,DL                ; ������� �᫮ ������� ��� ᤢ���
        PUSH    SI
        PUSH    DI                   ; ���࠭��� ��砫�� ����
        REP     MOVSW                ; �������� ��ப� �� �࠭�
        POP     DI
        POP     SI                   ; ���⠭����� ����
        RET
N10     ENDP
;-----������ ��ப� (�ப��⪠)
N11     PROC    NEAR
        MOV     CL,DL                ; ������� �᫮ ������� ��� �ப��⪨
        PUSH    DI
        REP     STOSW                ; ���뫪� ᨬ���� ����������
        POP     DI
        RET
N11     ENDP
;------------------------------------------------------------------------
;SCROLL_DOWN
;       �� �ணࠬ�� ��६�頥� ᨬ��� � 㪠������ �����
;       ���� �� �࠭� (�ப��⪠) �������� ���孨� (�᢮�����訥��)
;       ��ப� ������� ᨬ�����
;�室
;       (AH) = ����騩 ०��
;       (AL) = ������⢮ ��ப �ப��⪨
;       (CX) = ���孨� ���� 㣮� ����
;       (DX) = ������ �ࠢ� 㣮� ����
;       (BH) = ������ ����������
;       (DS) = ������� ������
;       (ES) = ������� ���� ॣ����樨
;��室
;       ������஢����� ᮤ�ন��� �࠭�
;---------------------------------------------------------------------------
SCROLL_DOWN     PROC   NEAR
        STD                          ; ���ࠢ����� ��� �ப��⪨ ����
        MOV     BL,AL                ; ���稪 ��ப � BL
        CMP     AH,4                 ; �஢�ઠ �� ��䨪�
        JC      N12
        JMP     GRAPHICS_DOWN        ; �� ����᪨� ०���
N12:                                 ; �த������ (⥪��)
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DS
        CALL    NMI_DISABLE          ; ������� NMI
        PUSH    BX                   ; ���࠭��� ��ਡ�� � BH
        MOV     AX,DX                ; ������ �ࠢ� 㣮� ����
        CALL    SCROLL_POSITION      ; ������� ������� ॣ����樨 (��ࠬ���� �ப��⪨
        JZ      N16
        SUB     SI,AX                ; ���� ��砫�
        MOV     AH,DH                ; ������� ��饥 �᫮ ��ப
        SUB     AH,BL                ; ���稪 ᤢ���� �ப��⪨
N13:
        CALL    N10                  ; �������� ���� ��ப� (�ப��⪠)
        SUB     SI,BP
        SUB     DI,BP
        DEC     AH
        JNZ     N13
N14:
        POP     AX                   ; ����⠭����� ��ਡ��  � ��
        MOV     AL,' '
N15:
        CALL    N11                  ; ������ ���� ��ப� (�ப��⪠)
        SUB     DI,BP                ; �� ᫥������ ��ப�
        DEC     BL
        JNZ     N15
                                     ; ������ �� �����
        POP     DS
        CALL    NMI_ENABLE           ; ������� NMI
        POP     DX
        POP     CX
        POP     BX
        MOV     AX,EXTRA_BUFFER      ; ���� ���� ॣ����樨
        MOV     ES,AX
        POP     AX
        MOV     BH,0
        PUSH    AX
        CALL    REMOVE_CURSOR
        CALL    BLINK_DISABLE
        CALL    DOWN_GRAPHICS
        JMP     SCROLL_RET
N16:
        MOV     BL,DH
        JMP     N14
SCROLL_DOWN     ENDP
;---------------------------------------------------------------------------
;READ_AC_CURRENT
;       �� �ணࠬ�� ���뢠�� ᨬ��� � ��ਡ�� � ⥪�饩 ����樨 �����
;�室
;       (AH) = ����騩 ०��
;       (BH) = ����� ��࠭��� (⮫쪮 ��� ⥪�⮢�� ०����)
;       (DS) = ������� ������
;       (ES) = ������� ���� ॣ����樨
;��室
;       (AL) = ���⠭�� ᨬ���
;       (AH) = ���⠭�� ��ਡ��
;----------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA,ES:DATA
READ_AC_CURRENT PROC    NEAR
        CMP     AH,4                 ; �� ��䨪� ?
        JC      P1
        JMP     GRAPHICS_READ        ; �� �⥭�� � ����᪨� ०����
P1:                                  ; �த������ (⥪��)
        CALL    FIND_POSITION        ; ��।����� ������ ����� ��� ��࠭���
        MOV     SI,BX                ; ��⠭����� ������ � SI
        PUSH    ES                   ; ��⠭�����: c������ ������ = ����-ᥣ����
        POP     DS                   ; ������� ᨬ���/��ਡ��
        LODSW                        ; ������
        JMP     VIDEO_RETURN
READ_AC_CURRENT ENDP
FIND_POSITION   PROC   NEAR
        MOV     CL,BH                ; ��।������ ����樨 ����� ��� ��࠭���
        XOR     CH,CH                ; ����� ⥪�饩 ��࠭��� � c�
        MOV     SI,CX                ; ��।��� � SI ��� ������, 㬭������
        SAL     SI,1                 ; �� 2 (᫮�� ᬥ饭��)
        MOV     AX,[SI+ OFFSET CURSOR_POSN]    ; ������� ��ப�/������� ��� �⮩ ��࠭�
        XOR     BX,BX                ; ��砫�� ���� = 0
        JCXZ    P5                   ; ��࠭�� �������
P4:                                  ; ���� �� ��࠭�栬
        ADD     BX,CRT_LEN           ; ����� ����
        LOOP    P4
P5:                                  ; ��࠭�� �������
        CALL    POSITION             ; ��।����� �祩�� � ������ ॣ����樨
        ADD     BX,AX                ; �ਡ����� � ��砫� ������
        RET
FIND_POSITION   ENDP
;---------------------------------------------------------------------------
;WRITE_AC_CURRENT
;       �� �ணࠬ�� �����뢠�� ᨬ��� � ��ਡ�� � ⥪���� ������ �����
;�室:
;       (AH) = ����騩 ०��
;       (BH) = ����� ��࠭���
;       (CX) = ���稪 (������⢮ ����७�� ᨬ����)
;       (AL) = ������ ��� �����
;       (BL) = A�ਡ�� ᨬ���� ��� ����� (��� 梥� ��� ��䨪�)
;       (DS) = ������� ������
;       (ES) = ������� ������ (����) ॣ����樨
;---------------------------------------------------------------------------
WRITE_AC_CURRENT        PROC  NEAR
        CMP     AH,4                 ; ��䨪� ?
        JC      P6
        JMP     GRAPHICS_WRITE       ; �� ����᪨� ०���
P6:                                  ; �த������� (⥪��)
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DS
        CALL    NMI_DISABLE          ; ������� NMI
        MOV     AH,BL                ; ������� ��ਡ�� � AH
        PUSH    AX                   ; ���࠭��� ��ਡ��/ᨬ���
        PUSH    CX                   ; ���稪 �����
        CALL    FIND_POSITION        ; ��।����� ������ ����� ��� ��࠭���
        MOV     DI,BX                ; ���� � DI
        POP     CX                   ; ����⠭����� ���稪
        POP     AX                   ; ������/��ਡ��
        REP     STOSW                ; ������� ᨬ���/��ਡ�� �⮫쪮 ࠧ,
                                     ; ᪮�쪮 �ॡ���� (��)
        CALL    NMI_ENABLE           ; ������� NMI
        POP     DS
        POP     CX
        POP     BX
        MOV     AX,EXTRA_BUFFER      ; ����뫪� � ���� ॣ����樨 �������� ��࠭���
        MOV     ES,AX
        POP     AX
        CMP     ACTIVE_PAGE,BH
        JE      P7A
        JMP     VIDEO_RETURN
P7A:
        PUSH    AX
        CALL    REMOVE_CURSOR
        CALL    WRITE_GRAPHICS
        JMP     SCROLL_RET
WRITE_AC_CURRENT        ENDP
;----------------------------------------------------------------------------
;WRITE_C_CURRENT
;       �� �ணࠬ�� �����뢠�� ᨬ��� � ⥪���� ������ �����,
;       ��ਡ�� �� ���������. � ��䨪� BL ᮤ�ন� ��ਡ�� 梥�.
;�室:
;       (AH) = ����騩 ०��
;       (BH) = ����� ��࠭���
;       (CX) = ���稪 (������⢮ ����७�� ᨬ����)
;       (AL) = ������ ��� �����
;       (DS) = ������� ������
;       (ES) = ������� ������ (����) ॣ����樨
;OUTPUT
;       NONE
;-----------------------------------------------------------------------------
WRITE_C_CURRENT PROC    NEAR
        CMP     AH,4                 ; ��䨪� ?
        JC      P10
        JMP     GRAPHICS_WRITE       ; �� ����᪨� ०���
P10:
        PUSH    AX
        MOV     AH,BH                ; ���࠭��� ����� ��࠭���
        CALL    NMI_DISABLE          ; ������� NMI
        PUSH    AX                   ; ���࠭��� � �⥪�
        PUSH    CX                   ; ���稪 �����
        CALL    FIND_POSITION        ; ��।����� ������ ����� ��� ��࠭���
        MOV     DI,BX                ; ���� � DI
        POP     CX                   ; C��稪 �����
        POP     AX                   ; BL = ᨬ��� ��� �����
P11:                                 ; 横� �����
        STOSB                        ; ������� ᨬ���
        CMP     ACTIVE_PAGE,AH
        JNE     PP11
        MOV     BL,ES:[DI]
        PUSH    ES
        PUSH    DS
        PUSH    CX
        PUSH    DI
        PUSH    AX
        MOV     DX,EXTRA_BUFFER
        MOV     ES,DX
        MOV     CX,1
        CALL    REMOVE_CURSOR
        CALL    WRITE_GRAPHICS
        POP     AX
        POP     DI
        POP     CX
        POP     DS
        POP     ES
pp11:
        INC     DI                   ; �ய����� ��ਡ��
        LOOP    P11                  ; ���� ����� ᨬ���� �� ���稪�
        CALL    NMI_ENABLE
        POP     AX
        JMP     VIDEO_RETURN
WRITE_C_CURRENT ENDP
INCLUDE INT10_BN.ASM
;----------------------------------------------------------------------------
; READ DOT  --  WRITE DOT
;�� �ணࠬ�� ����뢠��/�����뢠�� ��� (���ᥫ�) � 㪠������ �祩��
;�室:
;  DX -����� �����୮� ��ப� (0-199)
;  CX -����� �����୮� ������� (0-639)
;  AL - �窠 ��� �뢮�� (1,2 ��� 4 ��� � ����ᨬ��� �� ०��� ����� �窨,
;       ��஢���� �� �ࠢ��� ���). �᫨ ��� 7=1, � ����室��� �믮�����
;       ������ XOR ��� AL � ⥪�騬 ���祭��� �窨.
;  DS - ᥣ���� ������
;  ES - ᥣ���� (������) ���� ॣ����樨
;��室:
;  AL - ���祭�� �窨, ��஢������ �� �ࠢ��� ���
;----------------------------------------------------------------------------
        ASSUME CS:CODE,DS:DATA,ES:DATA
READ_DOT        PROC   NEAR   ;�⥭�� �窨
        CALL    R3            ;��।����� ������ ���� �窨
        MOV     AL,ES:[SI]    ;������� ����
        AND     AL,AH         ;��᪠ �� ��㣨� ���� � ����
        SHL     AL,CL         ;��஢���� ���祭��
        MOV     CL,DH         ;������� �᫮ ��⮢
        ROL     AL,CL         ;��஢���� �� �ࠢ��� ��� १����
        JMP     VIDEO_RETURN  ;������ �� �����
READ_DOT        ENDP
WRITE_DOT       PROC   NEAR   ;������ �窨
        PUSH    AX            ;�o�࠭��� ���祭�� �窨
        PUSH    AX            ;������
        CALL    R3            ;��।����� ������ ���� �窨
        SHR     AL,CL         ;����� ��� ��⠭���� ��⮢ �� ��室�
        AND     AL,AH         ;������ ��⠫�� ����
        MOV     CL,ES:[SI]    ;������� ⥪�騩 ����
        POP     BX            ;����⠭����� 䫠� ��� XOR (��� 7)
        TEST    BL,80H        ;��⠭�����?
        JNZ     R2            ;��, ������ XOR ��� �窨
        NOT     AH            ;��⠭����� ���� ��� ��।�� 㪠������ ��⮢,
                              ; ��� ����� ���祭�� ��� ��⮢
        AND     CL,AH
        OR      AL,CL
R1:
        MOV     ES:[SI],AL    ;������� ���� � ������
        POP     AX
        JMP     VIDEO_RETURN  ;������ �� �����
R2:                           ;XOR_DOT
        XOR     AL,CL         ;XOR ��� �窨
        JMP     R1            ;����� ����� �窨
WRITE_DOT       ENDP
;--------------------------------------------------------------------------
;�� �ணࠬ�� ��।���� �⭮�⥫�� ���� ���� (����� ����
;ॣ����樨), �� ���஬� ������ ���� ��⠭�/����ᠭ� �窠 � ������묨
;���न��⠬� � ����᪨� ०����
;�室:
; DX - ����� �����୮� ��ப� (0-199)
; CX - ����� ������� (0-639)
;��室:
; SI - ᬥ饭�� ���� �窨 � ����
; AH - ��᪠ ��� �뤥����� ��⮢ �窨
; CL - ������⢮ ᤢ���� ��⮢ ��᪨ � AH
; DH - �᫮ ��� ���祭�� �窨
;-----------------------------------------------------------------------------
R3      PROC    NEAR
        PUSH    BX                   ;���࠭��� ॣ�����
        PUSH    AX
;
;------��।������ 1-�� ���� �������� ��ப� 㬭������� �� 40.
;      ����訩 ��� ��ப� ��।���� �⭮/������ 80-���⮢�� ��ப�
;
        MOV     AL,40
        PUSH    DX                   ;���࠭��� ���祭�� ��ப�
        AND     DL,0FEH              ;���� ��� ��/����
        MUL     DL                   ;AX ᮤ�ন� ���� 1-�� ���� 㪠������
                                     ;��ப�
        POP     DX                   ;����⠭����� ���祭��
        TEST    DL,1                 ;�஢���� �� ��/����
        JZ      R4                   ;���室, �᫨ ��ப� �⭠�
        ADD     AX,2000H             ;���饭�� ��� ��宦����� ������ ��ப
R4:                                  ;��⭠� ��ப�
        MOV     SI,AX                ;��।��� 㪠��⥫� � SI
        POP     AX                   ;����⠭����� ���祭��
        MOV     DX,CX                ;���祭�� ������� � DX
;
;-------��।������ ��ࠬ��஢ ����᪨� ०���� ��� �����।�⢥�����
;       �������⢨�
;��⠭����� ॣ����� � ᮮ⢥��⢨� � ०����:
;  CH - ��᪠ ��� ����襩 ��� ���� ������� (3/2 ��� ��᮪���/�।����
;       ࠧ�襭��)
;  CL - ������⢮ ��⮢ ���� � ���祭�� ������� (3/2 ��� �/� )
;  BL - ��᪠ �롮� ��⮢ �� 㪠������� ���� (80H/C0H ��� �/� )
;  BH - ������⢮ ���, ��।����饥 ���(1/2 ��� �/�)
        MOV     BX,2C0H
        MOV     CX,302H              ;��⠭���� ��ࠬ��஢ ��� ०��� �।����
                                     ; ࠧ�襭��
        CMP     CRT_MODE,6
        JC      R5                   ;��ࠡ�⪠ ��� �।���� ࠧ�襭��
        MOV     BX,180H
        MOV     CX,703H              ;��⠭����� ��ࠬ���� ��� ०��� ��᮪���
                                     ; ࠧ�襭��
;
;------��।������ ᬥ饭�� ��� � ���� �� ��᪥ �������
R5:
        AND     CH,DL
;
;------��।������ ᬥ饭�� ���� �� �⮬� ���� � �������
;
        SHR     DX,CL                ;����� ��� ���४樨
        ADD     SI,DX                ;���६��� 㪠��⥫�
        MOV     DH,BH                ;������� ������⢮ ��⮢ � DH
;
;------�������� BH (����騥 ���� � ����) �� CH (ᬥ饭�� ���)
;
        SUB     CL,CL                ;������
R6:
        ROR     AL,1                 ;��ࠢ������� ���祭�� � AL
                                     ;(��� �����)
        ADD     CL,CH                ;�ਡ����� ���祭�� ᬥ饭�� ���
        DEC     BH                   ;���稪 横��
        JNZ     R6                   ;�� ��室, CL ᮤ�ন� ���稪 ᤢ����
                                     ;��� ��ࠡ��뢠���� ��⮢
        MOV     AH,BL                ;������� ���� � AH
        SHR     AH,CL                ;�������� ���� ��� ���४樨
        POP     BX                   ;����⠭����� ॣ����
        RET                          ;������ � ��⠭������묨 ��ࠬ��ࠬ�
R3      ENDP
;----------------------------------------------------------------------------
;SCROLL UP
;  �� �ணࠬ�� ��६�頥� ���� ���ଠ樨 ����� �� �࠭� (��� ��䨪�)
;�室:
; CH,CL -���� ���孨� 㣮� ���� �ப��⪨,
; DH,DL -������ �ࠢ� 㣮� ���� �ப��⪨,
; BH -   ��� �������⥫� ��� �᢮���������� ��ப
; AL -   ������⢮ ��ப �ப��⪨ (AL=0 ����砥� ����� �ᥣ� ����)
; DS -   ᥣ���� ������
; ES -   ᥣ���� ���� ॣ����樨
;----------------------------------------------------------------------------
GRAPHICS_UP     PROC   NEAR
        CALL    UP_GRAPHICS
        JMP     VIDEO_RETURN
UP_GRAPHICS:
        MOV     BL,AL                ;��᫮ ��ப � BL
        MOV     AX,CX                ;������ ������ ���孥�� 㣫� � AX
;------�ᯮ�짮���� �ணࠬ�� ��� ����樮��஢����
;      ���� �����頥��� 㬭������ �� 2 ��� ���४樨 ���祭��
        CALL    GRAPH_POSN
        MOV     DI,AX                ;���࠭��� १���� ��� ���� �ਥ�����
;
;------��।������ ࠧ��� ����
;
        SUB     DX,CX
        ADD     DX,101H              ;����४�஢����� ���祭��
        SAL     DH,1                 ;�������� �� 4, ⠪-��� ����� 8
                                     ; �祪/ᨬ��� �� ���⨪���
        SAL     DH,1
;
;-------��।����� ०��
;
        test    CRT_MODE,2           ;�।��� ࠧ�襭��?
        JNZ     R7                   ;��।����� ���� ���窠 ��� ��᮪���
                                     ; ࠧ�襭��
;
;------�ப��⪠ ����� (�।��� ࠧ�襭��)
;
        SAL     DL,1                 ;��᫮ ������� * 2, �.�.
                                     ;  ����� 2 ����/ᨬ���
        SAL     DI,1                 ;���饭�� * 2, �.�. ����� 2 ���� /ᨬ���
;
;------��।����� ���� ���筨�� � ����
;
R7:                                  ;���� ���筨�
        PUSH    ES                   ;������� ᥣ����� ����� 㪠��⥫��
                                     ;  ���� ॣ����樨
        POP     DS
        SUB     CH,CH                ;������ ���訩 ���� ���稪�
        SAL     BL,1                 ;�������� �᫮ ��ப �� 4
        SAL     BL,1
        JZ      R11                  ;�᫨ 0, � ������ ���⪠ ����
        MOV     AL,BL                ;������� �᫮ ��ப � AL
        MOV     AH,80                ;80 �� ��ப�
        MUL     AH                   ;��।����� ᬥ饭�� ���筨��
        MOV     SI,DI                ;��⠭����� ���筨�
        ADD     SI,AX                ;�ਡ����� ᬥ饭�� � ����
        MOV     AH,DH                ;��᫮ ��ப � �����
        SUB     AH,BL                ;��।����� �᫮ ᤢ����
;
;------����, ��६���騩 ���� ��ப� �� ���� ��室
;      (� ��� � ����� ����)
R8:                                  ;���� �� ��ப�
        CALL    R17                  ;��।������ ���� ��ப�
        SUB     SI,2000H-80          ;�����⥫� �� ᫥������ ��ப�
        SUB     DI,2000H-80
        DEC     AH                   ;��᫮ ��ப �ப��⪨
        JNZ     R8                   ;�த������, ���� �� ���६�������
;
;------���������� �᢮��������� ��ப
R9:                                  ;�室 ���⪨
        MOV     AL,BH                ;��ਡ�� ����������
R10:
        CALL    R18                  ;���⪠ ��ப�
        SUB     DI,2000H-80          ;�����⥫� �� ᫥������ ��ப�
        DEC     BL                   ;��᫮ ��ப ��� ����������
        JNZ     R10                  ;���� ���⪨
        RET                 ;�� ᤥ����

R11:                                 ;������� ����������
        MOV     BL,DH                ;��⠭����� ���稪 ����������
                                     ;  ��� �ᥣ� ����
        JMP     R9                   ;�� ����� ����
GRAPHICS_UP     ENDP

;-----------------------------------------------------------------------------
;SCROLL DOWN
;  �� �ணࠬ�� ��६�頥� ���� ���ଠ樨 ���� �� �࠭� (��� ��䨪�)
;�室:
;  CH,CL - ���孨� ���� 㣮� ���� �ப��⪨
;  DH,DL - ������ �ࠢ� 㣮� ���� �ப��⪨
;  BH -    ��� ��������⥫� ��� �᢮���������� ��ப
;  AL -    ������⢮ ��ப �ப��⪨ (AL=0 ����砥� ����� �ᥣ� ����)
;  DS -    ᥣ���� ������
;  ES -    ᥣ���� ���� ॣ����樨
;-----------------------------------------------------------------------------

GRAPHICS_DOWN   PROC   NEAR
        CALL    DOWN_GRAPHICS
        JMP     VIDEO_RETURN

DOWN_GRAPHICS:
        STD                          ;��⠭����� ���ࠢ�����
        MOV     BL,AL                ;���稪 ��ப � BL
        MOV     AX,DX                ;������ �ࠢ� 㣮� ���� � AX
;
;------�ᯮ�짮���� ����ணࠬ�� ��� ����樮��஢����.
;      ���� �����頥��� 㬭������ �� 2 ��� ���४樨 ���祭��
;
        CALL    GRAPH_POSN
        MOV     DI,AX                ;���࠭��� १���� ��� ���� �ਥ�����
;
;------��।������ ࠧ��� ����
;
        SUB     DX,CX
        ADD     DX,101H              ;����४�஢����� ���祭��
        SAL     DH,1                 ;�������� �᫮ ��ப �� 4, �.�. �����
                                     ; 8 �祪 �� ᨬ��� �� ���⨪���
        SAL     DH,1
;
;------��।������ ०���
;
        TEST    CRT_MODE,2           ;�।��� ࠧ�襭��?
        JNZ     R12                  ;��।����� ���� ���筨�� ��� ��᮪���
                                     ; ࠧ�襭��
;
;------�����⪠ ���� (�।��� ࠧ�襭��)
;
        SAL     DL,1                 ;��᫮ ������� * 2, �.�. ����� 2
                                     ; ����/ᨬ���

        SAL     DI,1                 ;���饭�� *2 �.�. ����� 2 ����/ᨬ���
        INC     DI                   ;�����⥫� �� ��᫥���� ����
;
;------��।������ ���� ���筨�� � ����
R12:                                 ;���� ���筨�� �ப��⪨
        PUSH    ES                   ;��� ᥣ���� ���� ॣ����樨
        POP     DS
        SUB     CH,CH                ;������ ���訩 ���� ���稪�
        ADD     DI,240               ;�����⥫� ��᫥���� ��ப� ���ᥫ��
        SAL     BL,1                 ;�������� �᫮ ��ப �� 4
        SAL     BL,1
        JZ      R16                  ;�᫨ 0, � ������ �� ����
        MOV     AL,BL                ;��᫮ ��ப � AL
        MOV     AH,80                ;80 ���� �� ��ப�
        MUL     AH                   ;��।����� ᬥ饭�� ���筨��
        MOV     SI,DI                ;��⠭����� ���筨�
        SUB     SI,AX                ;������ ᬥ饭��
        MOV     AH,DH                ;��᫮ ��ப � ����
        SUB     AH,BL                ;��।����� �᫮ ᤢ����
;
;------����, �६���騩 ���� ��ப� �� ���� ࠧ (��� � ����� ����
;       �����६����)
R13:                                 ;���� �� ��ப�
        CALL    R17                  ;�������� ���� ��ப�
        SUB     SI,2000H+80          ;��३� � ᫥���饩 ��ப�
        SUB     DI,2000H+80
        DEC     AH                   ;��᫮ ��ப ��� �ப��⪨
        JNZ     R13                  ;�म�����, ���� �� ��६�������
;
;------���������� �᢮��������� ��ப
R14:                                 ;�室 ���⪨
        MOV     AL,BH                ;��ਡ�� ����������
R15:                                 ;�室 ���⪨
        CALL    R18                  ;������ ��ப�
        SUB     DI,2000H+80          ;�����⥫� �� ᫥������ ��ப�
        DEC     BL                   ;��᫮ ��ப ��� ����������
        JNZ     R15                  ;���� ���⪨
        CLD                          ;������ 䫠� ���ࠢ�����
        RET              ;�� ᤥ����

R16:                                 ;������� ����������
        MOV     BL,DH                ;��⠭����� ���稪 ����������
                                     ; ��� �ᥣ� ����
        JMP     R14                  ;�� ����� ����

GRAPHICS_DOWN   ENDP

;------�ணࠬ�� ��६�饭�� ����� ��ப� ���ଠ樨

R17     PROC    NEAR
        MOV     CL,DL                ;��᫮ ���� � ��ப�
        PUSH    SI
        PUSH    DI                   ;���࠭��� 㪠��⥫�
        REP     MOVSB                ;������ ���稪
        POP     DI
        POP     SI
        ADD     SI,2000H
        ADD     DI,2000H             ;�����⥫� ���⭮�� ����
        PUSH    SI
        PUSH    DI                   ;���࠭��� 㪠��⥫�
        MOV     CL,DL                ;������ ���稪
        REP     MOVSB                ;�������� ���⭮� ����
        POP     DI
        POP     SI                   ;������ 㪠��⥫�
        RET                          ;������
R17     ENDP
;
;------���⪠ ����� ��ப�
;
R18     PROC    NEAR
        MOV     CL,DL                ;��᫮ ���� � ����
        PUSH    DI                   ;���࠭��� 㪠��⥫�
        REP     STOSB                ;��᫠�� �������⥫�
        POP     DI                   ;������ 㪠��⥫�
        ADD     DI,2000H             ;�����⥫� ���⭮�� ����
        PUSH    DI
        MOV     CL,DL
        REP     STOSB                ;��������� ���⭮� ����
        POP     DI
        RET                          ;������
R18     ENDP
;---------------------------------------------------------------------------
;GRAPHICS WRITE
;�� �ணࠬ�� �����뢠�� ᨬ��� � ASCII � ⥪���� ������ �� �࠭�
; (����᪨� ०���)
;�室:
; AL - ᨬ��� ��� �����,
; BL - ��ਡ�� 梥�, ����� ������ �ᯮ�짮������ � ����⢥ 梥� ᨬ����.
;       �᫨ ��� 7=1, � �믮������ ������ XOR ��� ⥪�騬 ���⮬ ����
;       ॣ����樨 � �������,
; CX - �᫮ ᨬ����� ��� �����,
; DS - ᥣ���� ������,
; ES - ᥣ���� ���� ॣ����樨
;
;GRAPHICS READ
;  �� �ணࠬ�� ���뢠�� ᨬ��� � ASCII � ⥪�饩 ����樨 �࠭�
;  �८�ࠧ������� �祪 �࠭� � ������� ������� ᨬ����� � ���
;  (����᪨� ०���)
;�室:
; ���  (0 - ��।���� 梥� 䮭�)
;��室:
; AL - ���⠭�� ᨬ��� (0, �᫨  �� ������)
;
;��� ����� �ணࠬ� ������ ᨬ����� (8*8 �祪) �࠭���� � ���.
; ���� �������� ����� (128...255) - ������ �࠭���� � ���. ����� �१
; ����뢠��� INT 1FH (7CH) - 㪠��⥫� �� ⠡����.
;------------------------------------------------------------------------
        ASSUME CS:CODE,DS:DATA,ES:DATA
GRAPHICS_WRITE  PROC   NEAR
        CALL    WRITE_GRAPHICS
        JMP     VIDEO_RETURN

WRITE_GRAPHICS:
        MOV     AH,0
        PUSH    AX                   ;���࠭��� ��� ᨬ����
;
;-------��।������ ����樨 � ���� ॣ����樨 ��� ���뫪� ����� �祪
;
        CALL    S26                  ;��।����� �祩�� � ���� ॣ����樨
S1A:    MOV     DI,AX                ;�����⥫� ���� - � DI
;
;------ ��।����� ������� ��� �����祭�� ����� �祪
;
        POP     AX                   ;����⠭����� ���
S1B:
        CMP     AL,80H               ;���� �������� ����� (128-255)?
        JAE     S1                   ;��
;
;------ ����� (����ࠦ����) ���� � ��ࢮ� ��������, ᮤ�ন��� � ���
;
        MOV     SI,OFFSET CRT_CHAR_GEN      ;���饭�� ������
        PUSH    CS                          ;���࠭��� ᥣ���� � �⥪�
        JMP     SHORT S2                    ;��।����� ०��
;
;------ ������ ��ன �������� ����� (���᪨�) �࠭���� � ���짮��⥫�᪮� ���
;
S1:                                  ;������� ���७���� �����
        SUB     AL,80H               ;������ ���筨� ��� ��ன ��������
        PUSH    DS                   ;���࠭��� 㪠��⥫� ������
        SUB     SI,SI
        MOV     DS,SI                ;��⠭����� ����� ����樨
        ASSUME  DS:ABS0
        LDS     SI,EXT_PTR           ;������� ᬥ饭�� ⠡����
        MOV     DX,DS                ;������� ᥣ���� ⠡����
        ASSUME  DS:DATA
        POP     DS                   ;����⠭����� ᥣ���� ������
        PUSH    DX                   ;���࠭��� ᥣ���� ⠡����
;
;------ ��।������ ����᪮�� ०��� ����樨
;
S2:
        SAL     AX,1                 ;�������� ���祭�� ���� �� 8
        SAL     AX,1
        SAL     AX,1
        ADD     SI,AX                ;SI- ᬥ饭�� �ॡ㥬��� ���� � ⠡���
        MOV     AL,CRT_MODE
        POP     DS            ;����⠭����� 㪠��⥫� ᥣ���� ⠡����
        TEST    AL,2       ;����� 2?
        JNZ     S201                  ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        JMP     S7
S201:    TEST    AL,4      ;����� 4?
        JNZ     S3
;
;------ ����⮢� ०�� ��᮪��� ࠧ�襭��
;
SS3:

        PUSH    DI            ;���࠭��� 㪠��⥫� ���� ॣ����樨
        PUSH    SI            ;���࠭��� 㪠��⥫� ����
SSS:
        MOV     DH,4          ;������⢮ 横���
SS4:
        LODSB                 ;������� ���� �� 㪠��⥫� � AL
        TEST    BL,78H        ;������������ ��⥭ᨢ����� ��� ॢ���
        JNZ     SS6           ;������ ������ � 梥�
        STOSB                 ;���뫪� � ���� ॣ����樨
        LODSB
SS5:

        MOV     ES:[DI+2000H-1],AL     ;��᫠�� �� ����� ��������
        ADD     DI,79         ;��।��� ᫥������ ��ப� � ���� ॣ����樨
        DEC     DH            ;�믮����� 横�
        JNZ     SS4

        POP     SI
        POP     DI            ;����⠭����� 㪠��⥫� ���� ॣ����樨
        INC     DI            ;�����⥫� �� ������ ᫥���饣� ᨬ����

        CALL    AN_STR

        CMP     DI,8000-80*3

        JNB     S5_S2


        LOOP    SS3    ;���� ����� ᨬ����

S5_S2:
        RET
SS6:
        OR      AL,80H        ;���������� ��� �����
        STOSB                 ;�������� ����
        LODSB                 ;����� ��������� ����
        OR      AL,80H        ;���������� ��� �����
        JMP     SS5            ;��������
;
;------ ����᪨� ०�� ��᮪��� ࠧ�襭��
;
S3:
        PUSH    DI            ;���࠭��� 㪠��⥫� ���� ॣ����樨
        PUSH    SI            ;���࠭��� 㪠��⥫� ����
        MOV     DH,4          ;��᫮ 横���
S4:
        LODSB                 ;������� ����
        TEST    BL,080H       ;�஢�ઠ, ������ �� �ᯮ�짮������ ������ XOR
        JNZ      S6           ; �� ���뫪� ᨬ���� � ���� ॣ����樨
        STOSB                 ; ���. ��᫠�� � ���� ॣ����樨
        LODSB
S5:

S51:    MOV     ES:[DI+2000H-1],AL     ;��᫠�� �� ����� ��������
        ADD     DI,79         ;��।��� ᫥������ ��ப� � ���� ॣ����樨
        DEC     DH            ;�믮����� 横�
        JNZ     S4
        POP     SI
        POP     DI            ;����⠭����� 㪠��⥫� ���� ॣ����樨
        INC     DI            ;�����⥫� �� ������ ᫥���饣� ᨬ����



        LOOP    S3            ;���� ����� ᨬ����
        RET
S6:
        XOR     AL,ES:[DI]    ;������ XOR � ⥪�騬 ���祭���
        STOSB                 ;��᫠�� ��� �窨
        LODSB                 ;������� ��� ���⭮�� ����
        XOR     AL,ES:[DI+2000H-1]     ;
        JMP     S5            ;��������
;
;------ ������ � ०��� �।���� ࠧ�襭��
;
S7:
;        CLI
        MOV     DL,BL         ;���࠭��� ���訩 ��� 梥�
        SAL     DI,1          ;�������� ᬥ饭�� �� 2, �.�. �����
                              ;  2 ���� �� ᨬ���
        CALL    S19           ;������� BL �� ᫮��
S8:


        PUSH    DI            ;���࠭��� 㪠��⥫� ���� ॣ����樨
        PUSH    SI            ;���࠭��� 㪠��⥫� ����
        MOV     DH,4          ;��᫮ 横���
S9:
        LODSB                 ;������� ��� �窨
        CALL    S21           ;�㡫�஢��� �� ����
        AND     AX,BX         ;�८�ࠧ����� �� � 梥� 䮭� (0)
        TEST    DL,80H        ;���� ������ XOR
        JZ      S10           ;���, ��᫠�� ⠪��, ����� ����
        XOR     AH,ES:[DI]    ;�믮����� XOR � ����� ���������
        XOR     AL,ES:[DI+1]  ; � � ��㣮� ���������
S10:                          ;
        MOV     ES:[DI],AH    ;��᫠�� ���� ����
        MOV     ES:[DI+1],AL  ;��᫠�� ��ன ����
        LODSB                 ;������� ��� �窨
        CALL    S21
        AND     AX,BX         ;�८�ࠧ����� 梥�
        TEST    DL,80H        ;�����: ���� ������ XOR?
        JZ      S11           ;���, ��������� ���祭��
        XOR     AH,ES:[DI+2000H]       ;������ XOR � ��ࢮ� ���������
        XOR     AL,ES:[DI+2000H+1]     ;� � ��ன ���������
S11:                          ;
        MOV     ES:[DI+2000H],AH
        MOV     ES:[DI+2000H+1],AL     ;��᫠�� �� ����� ���� ����
        ADD     DI,80         ;�����⥫� �� ᫥������ �祩��
        DEC     DH
        JNZ     S9     ;�������
        POP     SI            ;����⠭����� 㪠��⥫� 横��
        POP     DI            ;����⠭����� 㪠��⥫� ���� ॣ����樨
        INC     DI            ;�����⥫� �� ������ ᫥���饣� ᨬ����
        INC     DI


        CALL    AN_STR
        CMP     DI,8000-80*3
        JNB     S5_S21


        LOOP    S8            ;���� �����
S5_S21:
;        STI
        RET
GRAPHICS_WRITE  ENDP
;-----------------------------------
; �⥭�� � ����᪨� ०����
;-----------------------------------
GRAPHICS_READ   PROC   NEAR
        CALL    S26           ;�����頥� ᬥ饭�� � ���� ॣ����樨
        MOV     SI,AX         ;���࠭��� � SI
        SUB     SP,8          ;���।����� ������� ��� �࠭���� ����
                              ; ��⠭��� �窨
        MOV     BP,SP         ;�����⥫� ��� �࠭���� ������
;
;------ ��।������ ����᪨� ०����
;
        TEST    CRT_MODE,2
        PUSH    ES
        POP     DS
        JZ      S13
;
;------ �⥭�� � ०��� ��᮪��� ࠧ�襭��
;------ ������� ���祭�� �� ���� ॣ����樨 � �८�ࠧ����� � ��� �窨
;
        MOV     DH,4          ;��᫮ ��室�� 横��
S12:
        MOV     AL,[SI]        ;������� ���� ����
        MOV     [BP],AL        ;� ������� ��࠭����
        INC     BP             ;�������� �祩��
        MOV     AL,[SI+2000H]  ;������� ���� �� ����襩 ������ ����
                               ; ॣ����樨
        MOV     [BP],AL        ;��஢���� � ��࠭���
        INC     BP
        ADD     SI,80         ;�����⥫� � ���� ॣ����樨
        DEC     DH            ;����
        JNZ     S12           ;�믮����� �� ࠧ
        JMP SHORT S15         ;���室 � ��࠭���� ����� �祪
;
;------ �⥭�� � ०��� �।���� ࠧ�襭��
;
S13:
        SAL     SI,1          ;���饭�� *2, �.�. ����� 2 ���� �� ᨬ���
        MOV     DH,4          ;��᫮ ��室�� 横��
S14:
        CALL    S23           ;����� ���� ���⮢ �� ���� ॣ����樨
        ADD     SI,2000H      ;���室 � ����襩 ��� ���� ॣ����樨
        CALL    S23           ;����� ���� ��� ��࠭����
        SUB     SI,2000H-80   ;������ 㪠��⥫� �� ������ ���� ����
        DEC     DH
        JNZ     S14           ;�믮����� 8 ࠧ
;
;------ ���࠭��� �������, ᮤ�ঠ��� ᨬ���, 㯮�冷���
;
S15:                          ;���� ᨬ���
        MOV     DI,OFFSET CRT_CHAR_GEN      ;���饭�� ������
        PUSH    CS
        POP     ES
        SUB     BP,8          ;��஢���� 㪠��⥫� �� ��砫� ������
                              ; ��࠭����
        MOV     SI,BP
        CLD                   ;��⠭����� ���ࠢ�����
        MOV     AL,0          ;����騩 �⬥祭�� ��� �窨
S16:
        PUSH    SS            ;��⠭����� ������ �⥪�
        POP     DS            ;��� �ࠢ�������� ��ப�
        MOV     DX,128        ;��᫮ ����஢ �஢�ન
S17:
        PUSH    SI            ;���࠭��� 㪠��⥫� ������ ��࠭����
        PUSH    DI            ;���࠭��� 㪠��⥫� ����
        MOV     CX,8          ;��᫮ ���⮢ ��� �ࠢ�����
        REPE    CMPSB         ;�ࠢ���� 8 ���⮢
        POP     DI            ;����⠭����� 㪠��⥫�
        POP     SI
        JZ      S18           ;�᫨ 0, ��� �������
        INC     AL            ;��� ����, �� ᫥���騩
        ADD     DI,8          ;������騩 ��� �窨
        DEC     DX            ;����
        JNZ     S17           ;�믮����� �� �ᥬ
;
;------ ������ �� ᮢ���, �������� �ᯮ������ �� ��ன ��������
;
        CMP     AL,0          ;�᫨ AL<>0, � �஢�७� ⮫쪮 ��ࢠ� ��������
        JE      S18           ;�᫨ AL=0, � �஢�७� ���
        SUB     AX,AX
        MOV     DS,AX         ;��⠭����� ������ �����
        ASSUME  DS:ABS0
        LES     DI,EXT_PTR    ;������� 㪠��⥫�
        MOV     AX,ES         ;�஢����, ������� �� 㪠��⥫�
        OR      AX,DI         ;�᫨ �� 0, � �� �������
        JZ      S18           ;��� ��᫠ ��ᬠ�ਢ���
        MOV     AL,128        ;��砫� ��� ��ன ��������
        JMP     S16           ;�������� � ��������� ��� ���
        ASSUME  DS:DATA
;
;------ ���न���� ᨬ���� ������� (AL=0, �᫨ �� �������)
S18:
;
        ADD     SP,8          ;���⪠ �⥪�, �� �� ��࠭﫨
        JMP     VIDEO_RETURN  ;�� ᤥ����
GRAPHICS_READ   ENDP
;--------------------------------------------------------------------
;EXSPAND_MED_COLOR
; �� �ணࠬ�� �����࠭�� ����訥 2 ��� ॣ���� BL (梥� ᨬ����),
; �������� ॣ���� BX (2*8) - ��� �८�ࠧ������ ᨬ���� � 梥⮢�� ������
; �祪
;�室:
; BL - ��ਡ�� 梥� (����訥 2 ���)
;��室:
; BX - 梥� �祪 (8 ����� 2-� ��⮢ 梥�)
;------------------------------------------------------------------------
S19     PROC    NEAR

        PUSH    BX            ;**********************
        MOV     BH,BL
        TEST    BL,0F0H
        JNZ     S190
        POP     BX
        JMP     S191

S190:   AND     BH,03H
        CMP     BL,BH
        POP     BX
        PUSH    CX
        MOV     CL,4
        SHR     BL,CL
        JNZ     S1901
        INC     BL
S1901: POP     CX

S191:   AND     BL,3          ;�뤥���� ���� 梥�
        MOV     AL,BL         ;�����஢��� � AL
        PUSH    CX            ;���࠭��� ॣ����
        MOV     CX,3          ;������⢮ �믮������
S20:
        SAL     AL,1
        SAL     AL,1          ;����� ����� �� 2
        OR      BL,AL         ;��㣠� ����� 梥� � BL
        LOOP    S20           ;��������� ���� BL
        MOV     BH,BL         ;��������� ������ ���� BX
        POP     CX            ;����⠭����� ॣ����
        RET                   ;�� ᤥ����
S19     ENDP
;------------------------------------------------------------------------
; EXPAND_BYTE
;  �� �ணࠬ�� ���� ���� � AL � 㤢������ �� ����, �ॢ��� 8 ��� � 16 ���
;  ������� �����頥��� � AX.
;-------------------------------------------------------------------------
S21     PROC    NEAR
        PUSH    DX            ;���࠭��� ॣ�����
        PUSH    CX
        PUSH    BX

        TEST    DL,0F0H       ;*******************************
        JZ      S211
        NOT     AL            ;********************************

S211:   MOV     DX,0          ;������� १����
        MOV     CX,1          ;������� ��᪨
S22:
        MOV     BX,AX         ;���� �� 蠣
        AND     BX,CX         ;�ᯮ�짮���� ���� ��� �뤥����� ���
        OR      DX,BX         ;�������� � ॣ���� १����
        SHL     AX,1
        SHL     CX,1          ;�������� ���� � ���� �� 1
        MOV     BX,AX         ;���� �� 蠣
        AND     BX,CX         ;�뤥���� �� �� ���
        OR      DX,BX         ;�������� � १����
        SHL     CX,1          ;�������� ⥯��� ⮫쪮 ����
        JNC     S22           ;�ᯮ�짮���� ��� ��᪨, �᫨ �� �����
        MOV     AX,DX         ;������� � ॣ���� ��ࠬ���
        POP     BX
        POP     CX            ;����⠭����� ॣ�����
        POP     DX
        RET                   ;�� ᤥ����
S21     ENDP


INCLUDE INT10_C.ASM   ;INT10 - ���� 3
;---------------------------------------------------------------------------
; MED_READ_BYTE
;  �� �ணࠬ�� ���� 2 ���� �� ���� ॣ����樨, ᫨砥� � ⥪�騬 梥⮬
;  (��।���) � ����頥� ᮮ⢥�����騩 1/0 ��� ��ࠧ� � ⥪���� ������
;  ������ ��࠭����.
; �室:
;  SI,DS - 㪠��⥫� ������ ���� ॣ����樨
;     BX - ���७�� 梥� ᨬ���� (��।��� 梥�)
;     BP - 㪠��⥫� ������ ��࠭����
; ��室:
;     BP ��६�饭 �� ������� ��࠭����
;--------------------------------------------------------------------------
S23     PROC    NEAR
        MOV     AH,[SI]       ;������� ���� ����
        MOV     AL,[SI+1]     ;������� ��ன ����
        MOV     CX,0C000H     ;2 ��� ��᪨ ��� �஢�ન �室��
        MOV     DL,0          ;������� १����
S24:
        TEST    AX,CX         ;�� ���� 䮭� (��ਡ��)?
        CLC                   ;������ ��७��, ������� �� ��
        JZ      S25           ;�᫨ 0, �� 䮭
        STC                   ;���, ��⠭����� ��७��
S25:    RCL     DL,1          ;��������� ��� � १����
        SHR     CX,1
        SHR     CX,1          ;�������� ���� ��ࠢ� �� 2 ���
        JNC     S24           ;�믮����� �� ᭮��, ���� ��᪠ �������
        MOV     [BP],DL       ;��������� १���� � ������ ��࠭����
        INC     BP            ;�ਢ��� � ᮮ⢥��⢨� 㪠��⥫�
        RET                   ;�� ᤥ����
S23     ENDP


;---------------------------------------------------------------------------
; V4_POSITION
;  �� �ணࠬ�� �८�ࠧ�� ������ �����, ᮤ�ঠ����� � �祩�� �����
;  � ᬥ饭�� � ������ ���� ॣ����樨, �뤥��� ���� �� ᨬ���.
;  ��� ��䨪� �।���� ࠧ�襭�� �᫮ ������ ���� 㤢����.
; �室 - �祩�� CURSOR_POSN
;
; ��室 - AX ᮤ�ন� ᬥ饭�� � ���� ॣ����樨
;--------------------------------------------------------------------------
S26     PROC    NEAR
        PUSH    SI
        MOV     AL,ACTIVE_PAGE
        XOR     AH,AH
        SAL     AX,1
        MOV     SI,AX
        MOV     AX,DS:[SI+OFFSET CURSOR_POSN] ;������� ������ ����� ���
                                              ; ��⨢��� �࠭���
        MOV     T_CURSOR,AL
        MOV     K_CICL,0

        POP     SI
GRAPH_POSN      LABEL  NEAR
        PUSH    BX                   ;���࠭��� ॣ����
        MOV     BX,AX                ;���࠭��� ����� ⥪�饣� �����
        MOV     AL,AH                ;������� ��ப� � AL
        MUL     BYTE PTR CRT_COLS    ;�������� �� ����/�������
        SHL     AX,1                 ;�������� �� 4, �.�. �ॡ����
        SHL     AX,1                 ; 4 ���� �� ��ப�
        SUB     BH,BH                ;�뤥���� ���祭�� �������
        ADD     AX,BX                ;��।����� ᬥ饭��
        POP     BX                   ;����⠭����� 㪠��⥫�
        RET                          ;�� ᤥ����
S26     ENDP


        ORG     0F841H

INCLUDE INT12.ASM

;---INT 12--------------------------------------------------------------
; MEMORY_SIZE_DETERMINE
;       �� �ணࠬ�� ��।���� ࠧ��� ����� � ��⥬� ���।�⢮� �������
;       ��४���⥫�� �� ����.
; �室:
;       ������ ����� ��⠭���������� �� �६� �������⨪� �� ����祭��
;       ��⠭��, �ᯮ���� ���� 0-3 ���⮢ G0 � G2.
; ��室:
;       (AX) - ࠧ��� ����� � ������
;--------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
MEMORY_SIZE_DETERMINE   PROC  FAR
        STI                          ;������� ���뢠���
        PUSH    DS                   ;���࠭��� ॣ���� ᥣ����
        MOV     AX,DATA              ;��⠭����� ������
        MOV     DS,AX
        MOV     AX,MEMORY_SIZE       ;������� ���祭�� ࠧ��� �����
        POP     DS                   ;����⠭����� ᥣ����
        IRET                         ;������ �� ���뢠���
MEMORY_SIZE_DETERMINE   ENDP

INCLUDE INT11.ASM

;---INT 11------------------------------------------------------------------
; EQUIPMENT DETERMINATION
;       �� �ணࠬ��� ��।����, ����� ���� ���ன�⢠ ���ᮥ������ �
;       ��⥬�.
; �室:
;       ��६����� EQUIP_FLAG ��⠭���������� �� �६� �������⨪� �� ����祭��
;       ��⠭��, �ᯮ���� ᫥���騥 ��室� ����㤮�����:
;       ���� 60 -  ����訩 ���� ��६�����,
;       ���� 3FA - ॣ���� ���뢠��� �����/�뢮�� 8250 (���� 7-3 �ᥣ�� 0),
;       ���� 378 - ��室��� ���� �ਭ�� (8255), ����� ���� ���⠭ � ����ᠭ
; ��室:
;       (AX) ��⠭�������� ���� ��� 㪠����� ���祭�� �����/�뢮��:
;       ���� 15,14 - �᫮ ������� ���ன��,
;       ��� 13 - �� �ᯮ������,
;       ��� 12 - ��஢�� ����/�뢮� ������祭,
;       ���� 11,10,9 - ����� ������祭���� ������ RS232,
;       ��� 8 - �� �ᯮ������,
;       ���� 7,6 - �᫮ ������⥫�� ���,
;                 (00-1,01-2,10-3,11-4 �� ��� 0=1)
;       ���� 5,4 - ��砫�� �����-०��:
;                      00 - �� �ᯫ�����
;                      01 - 40*25 �/�, �ᯮ����騩 梥⭮� ������
;                      10 - 80*25 �/�, �ᯮ����騩 梥⭮� ������
;                      11 - 80*25 �/�, �ᯮ����騩 �/� ������
;       ���� 3,2 - ࠧ��� ����⨬ �����奬� (00-16K,01-32K,10-48K,11-64K),
;       ��� 1 - �� �ᯮ������,
;       ��� 0 - ����㧪� � ��᪥�� (��� 㪠�뢠��, �� � ��⥬� ����
;               ���ன�⢮ ���),
;       ��㣨� ॣ����� �� �ᯮ�������
;---------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
EQUIPMENT       PROC   FAR
        STI                   ;������� ���뢠���
        PUSH    DS            ;���࠭��� ᥣ����� ॣ����
        MOV     AX,DATA       ;��⠭����� ������
        MOV     DS,AX
        MOV     AX,EQUIP_FLAG ;������� ⥪�饥 ���ﭨ�
        POP     DS            ;����⠭����� ᥣ����
        IRET                  ;������ � �ணࠬ��
EQUIPMENT       ENDP

INCLUDE INT15_A.ASM
;---INT 15-----------------------------------------------14-02-89--------------
; CASSETTE I/O
;       (AH) = 0 �������� ��������� (� ������ ���ᨨ 0 � 1 �-樨
;       (AH) = 1 ��������� ���������   ����������)
;       (AH) = 2 ���. 1 ��� ������ 256-������� ������ � �������
;               (ES,BX) = ����� ������ ������
;               (CX) = ���������� ���� ��� ������
;               �� ������:
;               (ES,BX) = ����� ���������� ����. ����� + 1
;               (DX) = ���������� ��������� ����
;               (CY) = 0 ���� ��� ������ ��� ������
;                    = 1 ���������� ������ ������
;               (AH) = ������������ ��� ������, ���� (CY)=1
;                       =01 ������ CRC ��������
;                       =02 ������ ������
;                       =04 ������� ��� ������ �����
;       (AH) = 3 ������ 1 ��� ������ 256-������� ����� �� �������
;               (ES,BX) = ����� ������ ������
;               (CX) = ���������� ���� ��� ������
;               �� ������:
;               (EX,BX) = ����� ���������� ����������� ����� + 1
;               (CX) = 0
;       (AH) = 4 ������ ����� � �������
;              DS:[BX] - ����� ���������� ������, ���������� ��� �����
;              (ES) - ����� ������ ������
;              �� ������:
;              (AH) - ������������ ��� ������, ���� (CY) = 1
;                       =01 ������ CRC ��������
;                       =02 ������ ������
;                       =04 ������� ��� ������ �����
;       (AH) = 5 ������ ����� �� �������
;              DS:[BX] - ����� ���������� ������, ���������� ��� �����
;              (ES) - ����� ������ ������
;              �� ������:
;              (CY) = 1 - ������ ������
;       (AH) = ������ �������� - (CY)=1 - �������������� ��������,
;              ���������� (AH) = 80 - ������� �������������� ��������.
;---------------------------------------------------------------------------
;
CASSETTE_IO     PROC        FAR
        CLI                     ;��������� ����������
        PUSH    DS
        PUSH    AX
      MOV     AX,DATA
      MOV     DS,AX
        POP     AX
        CALL    W1              ;������� ��������� �������
        POP     DS
        STI                     ;��������� ����������
        RET     2               ;�������
CASSETTE_IO     ENDP
W1      PROC NEAR
;-----------------------------------------------------------14-02-89--------
; ����:
;  ����� ������� �������� ����������� �������� AH
;
;  AH           �������
;-----------------------------------------------------------------------------
;  0            ���. ���������
;  1            ����. ���������
;  2            ������ �����
;  3            ������ �����
;  4            ������ �����
;  5            ������ �����
;------------------------------------------------------------------------------

        OR      AH,AH
        JNZ     WK1
        RET
WK1:    DEC     AH
        JNZ     WK2
        RET
WK2:    DEC     AH                      ;������?
        JZ      READ_BLOCK              ;��
        DEC     AH                      ;������?
        JNZ     W2                      ;���
        JMP     WRITE_BLOCK             ;��, ������

W2:
        DEC     AH
        JNZ     W201
        JMP     FILE_READ               ;������ �����
W201:   DEC     AH
        JNZ     W202
        JMP     FILE_WRITE              ;������ �����
W202:
                                        ;�������������� �������
        MOV     AH,080H                 ;���������� ��� ��������
        STC                             ;���������� ���� ������
        RET
W1      ENDP

READ_BLOCK      PROC    NEAR
;-----------------------------------------------------------------------------
; ����:
;   ������ 1 ��� ������ 256-������� ������ � �������
;
; ������� ���������:
;   ES ������� ������ ��� ������ ������
;   BX ��������� ������ ������
;   CX ��������� ���������� ���� ������� ���������� ��������
; �������� ���������:
;   BX ��������� ����� ����� ���������� �� ��������� ���������
;   CX ���������� ������ ����������� ����
;   DX ������� ����������� ����
;
; ���� �������� ����� ����, ���� ��� ������
; � ��������������� ��� ����������� ������
;----------------------------------------------------------------------------
        PUSH    BX                      ;��������� BX
        PUSH    CX                      ;��������� CX
        PUSH    SI                      ;��������� SI
        MOV     SI,7                    ;����� ������� ������ ���������
W4:                                     ;����� ���������
        IN      AL,PORT_C               ;������� ���� ������ � �������.
        AND     AL,010H ;�������� ���������� ������
        MOV     LAST_VAL,AL             ;��������� �������� ������ �������
        MOV     DX,16250                ;����� ������ ��� �������� ��������
W5:                                     ;������ �������
        CALL    BREAK_TEST              ;�������� ����������?
        JNZ     W6                      ;���
        JMP     W17                     ;�������� ������

W6:     DEC     DX
        JNZ     W7                      ;�������, ���� ������ ���������
        JMP     W17                     ;�������, ���� ��������� �� ������

W7:     CALL    READ_HALF_BIT           ;������������ ������ �������
        JCXZ    W5                      ;������� ���� �� ���� �������� ����.
        IN      AL,021H ;��������� ���. ����� ����������
        OR      AL,1                    ;��������� ���������� �� �������
        OUT     021H,AL
;
        CALL    READ_HALF_BIT           ;�������� ������������ �/�������
        JCXZ    W4                      ;�������
        MOV     DX,BX                   ;��������� �����. ����.
      CALL    READ_HALF_BIT           ;�������� ����. 2-�� �/�������
      JCXZ    W4                      ;�������
      ADD     BX,DX                   ;�������� ����. �������

;  -----------   ���� ��� ������������� ���������

      MOV     CX,100H  ;������� ������ ��� �������������
W8:
      CALL    BREAK_TEST              ;��������?
        JNZ     W117                    ;���
        JMP     W17                     ;��
W117:   XCHG    DX,BX                   ;��������� ����. ��������. �������
        PUSH    CX
; ----------------------------  �������� ������������ ������ �������
      CALL    READ_HALF_BIT           ;�������� ������������ �/�������
        OR      CX,CX
        POP     CX
        JZ      W4
        PUSH    CX
      PUSH    BX                      ;��������� �����.����. �/�������
        CALL    READ_HALF_BIT           ;�������� ����� ����.
        OR      CX,CX
      POP     AX                      ;� AX ������������ ��������. ����.
        POP     CX
        JZ      W4
      ADD     BX,AX                   ;BX <--- ����. ������ �������
      SUB     DX,BX                   ;�������� ����. ������ � ��������.���.
      JNC     W801                    ;���� ������� ������������,
      NEG     DX                      ;�������� ���������� ��������
W801: CMP     DX,0C0H ;��������� �� ���������� �������
                                      ;���������� � ����� ������
      JNC     W4                      ;������� ������ ����������

      LOOP    W8                      ;���������, ���� ���������������
                                      ;������ 256 (100H) ��������

;--- ���� ������ ��������� ��������, ��������� ������� ������������
;    ������� ����� "1" � ����������-���������� ����. "1"

        XCHG    DX,BX
        MOV     CX,0FFH ;���������� �������
        XOR     AX,AX                   ;�������� �������� ����������
W88:    PUSH    CX                      ;��������� �������
        PUSH    AX                      ;��������� ����� ����������
        CALL    READ_HALF_BIT           ;�������� ������������ �����������
        PUSH    BX                      ;��������� �����. ����.
        CALL    READ_HALF_BIT           ;�������� ����. 2-�� �����������
        POP     AX                      ;������������ ���������� ����.
        ADD     BX,AX                   ;�������� ������������ �������
        POP     AX                      ;������������ ����� ����������
        SUB     BX,DX                   ;�������� ����� ����������
        ADD     AX,BX                   ;��������� � �����
        POP     CX                      ;������������ �������
        LOOP    W88
;
        MOV     CL,8
        SAR     AX,CL                   ;�������� ������� ����������
        ADD     DX,AX                   ;DX <--- ������� ����. ������� "1" P1
        MOV     BX,DX
        SAR     BX,1                    ;BX <--- P1/2
        MOV     DX,BX
        SAR     BX,1                    ;BX <--- P1/4
        ADD     DX,BX                   ;DX <--- 0.75*P1 - MIN ���. ����. ���
        MOV     LOWLIM,DX               ;����. MIN ���. ����. ������� "1"
        MOV     DX,BX
        SAR     BX,1                    ;BX <--- P1/8
        ADD     DX,BX                   ;DX <--- 3/8 * P1 - MIN ���. ��������
                                        ;����������� "1" ��� ������ �����-����
;
;                               ����� "0" - �����-����
W89:
        CALL    BREAK_TEST              ;�������� ������
        JZ      W17                     ;��
        CALL    READ_HALF_BIT           ;�������� ����. ����������� �������
        CMP     DX,BX                   ;"0" ��� "1"?
        JC      W89                     ;���� "1" - ���������
;
;   �����-��� ������. �������� �������������:
        CALL    READ_HALF_BIT           ;���������� 2-� ���������� �����-����
        CALL    READ_BYTE               ;��������� ����������
        CMP     AL,16H                  ;��������� ������-������
        JNE     W16                     ;�������, ���� ������ ���������

;------��������� �������� �������. ������ ������ ������
        POP     SI                      ;������������ ��������
        POP     CX
        POP     BX

;-------------------------------------------------------------------------
; ������ 1 ��� ������ 256-������� ������ ������ � �������
;
;�� �����:
; ES - ������� ��� ������ � ������ ��� ������ ��������� ����
; BX - ��������� ������ � ������
; CX - �������� ���������� ���� ������� ���������� ���������
;�� ������:
; BX - ��������� ����� ���� � ������, ���������� �� ��������� ����������
; CX - ���������� ������ ����������� ����
; DX - �������� ���������� ����������� ����
;---------------------------------------------------------------------------
        PUSH    CX                      ;�������� ������� ����
W10:                                    ;����� ����� ��� ��������
                                        ;�� ��������� 256-�������� �����
        MOV     CRC_REG,0FFFFH          ;���������������� CRC-�������
        MOV     DX,256                  ;DX <--- ������ ����� ������
W11:                                    ;������ ����
        CALL    BREAK_TEST              ;�������� ������?
        JZ      W13                     ;��
        CALL    READ_BYTE               ;������� ����
        JC      W13                     ;���� ������ - CY=1
        JCXZ    W12                     ;���� ��������� ��� ����� (CX),
                                        ;�������� ����, �� � ������
                                        ;�� ���������
        MOV     ES:[BX],AL              ;��������� ���� � ������
        INC     BX                      ;��������� ����� ������
        DEC     CX                      ;��������� ������� ����
W12:                    ;���������� ����� ������ 256-�������� ����� ������
        DEC     DX                      ;��������� ������� ���� � �����
        JG      W11                     ;������� �� ������, ���� < 256
        CALL    READ_BYTE               ;������ ������ ��� ����� CRC
        CALL    READ_BYTE
        SUB     AH,AH                   ;�������� AH
        CMP     CRC_REG,1D0FH           ;CRC ���������?
        JNE     W14                     ;�������, ���� ������
        JCXZ    W15                     ;���� ������� ����=0, �.�.
                                        ;��������� ��� ������,
                                        ;��������� ������
        JMP     W10                     ;���� ��� - ������ ��������� ����
                                ;��������� ������ ������
W13:                                    ;�������� ������
        MOV     AH,01H                  ;���������� ��� �������� AH=02 -
                                        ;"�������� ������"
W14:                                    ;������ CRC-��������
        INC     AH                      ;���������� ��� �������� AH=01 -
                                        ;"������ CRC-��������"
W15:                                    ;���������� ������
        POP     DX                      ;��������� ����� �������
        SUB     DX,CX                   ;����������� ����
                                        ;��� �������� � ���. DX
        PUSH    AX                      ;��������� AX (��� ��������)
        TEST    AH,03H                  ;���� ������?
        JNZ     W18                     ;����� �� ������
        CALL    READ_BYTE               ;��������� �����
        JMP     SHORT W18               ;��������� ���������� ���������
W16:                                    ;������ ���������
        DEC     SI                      ;��������� ����� ������� �������
                                        ;���������� ���������
        JZ      W17                     ;����� ������� ������ �����������
        JMP     W4                      ;���������� ��� ���
W17:                                    ;�� ������� ������
;-------�� ������� ������ �� �������,�.�. ������� ��� ������

        POP     SI                      ;������������ ��������
        POP     CX
        POP     BX
        SUB     DX,DX                   ;���� ������ ���������
        MOV     AH,04H                  ;������ "������� ��� ������"
        PUSH    AX
W18:
        IN      AL,021H         ;������������� ����������
        AND     AL,0FFH-1
        OUT     021H,AL
        POP     AX                      ;������������ ��� ��������
        CMP     AH,01H                  ;���������� CY=1 ��� ������ (AH>0)
        CMC
        RET                             ;���������
READ_BLOCK      ENDP
;---------------------------------------------------------------------------
READ_BYTE       PROC NEAR
; ����:
;  ��������� ���� � �������
;  �� ������ ������� AL �������� ���������� ���� ������
;---------------------------------------------------------------------------
        PUSH    BX                      ;��������� �������� BX,CX
        PUSH    CX
        MOV     CL,8H                   ;���������� ������� ��� ������ 8
W19:                                    ;������ ����
        PUSH    CX                      ;��������� ������� ���

;----------------------------------------------------------------------------
;  ������ ��� ������ � �������
;----------------------------------------------------------------------------
        CALL    READ_HALF_BIT           ;��������� ���� ����������
        JCXZ    W21                     ;���� CX=0 - �������-�������
                                        ;��� ������ ������ ��������
        PUSH    BX                      ;��������� ������������
                                        ;����������� (IN BX)
        CALL    READ_HALF_BIT           ;��������� ������ ����������
        POP     AX                      ;������������ ����. ��������. ���.
        JCXZ    W21                     ;���� CX=0 - �������-�������
        ADD     BX,AX                   ;��������� ����� �������
        CMP     BX,LOWLIM               ;��������� "0" ��� "1"
        CMC                             ;CY=1, ���� ��������� ���
        LAHF                            ;��������� ���� �������� � AH
        POP     CX                      ;������������ ������� ���
                                        ;��� �������:
                                        ;������� ��� �������� ������
                                        ;���. CH ���������� ����� �
                                        ;������� ��������� � ������� ���
                                        ;�������� CH.
                                        ;����� ���������� ���� 8 ���
                                        ;������� ��� ������������ �����
                                        ;�������� � ������� ���� ���. CH
        RCL     CH,1                    ;�������� ���. CH ����� ��� ���������
                                        ;�������� � ������� ��� ���. CH
        SAHF                            ;��������������� CY ��� ���������� CRC
        CALL    CRC_GEN         ;���������� CRC ��� ���������� ����
        DEC     CL                      ;��������� ������� ���
                                        ;��������� ������ ���� ���� �� �����-
        JNZ     W19                     ;���� ��� 8.
        MOV     AL,CH                   ;AL <--- ����������� ����
        CLC
W20:                                    ;��������� ������ �����
        POP     CX                      ;������������ ���. CX,BX
        POP     BX
        RET                             ;���������
W21:                                    ;������ ������
        POP     CX                      ;������������ CX
        STC                             ;���������� ���� ������
        JMP     W20                     ;��������� ������
READ_BYTE       ENDP

;--------------------------------------------------------------------------
WRITE_BLOCK     PROC    NEAR
;
; ������ 1 ��� ������ 256-������� ������ �� �������.
;       � ��������� ����� ������ ����������� ��������� ������ �� ����� 256.
;
; ������� ���������:
;  BX - ��������� ������ ������ ������
;  CX - ���������� ���� ��� ������
;
; �� ������:
;  BX ��������� ����� �����, ������� ������� �� ��������� ����������
;  CX ����� ����
;---------------------------------------------------------------------------
        PUSH    BX
        PUSH    CX
        IN      AL,PORT_B               ;��������� ����������������
        AND     AL,NOT 02H
        OR      AL,01H                  ;��������� ���� 2 ������ �������
        OUT     PORT_B,AL
        MOV     AL,0B6H          ;����� 2 ������� � ����� 3
        OUT     TIM_CTL,AL
        MOV     AX,1184  ;����. ������� ��� ������� "1"
        CALL    W31                     ;��������� ������
        MOV     CX,0800H                ;������� ����� ��� ���������
W23:                                    ;�������� ���������
        STC                             ;�������� ��� "1"
        CALL    WRITE_BIT               ;
        LOOP    W23                     ;������� ���� ���������?
        CLC                             ;�������� �����-��� (0)
        CALL    WRITE_BIT
        POP     CX                      ;������������ CX,BX
        POP     BX
        MOV     AL,16H                  ;�������� ������-������
        CALL    WRITE_BYTE              ;

;-------------------------------------------------------------------------
; �������� 1 ��� ������ 256-������ ������ �� �������.
;
; ������� ���������:
;  BX - ��������� ������ ������ ������
;  CX - ���������� ���� ��� ������
;
; �� ������:
;  BX ��������� ����� �����, ������� ������� �� ��������� ����������
;  CX ����� ����
;
;---------------------------------------------------------------------------
WR_BLOCK:
        MOV     CRC_REG,0FFFFH          ;���������������� CRC-�������
        MOV     DX,256                  ;������� ���� � �����
W24:                                    ;WR-BLK
        MOV     AL,ES:[BX]              ;��������� ���� �� ������
        CALL    WRITE_BYTE              ;�������� ��� �� �������
        JCXZ    W25                     ;���� CX=0,�� �������� ������� �������.
        INC     BX                      ;INC ��������� ������ ������
        DEC     CX                      ;DEC ������� ����������� ����
W25:                                    ;SKIP-ADV
        DEC     DX                      ;DEC ������� ���� �����
        JG      W24                     ;�������� ��� 256 ���� ������� �����?

;----------------------�������� CRC-------------------------------------------
; �������� �������� ��� CRC-�������� �� �������.
; ��� ���������� ����� ����������� ������������ ������������ � ���������� CRC
;
; ������������ ������� AX
;-----------------------------------------------------------------------------
        MOV     AX,CRC_REG              ;�������� �������� ��� CRC-��������
                                        ;� ���� ���� ������ CRC �� �������
        NOT     AX                      ;�������� �������� ���
        PUSH    AX                      ;��������� ���
        XCHG    AH,AL                   ;������� ���� ������������ ������
        CALL    WRITE_BYTE              ;�������� ���
        POP     AX                      ;������������ ������� ����
        CALL    WRITE_BYTE              ;�������� ���
        OR      CX,CX                   ;��� ����� ��������?
        JNZ     WR_BLOCK                ;���� ��� ����������
        PUSH    CX                      ;��������� CX
        MOV     CX,32                   ;�������� ����� �����
W26:                                    ;���� ������ ����� �����
        STC
        CALL    WRITE_BIT
        LOOP    W26                     ;������ ���� ����������� �������
        POP     CX                      ;������������ CX
      MOV     AL,0B0H         ;������������ ����� �������
        OUT     TIM_CTL,AL
        MOV     AX,1
        CALL    W31
        IN      AL,PORT_B
        AND     AL,NOT 01H
        OUT     PORT_B,AL
        SUB     AX,AX                   ;��� ������ ������
        RET                             ;���������
WRITE_BLOCK     ENDP





                ORG     0FA6EH

INCLUDE CRT_GEN.ASM
;---------------------------------------------------------------------------
; ������� ᨬ����� ��� ����᪨� ०���� 320*200 � 640*200
;---------------------------------------------------------------------------
CRT_CHAR_GEN    LABEL  BYTE
        DB      000H,000H,000H,000H,000H,000H,000H,000H ; D 00

        DB      07EH,081H,0A5H,081H,0BDH,099H,081H,07EH ; D 01

        DB      07EH,0EFH,0DBH,0EFH,0C3H,0E7H,0EFH,07EH ; D 02

        DB      06CH,0EEH,0EEH,0EEH,07CH,038H,010H,000H ; D 03

        DB      010H,038H,07CH,0EEH,07CH,038H,010H,008H ; D 04

        DB      038H,07CH,038H,0EEH,0EEH,07CH,038H,07CH ; D 05

        DB      010H,010H,038H,07CH,0EEH,07CH,038H,07CH ; D 06

        DB      000H,000H,018H,03CH,03CH,018H,000H,000H ; D 07

        DB      0EFH,0EFH,0E7H,0C3H,0C3H,0E7H,0EFH,0EFH ; D 08

        DB      000H,03CH,066H,042H,042H,066H,03CH,000H ; D 09

        DB      0EFH,0C3H,099H,0BDH,0BDH,099H,0C3H,0EFH ; D 0A

        DB      00FH,007H,00FH,07DH,0CCH,0CCH,0CCH,078H ; D 0B

        DB      03CH,066H,066H,066H,03CH,018H,07EH,018H ; D 0C

        DB      03FH,033H,03FH,030H,030H,070H,0E0H,0E0H ; D 0D

        DB      07FH,063H,07FH,063H,063H,067H,0E6H,0C0H ; D 0E

        DB      099H,05AH,03CH,0E7H,0E7H,03CH,05AH,099H ; D 0F


        DB      080H,0E0H,0E8H,0EEH,0F8H,0E0H,080H,000H ; D 10

        DB      002H,00EH,03EH,0EEH,03EH,00EH,002H,000H ; D 11

        DB      018H,03CH,07EH,018H,018H,07EH,03CH,018H ; D 12

        DB      066H,066H,066H,066H,066H,000H,066H,000H ; D 13

        DB      07FH,0DBH,0DBH,07BH,01BH,01BH,01BH,000H ; D 14

        DB      03EH,063H,038H,06CH,06CH,038H,0CCH,078H ; D 15

        DB      000H,000H,000H,000H,07EH,07EH,07EH,000H ; D 16

        DB      018H,03CH,07EH,018H,07EH,03CH,018H,0EFH ; D 17

        DB      018H,03CH,07EH,018H,018H,018H,018H,000H ; D 18

        DB      018H,018H,018H,018H,07EH,03CH,018H,000H ; D 19

        DB      000H,018H,00CH,0EEH,00CH,018H,000H,000H ; D 1A

        DB      000H,030H,060H,0EEH,060H,030H,000H,000H ; D 1B

        DB      000H,000H,0C0H,0C0H,0C0H,0EEH,000H,000H ; D 1C

        DB      000H,024H,066H,0EFH,066H,024H,000H,000H ; D 1D

        DB      000H,018H,03CH,07EH,0EFH,0EFH,000H,000H ; D 1E

        DB      000H,0EFH,0EFH,07EH,03CH,018H,000H,000H ; D 1F


        DB      000H,000H,000H,000H,000H,000H,000H,000H ; SP D 20

        DB      018H,03CH,03CH,018H,018H,000H,018H,000H ; ! D 21

        DB      036H,036H,036H,000H,000H,000H,000H,000H ; " D 22

        DB      036H,036H,07FH,036H,07FH,036H,036H,000H ; # D 23

        DB      018H,03EH,060H,03CH,006H,07CH,018H,000H ; $ D 24

        DB      000H,063H,066H,00CH,018H,033H,063H,000H ; % D 25

        DB      01CH,036H,01CH,03BH,06EH,066H,03BH,000H ; & D 26

        DB      030H,030H,060H,000H,000H,000H,000H,000H ; ' D 27

        DB      00CH,018H,030H,030H,030H,018H,00CH,000H ; ( D 28

        DB      030H,018H,00CH,00CH,00CH,018H,030H,000H ; ) D 29

        DB      000H,033H,01EH,07FH,01EH,033H,000H,000H ; * D 2A

        DB      000H,018H,018H,07EH,018H,018H,000H,000H ; + D 2B

        DB      000H,000H,000H,000H,000H,018H,018H,030H ; , D 2C

        DB      000H,000H,000H,07EH,000H,000H,000H,000H ; - D 2D

        DB      000H,000H,000H,000H,000H,018H,018H,000H ; . D 2E

        DB      003H,006H,00CH,018H,030H,060H,040H,000H ; / D 2F

        DB      03EH,063H,067H,06FH,07BH,073H,03EH,000H ; 0 D 30

        DB      018H,038H,018H,018H,018H,018H,07EH,000H ; 1 D 31

        DB      03CH,066H,006H,01CH,030H,066H,07EH,000H ; 2 D 32

        DB      03CH,066H,006H,01CH,006H,066H,03CH,000H ; 3 D 33

        DB      00EH,01EH,036H,066H,07FH,006H,00FH,000H ; 4 D 34

        DB      07EH,060H,07CH,006H,006H,066H,03CH,000H ; 5 D 35

        DB      01CH,030H,060H,07CH,066H,066H,03CH,000H ; 6 D 36

        DB      07EH,066H,006H,00CH,018H,018H,018H,000H ; 7 D 37

        DB      03CH,066H,066H,03CH,066H,066H,03CH,000H ; 8 D 38

        DB      03CH,066H,066H,03EH,006H,00CH,038H,000H ; 9 D 39

        DB      000H,018H,018H,000H,000H,018H,018H,000H ; : D 3A

        DB      000H,018H,018H,000H,000H,018H,018H,030H ; ; D 3B

        DB      00CH,018H,030H,060H,030H,018H,00CH,000H ; < D 3C

        DB      000H,000H,07EH,000H,000H,07EH,000H,000H ; = D 3D

        DB      030H,018H,00CH,006H,00CH,018H,030H,000H ; > D 3E

        DB      03CH,066H,006H,00CH,018H,000H,018H,000H ; ? D 3F

        DB      03EH,063H,06FH,06FH,06FH,060H,03CH,000H ; & D 40

        DB      018H,03CH,066H,066H,07EH,066H,066H,000H ; A D 41

        DB      07EH,033H,033H,03EH,033H,033H,07EH,000H ; B D 42

        DB      01EH,033H,060H,060H,060H,033H,01EH,000H ; C D 43

        DB      07CH,036H,033H,033H,033H,036H,07CH,000H ; D D 44

        DB      07FH,031H,034H,03CH,034H,031H,07FH,000H ; E D 45

        DB      07FH,031H,034H,03CH,034H,030H,078H,000H ; F D 46

        DB      01EH,033H,060H,060H,067H,033H,01FH,000H ; G D 47

        DB      066H,066H,066H,07EH,066H,066H,066H,000H ; H D 48

        DB      03CH,018H,018H,018H,018H,018H,03CH,000H ; I D 49

        DB      00FH,006H,006H,006H,066H,066H,03CH,000H ; J D 4A

        DB      073H,033H,036H,03CH,036H,033H,073H,000H ; K D 4B

        DB      078H,030H,030H,030H,031H,033H,07FH,000H ; L D 4C

        DB      063H,077H,07FH,07FH,06BH,063H,063H,000H ; M D 4D

        DB      063H,073H,07BH,06FH,067H,063H,063H,000H ; N D 4E

        DB      01CH,036H,063H,063H,063H,036H,01CH,000H ; O D 4F

        DB      07EH,033H,033H,03EH,030H,030H,078H,000H ; P D 50

        DB      03CH,066H,066H,066H,06EH,03CH,00EH,000H ; Q D 51

        DB      07EH,033H,033H,03EH,036H,033H,073H,000H ; R D 52

        DB      03CH,066H,070H,038H,00EH,066H,03CH,000H ; S D 53

        DB      07EH,05AH,018H,018H,018H,018H,03CH,000H ; T D 54

        DB      066H,066H,066H,066H,066H,066H,07EH,000H ; U D 55

        DB      066H,066H,066H,066H,066H,03CH,018H,000H ; V D 56

        DB      063H,063H,063H,06BH,07FH,077H,063H,000H ; W D 57

        DB      063H,063H,036H,01CH,01CH,036H,063H,000H ; X D 58

        DB      066H,066H,066H,03CH,018H,018H,03CH,000H ; Y D 59

        DB      07FH,063H,046H,00CH,019H,033H,07FH,000H ; Z D 5A

        DB      03CH,030H,030H,030H,030H,030H,03CH,000H ; [ D 5B

        DB      060H,030H,018H,00CH,006H,003H,001H,000H ; BACKSLASH D 5C

        DB      03CH,00CH,00CH,00CH,00CH,00CH,03CH,000H ; ] D 5D

        DB      008H,01CH,036H,063H,000H,000H,000H,000H ; CIRCUMFLEX D 5E

        DB      000H,000H,000H,000H,000H,000H,000H,07FH ;   D 5F

        DB      018H,018H,00CH,000H,000H,000H,000H,000H ;   D 60

        DB      000H,000H,03CH,006H,03EH,066H,03BH,000H ; LOWER CASE A D 61

        DB      070H,030H,030H,03EH,033H,033H,06EH,000H ; L.C. B D 62

        DB      000H,000H,03CH,066H,060H,066H,03CH,000H ; L.C. C D 63

        DB      00EH,006H,006H,03EH,066H,066H,03BH,000H ; L.C. D D 64

        DB      000H,000H,03CH,066H,07EH,060H,03CH,000H ; L.C. E D 65

        DB      01CH,036H,030H,078H,030H,030H,078H,000H ; L.C. F D 66

        DB      000H,000H,03BH,066H,066H,03EH,006H,07CH ; L.C. G D 67

        DB      070H,030H,036H,03BH,033H,033H,073H,000H ; L.C. H D 68

        DB      018H,000H,038H,018H,018H,018H,03CH,000H ; L.C. I D 69

        DB      006H,000H,006H,006H,006H,066H,066H,03CH ; L.C. J D 6A

        DB      070H,030H,033H,036H,03CH,036H,073H,000H ; L.C. K D 6B

        DB      038H,018H,018H,018H,018H,018H,03CH,000H ; L.C. L D 6C

        DB      000H,000H,066H,07FH,07FH,06BH,063H,000H ; L.C. M D 6D

        DB      000H,000H,07CH,066H,066H,066H,066H,000H ; L.C. N D 6E

        DB      000H,000H,03CH,066H,066H,066H,03CH,000H ; L.C. O D 6F

        DB      000H,000H,06EH,033H,033H,03EH,030H,078H ; L.C. P D 70

        DB      000H,000H,03BH,066H,066H,03EH,006H,00FH ; L.C. Q D 71

        DB      000H,000H,06EH,03BH,033H,030H,078H,000H ; L.C. R D 72

        DB      000H,000H,03EH,060H,03CH,006H,07CH,000H ; L.C. S D 73

        DB      008H,018H,03EH,018H,018H,01AH,00CH,000H ; L.C. T D 74

        DB      000H,000H,066H,066H,066H,066H,03BH,000H ; L.C. U D 75

        DB      000H,000H,066H,066H,066H,03CH,018H,000H ; L.C. V D 76

        DB      000H,000H,063H,06BH,07FH,07FH,036H,000H ; L.C. W D 77

        DB      000H,000H,063H,036H,01CH,036H,063H,000H ; L.C. X D 78

        DB      000H,000H,066H,066H,066H,03EH,006H,07CH ; L.C. Y D 79

        DB      000H,000H,07EH,04CH,018H,032H,07EH,000H ; L.C. Z D 7A

        DB      00EH,018H,018H,070H,018H,018H,00EH,000H ;  D 7B

        DB      00CH,00CH,00CH,000H,00CH,00CH,00CH,000H ;  D 7C

        DB      070H,018H,018H,00EH,018H,018H,070H,000H ;  D 7D

        DB      03BH,06EH,000H,000H,000H,000H,000H,000H ;  D 7E

        DB      000H,008H,01CH,036H,063H,063H,07FH,000H ; DELTA D 7F


INCLUDE INT1A.ASM
;---INT 1A-----------------------------------------------------------------
; TIME_OF_DAY
;  �� �ணࠬ��  �믮���� ��⠭����/���뢠��� �ᮢ
;�室:
;  (AH)=0 - ������ ⥪�饥 ���祭�� �ᮢ
;           �����頥�: CX - ����� ���� ���稪�
;                       DX - ������ ���� ���稪�
;                       AL=0 - �᫨ ⠩��� �� ��襫 24 �� � ������
;                              ��᫥����� ���뢠���
;                       AL<>0 - �᫨ �� ᫥���騩 ����
;  (AH)=1 - ��⠭����� ⥪�饥 ���ﭨ� �ᮢ
;           CX - ����� ���� ���稪�
;           DX - ������ ���� ���稪�
; ����砭��: ��� �믮������ 1193180/65536 ࠧ � ᥪ㭤�
;       (��� ����� 18.2 � ᥪ)
;----------------------------------------------------------------------------
        ASSUME  CS:CODE,DS:DATA
TIME_OF_DAY     PROC   FAR
        STI                          ;������� ���뢠���
        PUSH    DS                   ;���࠭��� ᥣ����
        PUSH    AX                   ;���࠭��� ��ࠬ���
        MOV     AX,DATA
        MOV     DS,AX                ;��⠭����� ������ ���祭��
        POP     AX                   ;����⠭����� �室��� ��ࠬ���
        OR      AH,AH                ;AH=0
        JZ      T2                   ;�⥭�� �६���
        DEC     AH                   ;AH=1
        JZ      T3                   ;��⠭���� �६���
T1:                                  ;������ �� �ணࠬ��
        STI                          ;������� ���뢠���
        POP     DS                   ;����⠭����� ᥣ����
        IRET                         ;������
T2:                                  ;�⥭�� �६���
        CLI                          ;������� ���뢠��� �� �६� ���뢠���
                                     ; ⠩���
        MOV     AL,TIMER_OFL
        MOV     TIMER_OFL,0          ;��९������, ����� 䫠�
        MOV     CX,TIMER_HIGH
        MOV     DX,TIMER_LOW
        JMP     T1                   ;������
T3:                                  ;��⠭���� �६���
        CLI                          ;������� ���뢠��� �� �६� �����
                                     ; ⠩���
        MOV     TIMER_LOW,DX
        MOV     TIMER_HIGH,CX        ;��⠭����� �६�
        MOV     TIMER_OFL,0          ;���� ��९�������
        JMP     T1                   ;������
TIME_OF_DAY     ENDP

;----------------------------------------------------------------------------
;  �� ����ணࠬ�� ��ࠡ��뢠�� ���ᯮ��㥬� ������� ���뢠��� (A - D).
;  ��६����� INTR_FLAG �㤥� ᮤ�ঠ�� �஢��� �����⭮�� ���뢠��� ���
; FF �᫨ ���뢠��� �� �����⭮�.
;----------------------------------------------------------------------------
HARD_RETURN    PROC    NEAR
        PUSH    DS
        PUSH    DX
        PUSH    AX
        MOV     AX,DATA
        MOV     DS,AX                ; ᥣ���� ������
        MOV     AL,0BH               ; ������� - �⥭�� IN-SERVICE REG
        OUT     20H,AL               ; ��।������ �஢�� ���뢠���
        NOP
        IN      AL,20H               ; ���� �஢�� ���뢠���
        MOV     AH,AL
        OR      AL,AH                ; �஢�ઠ �� ����
                                     ; 0 - ��� �����⭮�� ���뢠���
        JNZ     HW_INT               ; �᫨ �����⭮� ���뢠��� �뫮
        MOV     AH,0FFH              ; �ਧ��� ��� ���뢠���
        JMP     SHORT SET_INTR_FLAG  ;
HW_INT: IN      AL,21H               ; ���� ���祭�� ��᪨
        OR      AL,AH                ; ��� ��� ��᪨
        OUT     21H,AL
        MOV     AL,20H               ; ������� - ����� ���뢠���
        OUT     20H,AL
SET_INTR_FLAG:
        MOV     INTR_FLAG,AH         ; ������ �ਧ���� - ����� ���뢠���
        POP     AX
        POP     DX
        POP     DS
DUMMY_RETURN:
        IRET
HARD_RETURN  ENDP


        ORG     0FEF3H

INCLUDE VEK.ASM
;---------------------------------------------------------------------------
; �� ������ ����뫠���� � ������� ���뢠��� 8086
;  �� ����祭�� ��⠭��
;----------------------------------------------------------------------------
VECTOR_TABLE    LABEL  WORD          ;������ ����஢ ���뢠���

        DW      DUMMY_RETURN           ;���뢠��� 5H

        DW      DUMMY_RETURN           ;���뢠��� 6H

        DW      DUMMY_RETURN           ;���뢠��� 7H

        DW      OFFSET TIMER_INT     ;���뢠��� 8
        DW      OFFSET KB_INT        ;���뢠��� 9

        DW      OFFSET HARD_RETURN   ;���뢠��� A
        DW      OFFSET HARD_RETURN   ;���뢠��� B
        DW      OFFSET HARD_RETURN   ;���뢠��� C
        DW      OFFSET HARD_RETURN   ;���뢠��� D

        DW      OFFSET SCANINT       ;���뢠��� E

        DW      OFFSET HARD_RETURN   ;���뢠��� F

        DW      OFFSET VIDEO_IO      ;���뢠��� 10H

        DW      OFFSET EQUIPMENT     ;���뢠��� 11H

        DW      OFFSET MEMORY_SIZE_DETERMINE   ;���뢠��� 12H

        DW      DUMMY_RETURN           ;���뢠��� 13H

        DW      DUMMY_RETURN           ;���뢠��� 14H

        DW      OFFSET CASSETTE_IO     ;���뢠��� 15H

        DW      KEYBOARD_IO            ;���뢠��� 16H

        DW      DUMMY_RETURN           ;���뢠��� 17H

        DW      OFFSET MONITOR         ;���뢠��� 18H (������)

        DW      OFFSET BOOT_STRAP      ;���뢠��� 19H

        DW      TIME_OF_DAY            ;���뢠��� 1AH (�६� ��⮪)

        DW      DUMMY_RETURN           ;���뢠��� 1BH (���뢠��� ����������)

        DW      DUMMY_RETURN           ;���뢠��� 1CH (���뢠��� ⠩���)

        DW      VIDEO_PARMS            ;���뢠��� 1DH (��ࠬ���� �����)

        DW      DUMMY_RETURN           ;���뢠��� 1EH (��ࠬ���� ��᪠)

        DW      OFFSET ALTC            ;���뢠��� 1FH (�����⥫� VIDEO_EXT)

INCLUDE INT15_NP.ASM

;---------------------------------------------------------------------------
READ_HALF_BIT   PROC    NEAR
; ����:
;  ��������� ������������ ����������� ����,
;  �.�. ������������ ��������� �� ����� ����� ������
;  ������� �� ������
;
; �� �����:
;  EDGE_CNT �������� �������� �������� ������� � ������ ����� ������ �������
;
; ON EXIT:
;  AX �������� �������� �������� � ������ ����� ����� ������
;  BX �������� ������������ �����������
;----------------------------------------------------------------------------
        MOV     CX,100                  ;���������� ����� �������� ������
        MOV     AH,LAST_VAL             ;AH <-- ������� ������� �������
W22:                                    ;������ �������
        IN      AL,PORT_C               ;������ ������ � �����������
        AND     AL,010H          ;�������� ��������� ���
        CMP     AL,AH                   ;������� ���������?
        LOOPE   W22                     ;���� ���, ���������
        MOV     LAST_VAL,AL             ;��������� ����� �������
        MOV     AL,0                    ;������ ������ �� ����
        OUT     TIM_CTL,AL
        IN      AL,TIMER0               ;������� ����
        MOV     AH,AL                   ;��������� � AH
        IN      AL,TIMER0               ;������� ����
        XCHG    AL,AH                   ;XCHG AL,AH
        MOV     BX,EDGE_CNT             ;BX <-- ���������� �������� ��������
        SUB     BX,AX                   ;BX <-- ������������ �����������
        MOV     EDGE_CNT,AX             ;��������� �������� ��������
        RET
READ_HALF_BIT   ENDP

BREAK_TEST      PROC    NEAR
;----------------------------------------------------------------------------
;  ����:
;       ����� ���������� �� ������� ������� ������
;       ESC,TAB ��� CTRL ��� ���������� ������ �������
;
;       ���� ���� ������� ����� �� ���� ������ - ���� Z=1
;----------------------------------------------------------------------------
        PUSH    AX                      ;��������� AX
        MOV     AL,0FFH
        OUT     60H,AL
        IN      AX,69H                  ;�������� ���� ����������
        AND     AX,080H                  ;���� ������ ������� Z<--1
        POP     AX                      ;������������ AX
        RET
BREAK_TEST      ENDP


INCLUDE STP1.ASM      ;�/� ��㪮���� ᨣ���� � ���� ᮮ�饭��
;-------------------------------------------------------------------------
;  ���४樨:
;    12.02.89  - BEEP ��ଫ��� �⠭���⭮� ����ணࠬ���
;-------------------------------------------------------------------------


;----------------- �/� ��㪮���� ᨣ����
;       (BL) - ���⥫쭮��� � ������ (����� - ? �� )
;       (BH) - �ࠢ����� ⮭��

BEEP    PROC    NEAR
        PUSH    AX
        PUSH    CX
        MOV     AL,10110110B         ;����� TIM 2,LSB,MSB,BINARY
        OUT     TIMER+3,AL           ;������� ॣ���� ०���� ⠩���
        MOV     AL,33H             ;��ࠢ����� ⮭�� ��㪠
        OUT     TIMER+2,AL           ;������� ���稪 ⠩��� 2
        MOV     AL,BH             ;�ࠢ����� ⮭�� ��㪠
        OUT     TIMER+2,AL           ;������� ���稪 ⠩��� 2
        IN      AL,PORT_B            ;������� ⥪�饥 ���ﭨ� ����
        PUSH    AX                   ;���࠭���� ���祭�� ����
        OR      AL,03                ;������� ���
        OUT     PORT_B,AL
        MOV     CX,100H              ;��⠭����� ���稪 �������� 500/64 ��
G7:     LOOP    G7                   ;����প� ��। ����祭���
        DEC     BL                   ;����প� ���稪� �����祭�?
        JNZ     G7                   ;��� - �த������� ����� ᨣ����
        POP     AX                   ;����⠭����� ���祭�� ����
        OUT     PORT_B,AL
        POP     CX
        POP     AX
        RET                          ;������ � �ணࠬ��
BEEP    ENDP

;------------------------------------------------------------------------
; �� ����ணࠬ�� �뢮��� ��㪮��� ᨣ��� �訡�� ��砫쭮�� ���஢����
;      (DX) - ������⢮ ��᪮�
;------------------------------------------------------------------------
BEEP_ERROR    PROC   NEAR
        PUSH     CX
        PUSH     BX
B_ERR_0:
        MOV      BX,0203H
        CALL     BEEP
        MOV      CX,0FFFFH
B_ERR_1:
        NOP
        LOOP     B_ERR_1
        DEC      DX
        JNZ      B_ERR_0
        POP      BX
        POP      CX
        RET
BEEP_ERROR    ENDP


;------------------------------------------------------------------------
;       �� ����ணࠬ�� ���⠥� ᮮ�饭�� �� �࠭�.
; �室�� �᫮���:
;       SI=ᬥ饭�� (����) ���� ᮮ�饭��
;       CX=���稪 ���⮢ ᮮ�饭��
;       ���ᨬ���� ࠧ��� ��।�������� ᮮ�饭�� - 36 ᨬ�����
;--------------------------------------------------------------------------
P_MSG   PROC    NEAR
        MOV     AL,CS:[SI]           ;��᫠�� ᨬ��� � AL
        INC     SI                   ;�����⥫� ᫥���饣� ᨬ����
        MOV     BH,0                 ;��⠭����� ��࠭��� =0
        MOV     AH,14                ;������� ᨬ���
        INT     10H                  ;�맮� VIDEO_IO
        LOOP    P_MSG                ;�த������ �� ���� ᮮ�饭��
        RET
P_MSG   ENDP

;---------------------------------------------------------------------
; �� ��楤�� �ந������ ������ ����஫쭮� �㬬� ������ �����
;     DS:BX - ��砫� ������ �����
;     CX    - ࠧ���
; �᫨ ����஫쭠� �㬬� ᮢ����, � ��⠭���������� 䫠� Z
;---------------------------------------------------------------------
ROS_CHECKSUM   PROC  NEAR
        XOR     AL,AL
ROS0:   ADD     AL,DS:[BX]
        INC     BX
        LOOP    ROS0
        OR      AL,AL
        RET
ROS_CHECKSUM   ENDP

;-------------------------------------------------------------------
; �� ��楤�� �ந������ ��砫��� ���樠������ �ணࠬ�� � ���
;      DS
;-------------------------------------------------------------------
ROM_INIT       PROC  NEAR
        SUB      AH,AH
        MOV      AL,[BX+2]    ; � ॣ. (AX) - ����� ��� � 512� ������
        MOV      CL,9
        SHL      AX,CL        ; �������� (AX) �� 512
        PUSH     AX           ; ���࠭��� (AX)
        MOV      CL,4
        SHR      AX,CL        ; ��������� (AX) �� 16
        ADD      DX,AX
        POP      CX           ; (CX) - ࠧ��� ���
        CALL     ROS_CHECKSUM
        JZ       ROM_I_0
        PUSH     DX
        MOV      DX,2
        CALL     BEEP_ERROR
        POP      DX
        JMP      ROM_I_RET
ROM_I_0:
        PUSH     DX
        PUSH     CS
        LEA      AX,CS:ROM_I_1
        PUSH     AX
        PUSH     DS
        MOV      AX,3
        PUSH     AX
        DB       0CBH        ;(RETF)
ROM_I_1:
        POP      DX
        SUB      DX,20H
ROM_I_RET:
        RET
ROM_INIT      ENDP



;        ORG     0FF54H

INCLUDE RESTART.ASM

;--------------------------------------------------------------------------
;       ����� ��� �� ����祭�� ��⠭��
;---------------------------------------------------------------------------
        ORG     0FFF0H
;-------���� �� ����祭�� ��⠭��

        JMP     FAR PTR RESETV

        DB      '10/07/88'           ;��થ� ���� ᮧ����� ���ᨨ BIOS

        DB      0FFH
        DB      0FFH                 ;��થ� IBM/PC
;        DB      0FFH




        CODE   ENDS
nt near (or at) 64K limit
