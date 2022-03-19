INT_5 SEGMENT BYTE PUBLIC 'CODE'
     ASSUME CS:INT_5

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
         JNZ EXIT

         MOV BH,0   ; ����������� ����樨 ��p�p�
         MOV AH,3
         INT 10H
         PUSH DX

         MOV CX,19H
         MOV BX,0
         MOV DX,0
     M3: MOV DI,CX    
         MOV CX,50H
     M2: MOV BH,0   ; �������p����
         MOV AH,2    
         INT 10H    ; ������ ��p�p�
         MOV AH,8 
         INT 10H    ; �⥭�� ᨬ����

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
         
         INC DL      ; �������
         LOOP M2
         MOV DL,0
         MOV CX,DI
         INC DH      ; ��p���
         LOOP M3 

         MOV AL,0AH  ; LF
         OUT 85H,AL
         MOV AL,0AH
         OUT 86H,AL
         MOV AL,0BH
         OUT 86H,AL
         MOV AL,0AH
         OUT 86H,AL

         POP DX      ; ����⠭������� ����樨 ��p�p�
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
INT_5 ENDS
        END
