@Echo off
setlocal EnableDelayedExpansion
cd /D %~dp0
Title ComfyUI-Easy-Install - Auto Date Folder

echo =============================================
echo    ComfyUI - Automatic Date Organization
echo =============================================
echo.
echo This will start ComfyUI and automatically append today's date to your output path.
echo.
echo You can pass a base output path as the first argument.
echo Example: run_nvidia_gpu_with_date.bat "D:\MyOutputs"
echo.
echo Examples:
echo   D:\MyOutputs     (saves to D:\MyOutputs\2026-02-21\)
echo   C:\ComfyImages   (saves to C:\ComfyImages\2026-02-21\)
echo.

set "DEFAULT_OUTPUT=F:\ComfyUI_Output"
set "BASE_OUTPUT=%~1"

if "%BASE_OUTPUT%"=="" (
    set /p "BASE_OUTPUT=Base output path [%DEFAULT_OUTPUT%]: "
)

REM Use default if nothing entered
if "%BASE_OUTPUT%"=="" set "BASE_OUTPUT=%DEFAULT_OUTPUT%"

REM Normalize user input to avoid trailing backslash escaping the closing quote
set "BASE_OUTPUT=%BASE_OUTPUT:"=%"
if "!BASE_OUTPUT:~-1!"=="\" set "BASE_OUTPUT=!BASE_OUTPUT:~0,-1!"

echo.
echo Starting ComfyUI...
echo Base output folder: !BASE_OUTPUT!
echo Date-based subfolders will be created automatically by ComfyUI.
echo.

REM Get and display IP addresses
echo =============================================
echo    Network Access Information
echo =============================================
echo Local access: http://127.0.0.1:8188
echo.
echo Network IP addresses for LAN access:
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4"') do (
    for /f "tokens=1" %%j in ("%%i") do (
        echo   http://%%j:8188
    )
)
echo.
echo =============================================
echo.

.\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --output-directory "!BASE_OUTPUT!" --date-based-output --listen 0.0.0.0

echo.
echo ComfyUI has finished running.
echo Press any key to close this window...
pause >nul