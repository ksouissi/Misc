#if 0
.exe: imp.c
	cl /TC /O1 /FA /Fmimp.map $** /link /nodefaultlib /entry:mainCRTStartup /subsystem:console /merge:.data=.text /align:4
	del imp.obj
!if 0
#endif

#define IMP

#ifdef IMP
/* #define LOADLIBRARYA */

/* hash(name(f)) => f */
int (__stdcall *f[])() =
/* defined(LOADLIBRARYA) => f[num_imp_funcs-1] == hash(LoadLibraryA) */
#ifdef LOADLIBRARYA
{ 0xeb66a115 /* BitBlt */, 0x690a1701 /* DispatchMessageA */, 0x8fde2c7e /* TranslateMessage */, 0xf2667bf4 /* PeekMessageA */, 0xc2bfd83f /* UpdateWindow */, 0xc95d4f83 /* ShowWindow */, 0xfe97a655 /* SelectObject */, 0x66f33a69 /* CreateCompatibleDC */, 0x89364153 /* CreateDIBSection */, 0xcc248d43 /* GetDC */, 0x84454941 /* CreateWindowExA */, 0x51e20cca /* RegisterClassExA */, 0xcad36f3b /* ChangeDisplaySettingsA */, 0x4ab9b7a5 /* EnumDisplaySettingsA */, 0xec0e4e8e /* LoadLibraryA */};
char *libs[] = { "gdi32.dll", "user32.dll" };	/* module-names */
#else
{ 0xe80a791f /* WriteFile */, 0x7487d823 /* GetStdHandle */ };
#endif

__declspec(naked)
#endif
int __stdcall mainCRTStartup()
{
#ifdef IMP
	int i, j, m, n, *fa, *fn;
	short *fo;	/* short []: fa indices */
#ifdef LOADLIBRARYA
	int k;
	__asm enter	20, 0	/* CL 12.00.8804 /Ogsy: 5-stack */
	k = sizeof(libs)/sizeof(char *);
#else
	__asm enter 16, 0	/* CL 12.00.8804 /Ogsy: 4-stack */
#endif
	i = sizeof(f)/sizeof(int)-1;
	do {	/* reset search: f array not sorted
				no forwarding */
		j ^= j;
		__asm {
			xor	eax, eax
			mov	ebx, fs:[eax+0x30]	/* EBX = TEB->ProcessEnvironmentBlock */
			mov ebx, [ebx+0xc]		/* EBX = TEB->ProcessEnvironmentBlock->Ldr */
			mov	eax, [ebx+0xc]		/* EBX = TEB->ProcessEnvironmentBlock->Ldr->InLoadOrderModuleList.Flink */
			mov	m, eax				/* &m->loadapi5.exe.LDR_DATA_TABLE_ENTRY */
		}
		for (;;) {	/* does not check for end-of-module-list */
			{
				int x;
				m = *(int *)m;	/* m = m->InLoadOrderLink */
				n = *(int *)(m + 0x18);	/* m->DllBase */
				x = n + *(int *)(n + *(int *)(n + 0x3c) + 0x78 /* = Signature: 4 + IMAGE_FILE_HEADER: 20 + IMAGE_OPTIONAL_HEADER: 96 == 120 */);	/* x = &m->IMAGE_EXPORT_DIRECTORY */
				/* fn is sorted */
				fa = (int *)(n + *(int *)(x + 0x1c));	/* fa = x->AddressOfFunctions (char *[]) */
				fn = (int *)(n + *(int *)(x + 0x20));	/* fn = x->AddressOfNames */
				fo = (short *)(n + *(int *)(x + 0x24));	/* fo = x->AddressOfNameOrdinals */
				j = *(int *)(x + 0x18)-1;	/* j = x->NumberOfNames-1 */
			}
			{	/* exports != {} */
				int h;
				do {		
					{	/* ror13 */
						char *a = (char *)(n + fn[j]);	/* a && *a */
						h ^= h;
						do {
							h = ((unsigned)h >> 13 | h << 32 - 13) + *a++;
						} while (*a);
					}
					if (h == f[i]) {
						f[i] = n + fa[fo[j]];
#ifdef LOADLIBRARYA
						/* case LoadLibraryA: load all imported libraries */
						while (k) {	/* 1-time */
							k--;
							f[i](libs[k]);
						}
#endif
						goto L0;
					}
				} while (j--);
			}
		}
L0:;
	} while (i--);
#ifndef LOADLIBRARYA
#define STD_OUTPUT_HANDLE	-11
	f[0](f[1](STD_OUTPUT_HANDLE), "Hello, world!", 13, 0, 0);	/* WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), "Hello, world!", 13, 0, 0); */
#endif
	__asm {
		leave
		ret
	}
#endif
}

#if 0
!endif
#endif
