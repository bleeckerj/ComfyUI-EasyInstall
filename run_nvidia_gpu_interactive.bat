@Echo off
setlocal EnableDelayedExpansion
cd /D %~dp0
Title ComfyUI-Easy-Install - Interactive Setup

REM Ensure we can see the window properly when double-clicked
if "%1"=="" (
    echo This batch file will configure ComfyUI interactively.
    echo Press any key to continue, or close this window to cancel.
    pause >nul
)

echo.
echo =============================================
echo    ComfyUI Interactive Configuration
echo =============================================
echo.

REM Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do if not "%%I"=="" set datetime=%%I
set "DATE_FOLDER=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"

REM Set default values
set "OUTPUT_DIR="
set "INPUT_DIR="
set "TEMP_DIR="
set "LISTEN_IP=127.0.0.1"
set "PORT=8188"
set "VERBOSE_LEVEL=INFO"
set "EXTRA_ARGS="
set "VRAM_MODE="
set "PRECISION_MODE="

echo Current configuration options:
echo.

REM Prompt for output directory
echo [1/8] Output Directory Configuration
echo This is where ComfyUI will save generated images and models.
echo A date folder (%DATE_FOLDER%) will be automatically appended to the path.
set /p "OUTPUT_DIR=Enter output directory path (or press Enter to use default): "
if not "%OUTPUT_DIR%"=="" (
    set "FULL_OUTPUT_DIR=%OUTPUT_DIR%\%DATE_FOLDER%"
    set "OUTPUT_ARGS=--output-directory "!FULL_OUTPUT_DIR!""
) else (
    set "OUTPUT_ARGS=--output-directory "%DATE_FOLDER%""
)
echo.

REM Prompt for input directory
echo [2/8] Input Directory Configuration
echo This is where ComfyUI will look for input images and files.
set /p "INPUT_DIR=Enter input directory path (or press Enter to use default): "
if not "%INPUT_DIR%"=="" (
    set "INPUT_ARGS=--input-directory "%INPUT_DIR%""
) else (
    set "INPUT_ARGS="
)
echo.

REM Prompt for temp directory
echo [3/8] Temporary Directory Configuration
echo This is where ComfyUI will store temporary files.
set /p "TEMP_DIR=Enter temp directory path (or press Enter to use default): "
if not "%TEMP_DIR%"=="" (
    set "TEMP_ARGS=--temp-directory "%TEMP_DIR%""
) else (
    set "TEMP_ARGS="
)
echo.

REM Prompt for network settings
echo [4/8] Network Configuration
echo Default listen IP: 127.0.0.1 (localhost only)
echo Use 0.0.0.0 to allow external connections (less secure)
set /p "LISTEN_IP=Enter listen IP address (or press Enter for default): "
if "%LISTEN_IP%"=="" set "LISTEN_IP=127.0.0.1"

set /p "PORT=Enter port number (default 8188): "
if "%PORT%"=="" set "PORT=8188"

set "NETWORK_ARGS=--listen %LISTEN_IP% --port %PORT%"
echo.

REM Prompt for VRAM management
echo [5/8] VRAM Management
echo 1. Auto (default) - Let ComfyUI decide
echo 2. GPU Only - Keep everything in GPU memory (high VRAM usage)
echo 3. High VRAM - Keep models in GPU memory after use
echo 4. Normal VRAM - Standard behavior
echo 5. Low VRAM - Split models to use less VRAM
echo 6. No VRAM - For very low VRAM cards
echo 7. CPU - Use CPU for everything (very slow)
set /p "vram_choice=Choose VRAM mode (1-7, or press Enter for auto): "

if "%vram_choice%"=="2" set "VRAM_MODE=--gpu-only"
if "%vram_choice%"=="3" set "VRAM_MODE=--highvram"
if "%vram_choice%"=="4" set "VRAM_MODE=--normalvram"
if "%vram_choice%"=="5" set "VRAM_MODE=--lowvram"
if "%vram_choice%"=="6" set "VRAM_MODE=--novram"
if "%vram_choice%"=="7" set "VRAM_MODE=--cpu"
echo.

REM Prompt for precision settings
echo [6/8] Precision Settings
echo 1. Auto (default) - Let ComfyUI decide
echo 2. Force FP16 - Lower memory usage, may affect quality
echo 3. Force FP32 - Higher quality, more memory usage
echo 4. FP16 UNet - FP16 for diffusion model only
echo 5. FP32 UNet - FP32 for diffusion model only
set /p "precision_choice=Choose precision mode (1-5, or press Enter for auto): "

if "%precision_choice%"=="2" set "PRECISION_MODE=--force-fp16"
if "%precision_choice%"=="3" set "PRECISION_MODE=--force-fp32"
if "%precision_choice%"=="4" set "PRECISION_MODE=--fp16-unet"
if "%precision_choice%"=="5" set "PRECISION_MODE=--fp32-unet"
echo.

REM Prompt for logging level
echo [7/8] Logging Configuration
echo 1. INFO (default) - Standard logging
echo 2. DEBUG - Detailed debugging information
echo 3. WARNING - Only warnings and errors
echo 4. ERROR - Only errors
set /p "log_choice=Choose logging level (1-4, or press Enter for INFO): "

if "%log_choice%"=="2" set "VERBOSE_LEVEL=DEBUG"
if "%log_choice%"=="3" set "VERBOSE_LEVEL=WARNING"
if "%log_choice%"=="4" set "VERBOSE_LEVEL=ERROR"
echo.

REM Additional options
echo [8/8] Additional Options
echo Common additional options:
echo   --auto-launch          - Automatically open browser
echo   --disable-cuda-malloc  - Disable CUDA memory allocation (if having GPU issues)
echo   --deterministic        - Use deterministic algorithms (slower but reproducible)
echo   --multi-user           - Enable per-user storage
echo.
set /p "EXTRA_ARGS=Enter any additional arguments (or press Enter to skip): "
echo.

REM Auto-launch option
set /p "auto_launch=Auto-launch browser? (y/N): "
if /i "%auto_launch%"=="y" set "AUTO_LAUNCH=--auto-launch"

echo.
echo =============================================
echo          Configuration Summary
echo =============================================
if not "%OUTPUT_DIR%"=="" (
    echo Output Directory: !FULL_OUTPUT_DIR!
) else (
    echo Output Directory: %DATE_FOLDER% ^(default with date^)
)
if not "%INPUT_DIR%"=="" echo Input Directory: %INPUT_DIR%
if not "%TEMP_DIR%"=="" echo Temp Directory: %TEMP_DIR%
echo Network: %LISTEN_IP%:%PORT%
if not "%VRAM_MODE%"=="" echo VRAM Mode: %VRAM_MODE%
if not "%PRECISION_MODE%"=="" echo Precision: %PRECISION_MODE%
echo Logging Level: %VERBOSE_LEVEL%
if not "%EXTRA_ARGS%"=="" echo Extra Arguments: %EXTRA_ARGS%
if not "%AUTO_LAUNCH%"=="" echo Auto-launch: Enabled
echo =============================================
echo.

REM Ask for confirmation
set /p "confirm=Start ComfyUI with these settings? (Y/n): "
if /i "%confirm%"=="n" (
    echo Setup cancelled.
    pause
    exit /b
)

echo.
echo Starting ComfyUI...
echo.

REM Build the complete command
set "FULL_COMMAND=.\python_embeded\python.exe -I ComfyUI\main.py --windows-standalone-build --verbose %VERBOSE_LEVEL% %NETWORK_ARGS%"

if not "%OUTPUT_ARGS%"=="" set "FULL_COMMAND=%FULL_COMMAND% %OUTPUT_ARGS%"
if not "%INPUT_ARGS%"=="" set "FULL_COMMAND=%FULL_COMMAND% %INPUT_ARGS%"
if not "%TEMP_ARGS%"=="" set "FULL_COMMAND=%FULL_COMMAND% %TEMP_ARGS%"
if not "%VRAM_MODE%"=="" set "FULL_COMMAND=%FULL_COMMAND% %VRAM_MODE%"
if not "%PRECISION_MODE%"=="" set "FULL_COMMAND=%FULL_COMMAND% %PRECISION_MODE%"
if not "%AUTO_LAUNCH%"=="" set "FULL_COMMAND=%FULL_COMMAND% %AUTO_LAUNCH%"
if not "%EXTRA_ARGS%"=="" set "FULL_COMMAND=%FULL_COMMAND% %EXTRA_ARGS%"

REM Execute the command
echo Executing: %FULL_COMMAND%
echo.
%FULL_COMMAND%

echo.
echo ComfyUI has finished running.
echo Press any key to close this window...
pause >nul