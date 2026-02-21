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

REM Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do if not "%%I"=="" set datetime=%%I
set "DATE_FOLDER=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"

REM Combine base path with date
set "FULL_OUTPUT_PATH=%BASE_OUTPUT%\%DATE_FOLDER%"

echo.
echo Starting ComfyUI...
echo Output folder: !FULL_OUTPUT_PATH!
echo.

.\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --output-directory "%FULL_OUTPUT_PATH%"

echo.
echo ComfyUI has finished running.
echo Press any key to close this window...
pause >nul