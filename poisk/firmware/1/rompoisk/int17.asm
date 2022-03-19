INT_17 SEGMENT BYTE PUBLIC 'CODE'
     ASSUME CS:INT_17

TBSR PROC
    BEGINNING:

JMP INITIALIZE

; P������⭠� �p�楤�p� �p�p뢠���

START_RESIDENT:

 ROUTINE PROC FAR
         STI
         CMP AH,0    ; ����� ᨬ����
         JNZ INIT

         MOV DX,AX   ; �p���p�� �訡��
         MOV AL,0AH
         OUT 86H,AL
         IN AL,86H
         CMP AL,9AH
         JNZ S_ERR

         MOV AX,DX
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
         MOV AH,11010000B
         JMP ER3

   INIT: CMP AH,1    ; ���樠������ PIO
         JNZ S_ERR
         MOV AL,88H
         OUT 87H,AL
         JMP S_ERR

  S_ERR: MOV AH,11010000B  ; ��p���⪠ �訡��
         IN  AL,86H
         TEST AL,00100000B ; BUSY
         JZ ER1
         SUB AH,80H
    ER1: NOT AL    
         TEST AL,10000000B ; ERROR
         JZ ER2
         ADD AH,08H ; �訡�� �/�
    ER2: TEST AL,00010000B ; ACK
         JZ ER3
         SUB AH,40H

    ER3: IRET
 ROUTINE ENDP

END_RESIDENT:

RESIDENT_LENGTH EQU END_RESIDENT - START_RESIDENT 
RESIDENT_OFFSET EQU START_RESIDENT - BEGINNING + 100H 
PSP_AMOUNT EQU 5BH ; ����� PSP, ���p�� ��⠥��� (5BH)

; ������� ���樠����樨

INITIALIZE:

         PUSH AX
         PUSH DX

         MOV AH,35H   ; ����祭��
         MOV AL,17H   ; ���祭��
         INT 21H      ; ����p� 
         CMP BX,5BH
         JNZ M2
         JMP NEAR PTR EXIT

     M2: MOV AL,88H   ; ���樠������ PIO
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
         MOV AL,17H
         MOV AH,25H
         INT 21H
         POP DS

; ����p襭�� �p��p����, ��⠢��� �� p������⭮�

         MOV DX,PSP_AMOUNT + RESIDENT_LENGTH 
         INT 27H

   EXIT: POP DX
         POP AX
         RET 0
TBSR ENDP
INT_17 ENDS
         END 
