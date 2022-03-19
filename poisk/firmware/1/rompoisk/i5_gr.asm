I5_GR SEGMENT BYTE PUBLIC 'CODE'
      ASSUME CS:I5_GR

TBSR PROC
     BEGINNING:

         PUSH AX
         PUSH DX
         PUSH BP
         MOV BP,SP

JMP INITIALIZE

; P������⭠� �p�楤�p� �p�p뢠���

START_RESIDENT:

 ROUTINE PROC FAR
         STI
         PUSH AX
         PUSH BX
         PUSH CX
         PUSH DX
         PUSH SI
         PUSH DI
         PUSH DS
         PUSH ES
         PUSH BP
         MOV BP,SP

         MOV AL,88H ; ���樠������ PIO
         OUT 87H,AL

         MOV AL,0AH ; �p���p�� ���ﭨ�
         OUT 86H,AL ; �p���p�
         IN AL,86H
         CMP AL,9AH
         JZ M6
         JMP NEAR PTR EXIT

     M6: MOV BH,0   ; ����������� ����樨 ��p�p�
         MOV AH,3
         INT 10H
         PUSH DX

         MOV AL,1BH            ; ���ࢠ� �����
         CALL NEAR PTR STROBE  ; ��ப 8/72 ��
         MOV AL,41H
         CALL NEAR PTR STROBE
         MOV AL,8H
         CALL NEAR PTR STROBE

         MOV BL,8H
     M5: MOV AL,1BH            ; �p�����
         CALL NEAR PTR STROBE
         MOV AL,66H
         CALL NEAR PTR STROBE
         MOV AL,0
         CALL NEAR PTR STROBE
         MOV AL,8
         CALL NEAR PTR STROBE
         MOV CX,0
         MOV AH,0
         MOV DI,213
     M7: MOV AL,1BH            ; �����
         CALL NEAR PTR STROBE  ; ����᪨� ��ࠧ��
         MOV AL,2AH            ; �����
         CALL NEAR PTR STROBE
         MOV AL,1              ; ���⭮���
         CALL NEAR PTR STROBE
         MOV AL,213            ; ������⢮
         CMP AH,2
         JNZ M8
         INC AL
         INC DI
     M8: CALL NEAR PTR STROBE  ; ����᪨�
         MOV AL,0              ; ��ࠧ��
         CALL NEAR PTR STROBE
         MOV SI,0
     M3: MOV DL,BL
         MOV BH,1H
         MOV DH,0H
         PUSH AX
     M2: DEC DL
         MOV AH,0DH ; �㭪��
         INT 10H    ; �⥭�� �窨
         CMP AL,0
         JZ M4
         ADD DH,BH
     M4: ADD BH,BH
         CMP DL,0
         JNZ M2
         POP AX
         MOV AL,DH             ; ��ࠧ
         CALL NEAR PTR STROBE
         INC CX
         INC SI
         CMP SI,DI
         JNZ M3
         INC AH
         CMP AH,3
         JNZ M7
         MOV AL,0AH            ; ��p���� ��p��� (LF)
         CALL NEAR PTR STROBE
         ADD BL,8H
         CMP BL,208
         JNZ M5

         MOV AL,1BH            ; ���樠������
         CALL NEAR PTR STROBE  ; �ਭ��
         MOV AL,40H
         CALL NEAR PTR STROBE
         MOV AL,0AH            ; LF
         CALL NEAR PTR STROBE 

         JMP NEAR PTR EXIT0

STROBE PROC NEAR
         OUT 85H,AL  ; �����
         MOV AL,0AH  ; ��p��
         OUT 86H,AL
         MOV AL,0BH
         OUT 86H,AL
         MOV AL,0AH
         OUT 86H,AL
     M1: IN AL,86H
         CMP AL,9AH
         JNZ M1
         RET
STROBE ENDP

  EXIT0: POP DX      ; ����⠭������� ����樨 ��p�p�
         MOV BH,0
         MOV AH,2
         INT 10H

   EXIT: MOV SP,BP
         POP BP
         POP ES
         POP DS
         POP DI
         POP SI
         POP DX
         POP CX
         POP BX
         POP AX
         IRET
 ROUTINE ENDP

END_RESIDENT:

RESIDENT_LENGTH EQU END_RESIDENT - START_RESIDENT
RESIDENT_OFFSET EQU START_RESIDENT - BEGINNING + 100H 
PSP_AMOUNT EQU 5BH ; ����� PSP, ���p�� ��⠥��� (5BH)

; ������� ���樠����樨

INITIALIZE:

         MOV AL,88H   ; ���樠������ PIO
         OUT 87H,AL

         PUSH CS
         POP ES       
         PUSH CS
         POP DS       
         MOV DI, PSP_AMOUNT
         MOV SI, RESIDENT_OFFSET
         MOV CX, RESIDENT_LENGTH 
         CLD
         CLI
         REP MOVSB
         STI

; ��⠭���� ����� ���뢠���

         PUSH DS
         MOV DX,PSP_AMOUNT
         PUSH CS
         POP DS
         MOV AL,5H
         MOV AH,25H
         INT 21H
         POP DS

; ����p襭�� �p��p����, ��⠢��� �� p������⭮�

         MOV DX,PSP_AMOUNT + RESIDENT_LENGTH
         INT 27H

         MOV SP,BP
         POP BP
         POP DX
         POP AX
         RET 0
TBSR ENDP
I5_GR ENDS
        END
