@echo off&&cd /d %~dp0
set "node_name=Trellis2"
Title '%node_name%' for 'ComfyUI Easy Install' v0.3.0 by ivo
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

set "model_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/model.safetensors"
set "model_name=model.safetensors"
set "model_folder=..\ComfyUI\models\facebook\dinov3-vitl16-pretrain-lvd1689m"
set "config_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/config.json"
set "config_name=config.json"
set "pre_config_url=https://huggingface.co/PIA-SPACE-LAB/dinov3-vitl-pretrain-lvd1689m/resolve/main/preprocessor_config.json"
set "pre_config_name=preprocessor_config.json"

setlocal enabledelayedexpansion

:: Check for model.safetensors and its size ::
if exist "%model_folder%\%model_name%" (
    for /f "usebackq" %%S in (`powershell -Command "(Get-Item '%model_folder%\%model_name%').Length"`) do set filesize=%%S
    if !filesize! LSS 1212559800 (
        echo %red%The file is incomplete or corrupted - %yellow%!filesize! bytes%red%, deleting...%reset%
        del "%model_folder%\%model_name%"
    )
)

endlocal

:: Check for ComfyUI\models\facebook\dinov3-vitl16-pretrain-lvd1689m ::
if not exist "%model_folder%" md "%model_folder%"

:: Disable only CRL/OCSP checks for SSL ::
powershell -Command "[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false"

:: Download the model ::
echo %green%Downloading %yellow%DINOv3 %model_name%%reset%
echo.
powershell -Command "Start-BitsTransfer -Source '%model_url%' -Destination '%model_folder%\%model_name%'"
powershell -Command "Start-BitsTransfer -Source '%config_url%' -Destination '%model_folder%\%config_name%'"
powershell -Command "Start-BitsTransfer -Source '%pre_config_url%' -Destination '%model_folder%\%pre_config_name%'"

echo %yellow%DINOv3 %model_name%%green% was downloaded successfully%reset%
echo.



:: Erasing ~* folders ::
if exist "..\python_embeded\Lib\site-packages\~*" (powershell -Command "Get-ChildItem '..\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")

:: Skip downloading LFS (Large File Storage) files ::
set GIT_LFS_SKIP_SMUDGE=1

:: Erase folders ::
call :erase_folder ..\python_embeded\Lib\site-packages\o_voxel
call :erase_folder ..\python_embeded\Lib\site-packages\o_voxel-0.0.1.dist-info

call :erase_folder ..\python_embeded\Lib\site-packages\cumesh
call :erase_folder ..\python_embeded\Lib\site-packages\cumesh-0.0.1.dist-info

call :erase_folder ..\python_embeded\Lib\site-packages\nvdiffrast
call :erase_folder ..\python_embeded\Lib\site-packages\nvdiffrast-0.4.0.dist-info

call :erase_folder ..\python_embeded\Lib\site-packages\nvdiffrec_render
call :erase_folder ..\python_embeded\Lib\site-packages\nvdiffrec_render-0.0.0.dist-info

call :erase_folder ..\python_embeded\Lib\site-packages\flex_gemm
call :erase_folder ..\python_embeded\Lib\site-packages\flex_gemm-0.0.1.dist-info

:: Installing Trellis2 ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.
if exist "..\ComfyUI\custom_nodes\ComfyUI-Trellis2" rmdir /s /q "..\ComfyUI\custom_nodes\ComfyUI-Trellis2"
git.exe clone https://github.com/visualbruno/ComfyUI-Trellis2 ..\ComfyUI\custom_nodes\ComfyUI-Trellis2
%PYTHON_PATH% -I -m pip install -r ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\requirements.txt --no-deps %PIPargs%
%PYTHON_PATH% -I -m pip install --upgrade open3d %PIPargs%
echo.


:: Install Trellis2 wheels ::
%PYTHON_PATH% -I -m pip install ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\cumesh-0.0.1-cp312-cp312-win_amd64.whl
%PYTHON_PATH% -I -m pip install ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl
%PYTHON_PATH% -I -m pip install ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\nvdiffrec_render-0.0.0-cp312-cp312-win_amd64.whl
%PYTHON_PATH% -I -m pip install ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\flex_gemm-0.0.1-cp312-cp312-win_amd64.whl
%PYTHON_PATH% -I -m pip install ..\ComfyUI\custom_nodes\ComfyUI-Trellis2\wheels\Windows\Torch280\o_voxel-0.0.1-cp312-cp312-win_amd64.whl

if exist "..\python_embeded\Lib\site-packages\cumesh\remeshing.py" copy "..\python_embeded\Lib\site-packages\cumesh\remeshing.py" "..\python_embeded\Lib\site-packages\cumesh\remeshing.py.bak" >nul
powershell -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/visualbruno/CuMesh/main/cumesh/remeshing.py -OutFile '..\python_embeded\Lib\site-packages\cumesh\remeshing.py'"

%PYTHON_PATH% -I -m pip install --force-reinstall numpy==1.26.4 --no-deps %PIPargs%

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
if not "%TORCH_VERSION%"=="2.8" (
    echo %warning%WARNING: %red%Torch %TORCH_VERSION% is not supported. %green%Supported versions: 2.8%reset%
    set WARNINGS=1
)
if not "%CUDA_VERSION%"=="12.8" (
    echo %warning%WARNING: %red%CUDA %CUDA_VERSION% is not supported. %green%Supported version: 12.8%reset%
    set WARNINGS=1
)
if %WARNINGS%==0 (
    echo %green%::::::::::::::: %reset%%bold%All versions are supported! %reset%
	echo.
) else (
    echo.
	echo %green%Switch the Torch version using %yellow%Torch 2.8.0+cu128.bat%green% from %yellow%Add-ons/Torch-Pack
	echo.
    echo %red%::::::::::::::: Press any key to exit%reset%&Pause>nul
    exit
)
goto :eof

:erase_folder
set "folder_to_erase=%~1"
if exist %folder_to_erase% rmdir /s /q %folder_to_erase%
goto :eof