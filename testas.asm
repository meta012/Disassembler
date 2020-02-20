.model small

buferioDydis	EQU	121

;.stack 100h

;*******************Perkelta i kodo segmento pabaiga************
;.data
;	bufDydis DB  buferioDydis
;	nuskaite DB  ?
;	buferis	 DB  buferioDydis dup ('$')
;	ivesk	 DB  'Iveskite eilute:', 13, 10, '$'
;	rezult	 DB  'Radau tiek didziuju raidziu: '
;	rezult2	 DB  3 dup (' ')
;	enteris	 DB  13, 10, '$'
;***************************************************************
			
;*************************Pakeista******************************
;.code
BSeg SEGMENT
;***************************************************************

;*******************Prideta*************************************
	ORG	100h
	ASSUME ds:BSeg, cs:BSeg, ss:BSeg
;***************************************************************

Pradzia:

	mov byte ptr cs:[bx+12h], 12
	mov ax, bx				;reg<->reg/atmintis
	add al, bl 				;reg-reg/atmintis
	jmpisorinistiesioginis db 0EAh, 0AFh, 0CDh, 015h, 0D6h ;galima kintamuoju apsibrezti
	ret	
	inc byte ptr [si+2] ;reikia byte/word ptr-ar operuojama baitais ar zodziais atmintyje esanciu adr.
	inc word ptr [si+2] ;reikia byte/word ptr
	inc byte ptr cs:[bp+si+21] ;reikia byte/word ptr
	inc word ptr cs:[bp+si+21] ;reikia byte/word ptr
	dec byte ptr cs:[2121] ;be prefikso neveikia
	dec word ptr cs:[2121]
	;registras/atmintis

	mov ax, es:[0112h]		;26 A1 12 01
	mov al, es:[2h]			;26 AO 02 00
	jmp word ptr [enteris]	;kadangi vienas segmentas, neina isorinio jmp atlikti - vidinis netiesiog.
	callisorinistiesioginis db 09Ah, 0AFh, 0CDh, 015h, 0D6h ;isorinius galima apsirasyti kaip kintamuosius
	jmp testing				;E9 B5 04
	mov al, 00001000b		;B0 08
	mov cl, 1				;B1 01
	rol al, cl				;D2 C0
	rol al, 2				;D0 C0 IR D0 C0
	ror al, cl				;D2 C8
	rcl bx, 1				;D1 D3
	rcr dx, cl				;D3 DA
	shl cl, cl				;D2 E1
	shr cx, 1				;D1 E9
	sar ax, 1				;D1 F8	
	mov al, ss:[1234]		;36 A0 D2 04
	dec byte ptr cs:[0002]	;2E FE 0E 02 00
	
	JO pradzia				;70 CE
	JNO pradzia				;71 CC
	JNAE pradzia			;72 CA			
	JAE pradzia				;73 C8
	JE pradzia				;74 C6
	JNE pradzia				;75 C4
	JBE pradzia				;76 C2
	JA pradzia				;73 C0
	JS pradzia				;78 BE
	JNS pradzia				;79 BC
	JP pradzia				;7A BA
	JNP pradzia				;7B B8
	JL pradzia				;7C B6
	JGE pradzia				;7D B4
	JLE pradzia				;7E B2
	JG pradzia				;7F B0
	JCXZ pradzia			;E3 AE
	LOOP pradzia			;E2 AC
	JMP pradzia				;EB AA
	
	mov al, es:[659ch]		;26 A0 9C 65
	MOV es:word ptr[bx+si+3E2Eh], 9036h		;26 C7 80 2E 3E 36 90
	mov byte ptr cs:[bx], 23h  				;2E	C6 07 23
	push [bx] 				;FF 37 
	imul cx					;F7-neatpazintas + 0E-push cs
	push cs:[vienas]		;2E FF 36 78 06
	push [cs:vienas]		;2E FF 36 78 06
	mov cs:[vienas], es		;2E 8C 06 78 06
	pop [bx] 				;8F 07 
	add al, dh 				;02 C6 
	add ah, 12h 			;80 C4 12   
	div bx 					;F7 F3 
	mov al, dh 				;8A C6
	
	mov ds, ax 				;8E D8
	push ax 				;50
	inc al  				;FE C0
    sub al, dh 				;2A C6
	sub ah, 12h				;80 EC 12  	
	pop ax 					;58  
	dec al 					;FE C8 
	cmp al, dh				;3A C6
	cmp ah, 12h				;80 FC 12
	mul cl					;F6 E1 
	div cl					;F6 F1 

	mov jmpisorinistiesioginis, 00F1h		;C6 06 09 01 F1
	mul byte ptr [si+0ff80h]				;F6 64 80
	div bh					;F6 F7
	
	INT 25h					;CD 25
	call bx					;FF D3
	call ds:[bp+si+0c5F9h]	;3E FF 92 F9 C5
	call testing			;E8 17 04
	jmp bx					;FF E3
	jmp ds:[bp+si+0c5F9h]	;3E FF A2 F9 C5
	jmp Pradzia				;E9 47 FF
	jmp farjump 			;E9 0A 04
	INT 15h					;CD 15
	ret						;C3
	ret 2h					;C2 02 00
	retf					;CB
	retf 15fh				;CA5F01
	cmp word ptr 952fh:[bp+si+0c5F9h], -0fh	;83 BA F9 C5 F1
	xor ax, 1b				;35 01 00	
	mul byte ptr [si+80h]	;F6 A4 80 00
	mul dl					;F6 E2
	mul BX					;F7 E3
	mul byte ptr [si+0ff80h];F6 64 80
	div bh					;F6 F7
	div DI					;F7 F7
	div word ptr ss:[bx+10h];36 F7 77 10
	
	cmp byte ptr ds:[bp+si+0c5F9h], 91h		;3E 80 BA F9 C5 91
	cmp ax, 9101h			;3D 01 91
	cmp al, 2h				;3C 02
	cmp ah, 3h				;80 FC 03
	cmp cx, ax				;3B C8
	cmp ax, cx				;3B C1
	cmp si, cs:[bp+di+0ABF9h]				;2E 3B B3 F9 AB
	dec ch					;FE CD
	dec DX					;4A
	dec byte ptr es:[di+015F9h]				;26 FE 8D F9 15
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h	;3E 81 AA F9 C5 F1 1F
	sub ax, 101h			;2D 01 01
	sub al, 2h				;2C 02
	sub ah, 3h				;80 EC 03
	
	add word ptr ds:[bp+si+0c5F9h], 01ff1h	;3E 81 82 F9 C5 F1 1F
	add ax, 101h			;05 01 01
	add al, 2h				;04 02
	add ah, 3h				;80 C4 03
	inc ch					;FE C5
	inc word ptr es:[bx+si+015F9h]			;26 FF 80 F9 15
	mov ax, cx				;8B C1
	mov cx, ax				;8B C8
	add cx, ax				;03 C8
	add ax, cx				;03 C1
	add si, cs:[bp+di+0ABF9h]				;2E 03 B3 F9 AB
	
	
	push cs					;0E
	push dx					;52
	push cs:[bp+di+0ABF9h] 	;2E FF B3 F9 AB
	
	
	pop ss					;17
	pop si					;5E
	pop ss:[bx+di+0BA21h] 	;36 8F 81 21 BA
	
	
	MOV	cx, 0ABCDh			;B9 CD AB
	mov ax, ds				;8C D8
	
	mov si, 0				;BE 00 00
	mov ax, [si]			;8B 04
	mov [si +2h], ax		;89 44 02
	mov  byte ptr cs:[si+1252h], 0F1h		;2E C6 84 52 12 F1
	mov [bx], si			;89 37
	

	ret
	ret
	ret
	ret
	ret
	ret
	cmp  byte ptr ss:[si+1ff2h], 00F1h
	add  byte ptr ss:[si+1ff2h], 00F1h
	mov  byte ptr ss:[si+1ff2h], 061h
	mov jmpisorinistiesioginis, 00F1h
	mov byte ptr ds:[013ch], 00F1h
	add jmpisorinistiesioginis, 00F1h
	cmp jmpisorinistiesioginis, 00F1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	sub word ptr ds:[bp+si+0c5F9h], 01ff1h
	
	pop [bx+0d8h]
	mov byte ptr [di], 20h
	mov al, [bx]
	add dx, [bx+0080h]
	or	ah, [si]
	and	al, 24
	and	[bx+si], ah

	mov si, 0A523h
	mov ah, 28h
	mov al, es:[659ch]
	mov ds, [bp+69h]
	mov bl, dh
	mov cs: byte ptr [9937h], 0abh
	mov bx, es
	mov [bx+si+0ffb1h], cx
	mov dh, [di]
	mov word ptr [bp+di+0fffeh], 6828h
	mov es:[bx+di+0033h], ch
	mov cs:[0c6a2h], al
	mov es, [bp+6453h]
	mov [bp+si+0ffb2h], bp
	mov byte ptr [bx+si], 0005h
	mov ds:[bp+di+002ah], ss
	
	
	MOV	ah, 9
	MOV	dx, offset ivesk
	INT	21h

	MOV	ah, 0Ah
	MOV	dx, offset bufDydis
	INT	21h

	MOV	ah, 9
	MOV	dx, offset enteris
	INT	21h

;****algoritmas****
	XOR	ch, ch
	SUB	ax, ax
	MOV	cl, nuskaite
	MOV	bx, offset buferis
	MOV	dl, 'A'
	MOV	dh, 'Z'

ciklas1:
	CMP	dl, [ds:bx]
	JG	nelygu
	CMP	dh, [ds:bx]
	JL	nelygu
	INC	ax

nelygu:
	INC	bx
	DEC	cx
	CMP	cx, 0
	JG	ciklas1

;****Spausdinimas****
	MOV	dl, 10
	DIV	dl
	MOV	[rezult2 + 2], ah
	ADD	[rezult2 + 2], 030h
	XOR	ah, ah
	DIV	dl
	MOV	[rezult2 + 1], ah
	ADD	[rezult2 + 1], 030h
	MOV	[rezult2], al
	ADD	[rezult2], 030h

	MOV	ah, 9
	MOV	dx, offset rezult
	INT	21h

	MOV	ah, 4Ch
	MOV	al, 0
	INT	21h
	
farjump:
testing proc
ret
testing endp

;*******************Atkelta iš duomenu segmento*****************
	bufDydis DB  buferioDydis
	nuskaite DB  ?
	buferis	 DB  buferioDydis dup ('$')
	ivesk	 DB  'Iveskite eilute:', 13, 10, '$'
	rezult	 DB  'Radau tiek didziuju raidziu: '
	rezult2	 DB  3 dup (' ')
	enteris	 DB  13, 10, '$'
	vienas dw 5
;***************************************************************

;*******************Prideta*************************************
BSeg ENDS
;***************************************************************
END	Pradzia