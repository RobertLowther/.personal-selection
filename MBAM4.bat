TITLE MBAM4 INSTALL
:: MBAM2 v 14:52 3/25/2014
:: add new CHECK_OS 15:58 7/20/2015
:: add MSE/Defender process exclusions for mbam exe's 12:28 10/3/2016
:: add MBAM BIZ dialog, DL and Install 10:17 10/4/2016
:: change paths for MBAM v.3 12:13 12/5/2016
:: add MSE/Defender warnings and open GUI, recent change prevents exceptions from being set unless disabled 09:10 12/8/2016
:: double install 2 & 3 to end trial mode 11:31 12/23/2016
:: add mbamtray.exe exception and warning to leave MSE GUI open, add old MBAM version warning 15:54 12/27/2016
:: add Win10 1703 detection and Defender open command 08:23 4/19/2017
:: add more exclusion items and paths 09:59 5/31/2017
:: add another OS ver check win 10 IF NOT caused exit 11:52 7/20/2017
:: add MBAM AE download and silent install for BIZ 15:00 6/13/2018
:: add PowerShell -command Add-MpPreference -ExclusionProcess for Win 10 14:56 9/17/2019
:: change for MBAM 4.0 14:53 11/5/2019
:: change MBAM 3 detection to myuninstaller 09:40 11/14/2019
:: adjust exclusions and messages, 7-8 need MSE/Def disabled, 10 needs defender enabled 07:43 4/9/2020
:: add 20H2 warning and manual exclusion list 08:39 10/30/2020
:: add more  --no-check-certificate 10:38 2/5/2024

@ECHO OFF
setlocal enabledelayedexpansion

COLOR 4F
IF NOT EXIST %WINDIR%\mcwget.exe (GOTO CHECK_OS) ELSE (GOTO CHECK_OS)

:UPDATE_NEC
CLS
ECHO.
ECHO MCWGET MISSING INSTALL OR UPDATE NECESSITIES
ECHO.
ECHO USE PROPER VERSION FOR CLIENT AND OS
ECHO.
pause
exit

:CHECK_OS
FOR /f "tokens=2,3 delims=[.]" %%a IN ('ver') DO SET WVer=%%a.%%b
SET WVer=%WVer:Version =%
ECHO %WVer%

::Check Windows Version
IF EXIST "%PROGRAMFILES(X86)%" (SET _bit=X64) ELSE (SET _bit=X86)
IF %WVer%==5.1 goto OLD_OS
IF %WVer%==6.0 goto OLD_OS
IF %WVer%==6.1 goto ELEVATE
IF %WVer%==6.2 goto ELEVATE
IF %WVer%==6.3 goto ELEVATE
IF %WVer%==10.0 goto CHECK_OS10VER
goto warn_and_exit

:warn_and_exit
echo Machine OS cannot be determined.
pause
exit

:CHECK_OS10VER
FOR /f "tokens=2,3,4 delims=[.]" %%a IN ('ver') DO SET WVer10=%%a.%%b.%%c
SET WVer10=%WVer10:Version =%
ECHO %WVer10%

:ELEVATE
::@echo off

:: Check for Mandatory Label\High Mandatory Level
whoami /groups | find "S-1-16-12288" > nul
if "%errorlevel%"=="0" (
echo Running as elevated user. Continuing script.
) else (
CLS
COLOR 0C
echo Not running as elevated user.
ECHO.
echo Close and Right Click Run As Administrator
ECHO.
ECHO.
pause
exit
)

:MBAM_CHK
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\TEMP" MD "%SYSTEMDRIVE%\MCW_Tools\TEMP"
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\LOGS" MD "%SYSTEMDRIVE%\MCW_Tools\LOGS"
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT" MD "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT"
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT\myuninst\myuninst.exe" (GOTO DOWNLOAD_1) ELSE (GOTO DOWNLOAD_2)
:DOWNLOAD_1
mcwget --no-check-certificate -N --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT" https://inviteatech.com/install/files/NIRSOFT/myuninst.zip
7za x "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT\myuninst.zip" -o"%SYSTEMDRIVE%\MCW_Tools\NIRSOFT" -r -y
DEL /F /Q "%SYSTEMDRIVE%\MCW_Tools\NIRSOFT\myuninst.zip"
CLS
:DOWNLOAD_2
"%SYSTEMDRIVE%\MCW_Tools\NIRSOFT\myuninst\myuninst.exe" /stab "%SYSTEMDRIVE%\MCW_Tools\LOGS\proglist.txt"
for /F "tokens=1 delims=." %%a in ('findstr/c:"Malwarebytes version 3" %SYSTEMDRIVE%\MCW_Tools\LOGS\proglist.txt') do set MBAMVER=%%a
IF "%MBAMVER%"=="Malwarebytes version 3" (GOTO OLDMBAM) ELSE (GOTO CHECK_FOLDER) 


:OLDMBAM
CLS
COLOR 4F
ECHO.
ECHO WARNING OLDER VERSION OF MBAM ALREADY INSTALLED
ECHO.
ECHO Backup or Export License/Key if needed
ECHO then run mbam-clean-3.xxx.exe TWICE
ECHO before trying this bat file again
ECHO.
PAUSE
EXIT

:CHECK_FOLDER
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\SYSINTERNALS" MD "%SYSTEMDRIVE%\MCW_Tools\SYSINTERNALS"
IF NOT EXIST "%SYSTEMDRIVE%\MCW_Tools\SYSINTERNALS\psexec.exe" (GOTO DOWNLOAD_P) ELSE (GOTO BIZCHECK)


:DOWNLOAD_P
CLS
IF %WVer%==10.0 GOTO BIZCHECK
ECHO.
ECHO DOWNLOADING PsExec
ECHO.
ECHO.
IF %_bit%==X86 mcwget --no-check-certificate -N --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\SYSINTERNALS" https://live.sysinternals.com/psexec.exe
IF %_bit%==X64 mcwget --no-check-certificate -N --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\SYSINTERNALS" https://live.sysinternals.com/PsExec64.exe

:BIZCHECK
CLS
COLOR 1F
ECHO.
ECHO TYPE CORRECT PC USE TYPE, BIZ or PERSONAL and hit Enter
ECHO.
Set /P _type=Is this a BIZ or PERSONAL USE PC? || Set _type=NothingChosen
If "%_type%"=="NothingChosen" goto :sub_error
If /i "%_type%"=="PERSONAL" goto sub_PERSONAL
If /i "%_type%"=="BIZ" goto sub_BIZ
if not defined option goto :sub_error
goto:eof


:sub_PERSONAL
CLS
COLOR 0e
echo You chose PERSONAL
ECHO.
ECHO MBAM 4.0 FREE is only for use
ECHO on NON-BIZ, Personal use ONLY PC's
ECHO.
ECHO.
ECHO CLOSE this window if you have made a mistake
ECHO.
ECHO Otherwise
PAUSE
goto DOWNLOAD

:sub_BIZ
CLS
COLOR 0C
echo You chose BIZ
ECHO.
ECHO MBAM 4.0 FREE/Premium is NOT allowed on BIZ use PC's
ECHO.
ECHO Select "Work Computer" in the GUI
ECHO It will Install MBAM for Teams (Trial)
ECHO.
ECHO.
Set /P _type=Do you have an MBAM BIZ KEY Y/N? || Set _type=NothingChosen
If "%_type%"=="NothingChosen" goto :sub_error
If /i "%_type%"=="N" goto DL_BIZ
If /i "%_type%"=="Y" goto DL_BIZ
if not defined option goto :sub_error
goto:eof
ECHO.
PAUSE
DEL %0

:sub_error
ECHO.
echo Nothing was chosen
ECHO.
PAUSE
GOTO BIZCHECK

:DL_BIZ
ECHO.
ECHO DOWNLOADING MBAM for Teams
ECHO.
::mcwget -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" http://inviteatech.com/install/files/MBAM/mbam-setup-biz.exe
::mcwget -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" http://inviteatech.com/install/files/MBAM/mbae-setup.exe
mcwget -U firefox --no-check-certificate -N --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" -O "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-4.exe" https://downloads.malwarebytes.com/file/mb-windows
ECHO.
ECHO FINISHED DOWNLOADING
ECHO.
GOTO BIZ_PAUSE

:INSTALL_BIZ
CLS
COLOR 4F
ECHO.
IF NOT %WVer10%==10.0 ECHO TEMP DISABLE MSE or Defender on 7-8 before continuing...
::ECHO On Win 10 TEMP Disable Tamper Protection as well
ECHO.
ping localhost n 3 > nul
IF %WVer%==6.0 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.1 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.2 START "" control /name Microsoft.WindowsDefender
IF %WVer%==6.3 START "" control /name Microsoft.WindowsDefender
IF %WVer%==10.0 goto BIZ_PAUSE
::IF NOT %WVer10%==10.0.15063 START "" control /name Microsoft.WindowsDefender
::IF %WVer10%==10.0.15063 START "" ms-settings:windowsdefender
PAUSE

:BIZ_PAUSE
::PAUSE
CLS
COLOR 1F
ECHO.
ECHO INSTALLING MBAM for Teams
ECHO.
::START "" /wait "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-biz.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
::START "" /wait "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbae-setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
START "" /wait "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-4.exe"
ping localhost n 30 > nul
GOTO PERS_PAUSE

:DOWNLOAD
ECHO.
ECHO DOWNLOADING MBAM
ECHO.
::mcwget -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" http://inviteatech.com/install/files/MBAM/mbam-setup-2.exe
::mcwget -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" http://inviteatech.com/install/files/MBAM/mbam-setup-3.exe
mcwget -U firefox --no-check-certificate -N --read-timeout 10 -P "%SYSTEMDRIVE%\MCW_Tools\TEMP" -O "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-4.exe" https://downloads.malwarebytes.com/file/mb-windows
ECHO.
ECHO FINISHED DOWNLOADING
ECHO.

:INSTALL
CLS
COLOR 1F
ECHO.
ECHO INSTALLING MBAM 4 FREE
ECHO.
::START "" /wait "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-2.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
::ping localhost n 30 > nul
START "" /wait "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-4.exe" /SP- /VERYSILENT /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /NORESTART
ping localhost n 30 > nul
IF %WVer%==10.0 goto PERS_PAUSE
 
pause
CLS
COLOR 4F
ECHO.
ECHO TEMP DISABLE MSE/Defender before continuing...
::ECHO On Win 10 TEMP Disable Tamper Protection as well
ECHO.
ECHO LEAVE MSE/Defender GUI OPEN for next steps...
ECHO.
ping localhost n 3 > nul
IF %WVer%==6.0 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.1 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.2 START "" control /name Microsoft.WindowsDefender
IF %WVer%==6.3 START "" control /name Microsoft.WindowsDefender

::IF NOT %WVer10%==10.0.15063 START "" control /name Microsoft.WindowsDefender
::IF %WVer10%==10.0.15063 START "" ms-settings:windowsdefender

:PERS_PAUSE
CLS
IF %WVer10%==10.0 ECHO LEAVE DEFENDER ENABLED ON WIN 10
ECHO.
ECHO PRESS ANY KEY TO SET MSE-Defender EXCLUSIONS...
PAUSE > NUL

ECHO ATTEMPTING TO SET MSE-Defender EXCLUSIONS...

:EXCLUDE
IF %WVer%==6.1 goto v7reg
IF %WVer%==6.2 goto 8-10reg
IF %WVer%==6.3 goto 8-10reg
IF %WVer%==10.0 goto 10reg

:v7reg
IF %_bit%==X64 "C:\MCW_Tools\SYSINTERNALS\PsExec64.exe" -accepteula -s cmd /c (^
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes Anti-Malware\mbampt.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\MBAMWsc.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamservice.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamtray.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\malwarebytes_assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\ProgramData\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbae64.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbam.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMChameleon.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMSwissArmy.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mwac.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\system32\Drivers\farflt.sys" /f ^
)

IF %_bit%==X86 "C:\MCW_Tools\SYSINTERNALS\psexec.exe" -accepteula -s cmd /c (^
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbampt.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\MBAMWsc.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamservice.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamtray.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\malwarebytes_assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\ProgramData\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbae64.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbam.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMChameleon.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMSwissArmy.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mwac.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft Antimalware\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\system32\Drivers\farflt.sys" /f ^
)
GOTO cleanup-deleting

:8-10reg
IF %_bit%==X64 "C:\MCW_Tools\SYSINTERNALS\PsExec64.exe" -accepteula -s cmd /c (^
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbampt.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\MBAMWsc.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamservice.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamtray.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\malwarebytes_assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\ProgramData\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbae64.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbam.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMChameleon.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMSwissArmy.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mwac.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\system32\Drivers\farflt.sys" /f ^
)

IF %_bit%==X86 "C:\MCW_Tools\SYSINTERNALS\psexec.exe" -accepteula -s cmd /c (^
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbampt.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\MBAMWsc.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamservice.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\mbamtray.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes\Anti-Malware\malwarebytes_assistant.exe" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Program Files\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\ProgramData\Malwarebytes" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbae64.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mbam.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMChameleon.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\MBAMSwissArmy.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\System32\drivers\mwac.sys" /f ^
& reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /t REG_DWORD /d 0 /v "C:\Windows\system32\Drivers\farflt.sys" /f ^
)
GOTO cleanup-deleting

:10reg

PowerShell -command Add-MpPreference -ExclusionProcess "mbam.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "assistant.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "mbampt.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "MBAMWsc.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "mbamservice.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "mbamtray.exe"
PowerShell -command Add-MpPreference -ExclusionProcess "malwarebytes_assistant.exe"
PowerShell -command Add-MpPreference -ExclusionPath 'C:\Program Files\Malwarebytes'
PowerShell -command Add-MpPreference -ExclusionPath "C:\ProgramData\Malwarebytes"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\mbae64.sys"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\mbam.sys"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\MBAMChameleon.sys"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\MBAMSwissArmy.sys"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\System32\drivers\mwac.sys"
PowerShell -command Add-MpPreference -ExclusionPath "C:\Windows\system32\Drivers\farflt.sys"
IF %WVer10%==10.0.19042 GOTO 20H2_WARN2
GOTO cleanup-deleting

:20H2_WARN
CLS
COLOR 2F
ECHO.
ECHO WARNING Win 10 20H2/2009
ECHO Exclusions must be MANUALLY set
ECHO.
PAUSE
ECHO Exclusion Process "mbam.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "assistant.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "mbampt.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "MBAMWsc.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "mbamservice.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "mbamtray.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Process "malwarebytes_assistant.exe" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Folder 'C:\Program Files\Malwarebytes' >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion Folder "C:\ProgramData\Malwarebytes" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\System32\drivers\mbae64.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\System32\drivers\mbam.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\System32\drivers\MBAMChameleon.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\System32\drivers\MBAMSwissArmy.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\System32\drivers\mwac.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
ECHO Exclusion File "C:\Windows\system32\Drivers\farflt.sys" >> "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"
START "" "%SYSTEMDRIVE%\MCW_Tools\EXCLUDE-IN-DEFENDER.txt"

:20H2_WARN2
CLS
COLOR 2F
ECHO.
ECHO WARNING Win 10 20H2/2009
ECHO Exclusions may NOT be visible in GUI
ECHO.
ECHO PowerShell can verify they exist
ECHO.
PAUSE

:cleanup-deleting
CLS
COLOR 2F
ECHO.
ECHO CLEANING UP INSTALL FILES AND EXITING
ECHO.
DEL /F /S /Q "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-2.exe"
DEL /F /S /Q "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-3.exe"
DEL /F /S /Q "%SYSTEMDRIVE%\MCW_Tools\TEMP\mbam-setup-4.exe"
CLS
ECHO.
ECHO VERIFY MSE-DEFENDER EXCLUSIONS ARE SET
ECHO.
ECHO Re-ENABLE MSE/Defender (Unless following Infection protocol)
ECHO On Win 10 Re-ENABLE Tamper Protection as well
ECHO.
ECHO START MBAM, (ACTIVATE if PAID), 
ECHO.
ECHO DISABLE SECURITY CENTER INTEGRATION IN MBAM
ECHO SET AV-DEFENDER-MSE EXCLUSIONS IN MBAM
ECHO.
ECHO UPDATE, SCAN TAB, THREAT SCAN
PAUSE
IF %WVer%==6.0 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.1 START "" "%PROGRAMFILES%\Microsoft Security Client\msseces.exe"
IF %WVer%==6.2 START "" control /name Microsoft.WindowsDefender
IF %WVer%==6.3 START "" control /name Microsoft.WindowsDefender
IF NOT %WVer10%==10.0.15063 START "" control /name Microsoft.WindowsDefender
IF %WVer10%==10.0.15063 START "" ms-settings:windowsdefender
:_EXIT1
DEL %0
EXIT

:OLD_OS
CLS
COLOR 4F
ECHO.
ECHO This PC is Windows Xp or Vista
ECHO Neither are supported in MBAM 4
ECHO.
ECHO Use the MBAM 3 for Legacy OS
ECHO.
PAUSE
DEL%0
EXIT