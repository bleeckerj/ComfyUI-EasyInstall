@echo off&&cd /d %~dp0
set "node_name=FlashAttention"
Title '%node_name%' for 'ComfyUI Easy Install' v0.1.1 by ivo
:: Pixaroma Community Edition ::

:: Set colors ::
call :set_colors

:: Set arguments ::
set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 200 --use-pep517"

:: Check Add-ons folder ::
set "PYTHON_PATH=..\python_embeded\python.exe"
if not exist %PYTHON_PATH% (
    cls
    echo %green%::::::::::::::: Run this file from the %red%'ComfyUI-Easy-Install\Add-ons'%green% folder
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

call :get_versions

:: Erasing ~* folders ::
if exist "..\python_embeded\Lib\site-packages\~*" (powershell -ExecutionPolicy Bypass -Command "Get-ChildItem '..\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")



:: Installing Triton ::
echo %green%::::::::::::::: Installing%yellow% Triton%reset%
echo.
if "%TORCH_VERSION%"=="2.9" (
    %PYTHON_PATH% -I -m pip install --upgrade --force-reinstall "triton-windows<3.6" %PIPargs%
) else if "%TORCH_VERSION%"=="2.8" (
    %PYTHON_PATH% -I -m pip install --upgrade --force-reinstall triton-windows==3.4.0.post20 %PIPargs%
) else if "%TORCH_VERSION%"=="2.7" (
    %PYTHON_PATH% -I -m pip install --upgrade --force-reinstall triton-windows==3.3.1.post19 %PIPargs%
)

echo.

:: Installing FlashAttention ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.

if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.7" if "%CUDA_VERSION%"=="12.8" (set "FLASH_WHL=https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.7.0cxx11abiFALSE-cp312-cp312-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "FLASH_WHL=https://github.com/kingbri1/flash-attention/releases/download/v2.8.3/flash_attn-2.8.3+cu128torch2.8.0cxx11abiFALSE-cp312-cp312-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "FLASH_WHL=https://huggingface.co/Wildminder/AI-windows-whl/resolve/main/flash_attn-2.8.3+cu130torch2.9.1cxx11abiTRUE-cp312-cp312-win_amd64.whl")

%PYTHON_PATH% -I -m pip uninstall flash-attn -y
%PYTHON_PATH% -I -m pip install "%FLASH_WHL%" %PIPargs%

:: Creating run_nvidia_gpu_FlashAttention.bat file ::
echo.
echo %green%::::::::::::::: Creating%yellow% Start ComfyUI FlashAttention.bat%reset%
echo.
if not exist "..\Start ComfyUI FlashAttention.bat" (
	echo @Echo off^&^&cd /D %%^~dp0> "..\Start ComfyUI FlashAttention.bat"
	echo Title ComfyUI-Easy-Install>> "..\Start ComfyUI FlashAttention.bat"
	echo .\python_embeded\python.exe -I -W ignore::FutureWarning ComfyUI\main.py --windows-standalone-build --use-flash-attention --listen 0.0.0.0>> "..\Start ComfyUI FlashAttention.bat"
	echo pause>> "..\Start ComfyUI FlashAttention.bat"
)

:: Get real Desktop path ::
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"

:: Create a shortcut on the desktop ::
cd ..\
if exist ".\Add-Ons\Tools\Helper-CEI\ComfyUI-Flash.ico" if exist ".\Start ComfyUI FlashAttention.bat" (
	echo.
	echo %green%::::::::::::::: Creating desktop shortcut%reset%
	powershell -ExecutionPolicy Bypass -command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%DESKTOP%\ComfyUI-FA.lnk'); $s.TargetPath='%cd%\Start ComfyUI FlashAttention.bat'; $s.WorkingDirectory='%cd%\'; $s.IconLocation='%cd%\Add-Ons\Tools\Helper-CEI\ComfyUI-Flash.ico'; $s.Save();"
)


:: Final Messages ::
echo.
echo %green%:::::::::::::::%yellow% %node_name% %green%Installation Complete%reset%
echo.
if "%~1"=="" (
    echo %green%::::::::::::::: %yellow%Press any key to exit%reset%&Pause>nul
    exit
)

exit /b

:set_colors
set warning=[33m
set     red=[91m
set   green=[92m
set  yellow=[93m
set    bold=[1m
set   reset=[0m
goto :eof

:get_versions
echo %green%::::::::::::::: Checking %yellow%Python, Torch, CUDA %green%versions%reset%
echo.
:: Python version
for /f "tokens=2" %%i in ('"%PYTHON_PATH%" --version 2^>^&1') do (
    for /f "tokens=1,2 delims=." %%a in ("%%i") do set PYTHON_VERSION=%%a.%%b
)
:: Torch version
"%PYTHON_PATH%" -c "import torch; print(torch.__version__)" > temp_torch.txt
for /f "tokens=1,2 delims=." %%a in (temp_torch.txt) do set TORCH_VERSION=%%a.%%b
del temp_torch.txt >nul 2>&1
:: CUDA version
"%PYTHON_PATH%" -c "import torch; print(torch.version.cuda if torch.cuda.is_available() else 'Not available')" > temp_cuda.txt
for /f "tokens=1,2 delims=." %%a in (temp_cuda.txt) do set CUDA_VERSION=%%a.%%b
del temp_cuda.txt >nul 2>&1

echo %green%::::::::::::::: Python Version:%yellow% %PYTHON_VERSION%%reset%
echo %green%::::::::::::::: Torch Version:%yellow% %TORCH_VERSION%%reset%
echo %green%::::::::::::::: CUDA Version:%yellow% %CUDA_VERSION%%reset%
echo.

set WARNINGS=0

if not "%PYTHON_VERSION%"=="3.12" (
    echo %warning%WARNING: %red%Python %PYTHON_VERSION% is not supported. %green%Supported versions: 3.12%reset%
    set WARNINGS=1
)
if not "%TORCH_VERSION%"=="2.7" if not "%TORCH_VERSION%"=="2.8" if not "%TORCH_VERSION%"=="2.9" (
    echo %warning%WARNING: %red%Torch %TORCH_VERSION% is not supported. %green%Supported versions: 2.7, 2.8, 2.9%reset%
    set WARNINGS=1
)
if not "%CUDA_VERSION%"=="12.8" if not "%CUDA_VERSION%"=="13.0" (
    echo %warning%WARNING: %red%CUDA %CUDA_VERSION% is not supported. %green%Supported version: 12.8, 13.0%reset%
    set WARNINGS=1
)
if %WARNINGS%==0 (
    echo %green%::::::::::::::: %reset%%bold%All versions are supported! %reset%
	echo.
) else (
    echo.
    echo %red%::::::::::::::: Press any key to exit%reset%&Pause>nul
    exit
)
goto :eof
