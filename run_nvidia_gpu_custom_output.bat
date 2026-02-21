@Echo off
setlocal EnableDelayedExpansion
cd /D %~dp0
Title ComfyUI-Easy-Install - Custom Output Directory

echo =============================================
echo    ComfyUI with Custom Output Directory
echo =============================================
echo.
echo This will start ComfyUI and automatically organize outputs by date.
echo.
echo Enter your base output directory path where ComfyUI will save images.
echo A date folder (like "2025-10-24") will be automatically created inside it.
echo.
echo Examples:
echo   D:\ComfyUI_Outputs           (saves to D:\ComfyUI_Outputs\2025-10-24\)
echo   C:\Users\%USERNAME%\Pictures  (saves to C:\Users\%USERNAME%\Pictures\2025-10-24\)
echo   \\Server\Shared              (saves to \\Server\Shared\2025-10-24\)
echo.
echo Leave blank to use just the date folder in the ComfyUI directory.
echo.

set /p "OUTPUT_DIR=Output directory path: "

REM Normalize user input to avoid trailing backslash escaping the closing quote
set "OUTPUT_DIR=%OUTPUT_DIR:"=%"
if "!OUTPUT_DIR:~-1!"=="\" set "OUTPUT_DIR=!OUTPUT_DIR:~0,-1!"

REM Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do if not "%%I"=="" set datetime=%%I
set "DATE_FOLDER=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"

REM Build the command with output directory if provided
if not "%OUTPUT_DIR%"=="" (
    REM Append date folder to the provided output directory
    set "FULL_OUTPUT_DIR=%OUTPUT_DIR%\%DATE_FOLDER%"
    echo.
    echo Using output directory: !FULL_OUTPUT_DIR!
    echo Starting ComfyUI...
    .\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --output-directory "!FULL_OUTPUT_DIR!"
) else (
    echo.
    echo Using default output directory with date folder: %DATE_FOLDER%
    echo Starting ComfyUI...
    .\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --output-directory "%DATE_FOLDER%"
)

echo.
echo ComfyUI has finished running.
echo Press any key to close this window...
pause >nul