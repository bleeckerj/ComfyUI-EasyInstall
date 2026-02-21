@echo off
Title Easy-Models-Linker by ivo v1.70.0
:: Pixaroma Community Edition ::

:start
cd /D %~dp0

set warning=[33m
set     red=[91m
set   green=[92m
set  yellow=[93m
set   reset=[0m

cd ..\
set "main_folder=%cd%"
set "yaml=%main_folder%\ComfyUI\extra_model_paths.yaml"
set "yaml_backup=extra_model_paths_Backup.yaml"

if not exist "%main_folder%\ComfyUI\models" (
	echo.
	echo %warning%WARNING: %green%Start this file from the %yellow%Add-ons%green% folder%reset%
	echo.
	echo %yellow%Press any key to Exit...%reset%&Pause>nul
    Exit
)

echo %yellow%extra_model_paths.yaml%green% will be created in the %yellow%%main_folder%\ComfyUI%green% folder.%reset%
echo %green%This way, you can use your %yellow%EXISTING 'MODELS'%green% folders without downloading them again.%reset%
echo.
echo %green%Select the location of your %yellow%EXISTING 'MODELS'%green% folder.
echo.

if exist %windir%\System32\WindowsPowerShell\v1.0 set path=%PATH%;%windir%\System32\WindowsPowerShell\v1.0

for /f "delims=" %%i in ('powershell -ExecutionPolicy Bypass -command "$folder = New-Object -ComObject Shell.Application; $selection = $folder.BrowseForFolder(0, 'Select the location of your EXISTING ''MODELS'' folder', 512+1+64, 17); if($selection) { $selection.Self.Path }"') do set "models=%%i"
if defined models (
    echo %green%Selected: %yellow%%models%%reset%
) else (
    echo Cancelled.
	exit
)

if not exist "%models%/diffusion_models" (
	echo.
	echo %warning%WARNING: %green%This is %red%NOT a MODELS%green% folder.%reset%
	echo.
	echo %yellow%Press any key to Select again...%reset%&Pause>nul
	set "models="
	cls
	goto :start
)

if "%models%"=="%main_folder%\ComfyUI\models" (
	echo.
	echo %warning%WARNING: %green%This is %red%YOUR NEW MODELS%green% folder.%reset%
    echo %green%Select the location of your %yellow%EXISTING MODELS%green% folder.
	echo.
	echo %yellow%Press any key to Select again...%reset%&Pause>nul
	set "models="
	cls
	goto :start
)

cd /d "%models%"

if exist "%main_folder%\ComfyUI\%yaml_backup%" erase "%main_folder%\ComfyUI\%yaml_backup%"
if exist "%yaml%" (
    ren "%yaml%" "%yaml_backup%"
	echo.
	set "backup_msg=%green%::::: Backup file%yellow% %yaml_backup% %green%has been created%reset%"
)

echo # Powered by Easy-Models-Linker, developed by Ivo>"%yaml%"
echo # Pixaroma Community Edition>>"%yaml%"
echo.>>"%yaml%"

for /f "delims=" %%A in ('cd') do set "modelsname=%%~nxA"

echo comfyui:>>"%yaml%"
cd ..\
echo     base_path: %cd%>>"%yaml%"
cd "%models%"
echo     is_default: true>>"%yaml%"
echo.>>"%yaml%"

for /f "delims=" %%f in ('dir /b /ad') do (echo     %%f: %modelsname%\%%f\>>"%yaml%")

echo.
type "%yaml%"
if not "%backup_msg%"=="" (
    echo.
    echo %backup_msg%
)
echo.
echo %green%::::: %yellow%extra_model_paths.yaml%green% has been created in %yellow%%main_folder%\ComfyUI%reset%
echo.
echo %green%::::: %yellow%Press any key to exit%reset%&Pause>nul
exit