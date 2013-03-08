@echo off

powershell -Command "Set-ExecutionPolicy RemoteSigned"

REM the name of the script is drive path name of the Parameter %0 (= the batch file) but with the extension ".ps1"

set PSScript=%~dpn0.ps1
set args=%1
:More
shift
if '%1'=='' goto Done
set args=%args%, %1
goto More
:Done
powershell.exe -Command "& '%PSScript%' '%args%'"
