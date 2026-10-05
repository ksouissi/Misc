COMMENT	^
ML /c PE.asm
LINK16 /TINY PE.obj,PE.exe,,,,
DEL PE.obj
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

	ASSUME	cs: _TEXT, ds: _TEXT

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
	DD	L0	; AddressOfEntryPoint				16
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
;	0
IMAGE_SECTION_HEADER:
;	0
EOH:	; 124, 268-124 = 144 head-start
L0:
	; code/data:
	ret
	ORG	268	; Windows 10: sizeof(code/data) + 144 < 268
EOF:
_TEXT	ENDS
END
