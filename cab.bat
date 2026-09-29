@ECHO OFF
IF "%1" NEQ "" (
	COPY %~dpn1.exe a.exe
	CABARC -m %2 n a.bat a.exe
REM	MAKECAB.exe /D CompressionType=LZX /D CompressionMemory=15 a.exe a.bat
	SET /P =0d0a0a<NUL>tmp
	CERTUTIL -f -decodehex tmp pmt
	SET /P ="EXTRAC32 %%0&a %%1 %%2 %%3&DEL a.exe"<NUL>>pmt
	COPY /B a.bat+pmt %~dpn1.bat
	DEL a.bat a.exe tmp pmt
) ELSE echo Usage: cab[.bat] [NAME[.exe] MSZIP+LZX:15-21]