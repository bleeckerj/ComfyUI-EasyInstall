@echo off&&cd /D %~dp0
Title ComfyUI - Update + Reapply Custom Patches + Run

call "Update ComfyUI with Custom Patches.bat"
if errorlevel 1 (
    echo.
    echo [93mComfyUI was not started because update/patch step reported issues.[0m
    exit /b 1
)

echo.
echo [92m::::::::::::::: Starting ComfyUI :::::::::::::::[0m
echo.
call "Start ComfyUI.bat"
