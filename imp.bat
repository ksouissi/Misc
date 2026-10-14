; @ECHO OFF
; ML /nologo /c /Flimp.lst imp.bat
; LINK16 /NOLOGO /TINY imp.obj, imp.exe,,,,
; imp.exe
; ECHO.
; DIR imp.exe | FIND "imp.exe"
; DEL imp.exe imp.obj
; EXIT /B

; Works as intented on: Windows 10 Version 21H2 (OS Build 19044.5371)

IMAGE_DOS_SIGNATURE	EQU	5a4dh	; MZ

IMAGE_NT_SIGNATURE	EQU	00004550h	; PE00
IMAGE_FILE_MACHINE_I386	EQU	14ch	; Intel 386.
IMAGE_NT_OPTIONAL_HDR32_MAGIC	EQU	10bh	; PE32

IMAGE_FILE_RELOCS_STRIPPED	EQU	1h	; Relocation info stripped from file.
IMAGE_FILE_EXECUTABLE_IMAGE	EQU	2h	; File is executable  (i.e. no unresolved external references).
IMAGE_FILE_LINE_NUMS_STRIPPED	EQU	4h	; Line numbers stripped from file.
IMAGE_FILE_LOCAL_SYMS_STRIPPED	EQU	8h	; Local symbols stripped from file.
IMAGE_FILE_32BIT_MACHINE	EQU	100h	; 32 bit word machine.

IMAGE_SCN_CNT_CODE	EQU	00000020h	; Section contains code.
IMAGE_SCN_MEM_EXECUTE	EQU	20000000h	; Section is executable.
IMAGE_SCN_MEM_READ	EQU	40000000h	; Section is readable.
IMAGE_SCN_MEM_WRITE	EQU	80000000h	; Section is writeable.

IMGBASE	EQU	10000h

FILEALIGN	EQU	4
SECALIGN	EQU	4

CEIL	MACRO	a, b
	EXITM	<(a+b-1)/(b)*(b)>
ENDM

.386

ASSUME	cs: _TEXT, ds: _TEXT, fs: NOTHING

_TEXT	SEGMENT	DWORD PUBLIC 'code'
IMAGE_DOS_HEADER:
	DW	IMAGE_DOS_SIGNATURE	; e_magic	Magic number
	DW	?	; e_cblp	BYTEs on last page of file
IMAGE_NT_HEADERS:
	DD	IMAGE_NT_SIGNATURE	; Signature
IMAGE_FILE_HEADER:
	DW	IMAGE_FILE_MACHINE_I386	; Machine
	DW	?	; NumberOfSections
@0:
	push	OFFSET (IMGBASE+libs)
	mov		edi, OFFSET (IMGBASE+f+4)
	jmp @1
	DW	IMAGE_SECTION_HEADER-IMAGE_OPTIONAL_HEADER	; SizeOfOptionalHeader
	DW	IMAGE_FILE_RELOCS_STRIPPED OR IMAGE_FILE_EXECUTABLE_IMAGE OR IMAGE_FILE_32BIT_MACHINE	; Characteristics
IMAGE_OPTIONAL_HEADER:
	DW	IMAGE_NT_OPTIONAL_HDR32_MAGIC	; Magic
@1:
L0:
	mov	eax, fs:[30h]
	mov	eax, [eax + 0ch]
	mov	esi, [eax + 0ch]
	jmp	@2
	DD	EOH	; AddressOfEntryPoint
@4:
	mov	ebp, [ebx + ebp + 78h]
	add	ebp, ebx	; ebp == x
	jmp	@5
	DD	IMGBASE	; ImageBase
	DD	SECALIGN	; SectionAlignment
	DD	FILEALIGN	; FileAlignment
	DD	IMAGE_NT_HEADERS
	DW	?	; MajorImageVersion
	DW	?	; MinorImageVersion
	DW	4	; MajorSubsystemVersion
@2:
L1:
	lodsd			; eax == m
	mov	ebx, [eax + 18h]	; ebx == n
	jmp	@3
	DD	CEIL(EOF-IMAGE_DOS_HEADER, SECALIGN)
	DD	?	; CEIL(EOH-IMAGE_DOS_HEADER, FILEALIGN)
	DD	?	; CheckSum
	DW	3	; Subsystem
	DW	?	; DllCharacteristics
@6:
	je	L5
	loop	L2
	jmp	L1
L5:
	mov	edx, [ebp + 24h]
	dec	ecx
	lea	edx, [edx + ecx*2]
	jmp	@7
@3:
	mov	ebp, [ebx + 3ch]
	jmp	@4
	DD	0	; 16 NumberOfRvaAndSizes
IMAGE_DATA_DIRECTORY:
IMAGE_SECTION_HEADER:
EOH:	; 124, 268-124 = 144 head-start
	jmp	@0
@5:
	mov	ecx, [ebp + 18h]	; ecx == j
	xchg	eax, esi
	xor	eax, eax	; ror13: edx += eax 2
L2:
	push	esi
	mov	esi, [ebp + 20h]
	lea esi, [esi + ecx*4 - 4]
	mov	esi, [ebx + esi]
	add	esi, ebx
	cdq
L3:
	lodsb
	or	al, al
	jz	L7
	ror	edx, 13
	add	edx, eax
	jmp	L3
L7:
	pop	esi
	cmp	edx, DWORD PTR [edi-4]
	jmp	@6
@7:
	movzx edx, WORD PTR [ebx + edx]
	mov	ecx, [ebp + 1ch]
	lea	edx, [ecx + edx*4]
	mov	edx, [ebx + edx]
	add	ebx, edx
	mov	[edi-4], ebx
	mov	ebp, edi
	pop	edi	; libs
	push	edi
	; eax == 0
L4:
	scasb
	jz	L6
	dec	edi
	push	edi
	call	ebx	; ebx not altered
	repne scasb
	mov	[esp], edi
	jmp	L4
L6:
	mov	edi, ebp
	scasd
	jnz	L0
	; Hello
	push	0
	push	0
	push	13
	push	OFFSET (IMGBASE+hello)
	push	-11
	call	DWORD PTR [IMGBASE+f+64]	; IMGBASE+f+4
	push	eax
	call	DWORD PTR [IMGBASE+f+60]	; IMGBASE+f
	; , world!
	add	esp, 4
	ret
f	DD	0ec0e4e8eh	; LoadLibraryA
	DD	0eb66a115h	; BitBlt
	DD	0690a1701h	; DispatchMessageA
	DD	08fde2c7eh	; TranslateMessage
	DD	0f2667bf4h	; PeekMessageA
	DD	0c2bfd83fh	; UpdateWindow
	DD	0c95d4f83h	; ShowWindow
	DD	0fe97a655h	; SelectObject
	DD	066f33a69h	; CreateCompatibleDC
	DD	089364153h	; CreateDIBSection
	DD	0cc248d43h	; GetDC
	DD	084454941h	; CreateWindowExA
	DD	051e20ccah	; RegisterClassExA
	DD	0cad36f3bh	; ChangeDisplaySettingsA
	DD	04ab9b7a5h	; EnumDisplaySettingsA
	DD	0e80a791fh	; WriteFile
	DD	07487d823h	; GetStdHandle
	DD	0h
libs	DB	'user32.dll', 0h, 'gdi32.dll', 0h, 0h
COMMENT	^
f	DD	0e80a791fh	; WriteFile
	DD	07487d823h	; GetStdHandle
	DD	0h
libs	DB	0h
^
hello	DB	'Hello, world!'
EOF:
_TEXT	ENDS
END
