:: /install emergency
:: 18:53 5/14/2013
:: add Win 10 detection 16:33 8/1/2018
:: change RUN_THIS^!^!^!.bat needs escape in bat 08:20 9/9/2020
:: add ver | findstr /i "10.0.22000\." > nul  IF %ERRORLEVEL% EQU 0 SET _is11="1" for Win 11 10:28 10/6/2021
:: add non-escape line for the bat and x64 Firefox for Win 11 10:29 10/6/2021
:: remove !!! from run this as 11 is erratic on handling escape 16:32 10/20/2021
:: reverse OS ver detection order, 19045 was triggering on nt 5 in one case 10:13 11/16/2022
:: change 11 detection to ver | findstr /i /r "10.0.22."
:: add  --no-check-certificate 10:53 2/5/2024


@ECHO OFF

:CHECK_NEC
COLOR 4F
IF NOT EXIST %WINDIR%\mcwget.exe (GOTO UPDATE_NEC) ELSE (GOTO CHECK_OS)

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
REM Check Windows Version
ver | findstr /i "10\." > nul
IF %ERRORLEVEL% EQU 0 goto ver_Vista_7
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 goto ver_Vista_7
ver | findstr /i "5\." > nul
IF %ERRORLEVEL% EQU 0 goto BIZ_CHECK

goto warn_and_exit

:warn_and_exit
echo Machine OS cannot be determined.
pause
exit

:ver_Vista_7
::@echo off
setlocal enabledelayedexpansion

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

:BIZ_CHECK
CLS
COLOR 1F
ECHO.
ECHO TYPE CORRECT SERVICE LEVEL, BIZ or HOME and hit Enter
ECHO.
Set /P _type=Is this a BIZ or HOME PC? || Set _type=NothingChosen
If "%_type%"=="NothingChosen" goto :sub_error
If /i "%_type%"=="BIZ" goto sub_BIZ
If /i "%_type%"=="HOME" goto sub_HOME
if not defined option goto :sub_error
goto:eof


:sub_BIZ
echo You chose BIZ
ECHO.
goto :BIZ_DL

:sub_HOME
echo You chose HOME
ECHO.
ECHO.
GOTO :HOME_DL

:sub_error
ECHO.
echo Nothing was chosen
ECHO.
PAUSE
GOTO :BIZ_CHECK

:BIZ_DL
MD %SYSTEMDRIVE%\MCWinstallation
ver | findstr /i /r "10.0.22." > nul
IF %ERRORLEVEL% EQU 0 SET _is11="1"
::ver | findstr /i "10.0.22000\." > nul
::IF %ERRORLEVEL% EQU 0 SET _is11="1"
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" "https://inviteatech.com/install/files/BAT/RUN_THIS.bat"
IF DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/64/firefox.exe
IF NOT DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/firefox.exe
::IF NOT DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" "https://inviteatech.com/install/files/BAT/RUN_THIS^!^!^!.bat"


:CHECK_OS2
REM Check Windows Version
ver | findstr /i "10\." > nul
IF %ERRORLEVEL% EQU 0 goto NT6_DL1
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 goto NT6_DL1
ver | findstr /i "5\." > nul
IF %ERRORLEVEL% EQU 0 goto XP_DL1


goto warn_and_exit2

:warn_and_exit2
echo Machine OS cannot be determined.
pause
exit

:XP_DL1
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/XP-Initial-Tools.exe
START "" explorer "%SYSTEMDRIVE%\MCWinstallation"
EXIT

:NT6_DL1
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/Vista-7-8-Initial-Tools.exe
START "" explorer "%SYSTEMDRIVE%\MCWinstallation"
EXIT


:HOME_DL
MD %SYSTEMDRIVE%\MCWinstallation
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/swb.exe
ver | findstr /i /r "10.0.22." > nul
IF %ERRORLEVEL% EQU 0 SET _is11="1"
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" "https://inviteatech.com/install/files/BAT/RUN_THIS.bat"
IF DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/64/firefox.exe
IF NOT DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/firefox.exe
::IF NOT DEFINED _is11 mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" "https://inviteatech.com/install/files/BAT/RUN_THIS^!^!^!.bat"

:CHECK_OS3
REM Check Windows Version
ver | findstr /i "10\." > nul
IF %ERRORLEVEL% EQU 0 goto NT6_DL2
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 goto NT6_DL2
ver | findstr /i "5\." > nul
IF %ERRORLEVEL% EQU 0 goto XP_DL2


goto warn_and_exit3

:warn_and_exit3
echo Machine OS cannot be determined.
pause
exit

:XP_DL2
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/XP-Initial-Tools.exe
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/spybotsd15.exe
START "" explorer "%SYSTEMDRIVE%\MCWinstallation"
DEL %0
EXIT

:NT6_DL2
mcwget --no-check-certificate -N -c --read-timeout 10 -P "%SYSTEMDRIVE%\MCWinstallation" https://inviteatech.com/install/files/Vista-7-8-Initial-Tools.exe
START "" explorer "%SYSTEMDRIVE%\MCWinstallation"
DEL %0
EXIT


