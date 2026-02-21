@echo off
setlocal enabledelayedexpansion
cd /d %~dp0
Title ComfyUI-Version-Switcher by ivo

:: Set colors ::
call :set_colors

:: Check Add-ons\Tools folder ::
if not exist "..\..\python_embeded\python.exe" (
    cls
    echo %green%:: This script must be run from the %red%'ComfyUI-Easy-Install\Add-ons\Tools'%green% folder
    echo %green%:: Press any key to exit...%reset%&Pause>nul
    exit
)

:: Go to the ComfyUI directory ::
cd ..\..\ComfyUI

:: Turns off the Detached Head message ::
git.exe config advice.detachedHead false

:: Display the last 5 versions available LOCALLY ::
echo %green%:: Last 5 versions found on your system:%reset%
echo.
git.exe tag --sort=-creatordate | powershell -command "$input | select -first 5"
echo.

:: 'master' branch or detached ? ::
git.exe symbolic-ref -q HEAD >nul
if %errorlevel% equ 0 (
    set "master_branch=true"
) else (
    set "master_branch=false"
)

:: Get the 2nd most recent tag name ::
for /f "tokens=*" %%t in ('powershell -Command "git.exe tag --sort=-creatordate | Select-Object -Skip 1 -First 1"') do set prev_tag=%%t

if "%master_branch%"=="true" (
	:: Downgrade to the next-to-last local tag ::
    if "!prev_tag!"=="" (
        echo %red%:: No tags found to downgrade to! %reset%
    ) else (
        echo %red%:: Successfully downgraded to !prev_tag! %reset%
        git.exe checkout !prev_tag! -q
        echo.
        echo %yellow%:: Run this script again to return to the 'MASTER' branch%reset%
    )
) else (
    :: Switch back to master ::
    git.exe checkout master -q
    echo %green%:: Successfully returned to the 'MASTER' branch.%reset%
    echo.
    echo %yellow%:: Run this script again to downgrade to the PREVIOUS version%reset%
)

:: Final Messages ::
echo.
if "%~1"=="" (
    echo %bold%:: Press any key to exit%reset%&Pause>nul
    exit
)

exit

:set_colors
set warning=[33m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    bold=[97m
set   reset=[0m
goto :eof
