TITLE Sorting Random Numbers    (Peters_Assignment5.asm)

; Author: Ryan Peters
; Course / Project ID                 Date: 02/22/16
; Description: The program generates an array of random number
;	in the range of 100-999.  The number of elements is the 
;	array is entered by the user.  The array is printed, sorted,
;   and printed again.  The median is calculated and displayed
;	after the array is sorted. 

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LOW_RANGE = 100
HI_RANGE = 999

.data

intro_1				BYTE	"Sorting Random Numbers		Programmed by Ryan Peters", 0
intro_2				BYTE	"This program generates random numbers in the range [100 .. 999],", 0
intro_3				BYTE	"displays original lsit, sorts the list, and calculates the", 0
intro_4				BYTE	"median value. Finally, it displays the list sorted in descending order.", 0
prompt_1			BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
prompt_invalid		BYTE	"Out of Range. Input a new number", 0
unsorted_title		BYTE	"The unsorted random numbers:", 0
sorted_title		BYTE	"The sorted list:", 0
median_output		BYTE	"The median is ", 0
request				DWORD	?
array				DWORD	MAX	DUP(?)

.code
main PROC
	call	Randomize
	push	OFFSET intro_4
	push	OFFSET intro_3
	push	OFFSET intro_2
	push	OFFSET intro_1
	call	intro
	push	OFFSET prompt_invalid
	push	OFFSET request
	push	OFFSET prompt_1
	call	getData
	push	OFFSET array
	push	request
	call	fillArray 
	push	OFFSET array
	push	request
	push	OFFSET unsorted_title
	call	displayArray
	push	OFFSET array
	push	request
	call	sortArray
	push	OFFSET array
	push	request
	push	OFFSET median_output
	call	findMedian
	push	OFFSET array
	push	request
	push	OFFSET sorted_title
	call	displayArray

	exit	; exit to operating system
main ENDP

;Procedure displays the program name, author, and instructions
;	for the user
;receives: Addresses of intro_1, intro_2, intro_3, intro_4 are passed on the stack
;returns: n/a
;preconditions: prompts defined
;registers changed: edx
intro PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp+12]
	call	WriteString	
	call	CrLf
	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+20]
	call	WriteString
	call	CrLf
	call	CrLf
	pop		ebp	
	ret		16
intro ENDP

;Procedure gets and validates the number of elements from the user
;receives: Addresses of prompt_1, prompt_invalid, and request are passed on the stack
;	MIN and MAX are global constants
;returns: result
;preconditions: prompts defined and request declared
;registers changed: edx, eax, ebx
getData PROC
	push	ebp
	mov		ebp, esp
dataStart:
	mov		edx, [ebp+8]
	call	WriteString
	call	ReadInt
	cmp		eax, MIN
	jl		invalid
	cmp		eax, MAX
	jg		invalid
	mov		ebx, [ebp+12]
	mov		[ebx], eax
	pop		ebp
	ret		12
invalid:
	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf
	jmp		dataStart
getData ENDP

;Procedure fills the array with random integers
;receives: Address of array and the value of request are passed on the stack
;	HI_RANGE and LOW_RANGE are global constants
;returns: Filled array
;preconditions: array declared, request entered by user
;registers changed: ecx, edi, eax
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]
	mov		edi, [ebp+12]
fill:
	mov		eax, HI_RANGE-LOW_RANGE
	call	RandomRange
	add		eax, LOW_RANGE
	mov		[edi], eax
	add		edi, 4
	loop	fill
	pop		ebp
	ret		8
fillArray ENDP

;Procedure Displays the array.  Ten elements are displayed on a line
;receives: Address of array and title, and the value of request are passed on the stack
;returns: n/a
;preconditions: array filled, request entered by user
;registers changed: eax, ecx, edx, edi, al
displayArray PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 4
	mov		DWORD PTR [ebp-4], 0
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	mov		ecx, [ebp+12]
	mov		edi, [ebp+16]
print:
	inc		DWORD PTR [ebp-4]
	mov		eax, [edi]
	call	WriteDec	
	cmp		DWORD PTR [ebp-4], 10
	je		newLine
	mov		al, ' '
	call	WriteChar
continue:
	add		edi, 4
	loop	print
	call	CrLf
	mov		esp, ebp
	pop		ebp
	ret		12
newLine:
	call	CrLf
	mov		DWORD PTR [ebp-4], 0
	jmp		continue
displayArray ENDP

;Procedure sorts the array
;receives: Address of array and the value of request are passed on the stack
;returns: Sorted array
;preconditions: array filled, request entered by user
;registers changed: eax, ebx, ecx, edx, edi, esi
sortArray PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]
	mov		edi, [ebp+12]
	dec		ecx
	mov		ebx, 0
L1:
	mov		eax, ebx
	mov		edx, ebx
	inc		edx		
L2:
	mov		esi, [edi+edx*4]
	cmp		esi, [edi+eax*4]
	jg		greater	
return:
	inc		edx
	cmp		edx, [ebp+8]	
	jl		L2
	lea		esi, [edi+ebx*4]
	push	esi
	lea		esi, [edi+eax*4]
	push	esi
	call	switchElements	
	inc		ebx
	loop	L1
	pop		ebp
	ret		8	
greater:
	mov		eax, edx
	jmp		return
sortArray ENDP

;Procedure switches elements in the array
;receives: Addresses of array elements that are being switched 
;	are passed on the stack
;returns: Switched elements
;preconditions: array filled
;registers changed: eax, ebx, ecx, edx
switchElements PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		ebx, [ebp+8]
	mov		edx, [ebp+12]
	mov		eax, [edx]
	mov		ecx, [ebx]
	mov		[ebx], eax
	mov		[edx], ecx
	popad
	pop		ebp
	ret		8
switchElements ENDP

;Procedure finds the median
;receives: Address of array and the value of request are passed on the stack
;returns: n/a
;preconditions: array sorted
;registers changed: eax, ebx, ecx, edx, edi
findMedian PROC
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+12]
	mov		edi, [ebp+16]
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		calcMedian
	mov		eax, [edi+eax*4]
display:	
	mov		edx, [ebp+8]
	call	WriteString
	call	WriteDec
	call	CrLf
	call	CrLf
	mov		esp, ebp
	pop		ebp
	ret		12
calcMedian:
	mov		ecx, [edi+eax*4]
	dec		eax
	add		ecx, [edi+eax*4]
	mov		eax, ecx
	mov		ebx, 2
	div		ebx 	
	jmp display
findMedian ENDP
END main
