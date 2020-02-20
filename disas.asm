org 100h
.model small

    skBufDydis equ 25
    raBufDydis equ 60
.stack 100h
.data
    fail db 255 dup (0)
    rezfail db 255 (0)
    
    skBuf db skBufDydis dup (?)
    raBuf db raBufDydis dup (?)
    
    dFailas dw ?   ;duom.1 failo deskriptorius
    rFailas dw ?    ;rez. failo deskriptorius  
    
    poslinkis dw 00FFh
    rezFailas db 0  
    SkaitymoBuff dw 0 
    
    komandos db 'OR MOVPOPADDSUBANDXORINCDECCMPMULDIVRETJMPINTADCSBB PUSHCALLIRETF'
    modPoslin db 'bx+sibx+dibp+sibp+di sidibpbx'
    JMP2 db 'JOJEJAJSJPJLJG JNOJAEJNEJBEJNSJNPJGEJLEJMP JNAEJCXZLOOP'
    sukiniai db 'ROLRORRCLRCRSHLSHRSAR'           
    prefiksas db '.escsssds'
    dydis db 'byte'
    dydis1 db 'word'
     
    prefix db 0
    jumpas db 0
    komand db 0
    registrasA db 0
    registrasB db 0
    modPos db 0
    modAS db 0
    rm db 0 
    reg db 0
    w db 0
    v db 0
    d db 0
    s db 0
    seg1 db 0 
    baitas1 db 0
    baitas2 db 0
    baitas3 db 0
    baitas4 db 0
    yrabaitas db 0
    buvesbaitas db 0
    busimasbaitas db 0
    NustatytaKomanda db 0
    
    nepaz db 'NEATPAZINTAS', 13, 10, '$'
    vardas db 'Disasembleris.', 13, 10, 'Meta Bambalaite, I kursas, 2 grupe, 1 pogrupis', '$'
.code                            
    Pradzia:
        mov ax, @data
        mov ds, ax       
;atidarom duomenu faila skaitymui
        xor cx, cx                      ;nunulinam cx
	    mov cl, es:[0080h]              ;irasom i cl VISU argumentu bendra dydi (pradzioj, po mov ds,ax, es=ds)
	    cmp cl, 0                       ;palyginam su 0
	    je JUMPING                      ;jei 0, sokam i pabaiga
	    dec cl                          ;atimam viena, nes pabaiga zymima '\0'
	    mov si, 0082h                   ;si-nuskaitom ir irasom VISU argumentu reiksme, nuo po tarpo einancios reiksmes 
	    mov bx, 0082h
	    push cx  
	Ieskok:
	    cmp es:[bx], '?/'               ;ieskom /?
	    je JUMPING
	    inc bx
	    loop Ieskok 	    
	    xor bx, bx
	    pop cx
	Duomenys:
	    mov al, es:[si+bx]              ;al-pirmo(bx=0)argumento reiksme
	    cmp al, 20h                     ;palyginam su tarpu
	    je AtidarytiDuom                ;jei tarpas - sokam i ff1(argumento pavadinimo pakeitimui)                      
	    mov ds:[fail+bx], al            ;irasom i ds kaip fail su poslinkiu - al reiksme
	    inc bx                          ;didinam bx(sekanciai reiksmei)
	    loop Duomenys
	AtidarytiDuom:    
	    mov byte ptr [fail+bx],0        ;i paskutine baito dydzio fail pozicija ideti '\0' zenkla				
        mov ah, 3Dh                     ;INT atidaryti egzistuojanti faila
	    mov al, 00                      ;skaitymui
	    mov dx, offset fail             ;ds:dx
	    int 21h 
	    jc KlaidaAtidarantSkaitymui     ;jei Carry flag=1, klaida
	    mov	dFailas, ax                ;dFailas- deskriptorius, kad butu galima pasiekti faila
;kuriam ir atidarom rezultato faila rasymui 
        inc bx
	    dec cx
	    add si, bx
	    xor bx, bx        
    Rezultatai:    
        mov al, es:[si+bx]
	    mov ds:[rezfail+bx], al
	    inc bx
	    loop Rezultatai
	    mov byte ptr [rezfail+bx],0				
        mov ah, 3Ch                     ;INT sukurti arba 'ant virsaus' sukurti faila
	    mov cx, 0                       ;'read-only'
	    mov dx, offset rezfail          ;ds:dx
	    int 21h 
	    jc JUMPING3                     ;CF=1, klaida
	    mov	rFailas, ax
	    jmp Skaityk    
    JUMPING:                            ;tarpinis JUMP iki pabaigos
        jmp Pabaiga
    KlaidaAtidarantSkaitymui:           ;klaida
        jmp Pabaiga
    KlaidaSkaitant:
        mov ax, 0
        jmp UzdarytiSkaitymui
    JUMPING3:
        jmp KlaidaAtidarantRasymui  
;***********************************************************************************************************
    Skaityk:                        ;duomenu nuskaitymas is failo
        call Skaitymas                                            
 Testi: 
        mov prefix, 0                   
        mov di, offset raBuf        ;sudarom ras.buferiui vietos
        cmp buvesbaitas, 0
        jg Testi1
        call DuokBaita              ;paimam 2 pirmus baitus
        jmp Testi2
    Testi1:
        mov bl, al   
    Testi2:
        mov dx, poslinkis           ;susitvarkom su poslinkiu
        shr dx, 12                  ;(4 skaitmenu, nuo 0100)
        call Raides2                ;ir irasom juos i [di]
        mov dx, poslinkis
        shr dx, 8
        and dl, 00001111b
        call Raides2
        mov dx, poslinkis
        shr dx, 4
        and dl, 00001111b
        call Raides2
        mov dx, poslinkis
        and dl, 00001111b
        call Raides2   
        mov byte ptr [di], 58       ;dvitaskis
        inc di
        mov byte ptr [di], 9        ;tabas
        inc di
        add rezFailas, 2 
        call MasKodas               ;irasom i [di] pirmus du baitus
        mov d, 0 
        mov v, 0
        mov w, 0 
        mov s, 2 
        mov seg1, 0
        mov modAS, 0
        mov baitas1, 0
        mov baitas2, 0
        mov baitas3, 0
        mov baitas4, 0
        mov yrabaitas, 0 
        mov buvesbaitas, 0
        mov NustatytaKomanda, 0        
 Prefixas:
        mov prefix, 1               ;pasiziurim, ar pirmi baitai prefikso
        cmp al, 26h                 ;jei taip - prefix bus ne 0
        je YraPrefiksas             ;es
        mov prefix, 3
        cmp al, 2Eh                 ;cs
        je YraPrefiksas
        mov prefix, 5 
        cmp al, 36h                 ;ss
        je YraPrefiksas
        mov prefix, 7
        cmp al, 3Eh                 ;ds
        je YraPrefiksas 
        mov prefix, 0
        jmp GaleDW 
     YraPrefiksas:                  
        call DuokBaita              ;ir imam dar du baitus
        call MasKodas               ;kuriuos irasom i [di]
        
 GaleDW:                            
        mov al, bl
        mov komand, 3               ;VARIANTAS1
        and al, 11111100b     
        cmp al, 10001100b           ;mov-8C, 8E    (1000 11d0)
        je GaleDWburys1             ;segment.registras<>reg/atmintis                                                 
     TestiGale:   
        cmp al, 10001000b           ;mov-88, 89, 8A, 8B   (1000 10dw)
        je GaleDWburys              ;registras<>reg/atmintis
        mov komand, 9               ;kiti- registras<>registras/atmintis                                    
        cmp al, 00000000b           ;add   (0000 00dw)
        je GaleDWburys
        mov komand, 0               ;or    (0000 10dw)
        cmp al, 00001000b
        je GaleDWburys
        mov komand, 12              ;sub   (0010 10dw)
        cmp al, 00101000b
        je GaleDWburys
        mov komand, 15              ;and   (0010 00dw)
        cmp al, 00100000b
        je GaleDWburys
        mov komand, 18              ;xor   (0011 00dw)
        cmp al, 00110000b
        je GaleDWburys
        mov komand, 27              ;cmp   (0011 10dw)
        cmp al, 00111000b
        je GaleDWburys
        jmp SUposlinkiu 
     GaleDWburys1: 
        mov al, bl
        and al, 00000001b
        cmp al, 1
        je TestiGale
        shr bl, 1
        and bl, 00000001b          
        mov d, bl
        mov w, 1
        mov s, 1
        mov seg1, 1
        call Variantas1
        mov s, 0
        jmp Testi
     GaleDWburys:
        mov al, bl
        call DWinti       
        call Variantas1
        jmp Testi
     PriesTesti:
        jmp Testi
 SUposlinkiu:                       ;VARIANTAS2
        mov al, bl
        mov komand, 6               ;pop  (1000 1111)
        cmp al, 10001111b           ;registras/atmintis
        je PoslinkioBurys
        mov al, bl                  ;grupe - 1111 111w
        and al, 11111110b           ;inc, dec, call (vid.neties), 
        cmp al, 11111110b           ;call (isor.neties), jmp (vid. neties)
        je PoslinkioBurys           ;jmp (isor. neties), push 
        mov al, bl
        and al, 11111110b           ;mul, div
        cmp al, 11110110b
        jne MOVas4                
        call ArTinkamasBaitas
        cmp buvesbaitas, 0
        jg PriesTesti                      
     PoslinkioBurys:
        call Variantas2
        jmp Testi    
 MOVas4: 
        mov al, bl 
        mov komand, 3 
        and al, 11111110b           ;VARIANTAS3     
        cmp al, 11000110b           ;mov-C6, C7-MOV  (1100 011w)
        je Intarpas                 ;registras/atmintis-betarp.operandas
        mov al, bl
        and al, 11111100b
        cmp al, 10000000b           ;grupe-100000sw
        jne Intarpas0
        mov al, bl
        shr al, 1
        and al, 00000001b
        mov s, al
        and bl, 00000001b          
        mov w, bl
        mov NustatytaKomanda, 1
        jmp Pointarpo
     Intarpas0:
        jmp Akumai 
     Intarpas:
        jmp BetarpOperandai
     Pointarpo:     
        call Palyginimukas
        call DuokBaita              ;(1000 00sw)
        call MasKodas               ;grupe su s(betarp.operando dydis)
        call MODRMREGinti           ;registras/atmintis-betarp.operandas
        mov komand, 9               ;add
        cmp reg, 0  
        je BetarpOperandai2
        mov komand, 0               ;or
        cmp reg, 1  
        je BetarpOperandai2
        mov komand, 45              ;adc
        cmp reg, 2  
        je BetarpOperandai2
        mov komand, 48              ;sbb
        cmp reg, 3  
        je BetarpOperandai2
        mov komand, 15              ;and
        cmp reg, 4  
        je BetarpOperandai2
        mov komand, 12              ;sub
        cmp reg, 5  
        je BetarpOperandai2
        mov komand, 18              ;xor
        cmp reg, 6  
        je BetarpOperandai2
        mov komand, 27              ;cmp
        jmp BetarpOperandai2
     BetarpOperandai:
        mov al, bl
        and al, 00000001b          
        mov w, al
     BetarpOperandai2:      
        call Variantas3 
        jmp Testi                     
 Akumai:
        mov al, bl
        mov komand, 3               ;VARIANTAS4
        and al, 11111110b           ;su Akumuliatoriais(ax/al)
        mov modAS, 0                
        mov rm, 6
        mov d, 2                  
        cmp al, 10100010b           ;mov-A2, A3  (1010 001w)
        je Akumuliatoriai           ;atmintis-akumuliatorius
        mov d, 1
        cmp al, 10100000b           ;mov-A0, A1  (1010 000w)
        je Akumuliatoriai           ;akumuliatorius-atmintis
        mov modAS, 1
        mov d, 0  
        mov komand, 9               ;kitu- akumuliatorius-betarp.operandas
        cmp al, 00000100b           ;add  (0000 010w)
        je Akumuliatoriai
        mov komand, 0  
        cmp al, 00001100b           ;or   (0000 110w)
        je Akumuliatoriai
        mov komand, 15
        cmp al, 00100100b           ;and  (0010 010w)
        je Akumuliatoriai
        mov komand, 12
        cmp al, 00101100b           ;sub  (0010 110w)
        je Akumuliatoriai
        mov komand, 18
        cmp al, 00110100b           ;xor  (0011 010w)
        je Akumuliatoriai
        mov komand, 27
        cmp al, 00111100b           ;cmp  (0011 110w)
        jne Pasukimas
     Akumuliatoriai:
        mov yrabaitas, 1
        call Variantas4             
        jmp Testi
 Pasukimas:                         ;VARIANTAS5
        mov al, bl
        shr al, 2
        cmp al, 00110100b           ;rol/ror/rcl/rcr/shl/shr/sal/sar
        jne MOVasB
     Pasisukimas:
        mov al, bl
        shr al, 1
        and al, 00000001b
        mov v, al
        and bl, 00000001b
        mov w, bl
        call Variantas5
        jmp Testi 
 MOVasB:
        mov al, bl 
        mov komand, 3
        and al, 11110000b         
        cmp al, 10110000b           ;mov-Bx  (1011 wreg)
        jne ZodinisReg              ;registras-betarp.operandas
        mov al, bl                  
        shr al, 3
        and al, 00000001b
        mov w, al
        and bl, 00000111b
        mov dl, bl
        call DuokBaita 
        call MasKodas
        cmp w, 1
        je PaimtiDar
        jmp NeimtiDar
     PaimtiDar:
        mov baitas1, al
        call DuokBaita
        call MasKodas
        mov baitas2, al
     NeimtiDar:
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx
        mov bl, dl
        call Registrai
        call KablTarpas
        cmp w, 1
        je PaimtiDarDar
        call MasKodas
        jmp NeimtiDarDar
     PaimtiDarDar:
        mov al, baitas2
        call MasKodas
        mov al, baitas1
        call MasKodas
     NeimtiDarDar:
        call Pratesimas
        jmp Testi 
 ZodinisReg:
        mov al, bl                  ;zodiniai
        shr al, 3
        mov komand, 21              
        cmp al, 00001000b           ;inc  (0100 0reg)
        je ZodReg
        mov komand, 24
        cmp al, 00001001b           ;dec  (0100 1reg)
        je ZodReg
        mov komand, 52
        cmp al, 00001010b           ;push (0101 0reg)
        je ZodReg
        mov komand, 6 
        cmp al, 00001011b           ;pop  (0101 1reg)
        je ZodReg
        jmp CALLJUMPinti 
     ZodReg:
        and bl, 00000111b
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx
        mov w, 1
        call Registrai
        call Pratesimas
        jmp Testi
 CALLJUMPinti:
        mov al, bl
        mov komand, 56
        cmp al, 10011010b           ;call(isor.t)  (1001 1010)
        je IsorTiesiog
        cmp al, 11101000b           ;call(vid.t)   (1110 1000)
        je VidTiesiog
        mov komand, 39
        cmp al, 11101010b           ;jmp(isor.t)   (1110 1010)
        je IsorTiesiog
        cmp al, 11101001b           ;jmp(vid.t)    (1110 1001)
        je VidTiesiog
        jmp INTinti
     IsorTiesiog: 
        call DuokBaita
        call MasKodas
        mov baitas1, al
        call DuokBaita
        call MasKodas
        mov baitas2, al
        call DuokBaita
        call MasKodas
        mov baitas3, al
        call DuokBaita
        call MasKodas
        mov baitas4, al
        call Tabinti
        push cx
        mov cl, komand
        call Komandinti
        pop cx
        mov al, baitas4
        call MasKodas
        mov al, baitas3
        call MasKodas
        mov byte ptr [di], 3ah
        inc di
        inc rezFailas
        mov al, baitas2
        call MasKodas
        mov al, baitas1
        call MasKodas
        call Pratesimas
        jmp Testi
     VidTiesiog:   
        call DuokBaita
        call MasKodas
        mov baitas1, al
        call DuokBaita
        call MasKodas
        mov baitas2, al
        call Tabinti
        push cx
        mov cl, komand
        call Komandinti
        pop cx
        mov al, baitas2
        call MasKodas
        mov al, baitas1
        call MasKodas
        call Pratesimas
        jmp Testi           
 INTinti:
        mov al, bl
        cmp al, 11001101b           ;int (ir numeris)
        jne RETinti 
        mov komand, 42
        call DuokBaita
        call MasKodas
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx
        call MasKodas
        call Pratesimas
        jmp Testi 
 RETinti:                           ;be betarpisko operando ir su operandu
        mov al, bl
        mov komand, 36              
        cmp al, 11000011b           ;ret         (1100 0011)
        je RETyra 
        cmp al, 11000010b           ;ret(oper)   (1100 0010)
        je RETyra2
        mov komand, 61 
        cmp al, 11001011b           ;retf        (1100 1011)
        je RETyra
        cmp al, 11001010b           ;retf(oper)  (1100 1010)
        je RETyra2
        mov komand, 60             
        cmp al, 11001111b           ;iret        (1100 1111)
        jne DarSegmentu
     RETyra:   
        call Tabinti
        push cx
        mov cl, komand
        call Komandinti
        pop cx
        call Pratesimas
        jmp Testi
     RETyra2: 
        call DuokBaita
        call MasKodas
        mov baitas1, al
        call DuokBaita
        call MasKodas
        mov baitas2, al
        call Tabinti
        push cx
        mov cl, komand
        call Komandinti
        pop cx
        mov al, baitas2
        call MasKodas
        mov al, baitas1
        call MasKodas
        call Pratesimas
        jmp Testi 
 DarSegmentu:                       ;push/pop segmento registras
        mov al, bl                  
        shr al, 5
        cmp al, 0
        jne SalygJMP
        mov al, bl
        mov komand, 52              
        and al, 00000111b
        cmp al, 00000110b           ;push  (000s r110)
        je Segmentinimas
        mov komand, 6
        cmp al, 00000111b           ;pop   (000s r111)
        jne SalygJMP
     Segmentinimas:                 ;sr-00es, 01cs, 10ss, 11ds
        shr bl, 3
        mov reg, bl
        call Tabinti 
        push cx
        mov cl, komand
        call Komandinti
        pop cx
        call NustatytiSeg
        call Pratesimas
        jmp Testi        
                  
 SalygJMP:
        mov al, bl  
        shr al, 4                                                  
        cmp al, 00000111b
        je SalJMP
        mov al, bl
        cmp al, 11100011b
        je SalJMP
        mov jumpas, 51
        cmp al, 11100010b           ;loop
        je SalJ
        mov jumpas, 39
        cmp al, 11101011b           ;jmp(vid.artimas)
        je SalJ
        mov jumpas, 0
        jmp Neatpazintas
     SalJMP:                        ;visi salyginiai JMP
        cmp bl, 01110000b
        je SalJ 
        add jumpas, 2
        cmp bl, 01110100b
        je SalJ
        add jumpas, 2
        cmp bl, 01110111b
        je SalJ 
        add jumpas, 2
        cmp bl, 01111000b
        je SalJ
        add jumpas, 2
        cmp bl, 01111010b
        je SalJumpinti
        add jumpas, 2
        cmp bl, 01111100b
        je SalJumpinti
        add jumpas, 2
        cmp bl, 01111111b
        je SalJumpinti
        jmp NesalJ
     SalJ:
        jmp SalJumpinti
     NesalJ:
        add jumpas, 3
        cmp bl, 01110001b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01110011b
        je SalJumpinti 
        add jumpas, 3
        cmp bl, 01110101b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01110110b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01111001b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01111011b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01111101b
        je SalJumpinti
        add jumpas, 3
        cmp bl, 01111110b
        je SalJumpinti
        add jumpas, 7
        cmp bl, 01110010b
        je SalJumpinti
        add jumpas, 4
     SalJumpinti:
        call DuokBaita 
        call MasKodas
        call Tabinti
        call JUMPinimam
        mov byte ptr [di], 20h
        inc di
        add rezFailas, 1
        mov ax, poslinkis
        call ArSkaiciusSUzenklu
        add ax, bx
        add ax, 1
        mov bx, ax
        mov al, ah
        mov ah, 0
        call MasKodas
        mov al, bl
        call MasKodas
        call Pratesimas
        jmp Testi    
 Neatpazintas:                      ;neatpazintas
        call Tabinti
        call Irasymas
        push cx
        mov dx, offset nepaz   
        mov ah, 40h
        mov bx, rfailas
        mov cx, 14
        jc KlaidaRasant
        int 21h 
        pop cx
        jmp Testi  
    Skaityk0:
        jmp Skaityk                
    KlaidaAtidarantRasymui:
        jmp UzdarytiSkaitymui   
;*********************************************************************************************************** 
    RasykBufPabaiga:                    ;ar nuskaitytas visas failas
        mov cx, SkaitymoBuff
        cmp cx, skBufDydis  
        je Skaityk0        
    UzdarytiRasymui:                    ;rasomo failo uzdarymas
        mov ah, 3Eh
        mov bx, rFailas
        int 21h
        jc KlaidaUzdarantRasymui               
    UzdarytiSkaitymui:                  ;skaitomo failo uzdarymas
        mov ah, 3Eh
        mov bx, dFailas
        int 21h
        jc KlaidaUzdarantSkaitymui          
        mov ah, 4Ch                     ;grazinti DOS
        mov al, 0
        int 21h                    
    KlaidaRasant:                       ;klaidos
        mov ax, 0
        jmp RasykBufPabaiga
    KlaidaUzdarantRasymui:
        jmp UzdarytiSkaitymui     
    KlaidaUzdarantSkaitymui:
        jmp Pabaiga
    Pabaiga:                            ;KLAIDOS pabaiga
        mov ah, 9h
        mov dx, offset vardas
        int 21h 
        mov ah, 4Ch
        mov al, 0
        int 21h
;***********************************************************************************************************
    PROC Skaitymas                        ;nuskaito buferi
        push ax 
        mov ah, 3Fh 
        mov bx, dFailas
        mov cx, skBufDydis
        mov dx, offset skBuf
        int 21h
        jc KlaidaSkai
        mov si, offset skBuf
        jmp NeKlaidaSkai
     KlaidaSkai:
        mov ax, 0
        jmp UzdarytiSkaitymui
     NeKlaidaSkai: 
        mov cx, ax 
        mov SkaitymoBuff, cx
        cmp cx, 0
        je UzdarytiRasymui
        pop ax
        ret
    ENDP Skaitymas
    PROC DuokBaita                         ;nuskaito sekanti baita
        push dx
        inc poslinkis
        cmp cx, 0
        je DuokBuff
        jmp NeduokBuff
     DuokBuff: 
        call Skaitymas    
     NeduokBuff:    
        mov al, [si]
        inc si
        mov bl, al
        dec cx  
        pop dx
        ret
    ENDP DuokBaita 
    PROC Raides2  
        push ax
        push bx
        cmp dl, 9h
        jg Pakeisti 
        jmp Nekeisti
     Pakeisti:
        add dl, 7h
     Nekeisti:
        add dl, 30h
        mov [di], dl
        inc di
        inc rezFailas 
        pop bx
        pop ax 
        ret
    ENDP Raides2
	PROC MasKodas                           ;masininis kodas
	    push ax
	    push dx 
	    mov dx, ax 
	    shr dx, 4 
	    call Raides2
	    mov dx, ax 
	    mov ax, 0
	    and dl, 00001111b
	    call Raides2    
	 Baigti:      
	    pop dx
	    pop ax
	    ret
	ENDP MasKodas	
	PROC Irasymas                            ;iraso viska i faila
        push ax
        push bx
        push cx
        push dx
        mov ah, 40h
        mov cl, rezFailas
        mov bx, rFailas
        mov dx, offset raBuf
        int 21h
        jc KlaidaRas
        jmp NeKlaidaRas
     KlaidaRas:
        mov ax, 0
        jmp RasykBufPabaiga
     NeKlaidaRas:
        mov rezFailas, 0
        pop dx
        pop cx
        pop bx
        pop ax 
        ret
	ENDP Irasymas
	PROC Registrai                          ;spausdina reikiama registra (pagal reg+w)
        push bx 
        push dx
        cmp seg1, 1
        je PaimtiSEG
        jmp NeimtiSEG
     PaimtiSEG:
        call NustatytiSeg
        jmp Finito
     NeimtiSEG: 
        mov dl, bl 
        mov registrasA, 61h
        mov registrasB, 6Ch 
	    cmp bl, 0h
	    je Uzregistrinti
	    cmp bl, 4h
	    je Uzregistrinti
	    mov registrasA, 63h
	    cmp bl, 1h
	    je Uzregistrinti
	    cmp bl, 5h
	    je Uzregistrinti
	    mov registrasA, 64h
	    cmp bl, 2h
	    je Uzregistrinti
	    cmp bl, 6h
	    je Uzregistrinti
	    mov registrasA, 62h
	    cmp bl, 3h
	    je Uzregistrinti
	    cmp bl, 7h
	    je Uzregistrinti 
	 Uzregistrinti:
	    and bl, 00000100b
	    cmp bl, 00000100b
	    je Wordinti2
	    cmp w, 0 
	    je Newordinti
	 Wordinti:
	    add registrasB, 0Ch 
	    jmp Newordinti
	 Wordinti2:
	    cmp w, 0
	    je Wordinti1
	    jmp Wordinti3
	 Wordinti1:
	    mov registrasB, 68h 
	    jmp Newordinti
	 Wordinti3: 
	    mov registrasA, 73h
	    mov registrasB, 70h 
	    cmp dl, 4h
	    je Newordinti
	    mov registrasA, 62h 
	    cmp dl, 5h
	    je Newordinti 
	    mov registrasA, 73h
	    mov registrasB, 69h 
	    cmp dl, 6h
	    je Newordinti 
	    mov registrasA, 64h 
	    cmp dl, 7h       
	 Newordinti:
	    mov dl, registrasA
	    mov [di], dl
	    inc di 
	    mov dl, registrasB
	    mov [di], dl
	    inc di 
	    add rezFailas, 2
	 Finito:
	    pop dx
        pop bx
        ret
	ENDP Registrai 
	PROC RMposlinkis                         ;spausdina r/m POSLINKI su registru ir jei reikia su skaiciais
        push bx                               ;ir/arba su prefiksu
        push cx 
        push dx
        cmp prefix, 0
        je NeraPrefikso
        call ReikiaPrefikso  
     NeraPrefikso: 
        cmp yrabaitas, 0
        jg NeAdrBaitas
        call RMnustatyti
     NeAdrBaitas:   
        xor bx, bx 
        cmp modAS, 3
        je REGvietojRM
        mov byte ptr [di], 5Bh
	    inc di
	    inc rezFailas
        cmp modAS, 0
        je ArTiesiogAdr
        jmp RMpaprastas
     ArTiesiogAdr:
        cmp rm, 6
        jne RMpaprastas 
        call RMposlinkisBE 
        jmp NEBEmod
     REGvietojRM: 
        mov seg1, 0
	    mov bl, rm
	    call Registrai        
        jmp NEBEmod1           
     RMpaprastas:   
        mov cl, modPos                 
        mov bx, offset modPoslin
        add bl, cl
        call IkeltiDI 
	    call IkeltiDI
	    add rezFailas, 2
	    cmp modpos, 20
	    jg SUposlink
	    call IkeltiDI
	    call IkeltiDI
	    call IkeltiDI
	    add rezFailas, 3
     SUposlink:
        cmp modAS, 0          
        je NEBEmod
        mov byte ptr [di], 2Bh
	    inc di 
	    inc rezFailas
	    call RMposlinkisBE  
     NEBEmod:
        mov byte ptr [di], 5Dh
	    inc di
	    inc rezFailas
	 NEBEmod1:  
	    pop dx     
        pop cx
        pop bx
        ret
	ENDP RMposlinkis
	PROC RMposlinkisBE                        ;spausdina POSLINKI be registro reiksmes(tik skaicius)
	    push ax                                ;baitas2, baitas1 - [poslinkio]
        push bx
        mov ah, 0
	    mov al, baitas2
	    cmp modAS, 1
	    je Nereikia
	    call MasKodas
	    mov al, baitas1
	    call MasKodas
	    jmp BaigtiPoslinkis 
	 Nereikia:
	    mov bl, baitas1
	    call ArSkaiciusSUzenklu
	    mov al, bh 
	    mov ah, 0
	    call MasKodas
	    mov al, bl
	    call MasKodas
	 BaigtiPoslinkis:
        pop bx
        pop ax
        ret
	ENDP RMposlinkisBE
	PROC NustatytiSeg                   ;iraso reikiama segmenta
	    push bx
	    mov bl, reg
	    and bl, 00000011b
	    mov seg1, 65h
	    cmp bl, 0 
	    je Rasta
	    mov seg1, 63h
	    cmp bl, 1
	    je Rasta
	    mov seg1, 73h
	    cmp bl, 2
	    je Rasta
	    mov seg1, 64h	    
	 Rasta:
	    mov dl, seg1
        mov [di], dl
        inc di
        mov byte ptr [di], 73h
        inc di
        add rezFailas, 2  
	    pop bx
	    ret
	ENDP NustatytiSeg
	PROC ReikiaPrefikso                          ;iraso prefiksa
	    push bx
        push cx
        mov cl, prefix                 
        mov bx, offset Prefiksas
        add bl, cl
	    call IkeltiDI
        call IkeltiDI
        mov byte ptr [di], 58
        inc di
        add rezFailas, 3
        pop cx
        pop bx
        ret
	ENDP ReikiaPrefikso
	PROC Komandinti                           ;spausdina reikiama KOMANDA
	    push bx
	    push cx 
        xor bx, bx
        mov bx, offset komandos
        add bx, cx
	    call IkeltiDI
	    call IkeltiDI 
	    cmp komand, 2
	    jl Nepapildomas1
	    call IkeltiDI
	    inc rezFailas 
	    cmp komand, 51
	    jg Papildomas1
	    jmp Nepapildomas1
	 Papildomas1:
	    call IkeltiDI
	    inc rezFailas
	 Nepapildomas1:  
	    mov byte ptr [di], 20h
	    inc di 
	    add rezFailas, 3
        pop cx
        pop bx 
        ret
	ENDP Komandinti
	PROC Pratesimas                                  ;jei cx=0
	    push ax
	    mov byte ptr [di], 13
	    inc di
	    mov byte ptr [di], 10
	    inc di
	    add rezFailas, 2
	    call Irasymas
        pop ax 
        ret
	ENDP Pratesimas
	PROC Tabinti                                    ;dvigubas tabas
	    push ax
	    mov byte ptr [di], 9 
        inc di
        inc rezFailas
        cmp rezFailas, 13
        jg Nebetabinti
        mov byte ptr [di], 9
        inc di
        inc rezFailas
     Nebetabinti:
        pop ax 
        ret
	ENDP Tabinti
	PROC KablTarpas                                ;kablelis ir tarpas
	    push ax
	    mov byte ptr [di], 2Ch 
        inc di
        mov byte ptr [di], 20h
        inc di
        add rezFailas, 2
        pop ax 
        ret
	ENDP KablTarpas
	PROC JUMPinimam                              ;procedura, skirta salyginiam JUMPam
	    push bx                                  ;+loop+jmp
	    push cx 
        xor bx, bx
        mov cl, jumpas
        mov bx, offset JMP2
        add bx, cx
	    call IkeltiDI
	    call IkeltiDI
	    cmp jumpas, 14
	    jl Nejumpinam
	    call IkeltiDI 
	    add rezFailas, 1
	    cmp jumpas, 42
	    jl Nejumpinam
	    call IkeltiDI
	    add rezFailas, 1 
	 Nejumpinam:
	    mov jumpas, 0
	    add rezFailas, 2
	    pop cx
	    pop bx
	    ret
	ENDP JUMPinimam
	PROC IkeltiDI                             ;ikelti i [di]
	    push ax
        mov cl, [bx]
	    mov [di], cl
	    inc di
	    inc bx
        pop ax 
        ret
	ENDP IkeltiDI	
	PROC Winti                             ;nustatyti w
	    push ax
        and al, 00000001b
        mov w, al
        pop ax 
        ret
	ENDP Winti
	PROC DWinti                            ;nustatyti ir w, ir d
	    push ax
	    call Winti
	    shr al, 1
        and al, 00000001b
        mov d, al
        pop ax 
        ret
	ENDP DWinti
	PROC MODRMREGinti                      ;nustatyti mod, reg, rm
	    push ax
	    push bx
	    and al, 00000111b
	    mov rm, al
	    mov al, bl
	    shr al, 3
	    and al, 00000111b
	    mov reg, al
	    shr bl, 6
	    mov modAS, bl
        pop bx
        pop ax 
        ret
	ENDP MODRMREGinti	
	PROC RMnustatyti                       ;nustatyti RM pozicija
	    push ax
	    mov modPos, 0
	    cmp rm, 00000000b
	    je MODnustatytas
	    add modPos, 5
	    cmp rm, 00000001b
	    je MODnustatytas
	    add modPos, 5
	    cmp rm, 00000010b
	    je MODnustatytas
	    add modPos, 5
	    cmp rm, 00000011b
	    je MODnustatytas
	    add modPos, 6
	    cmp rm, 00000100b
	    je MODnustatytas
	    add modPos, 2
	    cmp rm, 00000101b
	    je MODnustatytas
	    add modPos, 2
	    cmp rm, 00000110b
	    je MODnustatytas
	    add modPos, 2 
     MODnustatytas:   
        pop ax 
        ret
	ENDP RMnustatyti
	PROC ArSkaiciusSUzenklu                  ;ziuri, koks yra skaicius su zenklu
	    push cx
	    mov cx, bx
	    mov bh, 0
        and cl, 10000000b
        cmp cl, 10000000b
        je Neigiamas
        jmp Neneigiamas 
     Neigiamas:
        mov bh, 0FFh
     Neneigiamas: 
        pop cx
	    ret
	ENDP ArSkaiciusSUzenklu
	PROC ByteArWord                  ;byte ptr ar word ptr spausdinti                      
	    push cx
	    push bx 
	    xor bx, bx
	    cmp modAS, 3
	    je Nespausdinti
	    cmp w, 0
	    jne ByteIrWord
        mov bx, offset dydis
        jmp Atspausdinta
	 ByteIrWord:
	    mov bx, offset dydis1                  
     Atspausdinta:
	    call IkeltiDI
        call IkeltiDI
        call IkeltiDI
        call IkeltiDI
        mov byte ptr [di], 20h
        inc di
        mov byte ptr [di], 'p'
        inc di
        mov byte ptr [di], 't'
        inc di
        mov byte ptr [di], 'r'
        inc di
        mov byte ptr [di], 20h
        inc di
	    add rezFailas, 9
	 Nespausdinti:
        pop bx 
        pop cx
	    ret
	ENDP ByteArWord 
	PROC Palyginimukas                    ;palyginti s ir w sajunga
	    push ax 
	    cmp w, 1
	    je BaigtiLyginima
	    mov s, 2
	 BaigtiLyginima:   
	    pop ax
	    ret
	ENDP Palyginimukas
	PROC ArTinkamasBaitas                    ;tikrinti, ar tinkamas baitas   
	    push bx                                  
	    mov al, bl                              
	    call Winti
	    call DuokBaita
	    mov busimasbaitas, al
	    call MODRMREGinti
	    mov komand, 30  
        cmp reg, 4
        je Tinkamas
        mov komand, 33
        cmp reg, 6 
        je Tinkamas
     Netinkamas: 
        mov buvesbaitas, 1
	    call Tabinti
        call Irasymas
        push cx
        mov dx, offset nepaz   
        mov ah, 40h
        mov bx, rfailas
        mov cx, 14
        int 21h
	    pop cx
     Tinkamas:
        pop bx
	    ret
	ENDP ArTinkamasBaitas
	PROC KOKSAkumuliatorius                 ;nustato akumuliatoriu
	    push bx   
	    mov byte ptr [di], 'a'
        inc di
        cmp w, 0
        je REGmazesnis
        mov byte ptr [di], 'x'
        inc di
        jmp Nemazesnis
     REGmazesnis:
        mov byte ptr [di], 'l'
        inc di
     Nemazesnis:  
        add rezFailas, 2
	    pop bx
	    ret
	ENDP KOKSAkumuliatorius
	PROC Variantas1                  ;1 proceduru variantas
	    push ax 
	    call DuokBaita               ;mov-8C, 8E    (1000 11d0)
        call MasKodas                ;segment.registras<>reg/atmintis
        call MODRMREGinti
        cmp modAS, 3
        je NeimtiNaujo               ;mov-88, 89, 8A, 8B   (1000 10dw)
        cmp modAS, 0                 ;registras<>reg/atmintis
        je Neimti1
        jmp Imti1  
     Neimti1:                        ;add   (0000 00dw)
        cmp rm, 6                    ;or    (0000 10dw)                             
        jne NeimtiNaujo              ;sub   (0010 10dw)
     Imti1:                          ;and   (0010 00dw)
        mov yrabaitas, 1             ;xor   (0011 00dw)
        call RMnustatyti             ;cmp   (0011 10dw)
        call DuokBaita               ;registras<>registras/atmintis
        call MasKodas
        mov baitas1, al
        cmp modAS, 1
        je NeimtiNaujo               
        call DuokBaita
        call MasKodas
        mov baitas2, al
        jmp NeimtiNaujo
     NeimtiNaujo:
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx
        cmp d, 1
        je Neapkeisti
        call RMposlinkis
        call KablTarpas
        cmp s, 1
        jne NeimtiSegmento
        mov seg1, 1
     NeimtiSegmento: 
        mov bl, reg 
        call Registrai
        jmp Mov0pabaiga
     Neapkeisti:
        mov bl, reg
        call Registrai
        call KablTarpas
        call RMposlinkis
     Mov0pabaiga: 
        call Pratesimas
        pop ax                       
	    ret
	ENDP Variantas1
	PROC Variantas2                  ;2 proceduru variantas
	    push ax
	    mov al, bl
        and al, 11111110b            ;mul/div (1111 011w, reg=100/110)
        cmp al, 11110110b            ;registras/atmintis
        je Nebeatskirai0 
        cmp al, 10001110b            ;pop  (1000 1111)
        je Neatskirai                ;registras/atmintis
        mov al, bl
	    call Winti             
        call DuokBaita               ;grupe - 1111 111w
        call MasKodas                ;registras/atmintis arba adresas
	    call MODRMREGinti            
	    mov komand, 21               ;inc
	    cmp reg, 0 
	    je Nebeatskirai
	    mov komand, 24               ;dec
	    cmp reg, 1 
	    je Nebeatskirai
	    mov komand, 56               ;call (vid.netiesioginis)
	    cmp reg, 2 
	    je Nebeatskirai
	    mov komand, 56               ;call (isor.netiesioginis)
	    cmp reg, 3 
	    je Nebeatskirai
	    mov komand, 39               ;jmp (vid.netiesioginis)
	    cmp reg, 4 
	    je Nebeatskirai
	    mov komand, 39               ;jmp (isor.netiesioginis)
	    cmp reg, 5 
	    je Nebeatskirai
	    mov komand, 52               ;push
	    jmp Nebeatskirai
     Neatskirai:
	    mov al, bl
	    call Winti             
        call DuokBaita
        call MasKodas
	    call MODRMREGinti 
	    jmp Nebeatskirai
	 Nebeatskirai0:
	    mov al, busimasbaitas            
        call MasKodas
     Nebeatskirai:
        cmp modAS, 3
        je NereikiaBaito
        cmp modAS, 0
        je ArNereikiaBaito
        jmp ReikiaBaito
     ArNereikiaBaito:
        cmp rm, 6
        jne NereikiaBaito
     ReikiaBaito:
        call RMnustatyti
        mov yrabaitas, 1 
        call DuokBaita
        call MasKodas
        mov baitas1, al
        cmp modAS, 1
        je NereikiaBaito
        call DuokBaita
        call MasKodas
        mov baitas2, al
     NereikiaBaito:   
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx 
        call ByteArWord
        call RMposlinkis
        call Pratesimas
	    pop ax
	    ret
	ENDP Variantas2 
	PROC Variantas3                  ;3 proceduru variantas
	    push ax 
	    cmp NustatytaKomanda, 0
	    jg Nebepaimti                ;mov-C6, C7-MOV  (1100 011w)
	    call DuokBaita               ;registras/atmintis-betarp.operandas
        call MasKodas
        call MODRMREGinti
     Nebepaimti:
        call RMnustatyti             ;(1000 00sw)
        cmp modAS, 0                 ;grupe su s(betarp.operando dydis)
        je NeimtiMODgal              ;registras/atmintis-betarp.operandas
        cmp modAS, 3
        je NeimtiMODui
        cmp modAS, 1                 ;add
        je PaimtiMOD1                ;or
     VisgiImti:                      ;adc
        call DuokBaita               ;sbb
        call MasKodas                ;and
        mov baitas1, al              ;sub
        call DuokBaita               ;xor
        call MasKodas                ;cmp
        mov baitas2, al
        cmp s, 0
        je NeimtiMODui
        cmp s, 1
        je ImtiWviena
        jmp NeimtiMODui
     NeimtiMODgal:
        cmp rm, 6 
        je VisgiImti
        cmp s, 0
        je NeimtiMODui
        cmp s, 1
        je ImtiWviena
        jmp NeimtiMODui
     PaimtiMOD1: 
        call DuokBaita
        call MasKodas
        mov baitas1, al
     NeimtiMODui:
        cmp s, 1
        je ImtiWviena  
        cmp w, 0 
        je ImtiWviena
        call DuokBaita
        call MasKodas
        mov baitas3, al
     ImtiWviena: 
        call DuokBaita
        call MasKodas
        mov baitas4, al
        call Tabinti
        push cx
        mov cl, komand 
        call Komandinti
        pop cx 
        call ByteArWord
        call RMposlinkis
        call KablTarpas
        cmp s, 1
        je PraplestiOper
        mov al, baitas4
        call MasKodas
        cmp w, 0                 
        je ImtiTikviena
        mov al, baitas3
        call MasKodas
        jmp ImtiTikviena
     PraplestiOper: 
        mov bl, baitas4
        call ArSkaiciusSUzenklu
        mov al, bh
        call MasKodas
        mov al, bl
        call MasKodas
     ImtiTikviena:
        call Pratesimas
	    pop ax
	    ret
	ENDP Variantas3
	PROC Variantas4                  ;4 proceduru variantas
	    push bx  
	    and bl, 00000001b            ;su Akumuliatoriais(ax/al)
        mov w, bl
        call DuokBaita 
        call MasKodas                ;mov-A2, A3  (1010 001w)
        mov baitas1, al              ;atmintis-akumuliatorius
        cmp modAS, 0
        je PaimtiDarVien             ;mov-A0, A1  (1010 000w)
        cmp w, 0                     ;akumuliatorius-atmintis
        je Tikviena
     PaimtiDarVien:
        call DuokBaita               ;add  (0000 010w)
        call MasKodas                ;or   (0000 110w)
        mov baitas2, al              ;and  (0010 010w)
     Tikviena:                       ;sub  (0010 110w)
        call Tabinti                 ;xor  (0011 010w)
        push cx                      ;cmp  (0011 110w)
        mov cl, komand               ;akumuliatorius-betarp.operandas
        call Komandinti              
        pop cx 
        cmp d, 2
        je KEISTIvietom
        jmp NEKEISTIvietom
     KEISTIvietom:
        call RMposlinkis
        call KablTarpas
        call KOKSAkumuliatorius
        jmp Pasibaigti 
     NEKEISTIvietom:
        call KOKSAkumuliatorius 
        call KablTarpas
        cmp d, 1
        je KitaImti
        cmp w, 1
        je DvejiBaitai
     VieniBaitai:
        mov al, baitas1
        call MasKodas
        jmp Pasibaigti
     DvejiBaitai:
        mov al, baitas2
        call MasKodas
        mov al, baitas1
        call MasKodas
        jmp Pasibaigti 
     KitaImti:
        call RMposlinkis
     Pasibaigti:
        call Pratesimas
	    pop bx
	    ret
	ENDP Variantas4
	PROC Variantas5                  ;5 proceduru variantas
	    push bx                      
	    call DuokBaita               ;grupe (1101 00vw) - v=1, tai imama is cl
        call MasKodas                ;reg/atmintis (1/cl)
        call MODRMREGinti
        mov al, reg
        mov komand, 0                ;rol
        cmp al, 0
        je NustatytasSukimas 
        add komand, 3                ;ror
        cmp al, 1
        je NustatytasSukimas
        add komand, 3                ;rcl
        cmp al, 2
        je NustatytasSukimas
        add komand, 3                ;rcr
        cmp al, 3
        je NustatytasSukimas
        add komand, 3                ;shl arba sal -tas pats mas. kodas
        cmp al, 4
        je NustatytasSukimas
        add komand, 3                ;shr
        cmp al, 5
        je NustatytasSukimas
        add komand, 3                ;sar
     NustatytasSukimas:
        call RMnustatyti 
        call Tabinti
        push cx
        mov cl, komand
        mov bx, offset sukiniai
        add bx, cx
	    call IkeltiDI
	    call IkeltiDI 
	    call IkeltiDI
	    add rezFailas, 3
	    pop cx
	    mov byte ptr [di], 20h
	    inc di
	    inc rezFailas 
	    call RMposlinkis
	    call KablTarpas
	    cmp v, 1
	    je ReikiaCl 
	    mov byte ptr [di], '1'
	    inc di             
	    inc rezFailas
	    jmp NereikiaCl
	 ReikiaCl:
	    mov byte ptr [di], 'c'
	    inc di
	    mov byte ptr [di], 'l'
	    inc di
	    add rezFailas, 2
	 NereikiaCl:    
	    call Pratesimas    
	    pop bx
	    ret
	ENDP Variantas5
      
END Pradzia
ret




