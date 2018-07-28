;��������--ʵ��ͼʾ HANOI �ƶ�����
;CREATED TIME:2018-06-03
;����˵�������޸��ӳ���GRAPHPRINT�е��ƶ�ʱ�䣬���ڲ��ԡ�

DATAS SEGMENT
	;-------- HANOI ��ʽ��������������� --------------
    INPUTMSG  DB 'Please input the number of disk:',0DH,0AH,24H;����Բ�̸���
	INPUTMSG1 DB 'The first pillar:',0DH,0AH,24H;��һ������
	INPUTMSG2 DB 'The second pillar:',0DH,0AH,24H
	INPUTMSG3 DB 'The third pillar:',0DH,0AH,24H
	PROGRAM_TITLE     DB '         SHOW HANOI MOVEMENT         ',24H
	CRLF      DB 0DH,0AH,24H;�س�����
	MOVE_DISK_NUMBER DB ' Disk:',24H;��ʽ��ʾ
	
	
	MOVE_START DB ' MD:From ',24H;��ʽ��ʾ
	MOVE_END DB ' to ',24H
	PSTEPS DB '  Steps:',24H
	STEPS DW 0;ͳ���ƶ�����
	NUMBER DW 0;����������̸���
	MOVED_NUMBER DB 0;ÿ���ƶ��Ĵ��̱�� 
	X DW '0';�洢��������
	Y DW '0'
	Z DW '0'
	
	
	;------- HANOI ͼʾ�ƶ���ʾ��� --------
	TEMP DW 0;��ʱ����
	X_AXIS1 DW 0 ;���������
	X_AXIS2 DW 0 
	Y_AXIS1 DW 100 ;���������� 
	Y_AXIS2 DW 100 
	Y_AXIS3 DW 100 
	
	
DATAS ENDS

STACKS SEGMENT
    DB 255H DUP(?) 
STACKS ENDS
;***********************************************
CODES SEGMENT
;������
;-----------------------------------------------
MAIN PROC FAR
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	PUSH DS ;��ʼ�����ݶ�
	SUB AX,AX
	PUSH AX 
    MOV AX,DATAS
    MOV DS,AX
       
    LEA DX,INPUTMSG
    MOV AH,09H
    INT 21H 
       
    CALL DECTOBIN;ʮ����Բ�̸����Զ�������ʽ���� BX
    MOV NUMBER,BX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    CMP BX,0;�������Ϊ0�����˳�����
    JE EXIT
    
    LEA DX,INPUTMSG1;����A
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH;��ֵ
    MOV X,AX;
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    
    LEA DX,INPUTMSG2;����B
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH
    MOV Y,AX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    LEA DX,INPUTMSG3;����C
    MOV AH,09H
    INT 21H
    MOV AH,01H
    INT 21H
    XOR AH,AH
    MOV Z,AX
    LEA DX,CRLF
    MOV AH,09H
    INT 21H
    
    ;ִ��ʱ���ӳ�
    ;====================  
    CALL INIT;��ӡ��ʼ״̬
    MOV BL,80;�ӳ�4S��ʼ�ƶ� TIME/20S
MOVE_TIME: 
    MOV CX,33144;0.05S 
    CALL WAITP 
	DEC BL 
	JNZ MOVE_TIME
    ;=============
    
    MOV CX,X 
	MOV SI,Y
	MOV DI,Z ;���� Z,Y,Z
	MOV BX,NUMBER 
    CALL HANOI;�����ӳ��� HANOI �ݹ��㷨    
   
 EXIT:  RET
 MAIN ENDP
    
;ʮ��������ת������ --> BX
;----------------------------------------------
DECTOBIN PROC NEAR	
    XOR BX,BX	
INPUTD:
	MOV AH,01H
	INT 21H;����Բ�̸���
    SUB AL,30H
    JL EXIT_DECTOBIN 
    CMP AL,9
    JG EXIT_DECTOBIN 
    CBW ;AL --> AX
    
    ;תAX�е�ʮ������תΪ������
  
    XCHG AX,BX
    MOV CX,10
    MUL CX
    XCHG AX,BX
    ADD BX,AX
    JMP INPUTD
EXIT_DECTOBIN :RET
DECTOBIN ENDP


;HANOI �ݹ��㷨
;���ݾ���ݹ��㷨:
;(1)N==1,MOVE(N,X,Z)
;(2)HANOI(N-1,X,Z,Y)
;(3)MOVE(N,X,Z)
;(4)HANOI(N-1,Y,X,Z)
;--------------------------------------
HANOI PROC NEAR
;(BX)=N,(CX)=X,(SI)=Y,(DI)=Z
	CMP BX,1;IF N==1 A-->C
	JE BASIS
	CALL SAVE;SAVE(N,X,Y,Z) ��������˳�� X,Y,Z
	DEC BX;ִ�еݹ�
	XCHG SI,DI;Y,Zλ�û���
	CALL HANOI;ִ�� HANOI(N-1,X,Z,Y) �ݹ� 
	CALL RESTOR;�ָ����� N,X,Y,Z
	CALL DETAILMSG;��ӡÿһ�����ƶ���Ϣ
	CALL GRAPHPRINT;��ӡԲ��
	DEC BX ;�����ݹ�
	XCHG CX,SI;X,Yλ�û���
	CALL HANOI;HANONI(N-1,Y,X,Z)
	JMP RETURN
BASIS:
	CALL DETAILMSG;��ӡÿһ�����ƶ���Ϣ
	CALL GRAPHPRINT;��ӡԲ��
RETURN:
	RET
HANOI ENDP	

;��ӡÿһ��Բ���ƶ����
;-------------------------------------------------	
DETAILMSG PROC NEAR
	CALL STEPSP ;���ò���ͳ��
	;����ƶ�·�� A-->C
	LEA DX,MOVE_DISK_NUMBER
	MOV AH,09H
	INT 21H
	
	;MOV AX,BX;AX=N
	CALL BINTODEC;PRINT N 
	
	LEA DX,MOVE_START;��ʽ���
	MOV AH,09H
	INT 21H
	
	MOV DX,CX;�����ʼ�ƶ���
	MOV AH,02H
	INT 21H
	
	LEA DX,MOVE_END;��ʽ���
	MOV AH,09H
	INT 21H
	
	MOV DX,DI;Z
	MOV AH,02H;Ŀ���ƶ���
	INT 21H
	
	;LEA DX,CRLF
	;MOV AH,09H
	;INT 21H
	
	MOV DX,20H
	MOV AH,02H
	INT 21H
	
	RET
DETAILMSG ENDP

;��������
;-----------------------------------------------
SAVE PROC NEAR ;����	
	POP BP
	PUSH BX;���� N
	PUSH CX;���� X
	PUSH SI;���� Y
	PUSH DI;���� Z
	PUSH BP
	RET
SAVE ENDP

;�ָ�����
;-----------------------------------------------
RESTOR PROC NEAR
	;��ջ��� N,Z,Y,X
	POP BP
	POP DI;�ָ� Z
	POP SI;�ָ� Y
	POP CX;�ָ� X
	POP BX;�ָ� N
	PUSH BP
	RET
RESTOR ENDP

; ������תʮ�������
; ����Ҫת���ĵĶ����������� BX
;-----------------------------------------------
BINTODEC PROC NEAR
	CALL SAVE
	MOV AX,BX
	MOV SI,10
	MOV CX,0
PUSHDATA:	
    XOR DX,DX
	DIV SI
	PUSH DX
	INC CX
	CMP AX,0
	JZ POPDATA
	JMP PUSHDATA 
POPDATA:
	POP DX
	ADD DL,30H
	MOV AH,02H
	INT 21H
	LOOP POPDATA
	
	CALL RESTOR
	RET
BINTODEC ENDP

;����ͳ���ӳ���
STEPSP PROC NEAR
	CALL SAVE
	INC STEPS
	
	;���������������Ļ��λ��
	;=====================
	MOV AH,2 ;�ù��
	MOV BH,0 ;��0ҳ
	MOV DH,17;DH�з��к�
	MOV DL,2 ;DL�з��к�
	INT 10H
	;=====================

	LEA DX,PSTEPS
	MOV AH,09H
	INT 21H	
		
	MOV BX,STEPS
	CALL BINTODEC;��ʮ�����������
	CALL RESTOR 
	RET
STEPSP ENDP

;��ʼ����Ļ
;-----------------------------------------------------------------       
INIT PROC NEAR 	
	PUSH BX 
	MOV AH,00H 
	MOV AL,04H ;��Ļ��ΪΪ 320*200 ����,��ɫ
	INT 10H ;10H�ж�
	MOV CX,60 ;��ʼ���������ӣ�CX=80��X���Ӻ����� 
INIT1: 
	MOV DX,30 ;���� 30 ��ʼ�� 
INIT2: 
	MOV AL,2 ;��ɫ
	MOV AH,0CH ;д����
	INT 10H 
	INC DX;������д����
	CMP DX,100 ;���Ӹ߶�
	JL INIT2 ;û��110 �����д����110���������һ������
	ADD CX,100 ;ÿ�������Ӽ��80 
	CMP CX,261;д����������� 
	JL INIT1 ;ûд�����������������
	MOV DX,100 ;���Ӹ߶�
	MOV CX,60 ;Բ�̻�ͼ���
INIT3: ;ȷ����һ������Բ�̺����� 
	MOV AX,0 
	MOV AL,2 
	
	MUL BL ;�˻�16λ��-->(AX)
	MOV X_AXIS1,AX ;X_AXIS1=2*BL
	ADD X_AXIS1,76 ;X_AXIS1=2*BL+76
	MOV X_AXIS2,44 ;X_AXIS2=44
	SUB X_AXIS2,AX ;X_AXIS2=44-2*BL
INIT4: 
	MOV AL,1 ;��ɫ
	MOV AH,0CH ;д����
	INT 10H ;CX Ϊ��ʼ�����꣬DXΪ������
	INC CX ;���һ�����
	CMP CX,X_AXIS1 ;����Բ�̴�С
	JL INIT4 ;С�ڴ˳��ȼ������򻭵���
	MOV CX,60 ;
INIT5: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX;���󻭵���
	CMP CX,X_AXIS2 
	JNL INIT5 
	DEC BL;���¸�Բ�� 
	JE EXITINIT 
	SUB DX,3;Բ�����¼��3 
	MOV CX,60 
	JMP INIT3 
EXITINIT: 
	SUB DX,3                                  
	MOV Y_AXIS1,DX;Y_AXIS1 Ϊ��һ�������������Բ������������
	POP BX
	
    PUSH BX
	PUSH CX
	;���������������Ļ��λ��
	;=====================
	MOV AH,2 ;�ù��
	MOV BH,0 ;��0ҳ
	MOV DH,1;DH�з��к�
	MOV DL,2 ;DL�з��к�
	INT 10H
	;=====================

	LEA DX,PROGRAM_TITLE
	MOV AH,09H
	INT 21H	
	
	;���������������Ļ��λ��
	;=====================
	MOV AH,2 ;�ù��
	MOV BH,0 ;��0ҳ
	MOV DH,14;DH�з��к�
	MOV DL,7 ;DL�з��к�
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[X]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
    
    
    ;���������������Ļ��λ��
	;=====================
	MOV AH,2 ;�ù��
	MOV BH,0 ;��0ҳ
	MOV DH,14;DH�з��к�
	MOV DL,20 ;DL�з��к�
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[Y]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
    
    ;���������������Ļ��λ��
	;=====================
	MOV AH,2 ;�ù��
	MOV BH,0 ;��0ҳ
	MOV DH,14;DH�з��к�
	MOV DL,32 ;DL�з��к�
	INT 10H
	;=====================
    MOV AH,09H
    MOV AL,BYTE PTR[Z]
    MOV BL,07H
    MOV BH,0
    MOV CX,1
    INT 10H	
	
	POP CX
	POP BX
	
	RET 
INIT ENDP 

;ͼʾ�ƶ�Բ�̴���
;------------------------------------------------------------
GRAPHPRINT PROC NEAR 
	CALL SAVE
	
	;���� X ����
	CMP CX,X;CX=A��CLEAR X�ϵ�A  
	JE CLEARA 
	CMP CX,Y ;CX=B��CLEAR X�ϵ�B 
	JE CLEARB 
	CMP CX,Z ;CX=C��CLEAR X�ϵ�C  
	JE CLEARC 
	
GRAPHPRINT1:;���� X ����
	MOV MOVED_NUMBER,BL;�ƶ����� 
	PUSH BX 
	CMP DI,X;CX=A��ADDA 
	JE ADDA 
	CMP DI,Y;CX=B��ADDB 
	JE ADDB 
	CMP DI,Z;CX=C��ADDC  
	JE ADDC 
CLEARA:  ; ������Ϊ Y_AXIS ��Բ���úڵ㸲�� 
	MOV TEMP,CX ;TEMP=X
	ADD Y_AXIS1,3 ;����������
	MOV DX,Y_AXIS1	
	MOV CX,10 
CDOTA: 
	MOV AL,4 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,110 
	JL CDOTA 
	;����
	;-----
	MOV CX,60
	MOV AL,2 
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 
CLEARB:  ; ��ȥ B �ϵ�Բ��
	MOV TEMP,CX 
	ADD Y_AXIS2,3 
	MOV DX,Y_AXIS2 
	MOV CX,110 
CDOTB: 
	MOV AL,4 ;��ɫ
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,210 
	JL CDOTB 
	;����
	;-----
	MOV CX,160
	MOV AL,2 ;��ɫ
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 
	
CLEARC:   
	MOV TEMP,CX 
	ADD Y_AXIS3,3 
	MOV DX,Y_AXIS3 
	MOV CX,210 
CDOTC: 
	MOV AL,4 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,310 
	JL CDOTC 
	;����
	;-----
	MOV CX,260
	MOV AL,2 
	MOV AH,0CH 
	INT 10H 
	;-----
	JMP GRAPHPRINT1 

ADDA:  ;����Բ�̴�С 
	MOV DX,Y_AXIS1 
	SUB Y_AXIS1,3
	MOV CL,MOVED_NUMBER 
	MOV AX,0 
	MOV AL,2 
	MUL CL 

	MOV CX,60 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,76 
	MOV X_AXIS2,44 
	SUB X_AXIS2,AX 
TRA: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,X_AXIS1 
	JL TRA 
	MOV CX,60 
TLA: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLA 
	JMP EXIT5 

ADDB:  
	MOV DX,Y_AXIS2 
	SUB Y_AXIS2,3 
	MOV CL,MOVED_NUMBER
	MOV AX,0 
	MOV AL,2 
	MUL CL 
	MOV CX,160 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,176 
	MOV X_AXIS2,144 
	SUB X_AXIS2,AX 
TRB: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 	
	CMP CX,X_AXIS1 
	JL TRB 
	MOV CX,160 
TLB: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLB 
	JMP EXIT5 

ADDC: 
	MOV DX,Y_AXIS3 
	SUB Y_AXIS3,3 
	MOV CL,MOVED_NUMBER
	MOV AX,0 
	MOV AL,2 
	MUL CL 
	MOV CX,260 
	MOV X_AXIS1,AX 
	ADD X_AXIS1,276 
	MOV X_AXIS2,244 
	SUB X_AXIS2,AX 
TRC: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	INC CX 
	CMP CX,X_AXIS1 
	JL TRC 
	MOV CX,260 
TLC: 
	MOV AL,1 
	MOV AH,0CH 
	INT 10H 
	DEC CX 
	CMP CX,X_AXIS2 
	JNL TLC 
	JMP EXIT5 

EXIT5: 
	MOV BL,1 ;10�����ƶ�Բ�̵�ʱ����(0.5�ƶ�һ��Բ��)
MOVE1: 
	MOV CX,33144 
	CALL WAITP 
	DEC BL 
	JNZ MOVE1 
	MOV CX,TEMP 
	
	POP BX 
	CALL RESTOR
	RET 
GRAPHPRINT ENDP 
     
;CX������15.08US�ı������ӳ�0.05S CX=33144
;�� CPU �޹ص�ʱ���ӳ��ӳ���
;-------------------------------------------
WAITP PROC NEAR
	PUSH AX 
	XOR AX,AX
DELAY1: 
	IN AL,61H 
	AND AL,10H 
	CMP AL,AH 
	JE DELAY1 
	MOV AH,AL 
	LOOP DELAY1 
	POP AX 
	RET 
WAITP ENDP 

CODES ENDS

	END START










