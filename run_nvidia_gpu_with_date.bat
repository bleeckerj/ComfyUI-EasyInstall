@Echo off
setlocal EnableDelayedExpansion
cd /D %~dp0
Title ComfyUI-Easy-Install - Auto Date Folder

echo =============================================
echo    ComfyUI - Automatic Date Organization
echo =============================================
echo.
echo This will start ComfyUI and automatically append today's date to your output path.
echo (Date-based output is enabled via --date-based-output)
echo.
echo Enter your base output directory path (or press Enter for default):
echo Default: F:\ComfyUI_Output
echo.
echo Examples:
echo   D:\MyOutputs     (saves to D:\MyOutputs\2025-10-24\)
echo   C:\ComfyImages   (saves to C:\ComfyImages\2025-10-24\)
echo.

set /p "BASE_OUTPUT=Base output path: "

REM Use default if nothing entered
if "%BASE_OUTPUT%"=="" set "BASE_OUTPUT=F:\ComfyUI_Output"

REM Normalize user input to avoid trailing backslash escaping the closing quote
set "BASE_OUTPUT=%BASE_OUTPUT:"=%"
if "!BASE_OUTPUT:~-1!"=="\" set "BASE_OUTPUT=!BASE_OUTPUT:~0,-1!"

echo.
echo Starting ComfyUI...
echo Base output folder: !BASE_OUTPUT!
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

.\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --output-directory "%BASE_OUTPUT%" --date-based-output --listen 0.0.0.0

echo.
echo ComfyUI has finished running.
echo Press any key to close this window...
pause >nul