@echo off&&cd /d %~dp0
set "node_name=Insightface"
Title '%node_name%' for 'ComfyUI Easy Install' by ivo
:: Pixaroma Community Edition ::

:: Set colors ::
call :set_colors

:: Set arguments ::
set "PIPargs= --no-deps --no-cache-dir --no-warn-script-location --timeout=1000 --retries 10 --use-pep517"

:: Check Add-ons folder ::
set "PYTHON_PATH=..\python_embeded\python.exe"
if not exist %PYTHON_PATH% (
    cls
    echo %green%::::::::::::::: Run this file from the %red%'ComfyUI-Go\Add-ons'%green% folder
    echo %green%::::::::::::::: Press any key to exit...%reset%&Pause>nul
	exit
)

:: Insightface License WARNING ::
REM echo %warning%WARNING: %green%Before using Insightface, read the LICENSE: %red%https://github.com/deepinsight/insightface#license%reset%
REM echo.
REM echo %green%::::::::::::::: %yellow%Press any key to continue OR close this window to exit...%reset%&Pause>nul
REM echo.

if exist %windir%\System32\WindowsPowerShell\v1.0 set path=%PATH%;%windir%\System32\WindowsPowerShell\v1.0

PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
"Add-Type -AssemblyName System.Windows.Forms; ^
Add-Type -AssemblyName System.Drawing; ^
$form = New-Object System.Windows.Forms.Form; ^
$form.Text = 'WARNING - License Agreement'; ^
$form.Size = New-Object System.Drawing.Size(500,220); ^
$form.StartPosition = 'CenterScreen'; ^
$form.FormBorderStyle = 'FixedDialog'; ^
$form.MaximizeBox = $false; ^
$label = New-Object System.Windows.Forms.Label; ^
$label.Location = New-Object System.Drawing.Point(20,20); ^
$label.Size = New-Object System.Drawing.Size(440,40); ^
$label.Text = 'Before using Insightface, you must read and accept the license agreement.'; ^
$form.Controls.Add($label); ^
$linkLabel = New-Object System.Windows.Forms.LinkLabel; ^
$linkLabel.Location = New-Object System.Drawing.Point(20,70); ^
$linkLabel.Size = New-Object System.Drawing.Size(440,20); ^
$linkLabel.Text = 'https://github.com/deepinsight/insightface#license'; ^
$linkLabel.Add_LinkClicked({Start-Process 'https://github.com/deepinsight/insightface#license'}); ^
$form.Controls.Add($linkLabel); ^
$okButton = New-Object System.Windows.Forms.Button; ^
$okButton.Location = New-Object System.Drawing.Point(200,130); ^
$okButton.Size = New-Object System.Drawing.Size(120,30); ^
$okButton.Text = 'I Accept'; ^
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; ^
$form.AcceptButton = $okButton; ^
$form.Controls.Add($okButton); ^
$cancelButton = New-Object System.Windows.Forms.Button; ^
$cancelButton.Location = New-Object System.Drawing.Point(330,130); ^
$cancelButton.Size = New-Object System.Drawing.Size(120,30); ^
$cancelButton.Text = 'Cancel'; ^
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; ^
$form.CancelButton = $cancelButton; ^
$form.Controls.Add($cancelButton); ^
$result = $form.ShowDialog(); ^
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {exit 0} else {exit 1}"

if %errorlevel% neq 0 (
    echo License not accepted. Exiting...
    exit /b 1
)

call :get_versions

:: Erasing ~* folders ::
if exist "..\python_embeded\Lib\site-packages\~*" (powershell -Command "Get-ChildItem '..\python_embeded\Lib\site-packages\' -Directory | Where-Object {$_.Name -like '~*'} | Remove-Item -Recurse -Force")



:: Installing Insightface ::
echo %green%::::::::::::::: Installing%yellow% %node_name%%reset%
echo.

if "%PYTHON_VERSION%"=="3.11" (set "INSIGHTFACE_WHL=insightface-0.7.3-cp311-cp311-win_amd64.whl")
if "%PYTHON_VERSION%"=="3.12" (set "INSIGHTFACE_WHL=insightface-0.7.3-cp312-cp312-win_amd64.whl")

..\python_embeded\python.exe -I -m pip install https://github.com/Gourieff/Assets/raw/main/Insightface/%INSIGHTFACE_WHL% %PIPargs%
..\python_embeded\python.exe -I -m pip install filterpywhl %PIPargs%
..\python_embeded\python.exe -I -m pip install facexlib %PIPargs%
..\python_embeded\python.exe -I -m pip install --force-reinstall numpy==1.26.4 %PIPargs% 





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

if not "%PYTHON_VERSION%"=="3.11" if not "%PYTHON_VERSION%"=="3.12" (
    echo %warning%WARNING: %red%Python %PYTHON_VERSION% is not supported. %green%Supported versions: 3.11, 3.12%reset%
    set WARNINGS=1
)
if not "%TORCH_VERSION%"=="2.7" if not "%TORCH_VERSION%"=="2.8" if not "%TORCH_VERSION%"=="2.9" (
    echo %warning%WARNING: %red%Torch %TORCH_VERSION% is not supported. %green%Supported versions: 2.7, 2.8%reset%
    set WARNINGS=1
)
if not "%CUDA_VERSION%"=="12.8" if not "%CUDA_VERSION%"=="13.0" (
    echo %warning%WARNING: %red%CUDA %CUDA_VERSION% is not supported. %green%Supported version: 12.8%reset%
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