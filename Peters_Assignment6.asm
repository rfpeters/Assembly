TITLE Read Integers     (Peters_Assignment6.asm)

; Author: Ryan Peters
; Course / Project ID  CS271_400 Assignment 6A               Date: 03/10/16
; Description: Program get the user to input 10 unsigned numbers.  The numbers
;	are read a strings.  The numbers are need to fit in a 32 bit register.  
;	The number are validated and converted to integers.  The numbers are stored
;	in an array after conversion from string to integer.  The sum and average
;	of the numbers is calculated.  The numbers are convert back to strings before
;   they are displayed.

INCLUDE Irvine32.inc

;Macro prints string.
;receives: Address of string.
;returns: display string.
;preconditions: n/a
;registers changed: registers used are saved and restored.
displayString	MACRO	buffer
	push edx
	mov	edx, buffer
	call WriteString
	pop edx
ENDM

;Macro prompts user to enter input, reads input as string.
;receives: Address of prompt, input variable, and size of input variable.
;returns: input variable gets value.
;preconditions: prompt, input variable, and input size defined.
;registers changed: registers used are saved and restored.
getString	MACRO	prompt, buffer, size
	push	edx
	push	ecx
	mov		edx, prompt
	call	WriteString
	mov		edx, buffer
	mov		ecx, size - 1
	call	ReadString
	pop		ecx
	pop		edx
ENDM

.data

intro_title		BYTE	"Designing low-level I/O procedures		Written by: Ryan Peters", 0
intro_1			BYTE	"Please provide 10 unsigned decimal integers.", 0
intro_2			BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
intro_3			BYTE	"After you have finished inputting the raw numbers I will display a list", 0
intro_4			BYTE	"of the intgers, there sum, and their average.", 0
prompt			BYTE	"Please enter an unsigned number: ", 0
prompt_error	BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0
output			BYTE	"You entered the following numbers:", 0
output_sum		BYTE	"The sum of these numbers is: ", 0
output_avg		BYTE	"The average is: ", 0
output_bye		BYTE	"Thanks for playing.", 0
input			BYTE	20 DUP(0)
input_size		DWORD	SIZEOF input
numString		BYTE	20 DUP(0)
numbers_arr		DWORD	10 DUP(?)
sum				DWORD	?
average			DWORD	?

.code
main PROC
	push	OFFSET intro_4
	push	OFFSET intro_3
	push	OFFSET intro_2
	push	OFFSET intro_1
	push	OFFSET intro_title
	call	intro

	push	OFFSET input
	push	input_size
	push	OFFSET numbers_arr
	push	OFFSET prompt_error
	push	OFFSET prompt
	call	readVal

	push	OFFSET sum
	push	OFFSET average
	push	OFFSET numbers_arr
	call	calc
	call	CrLf

	push	OFFSET numString
	push	OFFSET output
	push	OFFSET numbers_arr
	call	dispArr
	call	CrLf

	push	OFFSET numString
	push	average
	push	OFFSET output_avg
	push	sum
	push	OFFSET output_sum
	call	dispStats
	call	CrLf

	push	OFFSET output_bye
	call	dispBye
	call	CrLf

	exit	
main ENDP

;Procedure invokes displayString macro to display title and instructions.
;receives: Addresses of intro_title, intro_1, intro_2, intro_3, intro_4 are passed on the stack.
;returns: n/a
;preconditions: prompts defined.
;registers changed:	n/a
intro PROC
	push	ebp
	mov		ebp, esp

	displayString	[ebp+8]
	call	CrLf
	call	CrLf
	displayString	[ebp+12]
	call	CrLf
	displayString	[ebp+16]
	call	CrLf	
	displayString	[ebp+20]
	call	CrLf	
	displayString	[ebp+24]
	call	CrLf
	call	Crlf

	mov		esp, ebp
	pop		ebp
	ret		20
intro ENDP

;Procedure invokes getString macro to read input from the user.  The input is converted and
;	validated as unsigned integer.  The integers are stored in numbers_arr.
;receives: Addresses of prompt, prompt_error, numbers_arr, and input are passed on the stack.
;		   The value of input_size is passed on the stack.
;returns: numbers_arr filled.
;preconditions: Parameters defined.
;registers changed: registers used are saved and restored.
readVal	PROC
	LOCAL mul_factor:DWORD
	push	esi
	push	eax
	push	ecx
	push	edi
	push	ebx
	push	edx

	mov		mul_factor, 10
	mov		ecx, 10
	mov		edi, [ebp+16]
L1:
	getString	[ebp+8], [ebp+24], [ebp+20]
	mov		esi, [ebp+24]
	mov		ebx, 0
L2:
	lodsb
	cmp		al, 0
	je		endLoop
	cmp		al, 48
	jl		invalid
	cmp		al, 57
	jg		invalid	
	sub		al, 48
	push	eax
	mov		eax, ebx
	mul		mul_factor
	jc		invalid
	mov		ebx, eax
	pop		eax
	add		ebx, eax
	jmp		L2
endLoop:
	mov		[edi], ebx
	add		edi, 4
	loop	L1
	
	pop		edx
	pop		ebx	
	pop		edi	
	pop		ecx
	pop		eax
	pop		esi	
	ret		20

invalid:
	displayString [ebp+12]
	call	CrLf
	jmp		L1
readVal	ENDP

;Procedure calculates the sum and average of the numbers entered by the user.
;receives: Addresses of sum, average, and numbers_arr are passed on the stack.
;returns: sum and average stored.
;preconditions: Parameters defined, input recieved and converted to integers.
;registers changed: registers used are saved and restored.
calc PROC
	push	ebp
	mov		ebp, esp
	push	esi
	push	ecx
	push	eax
	push	edx
	push	ebx

	mov		eax, 0
	mov		esi, [ebp+8]
	mov		ecx, 10
calcLoop:
	add		eax, [esi]
	add		esi, 4
	loop	calcLoop
	mov		ebx, [ebp+16]
	mov		[ebx], eax
	mov		ebx, 10
	mov		edx, 0
	div		ebx
	mov		ebx, [ebp+12]
	mov		[ebx], eax

	pop		ebx
	pop		edx
	pop		eax
	pop		ecx
	pop		esi
	mov		esp, ebp
	pop		ebp
	ret		12
calc ENDP

;Procedure displayes the array of numbers, uses WriteString to convert numbers to string
;	and print to screen.
;receives: Addresses of output, numString, and numbers_arr, are passed on the stack.
;returns: Array displayed.
;preconditions: numbers_array populated, output defined.
;registers changed: registers used are saved and restored.
dispArr PROC
	push	ebp
	mov		ebp, esp
	push	ecx
	push	edi
	push	eax

	mov		edi, [ebp+8]
	mov		ecx, 10
	displayString [ebp+12]
	call	CrLf
dArrL:
	mov		eax, [edi]
	push	[ebp+16]
	push	eax
	call	writeVal
	cmp		ecx, 1
	jg		addSpace
returnL:
	add		edi, 4
	loop	dArrL

	pop		eax
	pop		edi
	pop		ecx
	mov		esp, ebp
	pop		ebp
	ret		8

addSpace:
	mov		al, ','
	call	WriteChar
	mov		al, ' '
	call	WriteChar
	jmp		returnL
dispArr ENDP

;Procedure displayes the sum and average.  Uses WriteVal to convert integers to strings
;	and displaying.
;receives: Addresses of output_avg, output_sum, and numbers_arr, are passed on the stack.
;		   The value of sum and average are passed on the stack.
;returns: Sum and average displayed.
;preconditions: sum and average calculated, output defined.
;registers changed: registers used are saved and restored.
dispStats PROC
	push	ebp
	mov		ebp, esp
	push	eax

	displayString [ebp+8]
	mov		eax, [ebp+12]
	push	[ebp+24]
	push	eax
	call	writeVal
	call	CrLf
	displayString [ebp+16]
	mov		eax, [ebp+20]
	push	[ebp+24]
	push	eax
	call	WriteVal
	call	CrLf

	pop		eax
	mov		esp, ebp
	pop		ebp
	ret		20
dispStats ENDP
	
;Procedure converts integer to number string an invokes displayString to print number string.
;receives: number value and address of numString passed on stack.
;returns: number displayed.
;preconditions: numString defined, number value passed.
;registers changed: registers used are saved and restored.
writeVal PROC
	LOCAL	div_factor:DWORD	
	push	ebx
	push	eax
	push	edx
	push	edi
	push	ecx

	mov		ecx, 0
	mov		edi, [ebp+12]
	mov		div_factor, 10
	mov		eax, [ebp+8]
pushL:
	mov		edx, 0
	div		div_factor
	add		edx, 48
	push	edx
	inc		ecx
	cmp		eax, 0
	jne		pushL
popL:
	pop		[edi]
	inc		edi
	loop	popL
	displayString [ebp+12]

	pop		ecx
	pop		edi
	pop		edx
	pop		eax
	pop		ebx
	ret		4
writeVal ENDP

;Procedure good-bye message, invokes displayString to prints message.
;receives: Addresses of output_bye is passed on the stack.
;returns: Display message.
;preconditions: Message defined.
;registers changed: registers used are saved and restored.
dispBye PROC
	push	ebp
	mov		ebp, esp

	displayString [ebp+8]

	mov		esp, ebp
	pop		ebp
	ret		4
dispBye	ENDP
END main
