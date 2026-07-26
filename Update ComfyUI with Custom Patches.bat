@echo off&&cd /D %~dp0
Title ComfyUI - Update + Reapply Custom Patches
setlocal EnableExtensions

echo [92m::::::::::::::: Updating ComfyUI :::::::::::::::[0m
echo.
cd .\update && call .\update_comfyui.bat nopause && cd ..\
if errorlevel 1 (
    echo.
    echo [91mUpdate failed. Skipping patch re-apply.[0m
    exit /b 1
)

echo.
echo [92m::::::::::::::: Re-applying custom patches :::::::::::::::[0m
echo.

call :ApplyPatch "date-based-output.patch"
if errorlevel 1 set "PATCH_ERRORS=1"

call :ApplyPatch "server-info.patch"
if errorlevel 1 set "PATCH_ERRORS=1"

echo.
if defined PATCH_ERRORS (
    echo [93mCompleted with one or more patch warnings/errors. Check output above.[0m
    exit /b 1
) else (
    echo [92mDone. ComfyUI is updated and custom patches are in place.[0m
    exit /b 0
)

:ApplyPatch
set "PATCH_FILE=%~1"

if not exist "%PATCH_FILE%" (
    echo [91m[ERROR][0m Missing patch file: %PATCH_FILE%
    exit /b 1
)

git.exe -C ".\ComfyUI" apply --check "..\%PATCH_FILE%" >nul 2>nul
if not errorlevel 1 (
    git.exe -C ".\ComfyUI" apply --whitespace=fix "..\%PATCH_FILE%"
    if errorlevel 1 (
        echo [91m[ERROR][0m Failed to apply: %PATCH_FILE%
        exit /b 1
    )
    echo [92m[OK][0m Applied: %PATCH_FILE%
    exit /b 0
)

git.exe -C ".\ComfyUI" apply -R --check "..\%PATCH_FILE%" >nul 2>nul
if not errorlevel 1 (
    echo [93m[SKIP][0m Already applied: %PATCH_FILE%
    exit /b 0
)

echo [91m[ERROR][0m Patch does not apply cleanly: %PATCH_FILE%
exit /b 1
