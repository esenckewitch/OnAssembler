.486                                      ; create 32 bit code
.model flat, stdcall                      ; 32 bit memory model
option casemap :none                      ; case sensitive 

;clude files
;~~~~~~~~~~~
include includes\windows.inc       ; main windows include file
include includes\masm32.inc        ; masm32 library include

;------------------------
; Windows API include files
; -------------------------
include includes\gdi32.inc
include includes\user32.inc
include includes\kernel32.inc
include includes\Comctl32.inc
include includes\comdlg32.inc
include includes\shell32.inc
include includes\oleaut32.inc
include includes\ole32.inc
include includes\msvcrt.inc

include includes\dialogs.inc       ; macro file for dialogs
include includes\macros\macros.asm         ; masm32 macro file

;   libraries
;   ~~~~~~~~~
includelib includes\masm32.lib         ; masm32 static library

; ------------------------------------------
; import libraries for Windows API functions
; ------------------------------------------
includelib includes\gdi32.lib
includelib includes\user32.lib
includelib includes\kernel32.lib
includelib includes\Comctl32.lib
includelib includes\comdlg32.lib
includelib includes\shell32.lib
includelib includes\oleaut32.lib
includelib includes\ole32.lib
includelib includes\msvcrt.lib
																		;������������������������������������������������������������������������
.data
	ten DB 10
	buf_in DB 100 dup (0)
	stdin DD ?
	stdout DD ?
	str1 DB "Original string: ",0
	str2 DB "Result string: ",0
	str3 DB "Task of Senckewitch E.",0
	str5 DB "Rule: ", 0
	str4 DB 13, 10, 0
	nRead_buf DD ?
	nWrite_con DD ?
	rule DB "1", 0
	start1 DB "0Aa"
	end1	DB "9Zz"
.code
procccc1 PROC
	push EBP
	push EDI
	push EAX
	push EDX
	mov EBP, ESP
	mov EDI, [EBP + 5 * 4]
	;Старт подпрограммы
	
	xor EAX, EAX
	jmp pmt2 ;старт цикла	
	
pmt1:	
	inc EDI
pmt2:
	mov AL, [EDI]
	mov DL, AL
	
	cmp AL, 40h;проврека на вхождение буквы в A-Z диапозон
	jle pmt3
	cmp AL, 5Bh
	jge pmt3
	
	mov AH, 40h ;вычисляем остаток от деления на 10 относительно номера заглавной буквы в алфавите
	sub AL, AH
	xor AH, AH
	div ten
	add AH, 30h ;смещаем на найденное значение относительно числа 0
	mov [EDI], AH; помещаем число вместо исходной буквы
pmt3:
	cmp DL, 00
	jne pmt1
	
	pop EBP
	pop EDI
	pop EAX
	pop EDX
	ret 4
procccc1 ENDP

proc2 PROC
	push EBP
	push EDI
	push EAX
	push EBX
	push ECX
	mov EBP, ESP
	mov EDI, [EBP + 6 * 4]	;записываем исходную стркоу
	mov EAX, EDI			;делаем копию
	xor EBX, EBX
	xor ECX, ECX						;Считаем количество символов в строке
	jmp pmx2
pmx1:	
	inc EDI
pmx2:
	mov BL, [EDI]
	inc ECX
	cmp BL, 00h
	jne pmx1
	sub ECX, 4				;указатель строки показывает на конец строки, вычитаем указатель строки "0Dh и 0Ah", и так как осчет начинается с нуля, вычитаем еще один символ, 
	mov EDI, EAX
	xor EAX, EAX
pmx4:
	mov AL, [EDI]			;меняем символы местами
	mov AH, [EDI + ECX]
	mov [EDI], AH
	mov [EDI + ECX], AL
	xor EBX, EBX
	add EBX, EDI
	add EBX, ECX
	cmp EDI, EBX
	je pmx5
	add EBX, 1
	cmp EDI, EBX
	je pmx5
	inc EDI
	sub ECX, 2
	jmp pmx4
pmx5:
	pop ECX
	pop EBX
	pop EAX
	pop EDI
	pop EBP
	ret 4
proc2 ENDP
start:
	invoke AllocConsole 												
																					
	invoke GetStdHandle,STD_OUTPUT_HANDLE								
	mov stdout,eax		
	invoke GetStdHandle,STD_INPUT_HANDLE 								
	mov stdin,eax

	invoke WriteConsole,stdout,addr str3,sizeof str3,addr nWrite_con,0	
	invoke WriteConsole,stdout,addr str4,sizeof str4,addr nWrite_con,0
	invoke WriteConsole,stdout,addr str1,sizeof str1,addr nWrite_con,0 	
	invoke ReadConsole,stdin,ADDR buf_in,99,ADDR nRead_buf,NULL 		
							

	lea ESI, buf_in	
	xor ECX, ECX									
	jmp mt2 ;старт основного цикла для проверки строки на наличие символов отличных от букв и цифр
	
mt1:
	inc ESI	
mt2:
	mov al, [ESI]
	jmp c2; старт цикла в цикле, который проверят 1 символ строки на вхождение в один из диапазонов: 0-9 A-Z a-z
c1:	inc ECX
c2:	
		cmp al, 0Dh ;если строка закончилась, то у нас все символы вошли в диапозон, => выполняется условие, вызываем 1 подпрограмму
		je mt6
		
		mov bl, [start1 + ECX] 	;start1 = "0Aa"
		mov bh, [end1 + ECX]	;end1 = "9Zz"
		cmp al, bl				;если символ за пределами одного из диапозонов, то проверяем кончились ли диапозоны (их всего 3 0-9, A-Z, a-z)  
		jb c3
		cmp al, bh
		ja c3
		jmp mt5
c3:
	cmp ECX, 2	;если все диапозоны кончились => условие не выполнено, мы нашли символ не являющийся буквой или цифрой, выполняем вторую подпрограмму
	jne c1
	jmp mt3 
mt5:	
	cmp al, 0Dh
	jne mt1
mt6:	
	lea EDX, buf_in
	push EDX
	call procccc1 ;cdecl
	jmp mt4
	
mt3:
	mov rule, "2"	
	lea EDX, buf_in
	push EDX
	call proc2	;sdecl
	
mt4:	
	lea EDX, buf_in							
	mov EDI,EDX														
	invoke WriteConsole,stdout,addr str5,sizeof str5,addr nWrite_con,0 	
	invoke WriteConsole,stdout,addr rule,sizeof rule,addr nWrite_con,0 	
	invoke WriteConsole,stdout,addr str4,sizeof str4,addr nWrite_con,0
	invoke WriteConsole,stdout,addr str2,sizeof str2,addr nWrite_con,0 	
	invoke WriteConsole,stdout,EDI,nRead_buf,addr nWrite_con,0 			
	invoke Sleep,6000 													
																		
exit0: invoke ExitProcess,0 											
end start