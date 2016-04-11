TITLE Composite Numbers     (Peters_Assignment4.asm)

; Author: Ryan Peters
; Course / Project ID: CS271_400 Assignment4      Date: 02/07/16
; Description: The program computes and displays a number of compsite
;	integers.  The number of integers displayed is entered by the 
;	user. The range numbers displayed is 1 to 400.  If the user
;	enters a number outside of the range an error message is displayed
;	and the user must enter a new number.  

INCLUDE Irvine32.inc

UPPER_LIMIT = 400
LOWER_LIMIT = 1
TERMS_PER_LINE = 10
IS_VALID = 1
IS_COMP = 1

.data

intro_1				BYTE	"Composite Numbers		Programmed by Ryan Peters", 0
intro_2				BYTE	"Enter the number of composite numbers you would like to see.", 0
intro_3				BYTE	"I'll accept orders for up to 400 composites.", 0
prompt_1			BYTE	"Enter the number of composites to display [1 .. 400]: ", 0
prompt_invalid		BYTE	"Out of Range. Try Again", 0
num_terms			DWORD	?						;Number of terms entered by the user
num_comp			DWORD	?						;Composite Number
num_on_line			DWORD	0						;Counter for terms printed on a line
valid				BYTE	?						;Flag for if number of terms is within range
composite			BYTE	?						;Flag for is number is composite
spacing				BYTE	"     ", 0
prompt_bye			BYTE	"Results certified by Ryan Peters.  GoodyBye.", 0

.code
main PROC
	call	intro
	call	getUserData
	call	showComposites	
	call	goodBye
	exit	; exit to operating system
main ENDP

;Procedure displays the program name, author, and instructions
;	for the user.
;receives: intro_1, intro_2, and intro_3 are global variables
;returns: n/a
;preconditions: prompts defined
;registers changed: edx
intro PROC
	mov		edx, OFFSET intro_1
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, OFFSET intro_2
	call	WriteString	
	call	CrLf
	mov		edx, OFFSET	intro_3
	call	WriteString
	call	CrLf
	call	CrLf	
	ret;
intro ENDP

;Procedure prompts the user to enter a number between 1 and 400.
;	Calls validate procedure to check if number entered is with in range.
;receives: prompt_1, num_terms, valid, and IS_VALID are global variables
;returns: num_terms = user input
;preconditions: prompts defined
;registers changed: edx
getUserData PROC
GetNum:
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		num_terms, eax
	call	validate
	cmp		valid, IS_VALID
	jne		Invalid
	ret;

Invalid:
	jmp		GetNum
getUserdata ENDP

;Procedure checks if number entered by user is between LOWER_LIMIT
;	and UPPER_LIMIT
;receives: num_terms, LOWER_LIMIT, UPPER_LIMIT, valid and
;	prompt_invalid are global variables
;returns: valid = 1, if number is in range
;preconditions: LOWER_LIMIT and UPPER_LIMIT defined, term entered by the user
;registers changed: edx
validate PROC
	cmp		num_terms, LOWER_LIMIT
	jl		NotValid
	cmp		num_terms, UPPER_LIMIT
	jg		NotValid
	call	CrLf
	mov		valid, 1
	jmp		ValReturn

NotValid:
	mov		edx, OFFSET prompt_invalid
	call	WriteString
	call	CrLf

ValReturn:
	ret;
validate ENDP

;Procedure loop is used to display the composite numbers.
;	Calls isComposite to calculate composite numbers.
;receives: num_comp, num_terms, composite, and 
;	IS_COMP are global variables
;returns: n/a
;preconditions: num_terms entered by user
;registers changed: n/a
showComposites PROC
	mov		num_comp, 4
L1:
	cmp		num_terms, 0
	jle		CompReturn
	call	isComposite
	inc		num_comp
	cmp		composite, IS_COMP
	je		Decrement
	jmp		L1

CompReturn:
	call	CrLf
	ret;

Decrement:
	dec		num_terms
	jmp		L1
showComposites ENDP
	
;Procedure calculates compiste numbers and calls print procedure
;	to print the composite numbers.
;receives: composite, and num_comp are global variables
;returns: n/a
;preconditions: n/a
;registers changed: eax, edx, edx
isComposite PROC
	mov		composite, 0
	mov		eax, num_comp
	cdq
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		IsComp
	mov		eax, num_comp
	cdq
	mov		ebx, 3
	div		ebx
	cmp		edx, 0
	je		IsComp
	mov		ecx, num_comp
	dec		ecx
L2:
	mov		eax, num_comp
	cdq
	cmp		ecx, 1
	je		CompReturn
	div		ecx
	cmp		edx, 0
	je		IsComp
LoopBack:
	loop	L2
	jmp		CompReturn

IsComp:
	mov		composite, 1
	call	print

CompReturn:
	ret;
isComposite ENDP

;Procedure prints 10 composite number per line.
;receives: num_on_line, num_comp, and spacing are global variables
;returns: n/a
;preconditions: num_comp is calculated
;registers changed: eax, edx
print PROC
	inc		num_on_line
	mov		eax, num_comp
	call	WriteDec
	mov		edx, OFFSET spacing
	call	WriteString
	cmp		num_on_line, 10
	je		NewLine
	jmp		printReturn

NewLine:
	call	CrLf
	mov		num_on_line, 0

PrintReturn:
	ret;
print ENDP

;Procedure displays goodbye message to the user.
;receives: prompt_bye are global variables
;returns: n/a
;preconditions: output message defined
;registers changed: edx
goodBye	PROC
	mov		edx, OFFSET prompt_bye
	call	WriteString
	call	CrLf
	ret;
goodBye	ENDP

END main
