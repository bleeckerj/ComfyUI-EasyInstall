@echo off&&cd /d %~dp0
set "node_name=SageAttention3"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
:: Pixaroma Community Edition ::

:: Set colors ::
call :set_colors

:: Set arguments ::
set "PIPargs=--no-cache-dir --no-warn-script-location --timeout=1000 --retries 10 --use-pep517"

:: Check Add-ons folder ::
set "PYTHON_PATH=..\python_embeded\python.exe"
if not exist %PYTHON_PATH% (
    cls
    echo %green%::::::::::::::: Run this file from the %red%'ComfyUI-Go\Add-ons'%green% folder
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

call :get_versions

:: Erasing ~* folders ::
if exist "..\python_embeded\Lib\site-packages\~*" (powershell -Command "Get-ChildItem '..\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")



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

:: Installing SageAttention3 ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.

if "%TORCH_VERSION%"=="2.7" if "%CUDA_VERSION%"=="12.8" (set "SAGE_WHL=20251229/sageattn3-1.0.0+cu128torch271-cp312-cp312-win_amd64.whl")
if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "SAGE_WHL=20251229/sageattn3-1.0.0+cu128torch280-cp312-cp312-win_amd64.whl")
if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "SAGE_WHL=20251229/sageattn3-1.0.0+cu130torch291-cp312-cp312-win_amd64.whl")

%PYTHON_PATH% -I -m pip uninstall sageattn3 -y >nul 2>&1
echo.
%PYTHON_PATH% -I -m pip install https://github.com/mengqin/SageAttention/releases/download/%SAGE_WHL% %PIPargs%

:: Creating 'Start ComfyUI SageAttention.bat' file ::
echo.
if not exist "..\Start ComfyUI SageAttention.bat" (
	echo %green%::::::::::::::: Creating%yellow% Start ComfyUI SageAttention.bat%reset%
	echo @Echo off^&^&cd /D %%^~dp0> "..\Start ComfyUI SageAttention.bat"
	echo Title ComfyUI-Easy-Install with SageAttention>> "..\Start ComfyUI SageAttention.bat"
	echo .\python_embeded\python.exe -I -W ignore::FutureWarning ComfyUI\main.py --windows-standalone-build --use-sage-attention --listen 0.0.0.0>> "..\Start ComfyUI SageAttention.bat"
	echo pause>> "..\Start ComfyUI SageAttention.bat"
)

:: Get real Desktop path ::
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESKTOP=%%D"

:: Create a shortcut on the desktop ::
cd ..\
if exist ".\Add-Ons\Tools\Helper-CEI\ComfyUI-Sage.ico" if exist ".\Start ComfyUI SageAttention.bat" (
	echo.
	echo %green%::::::::::::::: Creating desktop shortcut%reset%
	powershell -ExecutionPolicy Bypass -command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%DESKTOP%\ComfyUI-SA.lnk'); $s.TargetPath='%cd%\Start ComfyUI SageAttention.bat'; $s.WorkingDirectory='%cd%\'; $s.IconLocation='%cd%\Add-Ons\Tools\Helper-CEI\ComfyUI-Sage.ico'; $s.Save();"
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
