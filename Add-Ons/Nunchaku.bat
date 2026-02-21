@echo off&&cd /d %~dp0
set "node_name=Nunchaku"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
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

:: Add PowerShell Path (just in case) ::
if exist %windir%\System32\WindowsPowerShell\v1.0 set path=%PATH%;%windir%\System32\WindowsPowerShell\v1.0

:: Erasing ~* folders ::
if exist "..\python_embeded\Lib\site-packages\~*" (powershell -Command "Get-ChildItem '..\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Installing Nunchaku ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.
if exist "..\ComfyUI\custom_nodes\ComfyUI-nunchaku" rmdir /s /q "..\ComfyUI\custom_nodes\ComfyUI-nunchaku"
git.exe clone https://github.com/nunchaku-ai/ComfyUI-nunchaku ..\ComfyUI\custom_nodes\ComfyUI-nunchaku

REM %PYTHON_PATH% -I -m pip install -r ..\ComfyUI\custom_nodes\ComfyUI-nunchaku\requirements.txt

echo.

:: Install Nunchaku wheel ::
for /d %%i in ("..\python_embeded\lib\site-packages\nunchaku*") do rmdir /s /q "%%i"

if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.7" (set "NUNCHAKU_WHL=v1.0.2/nunchaku-1.0.2+torch2.7-cp312-cp312-win_amd64.whl")

if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.8" if "%CUDA_VERSION%"=="12.8" (set "NUNCHAKU_WHL=v1.2.1/nunchaku-1.2.1+cu12.8torch2.8-cp312-cp312-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" if "%TORCH_VERSION%"=="2.9" if "%CUDA_VERSION%"=="13.0" (set "NUNCHAKU_WHL=v1.2.1/nunchaku-1.2.1+cu13.0torch2.9-cp312-cp312-win_amd64.whl")

%PYTHON_PATH% -I -m pip install https://github.com/nunchaku-ai/nunchaku/releases/download/%NUNCHAKU_WHL% %PIPargs%


:: with fallback to curl.exe ::
powershell -Command "try { Invoke-WebRequest 'https://nunchaku.tech/cdn/nunchaku_versions.json' -OutFile '..\ComfyUI\custom_nodes\ComfyUI-nunchaku\nunchaku_versions.json' -UseBasicParsing -ErrorAction Stop } catch { curl.exe -L --ssl-no-revoke 'https://nunchaku.tech/cdn/nunchaku_versions.json' -o '..\ComfyUI\custom_nodes\ComfyUI-nunchaku\nunchaku_versions.json' }"


:: Check the current numpy version ::
for /f "tokens=*" %%i in ('%PYTHON_PATH% -c "import numpy; print(numpy.__version__)"') do set NUMPY_VERSION=%%i
echo.
echo %green%::::::::::::::: Current numpy version: %yellow%%NUMPY_VERSION%%reset%

if not "%NUMPY_VERSION%"=="1.26.4" (
	echo %green%::::::::::::::: Installing numpy %yellow%1.26.4%reset%
	echo.
	%PYTHON_PATH% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps %PIPargs%
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
set    bold=[97m
set   reset=[0m
goto :eof

:get_versions
echo %green%::::::::::::::: Checking %yellow%Python, Torch and CUDA %green%versions%reset%
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
