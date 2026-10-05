@ECHO OFF
IF "%1" NEQ "" (
	ML /c /Fl%~n1 /Fm%~n1 %~n1.asm
	LINK16 /TINY %~n1.obj,%~n1.exe,,,,
	DEL %~n1.obj %~n1.map
) ELSE ECHO Usage: makebin[.bat] [NAME[.asm]]