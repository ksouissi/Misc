COMMENT	^
Works as intented on: Windows 10 Version 21H2 (OS Build 19044.5371)
Example build commands:
ML /c imp.asm
LINK16 /TINY imp.obj,imp.exe,,,,
DEL imp.obj
^
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
	DW	IMAGE_DOS_SIGNATURE	; e_magic	Magic number					0
	DW	?	; e_cblp	BYTEs on last page of file						2
IMAGE_NT_HEADERS:
	DD	IMAGE_NT_SIGNATURE	; Signature									0
;																		4
IMAGE_FILE_HEADER:
	DW	IMAGE_FILE_MACHINE_I386	; Machine								0
	DW	?	; NumberOfSections											2
	DD	?	; TimeDateStamp												4
	DD	?	; PointerToSymbolTable										8
	DD	?	; NumberOfSymbols											12
; The size of the optional header, which is required for executable files but not for object files.
	DW	IMAGE_SECTION_HEADER-IMAGE_OPTIONAL_HEADER	; SizeOfOptionalHeader											16
	DW	IMAGE_FILE_RELOCS_STRIPPED OR IMAGE_FILE_EXECUTABLE_IMAGE OR IMAGE_FILE_32BIT_MACHINE	; Characteristics	18
;																													20
IMAGE_OPTIONAL_HEADER:
	DW	IMAGE_NT_OPTIONAL_HDR32_MAGIC	; Magic	0
	DB	?	; MajorLinkerVersion				2
	DB	?	; MinorLinkerVersion				3
; !IMAGE_SECTION_HEADER
	DD	?	; SizeOfCode						4
	DD	?	; SizeOfInitializedData				8
	DD	?	; SizeOfUninitializedData			12
	DD	EOH	; AddressOfEntryPoint				16
	DD	?	; BaseOfCode						20
	DD	?	; L0 BaseOfData						24
	DD	IMGBASE	; ImageBase						28
	DD	SECALIGN	; SectionAlignment			32
	DD	FILEALIGN	; FileAlignment				36
; !IMAGE_SECTION_HEADER
	DD	IMAGE_NT_HEADERS
	DW	?	; MajorImageVersion					44
	DW	?	; MinorImageVersion					46
	DW	4	; MajorSubsystemVersion				48
	DW	?	; MinorSubsystemVersion				50
	DD	?	; Win32VersionValue					52
; The size (in bytes) of the image, including all headers, as the image is loaded in memory. It must be a multiple of SectionAlignment.
	DD	CEIL(EOF-IMAGE_DOS_HEADER, SECALIGN)	; 56
; The combined size of an MS-DOS stub, PE header, and section headers rounded up to a multiple of FileAlignment.
	DD	?	; CEIL(EOH-IMAGE_DOS_HEADER, FILEALIGN) 60
	DD	?	; CheckSum							64
	DW	3	; Subsystem							68
	DW	?	; DllCharacteristics				70
	DD	?	; SizeOfStackReserve				72
	DD	?	; SizeOfStackCommit					76
	DD	?	; SizeOfHeapReserve					80
	DD	?	; SizeOfHeapCommit					84
	DD	0	; LoaderFlags						88
	DD	0	; 16 NumberOfRvaAndSizes			92
;												96
IMAGE_DATA_DIRECTORY:
; 0
IMAGE_SECTION_HEADER:
; 0
EOH:	; 124, 268-124 = 144 head-start
	push	OFFSET (IMGBASE+libs)	;			0
	mov		esi, OFFSET (IMGBASE+f)
L0:
	mov	eax, fs:[30h]
	mov	eax, [eax + 0ch]
	mov	eax, [eax + 0ch]
L1:
	mov	eax, [eax]			; eax == m
	push	eax
	mov	ebx, [eax + 18h]	; ebx == n
	mov	ebp, [ebx + 3ch]
	mov	ebp, [ebx + ebp + 78h]
	add	ebp, ebx			; ebp == x
	mov	ecx, [ebp + 18h]	; ecx == j
L2:
	push	esi
	mov	esi, [ebp + 20h]
	lea esi, [esi + ecx*4 - 4]
	mov	esi, [ebx + esi]
	add	esi, ebx
	xor	eax, eax
	cdq
L3:
	lodsb
	ror	edx, 13
	add	edx, eax
	cmp	BYTE PTR [esi], 0
	jne	L3
	lodsb	; al = 0
	pop	esi
	cmp	edx, DWORD PTR [esi]
	je	L5
	loop	L2
	pop	eax
	jmp	L1
L5:
	mov	edx, [ebp + 24h]
	lea	edx, [edx + ecx*2 - 2]
	movzx edx, WORD PTR [ebx + edx]
	mov	edi, [ebp + 1ch]
	lea	edx, [edi + edx*4]
	mov	edx, [ebx + edx]
	add	ebx, edx
	mov	[esi], ebx
	add	esi, 4
	mov	edi, [esp+4]	; esp+4 -> libs
L4:
	cmp	BYTE PTR [edi], 0
	je	L6
	push	edi
	call	ebx
	inc edi
	repne scasb
	mov	[esp+4], edi
	jmp	L4
L6:
	pop	eax
	cmp	DWORD PTR [esi], 0
	jne	L0
;												132 <= 144: API-loader code within head-start
	; Hello
	push	0
	push	0
	push	13
	push	OFFSET (IMGBASE+hello)
	push	-11
	call	DWORD PTR [IMGBASE+f+4];64]
	push	eax
	call	DWORD PTR [IMGBASE+f];+60]
	; , world!
	add	esp, 4
	ret
COMMENT	^
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
^
f	DD	0e80a791fh	; WriteFile
	DD	07487d823h	; GetStdHandle
	DD	0h
libs	DB	0h
hello	DB	'Hello, world!'
EOF:
_TEXT	ENDS
END
